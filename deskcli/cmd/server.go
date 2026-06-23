package cmd

import (
	"os"
	"os/exec"

	"github.com/spf13/cobra"
)

const serviceName = "dockcli"

var serverCmd = &cobra.Command{
	Use:   "server",
	Short: "Manage the deskcli API service",
}

func systemctl(args ...string) error {
	c := exec.Command("systemctl", args...)
	c.Stdout, c.Stderr = os.Stdout, os.Stderr
	return c.Run()
}

func init() {
	for _, sub := range []struct {
		use   string
		short string
		args  []string
	}{
		{"start", "Start the service", []string{"start", serviceName}},
		{"stop", "Stop the service", []string{"stop", serviceName}},
		{"restart", "Restart the service", []string{"restart", serviceName}},
		{"enable", "Enable service on boot", []string{"enable", serviceName}},
		{"disable", "Disable service on boot", []string{"disable", serviceName}},
		{"status", "Show service status", []string{"status", serviceName}},
	} {
		a := sub.args
		serverCmd.AddCommand(&cobra.Command{
			Use:   sub.use,
			Short: sub.short,
			RunE:  func(_ *cobra.Command, _ []string) error { return systemctl(a...) },
		})
	}
}
