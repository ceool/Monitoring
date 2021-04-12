#!/bin/sh

CDIR=$(pwd)
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
  - url: http://localhost:3100/loki/api/v1/push

scrape_configs:
- job_name: system
  static_configs:
  - targets:
      - localhost
    labels:
      job: varlogs
      __path__: /var/log/*log
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
