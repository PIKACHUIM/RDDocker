#!/bin/sh
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/common.sh"

case "$OS_ID" in
  debian|ubuntu)
    eval "$PKG_INSTALL openssh-server sudo vim nano wget curl git openssl"
    mkdir -p /var/run/sshd /root/.ssh /run/sshd
    echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d
    rm -f /etc/pam.d/sshd
    cp "$INSTALL_DIR/conf/sshd" /etc/pam.d/sshd
    ;;
  fedora)
    eval "$PKG_INSTALL openssh-server sudo vim nano wget curl git openssl"
    mkdir -p /var/run/sshd /root/.ssh /run/sshd
    rm -f /etc/pam.d/sshd
    cp "$INSTALL_DIR/conf/sshd" /etc/pam.d/sshd
    ;;
  arch|archlinux)
    eval "$PKG_UPDATE"
    eval "$PKG_INSTALL openssh sudo wget curl git openssl base-devel"
    mkdir -p /var/run/sshd /root/.ssh
    cp "$INSTALL_DIR/conf/sshd" /etc/pam.d/sshd 2>/dev/null || true
    ssh-keygen -A
    ;;
  alpine)
    eval "$PKG_INSTALL openssh-server sudo vim nano shadow bash openrc"
    mkdir -p /var/run/sshd /root/.ssh
    ssh-keygen -A
    ;;
esac

# SSH config
grep -q "PermitRootLogin" /etc/ssh/sshd_config \
  && sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
  || echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
grep -q "ListenAddress" /etc/ssh/sshd_config \
  || echo "ListenAddress 0.0.0.0" >> /etc/ssh/sshd_config

# Create user (UID 2000)
case "$OS_ID" in
  alpine)
    addgroup -g 2000 user 2>/dev/null || true
    adduser -u 2000 -G user -s /bin/bash -D user 2>/dev/null || true
    ;;
  arch|archlinux)
    groupadd -r -g 200 user 2>/dev/null || true
    useradd -m -u 200 -r -g user user 2>/dev/null || true
    ;;
  *)
    groupadd -r -g 2000 user 2>/dev/null || true
    useradd -u 2000 -m -r -g user user 2>/dev/null || true
    ;;
esac
echo "user ALL=(ALL) ALL" >> /etc/sudoers

# /run.sh
cat > /run.sh <<'EOF'
#!/bin/sh
echo "Starting Basic Server..."
nohup /usr/sbin/sshd -D &
EOF
chmod +x /run.sh

# Init system
case "$OS_ID" in
  alpine)
    rc-update add sshd default
    ;;
  *)
    cp "$INSTALL_DIR/conf/run.service" /etc/systemd/system/run.service 2>/dev/null || true
    systemctl enable run 2>/dev/null || true
    systemctl enable sshd 2>/dev/null || true
    ;;
esac
