package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

// installScripts maps app name to a shell snippet executed inside the container.
var installScripts = map[string]string{
	"firefox": `
OS=$(. /etc/os-release && echo "$ID")
case "$OS" in
  debian|ubuntu) apt-get install -y firefox-esr 2>/dev/null || apt-get install -y firefox ;;
  fedora)        dnf install -y firefox ;;
  arch)          pacman -S --noconfirm firefox ;;
  alpine)        apk add --no-cache firefox ;;
  *) echo "Unsupported OS: $OS" && exit 1 ;;
esac`,

	"chrome": `
OS=$(. /etc/os-release && echo "$ID")
ARCH=$(dpkg --print-architecture 2>/dev/null || echo amd64)
case "$OS" in
  debian|ubuntu)
    wget -q -O /tmp/chrome.deb "https://dl.google.com/linux/direct/google-chrome-stable_current_${ARCH}.deb"
    dpkg -i /tmp/chrome.deb || apt-get install -f -y; rm -f /tmp/chrome.deb ;;
  fedora)
    wget -q -O /tmp/chrome.rpm https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
    rpm -i /tmp/chrome.rpm || true; rm -f /tmp/chrome.rpm ;;
  *) echo "Chrome is only supported on Debian/Ubuntu/Fedora" && exit 1 ;;
esac`,

	"vscode": `
OS=$(. /etc/os-release && echo "$ID")
case "$OS" in
  debian|ubuntu)
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /usr/share/keyrings/microsoft.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list
    apt-get update && apt-get install -y code ;;
  fedora)
    rpm --import https://packages.microsoft.com/keys/microsoft.asc
    printf '[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc\n' > /etc/yum.repos.d/vscode.repo
    dnf install -y code ;;
  *) echo "VSCode is only supported on Debian/Ubuntu/Fedora" && exit 1 ;;
esac`,

	"qq": `
OS=$(. /etc/os-release && echo "$ID")
ARCH=$(dpkg --print-architecture 2>/dev/null || echo amd64)
case "$OS" in
  debian|ubuntu)
    wget -O /tmp/qq.deb "https://dldir1.qq.com/qqfile/qq/QQNT/Linux/QQ_3.2.12_240927_${ARCH}_01.deb"
    dpkg -i /tmp/qq.deb || apt-get install -f -y; rm -f /tmp/qq.deb ;;
  *) echo "QQ is only supported on Debian/Ubuntu" && exit 1 ;;
esac`,
}

var softCmd = &cobra.Command{
	Use:   "soft",
	Short: "Software management subcommands",
}

var softInstallCmd = &cobra.Command{
	Use:   "install <app> <container>",
	Short: "install software into a running container",
	Long:  "Available apps: firefox, chrome, vscode, qq",
	Args:  cobra.ExactArgs(2),
	RunE:  runSoftInstall,
}

var softListCmd = &cobra.Command{
	Use:   "list",
	Short: "List installable software",
	Run: func(_ *cobra.Command, _ []string) {
		for app := range installScripts {
			fmt.Println(app)
		}
	},
}

func runSoftInstall(_ *cobra.Command, args []string) error {
	app, container := args[0], args[1]
	script, ok := installScripts[app]
	if !ok {
		return fmt.Errorf("unknown app %q; run 'deskcli soft list' to see available apps", app)
	}
	eng, err := getEngine()
	if err != nil {
		return err
	}
	fmt.Printf("Installing %s in %s...\n", app, container)
	return eng.Exec(container, []string{"sh", "-c", script}, false)
}

func init() {
	softCmd.AddCommand(softInstallCmd, softListCmd)
}
