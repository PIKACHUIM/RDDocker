package config

import (
	"fmt"
	"os"
	"path/filepath"

	"gopkg.in/yaml.v3"
)

const (
	ConfigDir  = "/opt/easydesk/conf"
	DataDir    = "/opt/easydesk/data"
	MainConfig = "/opt/easydesk/conf/config.yaml"
)

type Config struct {
	Token   string `yaml:"token"`
	Engine  string `yaml:"engine"`
	Port    int    `yaml:"port"`
	DataDir string `yaml:"data_dir"`
}

type PortMap struct {
	Ext int `yaml:"ext"`
	Int int `yaml:"int"`
}

type ContainerConfig struct {
	Name   string    `yaml:"name"`
	Image  string    `yaml:"image"`
	Engine string    `yaml:"engine"`
	Ports  []PortMap `yaml:"ports"`
}

func Load() (*Config, error) {
	data, err := os.ReadFile(MainConfig)
	if err != nil {
		return &Config{Engine: "docker", Port: 8080}, nil
	}
	var c Config
	if err := yaml.Unmarshal(data, &c); err != nil {
		return nil, err
	}
	if c.Port == 0 {
		c.Port = 8080
	}
	if c.Engine == "" {
		c.Engine = "docker"
	}
	return &c, nil
}

func Save(c *Config) error {
	if err := os.MkdirAll(ConfigDir, 0755); err != nil {
		return err
	}
	data, err := yaml.Marshal(c)
	if err != nil {
		return err
	}
	return os.WriteFile(MainConfig, data, 0644)
}

func containerConfigPath(name string) string {
	return filepath.Join(ConfigDir, "containers", name+".yaml")
}

func LoadContainer(name string) (*ContainerConfig, error) {
	data, err := os.ReadFile(containerConfigPath(name))
	if err != nil {
		return nil, err
	}
	var c ContainerConfig
	return &c, yaml.Unmarshal(data, &c)
}

func SaveContainer(c *ContainerConfig) error {
	dir := filepath.Join(ConfigDir, "containers")
	if err := os.MkdirAll(dir, 0755); err != nil {
		return err
	}
	data, err := yaml.Marshal(c)
	if err != nil {
		return err
	}
	return os.WriteFile(containerConfigPath(c.Name), data, 0644)
}

func ListContainerConfigs() ([]*ContainerConfig, error) {
	dir := filepath.Join(ConfigDir, "containers")
	entries, err := os.ReadDir(dir)
	if err != nil {
		return nil, nil
	}
	var out []*ContainerConfig
	for _, e := range entries {
		if filepath.Ext(e.Name()) != ".yaml" {
			continue
		}
		name := e.Name()[:len(e.Name())-5]
		cc, err := LoadContainer(name)
		if err == nil {
			out = append(out, cc)
		}
	}
	return out, nil
}

func DeleteContainer(name string) error {
	path := containerConfigPath(name)
	if err := os.Remove(path); err != nil && !os.IsNotExist(err) {
		return fmt.Errorf("delete container config: %w", err)
	}
	return nil
}
