package cmd

import (
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"strconv"
	"strings"

	"github.com/pikachuim/deskcli/internal/config"
	"github.com/pikachuim/deskcli/internal/engine"
	"github.com/pikachuim/deskcli/internal/forward"
	"github.com/pikachuim/deskcli/internal/store"
	"github.com/spf13/cobra"
)

var deskCmd = &cobra.Command{
	Use:   "desk",
	Short: "Container management subcommands",
}

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

func genPassword() string {
	b := make([]byte, 8)
	_, _ = rand.Read(b)
	return hex.EncodeToString(b)
}

// resetPasswords sets root, user, and VNC passwords inside the container.
func resetPasswords(eng engine.Engine, name, password string) {
	cmds := []string{
		fmt.Sprintf("echo 'root:%s' | chpasswd", password),
		fmt.Sprintf("echo 'user:%s' | chpasswd", password),
		fmt.Sprintf("x11vnc -storepasswd '%s' /etc/x11vnc.pass", password),
	}
	for _, c := range cmds {
		if err := eng.Exec(name, []string{"bash", "-c", c}, false); err != nil {
			fmt.Printf("  warning: %v\n", err)
		}
	}
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
	cfg, _ := config.Load()
	if db, err := store.Open(cfg.DataDir); err == nil {
		_ = db.Delete(args[0])
		_ = db.Close()
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
	Short:   "Create and start a new container",
	Args:    cobra.ExactArgs(1),
	RunE:    runDeskNew,
}

var deskPullCmd = &cobra.Command{
	Use:   "pull <image>",
	Short: "Pull an image",
	Args:  cobra.ExactArgs(1),
	RunE: func(_ *cobra.Command, args []string) error {
		eng, err := getEngine()
		if err != nil {
			return err
		}
		return eng.Pull(args[0])
	},
}

var deskInfoCmd = &cobra.Command{
	Use:   "info <name>",
	Short: "Show container connection info and password",
	Args:  cobra.ExactArgs(1),
	RunE: func(_ *cobra.Command, args []string) error {
		cfg, _ := config.Load()
		db, err := store.Open(cfg.DataDir)
		if err != nil {
			return err
		}
		defer db.Close()
		r, err := db.Get(args[0])
		if err != nil {
			return fmt.Errorf("container not found in database: %w", err)
		}
		fmt.Printf("Name    : %s\n", r.Name)
		fmt.Printf("Image   : %s\n", r.Image)
		fmt.Printf("Engine  : %s\n", r.Engine)
		fmt.Printf("Password: %s\n", r.Password)
		fmt.Printf("SSH     : <host>:%d  -> container:22\n", r.PortSSH)
		fmt.Printf("RDP     : <host>:%d  -> container:3389\n", r.PortRDP)
		fmt.Printf("NX      : <host>:%d  -> container:4000\n", r.PortNX)
		fmt.Printf("VNC     : <host>:%d  -> container:5900\n", r.PortVNC)
		return nil
	},
}

var deskPasswdCmd = &cobra.Command{
	Use:   "passwd <name>",
	Short: "Reset container password (root/user/VNC in sync)",
	Args:  cobra.ExactArgs(1),
	RunE: func(_ *cobra.Command, args []string) error {
		name := args[0]
		cfg, _ := config.Load()
		eng, err := engine.New(cfg.Engine)
		if err != nil {
			return err
		}
		db, err := store.Open(cfg.DataDir)
		if err != nil {
			return err
		}
		defer db.Close()
		password := genPassword()
		resetPasswords(eng, name, password)
		if err := db.UpdatePassword(name, password); err != nil {
			return err
		}
		fmt.Printf("Password reset to: %s\n", password)
		return nil
	},
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

	db, err := store.Open(cfg.DataDir)
	if err != nil {
		return err
	}
	defer db.Close()

	// Build port list: auto-allocate 4 ports for 22/3389/4000/5900 if not specified
	var rec store.ContainerRecord
	ports := newPorts
	if len(ports) == 0 {
		extPorts, err := config.AllocatePorts(cfg.PortRange, db.UsedPorts())
		if err != nil {
			return err
		}
		// extPorts[0]=SSH, [1]=RDP, [2]=NX, [3]=VNC
		ports = []string{
			fmt.Sprintf("%d:22", extPorts[0]),
			fmt.Sprintf("%d:3389", extPorts[1]),
			fmt.Sprintf("%d:4000", extPorts[2]),
			fmt.Sprintf("%d:5900", extPorts[3]),
		}
		rec.PortSSH = extPorts[0]
		rec.PortRDP = extPorts[1]
		rec.PortNX = extPorts[2]
		rec.PortVNC = extPorts[3]
	} else {
		// Parse manually specified ports to fill known service mappings
		for _, p := range ports {
			parts := strings.SplitN(p, ":", 2)
			if len(parts) != 2 {
				continue
			}
			ext, _ := strconv.Atoi(parts[0])
			in, _ := strconv.Atoi(parts[1])
			switch in {
			case 22:
				rec.PortSSH = ext
			case 3389:
				rec.PortRDP = ext
			case 4000:
				rec.PortNX = ext
			case 5900:
				rec.PortVNC = ext
			}
		}
	}

	if err := eng.Run(image, name, ports, nil); err != nil {
		return err
	}

	for _, sw := range newSoftwares {
		fmt.Printf("Installing %s...\n", sw)
		if err := eng.Exec(name, []string{"apt-get", "install", "-y", sw}, false); err != nil {
			fmt.Printf("Warning: failed to install %s: %v\n", sw, err)
		}
	}

	// Set passwords
	password := genPassword()
	fmt.Println("Setting passwords...")
	resetPasswords(eng, name, password)

	// Save to YAML config (for iptables restore)
	var portMaps []config.PortMap
	for _, p := range ports {
		parts := strings.SplitN(p, ":", 2)
		if len(parts) == 2 {
			ext, _ := strconv.Atoi(parts[0])
			in, _ := strconv.Atoi(parts[1])
			portMaps = append(portMaps, config.PortMap{Ext: ext, Int: in})
		}
	}
	_ = config.SaveContainer(&config.ContainerConfig{Name: name, Image: image, Engine: cfg.Engine, Ports: portMaps})

	// Apply iptables
	if ip, err := eng.GetIP(name); err == nil && ip != "" {
		_ = forward.ApplyContainerRules(ip, portMaps)
	}

	// Save to SQLite DB
	rec.Name = name
	rec.Image = image
	rec.Engine = cfg.Engine
	rec.Password = password
	if err := db.Save(&rec); err != nil {
		fmt.Printf("Warning: failed to save to DB: %v\n", err)
	}

	fmt.Printf("\nContainer %s created from image %s\n", name, image)
	fmt.Printf("Password : %s\n", password)
	fmt.Printf("SSH      : <host>:%d\n", rec.PortSSH)
	fmt.Printf("RDP      : <host>:%d\n", rec.PortRDP)
	fmt.Printf("NX       : <host>:%d\n", rec.PortNX)
	fmt.Printf("VNC      : <host>:%d\n", rec.PortVNC)
	return nil
}

func init() {
	deskNewCmd.Flags().StringVar(&newName, "name", "", "Container name")
	deskNewCmd.Flags().StringArrayVar(&newPorts, "port", nil, "Port mapping ext:int (repeatable, auto if omitted)")
	deskNewCmd.Flags().StringArrayVar(&newSoftwares, "add-soft", nil, "Software to preinstall (repeatable)")

	deskCmd.AddCommand(
		&cobra.Command{Use: "list", Short: "List containers", RunE: runList},
		&cobra.Command{Use: "stop <name>", Short: "Stop container", Args: cobra.ExactArgs(1), RunE: runStop},
		&cobra.Command{Use: "start <name>", Short: "Start container", Args: cobra.ExactArgs(1), RunE: runStart},
		&cobra.Command{Use: "restart <name>", Short: "Restart container", Args: cobra.ExactArgs(1), RunE: runRestart},
		&cobra.Command{Use: "rm <name>", Short: "Remove container", Args: cobra.ExactArgs(1), RunE: runRm},
		&cobra.Command{Use: "exec <name> <cmd...>", Short: "Exec in container", Args: cobra.MinimumNArgs(2), RunE: runExec},
		deskNewCmd, deskPullCmd, deskInfoCmd, deskPasswdCmd,
	)
}
