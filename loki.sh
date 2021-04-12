#!/bin/sh

CDIR=$(pwd)
mkdir $CDIR/loki
cd loki

curl -O -L "https://github.com/grafana/loki/releases/download/v2.2.1/loki-linux-amd64.zip"
unzip "loki-linux-amd64.zip"
chmod a+x "loki-linux-amd64"
rm -rf loki-linux-amd64.zip

wget https://raw.githubusercontent.com/grafana/loki/master/cmd/loki/loki-local-config.yaml

touch /etc/systemd/system/loki.service
cat > /etc/systemd/system/loki.service <<EOF
[Unit]
Description=loki for Grafana monitoring
After=network.target
[Service]
ExecStart=$CDIR/loki/loki-linux-amd64 -config.file=$CDIR/loki/loki-local-config.yaml
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start loki
systemctl enable loki
systemctl status loki
