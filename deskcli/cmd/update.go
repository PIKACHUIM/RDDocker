package cmd

import (
	"fmt"
	"os"
	"os/exec"
	"runtime"
	"strings"

	"github.com/spf13/cobra"
)

var updateCmd = &cobra.Command{
	Use:   "update",
	Short: "Update deskcli to the latest release",
	RunE: func(_ *cobra.Command, _ []string) error {
		url := fmt.Sprintf("https://github.com/PIKACHUIM/RDDocker/releases/download/v0.0.0-beta/deskcli-linux-%s", runtime.GOARCH)
		fmt.Printf("Downloading %s ...\n", url)
		c := exec.Command("curl", "-fsSL", url, "-o", "/tmp/deskcli-update")
		c.Stdout = os.Stdout
		c.Stderr = os.Stderr
		if err := c.Run(); err != nil {
			return fmt.Errorf("download failed: %w", err)
		}
		_ = os.Chmod("/tmp/deskcli-update", 0755)
		self, err := os.Executable()
		if err != nil {
			self = "/usr/local/bin/deskcli"
		}
		self = strings.TrimSuffix(self, " ")
		if err := os.Rename("/tmp/deskcli-update", self); err != nil {
			// fallback: use install
			return exec.Command("install", "-m755", "/tmp/deskcli-update", self).Run()
		}
		fmt.Printf("Updated to latest release at %s\n", self)
		return nil
	},
}
