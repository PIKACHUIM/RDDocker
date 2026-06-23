package cmd

import (
	"bufio"
	"fmt"
	"os"
	"strings"

	"github.com/spf13/cobra"
)

var uninstallCmd = &cobra.Command{
	Use:   "uninstall",
	Short: "Uninstall deskcli and its service",
	RunE: func(_ *cobra.Command, _ []string) error {
		_ = systemctl("stop", serviceName)
		_ = systemctl("disable", serviceName)
		_ = os.Remove("/etc/systemd/system/dockcli.service")
		_ = systemctl("daemon-reload")
		_ = os.Remove("/usr/local/bin/deskcli")
		fmt.Print("Remove config and data (/opt/deskcli)? [y/N]: ")
		s, _ := bufio.NewReader(os.Stdin).ReadString('\n')
		if strings.TrimSpace(strings.ToLower(s)) == "y" {
			_ = os.RemoveAll("/opt/deskcli")
			fmt.Println("Removed /opt/deskcli")
		}
		fmt.Println("deskcli uninstalled.")
		return nil
	},
}
