package api

import (
	"fmt"
	"os/exec"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/pikachuim/deskcli/internal/config"
	"github.com/pikachuim/deskcli/internal/engine"
	"github.com/pikachuim/deskcli/internal/forward"
)

func authMiddleware(token string) gin.HandlerFunc {
	return func(c *gin.Context) {
		if c.GetHeader("X-Token") != token {
			c.AbortWithStatusJSON(401, gin.H{"success": false, "message": "unauthorized"})
			return
		}
		c.Next()
	}
}

func Start(cfg *config.Config) error {
	go restoreIPTables(cfg)

	gin.SetMode(gin.ReleaseMode)
	r := gin.New()
	r.Use(gin.Recovery())

	v1 := r.Group("/api/v1", authMiddleware(cfg.Token))
	{
		v1.GET("/containers", ListContainers)
		v1.POST("/containers", CreateContainer)
		v1.GET("/containers/:name", GetContainer)
		v1.DELETE("/containers/:name", RemoveContainer)
		v1.POST("/containers/:name/start", StartContainer)
		v1.POST("/containers/:name/stop", StopContainer)
		v1.POST("/containers/:name/restart", RestartContainer)
		v1.POST("/containers/:name/exec", ExecContainer)
		v1.POST("/containers/:name/passwd", SetPassword)
	}

	return r.Run(fmt.Sprintf(":%d", cfg.Port))
}

func newEngine(cfg *config.Config) (engine.Engine, error) {
	return engine.New(cfg.Engine)
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

func restoreIPTables(cfg *config.Config) {
	containers, err := config.ListContainerConfigs()
	if err != nil || len(containers) == 0 {
		return
	}
	for _, cc := range containers {
		if len(cc.Ports) == 0 {
			continue
		}
		ip := getContainerIP(cfg.Engine, cc.Name)
		if ip != "" {
			_ = forward.ApplyContainerRules(ip, cc.Ports)
		}
	}
}
