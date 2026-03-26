#!/bin/bash
# 架构与安全提示：为了实现纯粹的部署文件，我们抽离出打包过程。
# 该脚本必须要在节点存在代码的环境下执行（如 CI/CD 或本地开发环境）。
# 这里将为所有组件打包并 push 到私有 Harbor 仓库。

set -e

REGISTRY="harbor.naivehero.top:8443/claw"
# 动态获取当前日期作为版本号 (例如 "3.26")
TAG=$(date +%-m.%d)

echo "开始构建镜像并 Push 到私有仓库: ${REGISTRY} ..."

# 1. 编译 nodeskclaw-backend
echo "[1/3] 构建 nodeskclaw-backend..."
docker build -t ${REGISTRY}/nodeskclaw-backend:${TAG} -f ../projects/nodeskclaw/nodeskclaw-backend/Dockerfile ../projects/nodeskclaw/
docker push ${REGISTRY}/nodeskclaw-backend:${TAG}

# 2. 编译 nodeskclaw-llm-proxy
echo "[2/3] 构建 nodeskclaw-llm-proxy..."
docker build -t ${REGISTRY}/nodeskclaw-llm-proxy:${TAG} ../projects/nodeskclaw/nodeskclaw-llm-proxy/
docker push ${REGISTRY}/nodeskclaw-llm-proxy:${TAG}

# 3. 编译 nodeskclaw-portal
echo "[3/3] 构建 nodeskclaw-portal..."
docker build -t ${REGISTRY}/nodeskclaw-portal:${TAG} ../projects/nodeskclaw/nodeskclaw-portal/
docker push ${REGISTRY}/nodeskclaw-portal:${TAG}

echo "所有镜像打包、打 tag 及 Push 均已完成！"

# 4. 自动修改 docker-compose.yml 中的版本兜底值
echo "[4/4] 自动更新 docker-compose.yml 镜像版本号至 ${TAG}..."
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS 环境
  sed -i '' "s/\\\${APP_VERSION:-[a-zA-Z0-9.\-]*}/\\\${APP_VERSION:-${TAG}}/g" docker-compose.yml
else
  # Linux (Ubuntu, CentOS, etc.)
  sed -i "s/\\\${APP_VERSION:-[a-zA-Z0-9.\-]*}/\\\${APP_VERSION:-${TAG}}/g" docker-compose.yml
fi
echo "成功将 docker-compose.yml 默认版本指针更新！"

echo "请在部署目录直接执行: docker-compose up -d"
