#!/bin/sh
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/common.sh"

echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d 2>/dev/null || true

# Install X11 base packages
case "$OS_ID" in
  debian|ubuntu)
    eval "$PKG_UPDATE"
    eval "$PKG_INSTALL xserver-xorg-core xauth xorg wget gnupg2 \
      xserver-xorg-video-dummy curl net-tools \
      xfonts-base xfonts-75dpi xfonts-100dpi xfonts-scalable \
      dbus-user-session dbus-x11 xinit xvfb xrdp x11vnc"
    eval "$PKG_INSTALL neofetch 2>/dev/null || true"
    ;;
  fedora)
    eval "$PKG_UPDATE"
    eval "$PKG_INSTALL xorg-x11-server-Xorg xorg-x11-xauth \
      xorg-x11-server-Xvfb wget curl net-tools dbus xrdp x11vnc"
    ;;
  arch|archlinux)
    eval "$PKG_INSTALL xorg-server xf86-video-dummy xorg-xauth \
      xorg-xvfb xrdp x11vnc dbus curl wget"
    ;;
  alpine)
    eval "$PKG_INSTALL xorg-server xf86-video-dummy xauth x11vnc xvfb \
      dbus dbus-x11 font-dejavu font-noto xrdp"
    ;;
esac

# xorg.conf (dummy driver for headless)
cp "$INSTALL_DIR/conf/xorg.conf" /usr/share/X11/xorg.conf.d/99-dummy.conf
echo 'allowed_users=anybody' > /etc/X11/Xwrapper.config 2>/dev/null || true

# VNC password
mkdir -p /etc/x11vnc
x11vnc -storepasswd 12345678 /etc/x11vnc.pass 2>/dev/null || echo "12345678" > /etc/x11vnc.pass

# Write x11vnc startup helper
cat > /x11vnc.sh <<'EOF'
#!/bin/sh
export DISPLAY=:9
nohup x11vnc -forever -noxdamage -repeat -rfbauth /etc/x11vnc.pass \
  -rfbport 5900 -shared -create -display :9 &
EOF
chmod +x /x11vnc.sh

# NoMachine (deb/rpm only - not Alpine/Arch)
case "$OS_ID" in
  debian|ubuntu)
    NX_ARCH=$(dpkg --print-architecture | sed 's/arm64/aarch64/')
    NX_URL="https://download.nomachine.com/download/8.14/Linux/nomachine_8.14.2_1_${NX_ARCH}.deb"
    wget -q "$NX_URL" -O /tmp/nx.deb \
      && dpkg -i /tmp/nx.deb || echo "NoMachine install skipped" \
      && rm -f /tmp/nx.deb
    ;;
  fedora)
    NX_URL="https://download.nomachine.com/download/8.14/Linux/nomachine_8.14.2_1_x86_64.rpm"
    wget -q "$NX_URL" -O /tmp/nx.rpm \
      && rpm -i /tmp/nx.rpm || echo "NoMachine install skipped" \
      && rm -f /tmp/nx.rpm
    ;;
esac

# Configure NoMachine
if [ -f /usr/NX/etc/node.cfg ]; then
  sed -i '$a PhysicalDesktopAuthorization 0' /usr/NX/etc/node.cfg
  sed -i '$a WaylandModes "egl,compositor,drm"' /usr/NX/etc/node.cfg
fi
if [ -f /usr/NX/etc/server.cfg ]; then
  cat >> /usr/NX/etc/server.cfg <<'NX'
VirtualDesktopAccess all
VirtualDesktopMode 2
PhysicalDesktopAccess all
PhysicalDesktopMode 2
CreateDisplay 1
DisplayGeometry 1920x1080
StartHTTPDaemon Automatic
EnableWebPlayer 1
WebAccessType systemlogin
NX
fi

# Append NX + dbus startup to /run.sh
cat >> /run.sh <<'EOF'
export DISPLAY=:0
/etc/init.d/dbus start 2>/dev/null || dbus-daemon --system &
[ -f /etc/NX/nxserver ] && /etc/NX/nxserver --startup
EOF
