#!/bin/sh

CDIR=$(pwd)

loki_ip=10.0.2.10
loki_port=3100
batchwait="10s" #디폴트 1초
service="ceool"
pod="dev"
stream="was_01"
appArr=("App1" "App2" "App3" "App4" "App5")
path="/data/log" # 아래 __path__ 확인


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
EOF

for app in "${appArr[@]}";
do
echo "  - targets:
      - localhost
    labels:
      job: varlogs
      pod_name: ${pod}
      stream: ${service}-${pod}-${stream}-${app}
      __path__: ${path}/${app}/*" >> $CDIR/promtail/promtail-local-config.yaml
done

echo "     # host: testserver
#pipeline_stages:
#  - timestamp:
#    format: 2006/01/02 15:04:05.999 MST
#    source: timestamp" >> $CDIR/promtail/promtail-local-config.yaml


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
systemctl --runtime set-property promtail CPUQuota=50%
systemctl status promtail