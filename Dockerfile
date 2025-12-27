FROM alpine:3.19

RUN apk add --no-cache \
    wget \
    unzip \
    ca-certificates \
    nginx \
    bash \
    tzdata

ENV TZ=Asia/Shanghai

ARG XRAY_VERSION=1.8.24

RUN mkdir -p /tmp/xray && \
    wget -O /tmp/xray/xray.zip "https://github.com/XTLS/Xray-core/releases/download/v${XRAY_VERSION}/Xray-linux-64.zip" && \
    unzip /tmp/xray/xray.zip -d /tmp/xray && \
    mv /tmp/xray/xray /usr/local/bin/ && \
    mv /tmp/xray/geo*.dat /usr/local/bin/ && \
    chmod +x /usr/local/bin/xray && \
    rm -rf /tmp/xray

RUN mkdir -p /app/web /var/log/nginx /var/lib/nginx/tmp /run/nginx /tmp/nginx

WORKDIR /app

COPY nginx.conf /etc/nginx/nginx.conf
COPY config.json /app/config.json
COPY entrypoint.sh /app/entrypoint.sh
COPY web/ /app/web/

RUN chmod +x /app/entrypoint.sh

RUN adduser -D -u 1000 user && \
    chown -R user:user /app && \
    chown -R user:user /var/log/nginx && \
    chown -R user:user /var/lib/nginx && \
    chown -R user:user /run/nginx && \
    chown -R user:user /tmp

USER user

EXPOSE 7860

CMD ["/app/entrypoint.sh"]
