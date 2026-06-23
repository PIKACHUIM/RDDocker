#!/bin/bash
set -e

INSTALL_DIR="/opt/deskcli"
CONF_DIR="$INSTALL_DIR/conf"
CONTAINER_CONF_DIR="$CONF_DIR/containers"
BIN_DIR="/usr/local/bin"

read -r -p "Container data directory [/opt/deskcli/data]: " DATA_INPUT </dev/tty
DATA_DIR="${DATA_INPUT:-/opt/deskcli/data}"

mkdir -p "$DATA_DIR" "$CONF_DIR" "$CONTAINER_CONF_DIR"

ARCH=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')
BINARY_URL="https://github.com/PIKACHUIM/RDDocker/releases/download/v0.0.0-beta/deskcli-linux-${ARCH}"

echo "Downloading binary from $BINARY_URL ..."
curl -fsSL "$BINARY_URL" -o /tmp/dockcli

install -m755 /tmp/dockcli "$BIN_DIR/deskcli"

if [ ! -f "$CONF_DIR/config.yaml" ]; then
    TOKEN=$(openssl rand -hex 16 2>/dev/null || tr -dc 'a-f0-9' </dev/urandom | head -c32)
    cat > "$CONF_DIR/config.yaml" <<EOF
token: "$TOKEN"
engine: "docker"
port: 8080
data_dir: "$DATA_DIR"
EOF
    echo "Generated API token: $TOKEN"
fi

cat > /etc/systemd/system/dockcli.service <<EOF
[Unit]
Description=deskcli Container Manager
After=network.target docker.service

[Service]
Type=simple
ExecStart=/usr/local/bin/deskcli serve
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable dockcli
systemctl start dockcli

echo "deskcli installed successfully!"
echo "Config: $CONF_DIR/config.yaml"
echo "Data:   $DATA_DIR"
echo "API port: $(grep port "$CONF_DIR/config.yaml" | awk '{print $2}')"
echo "Token: $(grep token "$CONF_DIR/config.yaml" | awk '{print $2}')"
