# 계약 표면 (contracts/) — `bee contracts`

이 디렉토리는 모듈의 **상호 계약 표면**이다 — 다른 모듈/소비자가 이 모듈과 어떻게
통신하는지의 단일 참조.

- `openapi.yaml` — HTTP(동기) 계약. `spec.routing` 으로 노출하는 API.
- `asyncapi.yaml` — 이벤트/메시징(비동기) 계약. NATS 등으로 publish/subscribe 하는 subject.

## 규약

- **이건 모듈간 상호 계약을 확인하기 위한 수단(`bee contracts <module>`)이며, publish 시
  스냅샷에 그대로 보관된다** — env-pinned(배포된 버전의 계약, provenance.moduleCommit 과 함께).
- **모듈간 통신 프로토콜이 존재하면 반드시 작성하고 최신화한다.** HTTP 표면이 있으면
  `openapi.yaml`, 메시징이 있으면 `asyncapi.yaml`. 안 쓰는 종류의 파일은 삭제해도 된다
  (어휘 없음 — **파일 존재 = 계약 있음**).
- bee 는 이 계약을 **운반·노출만** 한다 — 생성·검증·정합 확인은 하지 않는다(파생 0).
  계약이 구현과 맞는지는 **작성자 책임**(또는 별도 lint). bee 는 *보여줄* 뿐 *맞다고* 안 한다.

소비자는 `bee contracts <이 모듈>` 으로 이 계약을 읽어 자기 구현을 맞춘다.
