package engine

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
)

type LxcEngine struct{ isLxd bool }

func (l *LxcEngine) List() ([]ContainerInfo, error) {
	var out []byte
	var err error
	if l.isLxd {
		out, err = exec.Command("lxc", "list", "--format", "csv", "-c", "ns").Output()
	} else {
		out, err = exec.Command("lxc-ls", "-f", "--fancy-format", "NAME,STATE").Output()
	}
	if err != nil {
		return nil, err
	}
	var list []ContainerInfo
	for i, line := range strings.Split(strings.TrimSpace(string(out)), "\n") {
		if line == "" || (!l.isLxd && i == 0) {
			continue
		}
		parts := strings.Fields(line)
		if len(parts) < 1 {
			continue
		}
		info := ContainerInfo{Name: strings.Split(parts[0], ",")[0]}
		if l.isLxd {
			sp := strings.SplitN(line, ",", 2)
			info.Name = sp[0]
			if len(sp) > 1 {
				info.Status = sp[1]
			}
		} else if len(parts) > 1 {
			info.Status = parts[1]
		}
		list = append(list, info)
	}
	return list, nil
}

func (l *LxcEngine) Pull(image string) error {
	if l.isLxd {
		c := exec.Command("lxc", "image", "copy", image, "local:")
		c.Stdout, c.Stderr = os.Stdout, os.Stderr
		return c.Run()
	}
	return fmt.Errorf("pull not supported for native lxc")
}

func (l *LxcEngine) Start(name string) error {
	if l.isLxd {
		return exec.Command("lxc", "start", name).Run()
	}
	return exec.Command("lxc-start", "-n", name).Run()
}

func (l *LxcEngine) Stop(name string) error {
	if l.isLxd {
		return exec.Command("lxc", "stop", name).Run()
	}
	return exec.Command("lxc-stop", "-n", name).Run()
}

func (l *LxcEngine) Restart(name string) error {
	_ = l.Stop(name)
	return l.Start(name)
}

func (l *LxcEngine) Remove(name string) error {
	if l.isLxd {
		return exec.Command("lxc", "delete", "--force", name).Run()
	}
	return exec.Command("lxc-destroy", "-n", name).Run()
}

func (l *LxcEngine) Exec(name string, cmd []string, detach bool) error {
	var c *exec.Cmd
	if l.isLxd {
		c = exec.Command("lxc", append([]string{"exec", name, "--"}, cmd...)...)
	} else {
		c = exec.Command("lxc-attach", append([]string{"-n", name, "--"}, cmd...)...)
	}
	if !detach {
		c.Stdin, c.Stdout, c.Stderr = os.Stdin, os.Stdout, os.Stderr
	}
	return c.Run()
}

func (l *LxcEngine) Run(image, name string, ports []string, env []string) error {
	if l.isLxd {
		if err := exec.Command("lxc", "init", image, name).Run(); err != nil {
			return err
		}
		return exec.Command("lxc", "start", name).Run()
	}
	return exec.Command("lxc-create", "-n", name, "-t", image).Run()
}

func (l *LxcEngine) SetPassword(name, password string) error {
	return l.Exec(name, []string{"bash", "-c", fmt.Sprintf("echo 'root:%s' | chpasswd", password)}, false)
}

func (l *LxcEngine) Info(name string) (*ContainerInfo, error) {
	var out []byte
	var err error
	if l.isLxd {
		out, err = exec.Command("lxc", "info", name).Output()
	} else {
		out, err = exec.Command("lxc-info", "-n", name).Output()
	}
	if err != nil {
		return nil, err
	}
	info := &ContainerInfo{Name: name}
	for _, line := range strings.Split(string(out), "\n") {
		if strings.Contains(strings.ToLower(line), "status:") || strings.Contains(strings.ToLower(line), "state:") {
			parts := strings.SplitN(line, ":", 2)
			if len(parts) == 2 {
				info.Status = strings.TrimSpace(parts[1])
			}
		}
	}
	return info, nil
}

func (l *LxcEngine) GetIP(name string) (string, error) {
	if l.isLxd {
		out, err := exec.Command("lxc", "list", name, "--format", "csv", "-c", "4").Output()
		if err != nil {
			return "", err
		}
		return strings.TrimSpace(string(out)), nil
	}
	out, err := exec.Command("lxc-info", "-n", name, "-iH").Output()
	if err != nil {
		return "", err
	}
	return strings.TrimSpace(string(out)), nil
}
