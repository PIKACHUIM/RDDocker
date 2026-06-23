package cmd

import (
	"fmt"
	"os/exec"
	"strconv"
	"strings"

	"github.com/pikachuim/deskcli/internal/config"
	"github.com/pikachuim/deskcli/internal/engine"
	"github.com/pikachuim/deskcli/internal/forward"
	"github.com/spf13/cobra"
)

var deskCmd = &cobra.Command{
	Use:   "desk",
	Short: "Container management subcommands",
}

// top-level aliases
var stopCmd = &cobra.Command{Use: "stop <name>", Short: "Stop a container", Args: cobra.ExactArgs(1), RunE: runStop}
var startCmd = &cobra.Command{Use: "start <name>", Short: "Start a container", Args: cobra.ExactArgs(1), RunE: runStart}
var restartCmd = &cobra.Command{Use: "restart <name>", Short: "Restart a container", Args: cobra.ExactArgs(1), RunE: runRestart}
var rmCmd = &cobra.Command{Use: "rm <name>", Short: "Remove a container", Args: cobra.ExactArgs(1), RunE: runRm}
var execCmd = &cobra.Command{Use: "exec <name> <cmd...>", Short: "Execute command in container", Args: cobra.MinimumNArgs(2), RunE: runExec}

func getEngine() (engine.Engine, error) {
	cfg, err := config.Load()
	if err != nil {
		return nil, err
	}
	return engine.New(cfg.Engine)
}

func runStop(_ *cobra.Command, args []string) error {
	eng, err := getEngine()
	if err != nil {
		return err
	}
	return eng.Stop(args[0])
}
func runStart(_ *cobra.Command, args []string) error {
	eng, err := getEngine()
	if err != nil {
		return err
	}
	return eng.Start(args[0])
}
func runRestart(_ *cobra.Command, args []string) error {
	eng, err := getEngine()
	if err != nil {
		return err
	}
	return eng.Restart(args[0])
}

func runRm(_ *cobra.Command, args []string) error {
	eng, err := getEngine()
	if err != nil {
		return err
	}
	if err := eng.Remove(args[0]); err != nil {
		return err
	}
	return config.DeleteContainer(args[0])
}

func runExec(_ *cobra.Command, args []string) error {
	eng, err := getEngine()
	if err != nil {
		return err
	}
	return eng.Exec(args[0], args[1:], detach)
}

var (
	newName      string
	newPorts     []string
	newSoftwares []string
)

var deskNewCmd = &cobra.Command{
	Use:     "new <image>",
	Aliases: []string{"run"},
	Short:   "creator and start a new container",
	Args:    cobra.ExactArgs(1),
	RunE:    runDeskNew,
}

func runDeskNew(_ *cobra.Command, args []string) error {
	image := args[0]
	cfg, err := config.Load()
	if err != nil {
		return err
	}
	eng, err := engine.New(cfg.Engine)
	if err != nil {
		return err
	}

	name := newName
	if name == "" {
		name = strings.ReplaceAll(strings.Split(image, ":")[0], "/", "-")
	}

	if err := eng.Run(image, name, newPorts, nil); err != nil {
		return err
	}

	for _, sw := range newSoftwares {
		fmt.Printf("Installing %s in %s...\n", sw, name)
		if err := eng.Exec(name, []string{"apt-get", "install", "-y", sw}, false); err != nil {
			fmt.Printf("Warning: failed to install %s: %v\n", sw, err)
		}
	}

	var portMaps []config.PortMap
	for _, p := range newPorts {
		parts := strings.SplitN(p, ":", 2)
		if len(parts) == 2 {
			ext, _ := strconv.Atoi(parts[0])
			in, _ := strconv.Atoi(parts[1])
			portMaps = append(portMaps, config.PortMap{Ext: ext, Int: in})
		}
	}

	cc := &config.ContainerConfig{Name: name, Image: image, Engine: cfg.Engine, Ports: portMaps}
	if err := config.SaveContainer(cc); err != nil {
		return err
	}

	if ip := getContainerIP(cfg.Engine, name); ip != "" {
		_ = forward.ApplyContainerRules(ip, portMaps)
	}

	fmt.Printf("Container %s started from image %s\n", name, image)
	return nil
}

func getContainerIP(engineType, name string) string {
	var out []byte
	var err error
	switch engineType {
	case "docker", "podman":
		out, err = exec.Command(engineType, "inspect", "-f",
			"{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}", name).Output()
	case "lxd":
		out, err = exec.Command("lxc", "list", name, "--format", "csv", "-c", "4").Output()
	default:
		return ""
	}
	if err != nil {
		return ""
	}
	return strings.TrimSpace(string(out))
}

func init() {
	deskNewCmd.Flags().StringVar(&newName, "name", "", "Container name")
	deskNewCmd.Flags().StringArrayVar(&newPorts, "port", nil, "Port mapping ext:int (repeatable)")
	deskNewCmd.Flags().StringArrayVar(&newSoftwares, "add-soft", nil, "Software to preinstall (repeatable)")

	deskCmd.AddCommand(
		&cobra.Command{Use: "list", Short: "List containers", RunE: runList},
		&cobra.Command{Use: "stop <name>", Short: "Stop container", Args: cobra.ExactArgs(1), RunE: runStop},
		&cobra.Command{Use: "start <name>", Short: "Start container", Args: cobra.ExactArgs(1), RunE: runStart},
		&cobra.Command{Use: "restart <name>", Short: "Restart container", Args: cobra.ExactArgs(1), RunE: runRestart},
		&cobra.Command{Use: "rm <name>", Short: "Remove container", Args: cobra.ExactArgs(1), RunE: runRm},
		&cobra.Command{Use: "exec <name> <cmd...>", Short: "Exec in container", Args: cobra.MinimumNArgs(2), RunE: runExec},
		deskNewCmd,
	)
}
