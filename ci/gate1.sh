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

# digest 존재(phantom pin 방어, G53) — 렌더된 매니페스트가 pin 한 이미지 digest 가 registry 에
# *실재*하는지 crane 으로 확인(없으면 ImagePullBackOff). image-less(G21)는 참조 0 → skip.
# crane 미설치면 관용(로컬 gate1 실행 무해) — CI(module-publish.yaml)가 crane 설치+ghcr 인증.
echo "── 게이트1: 이미지 digest 존재 (crane — phantom pin 방어, G53) ──"
if command -v crane >/dev/null 2>&1; then
  REFS=$(grep -rhoE 'image:[[:space:]]*[^[:space:]]+@sha256:[0-9a-f]+' "$ENV_DIR" \
         | sed -E 's/^image:[[:space:]]*//' | sort -u || true)
  if [ -z "$REFS" ]; then
    echo "  (digest-pin 이미지 참조 없음 — image-less 모듈, G21) skip"
  else
    for ref in $REFS; do
      if crane manifest "$ref" >/dev/null 2>&1; then
        echo "  ✓ 실재: $ref"
      else
        echo "::error::digest 미실재(phantom pin) — $ref : registry 에 없음(빌드·push 누락?). ImagePullBackOff 위험."
        exit 1
      fi
    done
  fi
else
  echo "  ⚠ crane 미설치 — digest 존재 게이트 skip(로컬 실행). CI 는 crane 설치 필수."
fi

echo "✓ 게이트1 통과: $ENV_DIR"
