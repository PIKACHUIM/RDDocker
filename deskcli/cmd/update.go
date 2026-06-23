package cmd

import (
	"fmt"
	"os"
	"os/exec"
	"runtime"

	"github.com/spf13/cobra"
)

var updateCmd = &cobra.Command{
	Use:   "update",
	Short: "Update deskcli to the latest release",
	RunE: func(_ *cobra.Command, _ []string) error {
		url := fmt.Sprintf(
			"https://github.com/PIKACHUIM/RDDocker/releases/download/v0.0.0-beta/deskcli-linux-%s",
			runtime.GOARCH,
		)
		fmt.Printf("Downloading %s ...\n", url)
		tmp := "/tmp/deskcli-update"
		c := exec.Command("curl", "-fsSL", url, "-o", tmp)
		c.Stdout, c.Stderr = os.Stdout, os.Stderr
		if err := c.Run(); err != nil {
			return fmt.Errorf("download failed: %w", err)
		}
		_ = os.Chmod(tmp, 0755)
		self, err := os.Executable()
		if err != nil {
			self = "/usr/local/bin/deskcli"
		}
		if err := os.Rename(tmp, self); err != nil {
			return exec.Command("install", "-m755", tmp, self).Run()
		}
		fmt.Printf("Updated at %s\n", self)
		return nil
	},
}
