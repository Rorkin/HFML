#!/bin/bash

echo "========================================"
echo "  Starting Proxy Services"
echo "========================================"

# 设置 UUID
UUID=${UUID:-"ffb1b66c-c092-4da6-869f-bc482eaf7270"}

echo "[Info] UUID: ${UUID:0:8}..."

# 替换配置文件中的占位符
sed -i "s/UUID_PLACEHOLDER/$UUID/g" /app/config.json

# 创建必要目录
mkdir -p /tmp/nginx

# 验证配置
echo "[Info] Validating Xray configuration..."
/usr/local/bin/xray -test -config /app/config.json

if [ $? -ne 0 ]; then
    echo "[Error] Xray configuration is invalid!"
    exit 1
fi

echo "[Info] Configuration is valid."

# 启动 Nginx
echo "[Info] Starting Nginx..."
nginx -c /etc/nginx/nginx.conf

if [ $? -ne 0 ]; then
    echo "[Error] Failed to start Nginx!"
    exit 1
fi

echo "[Info] Nginx started successfully."

# 启动 Xray
echo "[Info] Starting Xray..."
echo "========================================"

exec /usr/local/bin/xray run -config /app/config.json
