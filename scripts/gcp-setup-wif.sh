#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# (선택) 키 없이 배포하기: Workload Identity Federation(WIF)
# 키 파일을 만들 수 없는 조직 계정이거나, 실무 방식으로 해 보고 싶을 때 씁니다.
# 먼저 gcp-setup.sh 의 1~4단계가 끝나 있어야 합니다. (5단계 키 만들기는 건너뛰어도 됨)
# 사용법 (Cloud Shell):
#   GITHUB_REPO="내아이디/cicd-backend" bash scripts/gcp-setup-wif.sh
# ─────────────────────────────────────────────────────────────
set -euo pipefail

PROJECT_ID="${PROJECT_ID:-$(gcloud config get-value project 2>/dev/null)}"
GITHUB_REPO="${GITHUB_REPO:?GITHUB_REPO=\"owner/repo\" 형태로 넣어 주세요}"
SA_EMAIL="github-deployer@${PROJECT_ID}.iam.gserviceaccount.com"
POOL="github"
PROVIDER="cicd-backend"

echo "▶ 1/3  Workload Identity Pool 만들기"
gcloud iam workload-identity-pools describe "${POOL}" --project "${PROJECT_ID}" --location=global >/dev/null 2>&1 || \
gcloud iam workload-identity-pools create "${POOL}" \
  --project="${PROJECT_ID}" --location="global" --display-name="GitHub Actions Pool"
POOL_ID="$(gcloud iam workload-identity-pools describe "${POOL}" --project="${PROJECT_ID}" --location=global --format='value(name)')"

echo "▶ 2/3  GitHub용 Provider 만들기 (이 저장소에서 온 요청만 받도록 조건을 겁니다)"
gcloud iam workload-identity-pools providers describe "${PROVIDER}" --project "${PROJECT_ID}" --location=global --workload-identity-pool="${POOL}" >/dev/null 2>&1 || \
gcloud iam workload-identity-pools providers create-oidc "${PROVIDER}" \
  --project="${PROJECT_ID}" --location="global" --workload-identity-pool="${POOL}" \
  --display-name="cicd-backend repo" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" \
  --attribute-condition="assertion.repository == '${GITHUB_REPO}'" \
  --issuer-uri="https://token.actions.githubusercontent.com"

echo "▶ 3/3  이 저장소의 Actions가 github-deployer 계정을 쓸 수 있게 허락"
gcloud iam service-accounts add-iam-policy-binding "${SA_EMAIL}" \
  --project="${PROJECT_ID}" --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/${POOL_ID}/attribute.repository/${GITHUB_REPO}" --quiet >/dev/null

PROVIDER_NAME="$(gcloud iam workload-identity-pools providers describe "${PROVIDER}" --project="${PROJECT_ID}" --location=global --workload-identity-pool="${POOL}" --format='value(name)')"
echo
echo "GitHub 저장소 → Settings → Secrets and variables → Actions → [Variables] 탭에 두 개 등록:"
echo "  WIF_PROVIDER        = ${PROVIDER_NAME}"
echo "  WIF_SERVICE_ACCOUNT = ${SA_EMAIL}"
echo "그다음 .github/workflows/cd.yml 의 로그인 단계를 가이드 부록 B처럼 바꾸면 됩니다."
