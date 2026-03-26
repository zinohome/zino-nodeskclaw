#!/bin/bash
# 架构及安全说明：
# 此脚本用于自动化准备外部依赖代码，从而分离核心业务源码与部署脚本。
# 通过脚本拉取而非 Git Submodule，可以方便后续在多环境下更灵活地指定版本或分支。
set -e

PROJECTS_BASE_DIR="projects"
TARGET_DIR="${PROJECTS_BASE_DIR}/nodeskclaw"
REPO_URL="https://github.com/NoDeskAI/nodeskclaw.git"

echo "=========================================="
echo "    开始初始化外部项目环境 (NoDeskClaw)   "
echo "=========================================="

# 安全检查并创建父级目录
if [ ! -d "$PROJECTS_BASE_DIR" ]; then
    echo "[INFO] 创建基础目录: $PROJECTS_BASE_DIR"
    mkdir -p "$PROJECTS_BASE_DIR"
fi

# 检查子目录决定是否克隆
if [ ! -d "$TARGET_DIR" ]; then
    echo "[INFO] 即将从 $REPO_URL 克隆 nodeskclaw..."
    git clone "$REPO_URL" "$TARGET_DIR"
    echo "[INFO] ✅ $TARGET_DIR 拉取成功！"
else
    echo "[INFO] ✅ 目录 $TARGET_DIR 已经存在，跳过拉取。"
    # 您可在此扩展拉取最新代码的逻辑 (例如 cd $TARGET_DIR && git pull)
fi

echo "=========================================="
echo "          环境拉取与验证完毕！            "
echo "=========================================="
