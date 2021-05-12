#!/bin/sh

CDIR=$(pwd)
version="1.1.2"

wget --directory-prefix=$CDIR  https://github.com/prometheus/node_exporter/releases/download/v$version/node_exporter-$version.linux-amd64.tar.gz

tar xvf $CDIR/node_exporter-*.tar.gz -C $CDIR/
rm -rf $CDIR/node_exporter-*.tar.gz
mv $CDIR/node_exporter-*.tar.gz

touch /etc/systemd/system/node_exporter.service
cat > /etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=node_exporter for Prometheus Monitoring
After=network.target
[Service]
ExecStart=$CDIR/node_exporter-$version.linux-amd64/node_exporter
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start node_exporter
systemctl enable node_exporter
systemctl status node_exporter