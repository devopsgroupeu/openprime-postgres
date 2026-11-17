#!/usr/bin/env bash
# Unit-test the chart's alert rules (OP-278) with promtool.
#
# Renders the PrometheusRule the way production does (release openprime-postgres
# in namespace openprime, backups on), takes its rule groups and runs
# tests/alert-rules/*.test.yml against them. Needs helm, plus promtool on PATH
# or docker. Runs in CI (.github/workflows/ci.yml) and locally:
#   scripts/test-alert-rules.sh
set -euo pipefail
cd "$(dirname "$0")/.."

# Same Prometheus version as the production kube-prometheus-stack.
PROMETHEUS_IMAGE="${PROMETHEUS_IMAGE:-quay.io/prometheus/prometheus:v3.9.1}"
dir=tests/alert-rules
rules=rules.generated.yml

# The rule groups are everything under `spec:`, one indent level up.
helm template openprime-postgres chart --namespace openprime \
  --api-versions monitoring.coreos.com/v1 \
  --set auth.existingSecret=ci,backup.enabled=true,backup.bucket=ci,prometheusRule.enabled=true \
  --show-only templates/prometheusrule.yaml |
  sed -n '/^spec:$/,$p' | sed '1d; s/^  //' >"$dir/$rules"

run_promtool() {
  if type -P promtool >/dev/null; then
    (cd "$dir" && promtool "$@")
  else
    docker run --rm -v "$PWD/$dir:/rules" -w /rules --entrypoint promtool "$PROMETHEUS_IMAGE" "$@"
  fi
}

tests=()
for f in "$dir"/*.test.yml; do tests+=("$(basename "$f")"); done

run_promtool check rules "$rules"
run_promtool test rules "${tests[@]}"
