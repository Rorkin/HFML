FROM alpine:3.19

# 安装必要工具
RUN apk add --no-cache \
    wget \
    unzip \
    ca-certificates \
    nginx \
    bash \
    tzdata

# 设置时区
ENV TZ=Asia/Shanghai

# Xray 版本
ARG XRAY_VERSION=1.8.24

# 下载并安装 Xray（修正解压方式）
RUN mkdir -p /tmp/xray && \
    wget -O /tmp/xray/xray.zip "https://github.com/XTLS/Xray-core/releases/download/v${XRAY_VERSION}/Xray-linux-64.zip" && \
    unzip /tmp/xray/xray.zip -d /tmp/xray && \
    mv /tmp/xray/xray /usr/local/bin/ && \
    mv /tmp/xray/geo*.dat /usr/local/bin/ && \
    chmod +x /usr/local/bin/xray && \
    rm -rf /tmp/xray

# 创建工作目录和必要目录
RUN mkdir -p /app /var/log/nginx /var/lib/nginx/tmp /run/nginx /tmp/nginx

WORKDIR /app

# 复制配置文件
COPY nginx.conf /etc/nginx/nginx.conf
COPY config.json /app/config.json
COPY entrypoint.sh /app/entrypoint.sh

# 设置权限
RUN chmod +x /app/entrypoint.sh

# 创建非 root 用户并设置权限（HF 要求）
RUN adduser -D -u 1000 user && \
    chown -R user:user /app && \
    chown -R user:user /var/log/nginx && \
    chown -R user:user /var/lib/nginx && \
    chown -R user:user /run/nginx && \
    chown -R user:user /tmp/nginx

USER user

EXPOSE 7860

CMD ["/app/entrypoint.sh"]
