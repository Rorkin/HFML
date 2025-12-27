#!/bin/bash

echo "========================================"
echo "  Starting Proxy Services"
echo "========================================"

# 设置 UUID
UUID=${UUID:-"4d5be0ce-1f3d-4ffb-8d88-2e80bccb9c9a"}

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
    cat /app/config.json
    exit 1
fi

echo "[Info] Configuration is valid."

# 测试 DNS 解析
echo "[Info] Testing DNS resolution..."
echo "  - Google: $(nslookup -timeout=3 google.com 8.8.8.8 2>/dev/null | grep -A1 'Name:' | tail -1 || echo 'FAILED')"
echo "  - YouTube: $(nslookup -timeout=3 youtube.com 8.8.8.8 2>/dev/null | grep -A1 'Name:' | tail -1 || echo 'FAILED')"
echo "  - Googlevideo: $(nslookup -timeout=3 r1---sn-a5mekn7k.googlevideo.com 8.8.8.8 2>/dev/null | grep -A1 'Name:' | tail -1 || echo 'FAILED')"

# 测试出站连接
echo "[Info] Testing outbound connectivity..."
echo "  - Google: $(wget -q -O /dev/null --timeout=5 https://www.google.com && echo 'OK' || echo 'FAILED')"
echo "  - YouTube: $(wget -q -O /dev/null --timeout=5 https://www.youtube.com && echo 'OK' || echo 'FAILED')"

# 启动 Nginx
echo "[Info] Starting Nginx..."
nginx -c /etc/nginx/nginx.conf

if [ $? -ne 0 ]; then
    echo "[Error] Failed to start Nginx!"
    exit 1
fi

echo "[Info] Nginx started successfully."

# 后台监控日志
(
    sleep 10
    while true; do
        if [ -f /tmp/xray-access.log ]; then
            echo "[Xray Access Log - Last 5 lines]"
            tail -5 /tmp/xray-access.log
        fi
        if [ -f /tmp/xray-error.log ]; then
            echo "[Xray Error Log - Last 5 lines]"
            tail -5 /tmp/xray-error.log
        fi
        sleep 60
    done
) &

# 启动 Xray
echo "[Info] Starting Xray..."
echo "========================================"

exec /usr/local/bin/xray run -config /app/config.json
