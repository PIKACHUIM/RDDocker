package cmd

import (
	"github.com/pikachuim/easydesk/internal/api"
	"github.com/pikachuim/easydesk/internal/config"
	"github.com/spf13/cobra"
)

var serveCmd = &cobra.Command{
	Use:   "serve",
	Short: "Start the API server",
	RunE: func(cmd *cobra.Command, args []string) error {
		cfg, err := config.Load()
		if err != nil {
			return err
		}
		return api.Start(cfg)
	},
}
