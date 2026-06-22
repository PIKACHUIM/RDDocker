package cmd

import (
	"fmt"
	"strings"

	"github.com/pikachuim/easydesk/internal/config"
	"github.com/pikachuim/easydesk/internal/engine"
	"github.com/spf13/cobra"
)

var listCmd = &cobra.Command{
	Use:   "list",
	Short: "List all containers",
	RunE:  runList,
}

func runList(cmd *cobra.Command, args []string) error {
	cfg, err := config.Load()
	if err != nil {
		return err
	}
	eng, err := engine.New(cfg.Engine)
	if err != nil {
		return err
	}
	containers, err := eng.List()
	if err != nil {
		return err
	}
	fmt.Printf("%-20s %-20s %-30s %s\n", "NAME", "STATUS", "IMAGE", "PORTS")
	fmt.Println(strings.Repeat("-", 90))
	for _, c := range containers {
		fmt.Printf("%-20s %-20s %-30s %s\n", c.Name, c.Status, c.Image, strings.Join(c.Ports, ", "))
	}
	return nil
}
