package cmd

import (
	"os"

	"github.com/spf13/cobra"
)

var detach bool

var rootCmd = &cobra.Command{
	Use:   "deskcli",
	Short: "desktop container management tool",
}

func Execute() {
	if err := rootCmd.Execute(); err != nil {
		os.Exit(1)
	}
}

func init() {
	rootCmd.PersistentFlags().BoolVarP(&detach, "detach", "d", false, "Run in background (detach)")
	rootCmd.AddCommand(confCmd, listCmd, deskCmd, serveCmd, softCmd)
	rootCmd.AddCommand(stopCmd, startCmd, restartCmd, rmCmd, execCmd)
}
