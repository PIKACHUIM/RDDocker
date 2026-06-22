#!/bin/bash
set -e

INSTALL_DIR="/opt/easydesk"
CONF_DIR="$INSTALL_DIR/conf"
CONTAINER_CONF_DIR="$CONF_DIR/containers"
BIN_DIR="/usr/local/bin"

read -p "Container data directory [/opt/easydesk/data]: " DATA_INPUT
DATA_DIR="${DATA_INPUT:-/opt/easydesk/data}"

mkdir -p "$DATA_DIR" "$CONF_DIR" "$CONTAINER_CONF_DIR"

ARCH=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')
BINARY_URL="https://github.com/pikachuim/RDDocker/releases/latest/download/easydesk-linux-${ARCH}"

if command -v go &>/dev/null && [ -f "$(dirname "$0")/go.mod" ]; then
    echo "Building from source..."
    (cd "$(dirname "$0")" && go build -ldflags="-s -w" -o /tmp/easydesk .)
else
    echo "Downloading binary from $BINARY_URL ..."
    curl -fsSL "$BINARY_URL" -o /tmp/easydesk
fi

install -m755 /tmp/easydesk "$BIN_DIR/easydesk"

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

cat > /etc/systemd/system/easydesk.service <<EOF
[Unit]
Description=EasyDesk Container Manager
After=network.target docker.service

[Service]
Type=simple
ExecStart=/usr/local/bin/easydesk serve
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable easydesk
systemctl start easydesk

echo "EasyDesk installed successfully!"
echo "Config: $CONF_DIR/config.yaml"
echo "Data:   $DATA_DIR"
echo "API port: $(grep port "$CONF_DIR/config.yaml" | awk '{print $2}')"
echo "Token: $(grep token "$CONF_DIR/config.yaml" | awk '{print $2}')"
