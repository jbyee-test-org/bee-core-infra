#!/usr/bin/env bash
# 게이트1 러너 — 검증은 CI 의 책임(규칙 2). 정책은 policy/(rego)가, 여기는 기계적 호출만.
# 사용: ci/gate1.sh <snapshot envs/<env> 디렉토리> [platform.yaml]
set -euo pipefail

ENV_DIR="$1"
CI_DIR="$(cd "$(dirname "$0")" && pwd)"
PLATFORM="${2:-$CI_DIR/../platforms/bitcert/platform.yaml}"

echo "── 게이트1: kubeconform (스키마) ──"
find "$ENV_DIR" -name '*.yaml' ! -name module.yaml ! -name provenance.yaml -print0 \
  | xargs -0 kubeconform -strict -summary

echo "── 게이트1: conftest (매니페스트 정책) ──"
find "$ENV_DIR" -name '*.yaml' ! -name module.yaml ! -name provenance.yaml -print0 \
  | xargs -0 conftest test --policy "$CI_DIR/policy/manifests"

echo "── 게이트1: conftest (provenance 정책, platform=$PLATFORM) ──"
find "$ENV_DIR" -name provenance.yaml -print0 \
  | xargs -0 conftest test --policy "$CI_DIR/policy/provenance" --data "$PLATFORM"

echo "✓ 게이트1 통과: $ENV_DIR"
