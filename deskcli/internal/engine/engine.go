package engine

import "fmt"

type ContainerInfo struct {
	Name   string
	Status string
	Image  string
	Ports  []string
	ID     string
}

type Engine interface {
	List() ([]ContainerInfo, error)
	Start(name string) error
	Stop(name string) error
	Restart(name string) error
	Remove(name string) error
	Exec(name string, cmd []string, detach bool) error
	Run(image, name string, ports []string, env []string) error
	Pull(image string) error
	SetPassword(name, password string) error
	Info(name string) (*ContainerInfo, error)
	GetIP(name string) (string, error)
}

func New(engineType string) (Engine, error) {
	switch engineType {
	case "docker":
		return &DockerEngine{binary: "docker"}, nil
	case "podman":
		return &DockerEngine{binary: "podman"}, nil
	case "lxc":
		return &LxcEngine{isLxd: false}, nil
	case "lxd":
		return &LxcEngine{isLxd: true}, nil
	default:
		return nil, fmt.Errorf("unsupported engine: %s", engineType)
	}
}
