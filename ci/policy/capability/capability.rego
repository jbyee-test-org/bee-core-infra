# 게이트1 정책 — 모듈 uses/provides 정합 (G36 capability · G37 리소스 · G44 db.target).
# 입력: module.yaml(스냅샷 동봉본, G9) · 데이터: platform.yaml(conftest --data → data.spec.*).
# **doctor(CLI, G19 프리플라이트=warn)와 동일 규칙을 CI 게이트(deny)로 승격**(규칙 2 — 검증은 CI).
# 주입형 어휘(db·routing)만 대상 — events·btc 는 접속형(G41·G42)이라 capability 파생 없음.
package main

import rego.v1

# platform.yaml(conftest --data) → 직접 경로 참조(object.get(data,..) 는 data 전체 참조라 재귀).
default provides := {}

provides := data.spec.substrate.provides

default resources := {}

resources := data.spec.resources

default mod := "?"

mod := input.metadata.name

# ── capability(G36): 모듈이 쓰는 어휘(db·routing)는 플랫폼 provides 에 존재해야 ──
deny contains msg if {
	some cap in ["db", "routing"]
	input.spec[cap]
	not provides[cap]
	msg := sprintf("%s: uses %q ⊄ provides — 플랫폼 미제공(substrate, G36)", [mod, cap])
}

# ── db.target(G44): 선언 필수(기본값 없음 — bee 철학 명시>암묵) ──
deny contains msg if {
	input.spec.db
	not input.spec.db.target
	msg := sprintf("%s: db.target 미선언 — psql|mysql 명시 필수(G44, 기본값 없음)", [mod])
}

# ── db.target(G44): provides.db[].target 멀티-target dispatch 안에 있어야 ──
deny contains msg if {
	t := input.spec.db.target
	targets := {e.target | some e in provides.db}
	not targets[t]
	msg := sprintf("%s: db.target %q ∉ provides.db %v (G44)", [mod, t, targets])
}

# ── resource compute 프로파일(G37): platform.resources.compute 에 정의돼야 ──
deny contains msg if {
	c := input.spec.uses.compute
	not resources.compute[c]
	msg := sprintf("%s: compute 프로파일 %q 미정의 — platform.resources.compute (G37)", [mod, c])
}

# ── resource storage 프로파일(G37): platform.resources.storage 에 정의돼야 ──
deny contains msg if {
	s := input.spec.uses.storage.profile
	not resources.storage[s]
	msg := sprintf("%s: storage 프로파일 %q 미정의 — platform.resources.storage (G37)", [mod, s])
}
