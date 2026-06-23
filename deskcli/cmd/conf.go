package cmd

import (
	"fmt"
	"strconv"

	"github.com/pikachuim/deskcli/internal/config"
	"github.com/spf13/cobra"
)

var confCmd = &cobra.Command{
	Use:   "configs",
	Short: "Manage configuration",
}

var confSetCmd = &cobra.Command{
	Use:   "set <key> <value>",
	Short: "Set a config value (token|engine|port|port_range)",
	Args:  cobra.ExactArgs(2),
	RunE: func(cmd *cobra.Command, args []string) error {
		cfg, err := config.Load()
		if err != nil {
			return err
		}
		key, val := args[0], args[1]
		switch key {
		case "token":
			cfg.Token = val
		case "engine":
			cfg.Engine = val
		case "port":
			p, err := strconv.Atoi(val)
			if err != nil {
				return fmt.Errorf("invalid port: %s", val)
			}
			cfg.Port = p
		case "port_range":
			cfg.PortRange = val
		default:
			return fmt.Errorf("unknown key: %s", key)
		}
		return config.Save(cfg)
	},
}

var confGetCmd = &cobra.Command{
	Use:   "get <key>",
	Short: "Get a config value (token|engine|port|port_range)",
	Args:  cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		cfg, err := config.Load()
		if err != nil {
			return err
		}
		switch args[0] {
		case "token":
			fmt.Println(cfg.Token)
		case "engine":
			fmt.Println(cfg.Engine)
		case "port":
			fmt.Println(cfg.Port)
		case "port_range":
			fmt.Println(cfg.PortRange)
		default:
			return fmt.Errorf("unknown key: %s", args[0])
		}
		return nil
	},
}

func init() {
	confCmd.AddCommand(confSetCmd, confGetCmd)
}
