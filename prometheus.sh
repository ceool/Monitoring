#!/bin/sh

CDIR=$(pwd)
version="2.26.0"

# https://prometheus.io/download/
wget https://github.com/prometheus/prometheus/releases/download/v$version/prometheus-$version.linux-amd64.tar.gz
tar xvfz prometheus-*.tar.gz
rm prometheus-*.tar.gz

cat > $CDIR/prometheus-$version.linux-amd64/prometheus.yml <<EOF
# my global config
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 60s
    file_sd_configs:
      - files:
        - 'targets.json'

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    # static_configs:
    # - targets: ['localhost:9090']
EOF

touch $CDIR/prometheus-$version.linux-amd64/targets.json
# targets 수정 필요
cat > $CDIR/prometheus-$version.linux-amd64/targets.json <<EOF
[
  {
    "targets": [ "localhost:9090", "1.1.1.1:9100" ],
    "labels": {
      "env": "prod",
      "job": "job-name-1"
    }
    },
  {
    "targets": [ "2.2.2.2:9100" ],
    "labels": {
      "env": "dev",
      "job": "job-name-2"
    }
  }
]
EOF

touch /etc/systemd/system/prometheus.service
cat > /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=prometheus for Grafana Monitoring
After=network.target
[Service]
ExecStart=$CDIR/prometheus-$version.linux-amd64/prometheus --config.file=$CDIR/prometheus-$version.linux-amd64/prometheus.yml --storage.tsdb.retention=2160h
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start prometheus
systemctl enable prometheus
systemctl status prometheus
