# core-infra — bee 플랫폼 공용 인프라 (chart · 정책 · starter)

> 단일 기준은 워크스페이스의 `GENESIS.md`. 이 레포는 G5 가 정의한 고정 3 레포 중 하나.

| 디렉토리 | 내용 | 상태 |
|---|---|---|
| `chart/` | `bee-module` 공용 차트 — **파생 엔진**(규칙 1). `values.schema.json` = 입력 계약(G9) | 0.1.0 |
| `platforms/<name>/platform.yaml` | 플랫폼 디스크립터 — chart 지원 범위 정책(G6) + products→namespace 배치 데이터. **좌표 파생 없음** | bitcert |
| `starter/` | 모듈 starter 데이터 — chart 와 공동 버전(G5). `bee new` 가 복사+치환+등록 | Phase 3 슬롯 |
| `ci/` | 재사용 CI 워크플로(렌더·lint·publish) + ArgoCD 정의 | Phase 2 슬롯 |

소비: Phase 1 = 워크스페이스가 이 레포 위치를 바인딩(경로 참조), Phase 2 = chart OCI 릴리스(G6).
