# ci — 재사용 워크플로 + ArgoCD 정의 (Phase 2 슬롯)

- 재사용 CI 워크플로: 렌더 → 게이트1 lint(kubeconform/conftest/decK, chart 버전 범위 검사 —
  규칙 2: 차단은 여기서) → 스냅샷 커밋(`bee publish` headless 재사용, G5).
- ArgoCD Application/ApplicationSet 정의 — 스냅샷 레포를 watch, 공유환경 적용 독점(G5·G7).
- 모듈 레포는 여기 워크플로를 호출하는 얇은 yaml 만 가진다.
