# 게이트1 정책 — provenance.chartVersion 이 플랫폼 지원 범위 안인가 (G6).
# 입력: provenance.yaml · 데이터: platform.yaml (conftest --data) → data.spec.chart.supported
package main

import rego.v1

deny contains msg if {
	not input.chartVersion
	msg := "provenance 에 chartVersion 없음 — G6 pin 기록 필수"
}

deny contains msg if {
	v := input.chartVersion
	some bound in split(data.spec.chart.supported, " ")
	startswith(bound, ">=")
	semver.compare(v, trim_prefix(bound, ">=")) == -1
	msg := sprintf("chartVersion %s < 지원 최소 %s (G6 범위 밖)", [v, trim_prefix(bound, ">=")])
}

deny contains msg if {
	v := input.chartVersion
	some bound in split(data.spec.chart.supported, " ")
	startswith(bound, "<")
	not startswith(bound, "<=")
	semver.compare(v, trim_prefix(bound, "<")) >= 0
	msg := sprintf("chartVersion %s >= 지원 상한 %s (G6 범위 밖)", [v, trim_prefix(bound, "<")])
}
