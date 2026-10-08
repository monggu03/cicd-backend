# cicd-backend

동홍동락 1차 세미나 「CI/CD, 어떻게 하는 걸까」 실습용 **백엔드 레포**입니다. (Spring Boot 4.1 · Java 21)
프론트는 `cicd-frontend` 레포에 따로 있습니다.

| 무엇 | 어디서 |
|---|---|
| 검사 (CI) | `.github/workflows/ci.yml` → PR마다 `./gradlew test` (`backend-test`) |
| 배포 (CD) | `.github/workflows/cd.yml` → main 머지마다 test → Cloud Run 배포 |
| 클라우드 준비 | `scripts/gcp-setup.sh` (Cloud Shell에서 한 번) |

```bash
./gradlew bootRun     # http://localhost:8080/api/sessions , /api/hello
./gradlew test
```

실습 순서는 함께 받은 가이드북(GUIDE.md)을 따라가면 됩니다.

| 실습 | 하는 것 | 잡히는 곳 |
|---|---|---|
| 4 | API 필드 `title` → `name` | `backend-test` |
| 5 | 인사말 v1 → v2 머지 | `Backend CD` → Cloud Run 새 리비전 |
| 6 | v1 리비전으로 롤백 | Cloud Run 트래픽 전환 |
