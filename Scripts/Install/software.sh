#!/bin/sh
# Optional software installer - controlled by env vars
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/common.sh"

# Firefox
if [ "${INSTALL_FIREFOX:-false}" = "true" ]; then
  case "$OS_ID" in
    debian|ubuntu) eval "$PKG_INSTALL firefox-esr 2>/dev/null || $PKG_INSTALL firefox" ;;
    fedora)        eval "$PKG_INSTALL firefox" ;;
    arch)          eval "$PKG_INSTALL firefox" ;;
    alpine)        eval "$PKG_INSTALL firefox" ;;
  esac
fi

# Google Chrome (deb/rpm only)
if [ "${INSTALL_CHROME:-false}" = "true" ]; then
  case "$OS_ID" in
    debian|ubuntu)
      wget -q -O /tmp/chrome.deb \
        "https://dl.google.com/linux/direct/google-chrome-stable_current_${ARCH_DEB}.deb"
      dpkg -i /tmp/chrome.deb || apt-get install -f -y
      rm -f /tmp/chrome.deb ;;
    fedora)
      wget -q -O /tmp/chrome.rpm \
        "https://dl.google.com/linux/direct/google-chrome-stable_current_${ARCH_RPM}.rpm"
      rpm -i /tmp/chrome.rpm || true
      rm -f /tmp/chrome.rpm ;;
  esac
fi

# VS Code (deb/rpm only)
if [ "${INSTALL_VSCODE:-false}" = "true" ]; then
  case "$OS_ID" in
    debian|ubuntu)
      wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
        | gpg --dearmor > /usr/share/keyrings/microsoft.gpg
      echo "deb [arch=${ARCH_DEB} signed-by=/usr/share/keyrings/microsoft.gpg] \
        https://packages.microsoft.com/repos/code stable main" \
        > /etc/apt/sources.list.d/vscode.list
      eval "$PKG_UPDATE && $PKG_INSTALL code" ;;
    fedora)
      rpm --import https://packages.microsoft.com/keys/microsoft.asc
      cat > /etc/yum.repos.d/vscode.repo <<'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
      eval "$PKG_INSTALL code" ;;
  esac
fi

# QQ (deb only)
if [ "${INSTALL_QQ:-false}" = "true" ]; then
  QQ_URL="https://dldir1.qq.com/qqfile/qq/QQNT/Linux/QQ_3.2.12_240927_${ARCH_DEB}_01.deb"
  case "$OS_ID" in
    debian|ubuntu)
      wget -O /tmp/qq.deb "$QQ_URL"
      dpkg -i /tmp/qq.deb || apt-get install -f -y
      rm -f /tmp/qq.deb ;;
  esac
fi
