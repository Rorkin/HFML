#!/bin/bash

echo "========================================"
echo "  Starting Proxy Services"
echo "========================================"

# 设置 UUID（从环境变量读取，否则使用默认值）
UUID=${UUID:-"a]随机生成的UUID"}

# 为 Shadowsocks 2022 生成 Base64 密钥（16字节 = AES-128）
SS_PASSWORD=${SS_PASSWORD:-$(echo -n "$UUID" | head -c 16 | base64)}

echo "[Info] UUID: $UUID"
echo "[Info] SS Password: $SS_PASSWORD"

# 替换配置文件中的占位符
sed -i "s/UUID_PLACEHOLDER/$UUID/g" /app/config.json
sed -i "s|SS_PASSWORD_PLACEHOLDER|$SS_PASSWORD|g" /app/config.json

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

# 启动 Nginx（后台）
echo "[Info] Starting Nginx..."
nginx -c /etc/nginx/nginx.conf

if [ $? -ne 0 ]; then
    echo "[Error] Failed to start Nginx!"
    exit 1
fi

echo "[Info] Nginx started successfully."

# 启动 Xray（前台，保持容器运行）
echo "[Info] Starting Xray..."
echo "========================================"

exec /usr/local/bin/xray run -config /app/config.json
