#!/usr/bin/env bash
# 게이트1 러너 — 검증은 CI 의 책임(규칙 2). 정책은 policy/(rego)가, 여기는 기계적 호출만.
# 사용: ci/gate1.sh <snapshot envs/<env> 디렉토리> [platform.yaml]
set -euo pipefail

ENV_DIR="$1"
CI_DIR="$(cd "$(dirname "$0")" && pwd)"
PLATFORM="${2:-$CI_DIR/../platform.yaml}"   # core-infra = 1 플랫폼(G43) — 디스크립터는 레포 루트

echo "── 게이트1: kubeconform (스키마 — CRD 는 datree 카탈로그, 미등재는 통과·conftest 가 보완) ──"
find "$ENV_DIR" -name '*.yaml' ! -name module.yaml ! -name provenance.yaml ! -path '*/contracts/*' -print0 \
  | xargs -0 kubeconform -strict -summary -ignore-missing-schemas \
      -schema-location default \
      -schema-location 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json'

echo "── 게이트1: conftest (매니페스트 정책) ──"
find "$ENV_DIR" -name '*.yaml' ! -name module.yaml ! -name provenance.yaml ! -path '*/contracts/*' -print0 \
  | xargs -0 conftest test --policy "$CI_DIR/policy/manifests"

echo "── 게이트1: conftest (provenance 정책, platform=$PLATFORM) ──"
find "$ENV_DIR" -name provenance.yaml -print0 \
  | xargs -0 conftest test --policy "$CI_DIR/policy/provenance" --data "$PLATFORM"

echo "── 게이트1: conftest (uses/provides — module.yaml vs platform, G36/G37/G44) ──"
find "$ENV_DIR" -name module.yaml -print0 \
  | xargs -0 conftest test --policy "$CI_DIR/policy/capability" --data "$PLATFORM"

echo "✓ 게이트1 통과: $ENV_DIR"
