package engine

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
)

type DockerEngine struct{ binary string }

func (d *DockerEngine) List() ([]ContainerInfo, error) {
	out, err := exec.Command(d.binary, "ps", "-a", "--format", "{{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}").Output()
	if err != nil {
		return nil, err
	}
	var list []ContainerInfo
	for _, line := range strings.Split(strings.TrimSpace(string(out)), "\n") {
		if line == "" {
			continue
		}
		parts := strings.SplitN(line, "\t", 4)
		info := ContainerInfo{Name: parts[0]}
		if len(parts) > 1 {
			info.Status = parts[1]
		}
		if len(parts) > 2 {
			info.Image = parts[2]
		}
		if len(parts) > 3 && parts[3] != "" {
			info.Ports = strings.Split(parts[3], ", ")
		}
		list = append(list, info)
	}
	return list, nil
}

func (d *DockerEngine) Pull(image string) error {
	c := exec.Command(d.binary, "pull", image)
	c.Stdout, c.Stderr = os.Stdout, os.Stderr
	return c.Run()
}

func (d *DockerEngine) Start(name string) error   { return exec.Command(d.binary, "start", name).Run() }
func (d *DockerEngine) Stop(name string) error    { return exec.Command(d.binary, "stop", name).Run() }
func (d *DockerEngine) Restart(name string) error { return exec.Command(d.binary, "restart", name).Run() }
func (d *DockerEngine) Remove(name string) error  { return exec.Command(d.binary, "rm", "-f", name).Run() }

func (d *DockerEngine) Exec(name string, cmd []string, detach bool) error {
	args := []string{"exec"}
	if detach {
		args = append(args, "-d")
	} else {
		args = append(args, "-it")
	}
	args = append(append(args, name), cmd...)
	c := exec.Command(d.binary, args...)
	if !detach {
		c.Stdin, c.Stdout, c.Stderr = os.Stdin, os.Stdout, os.Stderr
	}
	return c.Run()
}

func (d *DockerEngine) Run(image, name string, ports []string, env []string) error {
	args := []string{"run", "-d", "--name", name, "--privileged", "--shm-size=1024m"}
	for _, p := range ports {
		args = append(args, "-p", p)
	}
	for _, e := range env {
		args = append(args, "-e", e)
	}
	args = append(args, image)
	return exec.Command(d.binary, args...).Run()
}

func (d *DockerEngine) SetPassword(name, password string) error {
	return exec.Command(d.binary, "exec", name, "bash", "-c", fmt.Sprintf("echo 'root:%s' | chpasswd", password)).Run()
}

func (d *DockerEngine) Info(name string) (*ContainerInfo, error) {
	out, err := exec.Command(d.binary, "inspect", "--format", "{{.Id}}\t{{.State.Status}}\t{{.Config.Image}}", name).Output()
	if err != nil {
		return nil, err
	}
	parts := strings.SplitN(strings.TrimSpace(string(out)), "\t", 3)
	info := &ContainerInfo{Name: name}
	if len(parts) > 0 {
		info.ID = parts[0]
	}
	if len(parts) > 1 {
		info.Status = parts[1]
	}
	if len(parts) > 2 {
		info.Image = parts[2]
	}
	return info, nil
}

func (d *DockerEngine) GetIP(name string) (string, error) {
	out, err := exec.Command(d.binary, "inspect", "-f", "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}", name).Output()
	if err != nil {
		return "", err
	}
	return strings.TrimSpace(string(out)), nil
}
