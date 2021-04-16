#!/bin/sh

CDIR=$(pwd)

loki_ip=10.0.2.10
loki_port=3100
batchwait="10s" #디폴트 1초
service="ceool"
pod="dev"
stream="web_01"
path="/var/log/*log"


mkdir $CDIR/promtail
cd promtail

curl -O -L "https://github.com/grafana/loki/releases/download/v2.2.1/promtail-linux-amd64.zip"
unzip "promtail-linux-amd64.zip"
chmod a+x "promtail-linux-amd64"
rm -rf promtail-linux-amd64.zip

touch $CDIR/promtail/promtail-local-config.yaml
cat > $CDIR/promtail/promtail-local-config.yaml <<EOF
# 서버에 맞게 변경 필요
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://${loki_ip}:${loki_port}/loki/api/v1/push
    batchwait: "${batchwait}"

scrape_configs:
- job_name: system
  static_configs:
  - targets:
      - localhost
    labels:
      job: varlogs
      container_name: ${service}
      pod_name: ${service}-${pod}
      stream: ${service}-${pod}-${stream}
      __path__: ${path}
     # host: testserver
#pipeline_stages:
#  - timestamp:
#    format: 2006/01/02 15:04:05.999 MST
#    source: timestamp
EOF

touch /etc/systemd/system/promtail.service
cat > /etc/systemd/system/promtail.service <<EOF
[Unit]
Description=promtail for loki
After=network.target
[Service]
ExecStart=$CDIR/promtail/promtail-linux-amd64 -config.file=$CDIR/promtail/promtail-local-config.yaml
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start promtail
systemctl enable promtail
systemctl status promtail
