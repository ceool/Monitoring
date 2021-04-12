#!/bin/sh

CDIR=$(pwd)

wget --directory-prefix=$CDIR  https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
tar xvf $CDIR/node_exporter-1.0.1.linux-amd64.tar.gz -C $CDIR/
rm $CDIR/node_exporter-1.0.1.linux-amd64.tar.gz
mv $CDIR/node_exporter-1.0.1.linux-amd64 $CDIR/node_exporter

touch /etc/systemd/system/monitoring.service
cat > /etc/systemd/system/monitoring.service <<EOF
[Unit]
Description=node_exporter for Prometheus Monitoring
After=network.target
[Service]
ExecStart=$CDIR/node_exporter/node_exporter
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start monitoring
systemctl enable monitoring
systemctl status monitoring
