#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# Google Cloud 준비 스크립트 (서비스 계정 키 방식)
# 어디서: Google Cloud 콘솔 오른쪽 위 [>_] 버튼 → Cloud Shell
# 사용법:
#   gcloud config set project <내-프로젝트-ID>
#   bash scripts/gcp-setup.sh
# 하는 일:
#   1) Cloud Run·Cloud Build·Artifact Registry API 켜기
#   2) Cloud Build가 쓰는 기본 계정에 빌드 권한(run.builder) 주기
#   3) GitHub Actions 전용 서비스 계정(github-deployer) 만들기
#   4) 배포에 필요한 권한만 주기
#   5) 키(JSON) 만들어서 한 줄로 출력 → GitHub Secret GCP_SA_KEY 에 붙여 넣기
# ─────────────────────────────────────────────────────────────
set -euo pipefail

PROJECT_ID="${PROJECT_ID:-$(gcloud config get-value project 2>/dev/null)}"
SA_NAME="github-deployer"

if [[ -z "${PROJECT_ID}" ]]; then
  echo "❌ 프로젝트가 정해지지 않았습니다. 먼저: gcloud config set project <프로젝트-ID>"
  exit 1
fi

PROJECT_NUMBER="$(gcloud projects describe "${PROJECT_ID}" --format='value(projectNumber)')"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
COMPUTE_SA="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

echo "▶ 프로젝트: ${PROJECT_ID} (${PROJECT_NUMBER})"

echo "▶ 1/5  API 켜기 (1~2분 걸릴 수 있습니다)"
gcloud services enable run.googleapis.com cloudbuild.googleapis.com artifactregistry.googleapis.com \
  --project "${PROJECT_ID}"

# 기본 계정(Compute Engine default service account)이 아직 없으면 Compute API를 켜서 만들어지게 합니다.
if ! gcloud iam service-accounts describe "${COMPUTE_SA}" --project "${PROJECT_ID}" >/dev/null 2>&1; then
  echo "   기본 계정이 없어 Compute Engine API를 켭니다"
  gcloud services enable compute.googleapis.com --project "${PROJECT_ID}"
fi

echo "▶ 2/5  Cloud Build 기본 계정에 빌드 권한(roles/run.builder)"
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${COMPUTE_SA}" --role="roles/run.builder" \
  --condition=None --quiet >/dev/null

echo "▶ 3/5  GitHub Actions 전용 서비스 계정: ${SA_EMAIL}"
if ! gcloud iam service-accounts describe "${SA_EMAIL}" --project "${PROJECT_ID}" >/dev/null 2>&1; then
  gcloud iam service-accounts create "${SA_NAME}" \
    --project "${PROJECT_ID}" --display-name="GitHub Actions deployer"
fi

echo "▶ 4/5  배포 권한 주기"
for ROLE in roles/run.sourceDeveloper roles/serviceusage.serviceUsageConsumer; do
  gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${SA_EMAIL}" --role="${ROLE}" \
    --condition=None --quiet >/dev/null
  echo "   + ${ROLE}"
done
# Cloud Run 서비스와 빌드는 기본 계정(COMPUTE_SA) 이름으로 돕니다.
# github-deployer가 그 계정 "이름으로" 일을 시킬 수 있게 허락(actAs)합니다.
gcloud iam service-accounts add-iam-policy-binding "${COMPUTE_SA}" \
  --project "${PROJECT_ID}" \
  --member="serviceAccount:${SA_EMAIL}" --role="roles/iam.serviceAccountUser" \
  --quiet >/dev/null
echo "   + roles/iam.serviceAccountUser (on ${COMPUTE_SA})"

echo "▶ 5/5  키 만들기"
gcloud iam service-accounts keys create key.json --iam-account="${SA_EMAIL}" --project "${PROJECT_ID}"

echo
echo "────────────────────────────────────────────────────────────"
echo " 아래 한 줄 전체를 복사해서"
echo " GitHub cicd-backend 저장소 → Settings → Secrets and variables → Actions"
echo " → New repository secret → 이름: GCP_SA_KEY  에 붙여 넣으세요."
echo "────────────────────────────────────────────────────────────"
python3 -c 'import json,sys; print(json.dumps(json.load(open("key.json")), separators=(",", ":")))'
echo "────────────────────────────────────────────────────────────"
echo " 붙여 넣었으면 Cloud Shell에 남은 키 파일은 지우세요:  rm key.json"
echo " 키는 비밀번호와 같습니다. 카톡·디스코드·깃허브 어디에도 올리지 마세요."
