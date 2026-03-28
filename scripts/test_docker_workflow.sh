#!/usr/bin/env bash
set -euo pipefail

WORKFLOW_FILE=".github/workflows/docker-image.yml"

if [[ ! -f "${WORKFLOW_FILE}" ]]; then
  echo "FAIL: ${WORKFLOW_FILE} 不存在"
  exit 1
fi

assert_contains() {
  local pattern="$1"
  local message="$2"
  if ! grep -Eq "${pattern}" "${WORKFLOW_FILE}"; then
    echo "FAIL: ${message}"
    exit 1
  fi
}

assert_contains '^name:\s*Docker Image$' "缺少工作流名称"
assert_contains 'workflow_dispatch:' "缺少手动触发"
assert_contains 'branches:\s*\[main\]' "缺少 main 分支触发"
assert_contains "tags:\s*\\['v\\*'\\]" "缺少 v* tag 触发"
assert_contains 'packages:\s*write' "缺少 packages: write 权限"
assert_contains 'docker/login-action@v3' "缺少 GHCR 登录步骤"
assert_contains 'registry:\s*ghcr\.io' "GHCR registry 配置缺失"
assert_contains 'docker/metadata-action@v5' "缺少 metadata 标签生成"
assert_contains 'docker/build-push-action@v6' "缺少镜像构建推送步骤"
assert_contains 'ghcr\.io/\$\{\{\s*github\.repository\s*\}\}' "镜像仓库未指向 ghcr.io/<owner>/<repo>"
assert_contains 'platforms:\s*linux/amd64,linux/arm64' "缺少多架构构建 (amd64/arm64)"

echo "PASS: Docker workflow 关键配置校验通过"
