# 게이트1 정책 — 공유환경 렌더의 floating tag 금지 (구 D7 계승, GENESIS 규칙 8).
# 대상: 스냅샷의 렌더 매니페스트(리소스별 파일). CLI 는 경고만, 차단은 여기서(규칙 2·G6).
package main

import rego.v1

deny contains msg if {
	input.kind == "Deployment"
	some c in input.spec.template.spec.containers
	not contains(c.image, "@sha256:")
	msg := sprintf("floating tag 금지(게이트1): %s — 공유환경은 digest pin 필수", [c.image])
}
