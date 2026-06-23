package api

import (
	"fmt"
	"net/http"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/pikachuim/deskcli/internal/config"
	"github.com/pikachuim/deskcli/internal/engine"
	"github.com/pikachuim/deskcli/internal/forward"
)

func ok(c *gin.Context, data interface{}) {
	c.JSON(http.StatusOK, gin.H{"success": true, "data": data, "message": "ok"})
}

func fail(c *gin.Context, code int, msg string) {
	c.JSON(code, gin.H{"success": false, "data": nil, "message": msg})
}

func loadEngine(c *gin.Context) (engine.Engine, *config.Config, bool) {
	cfg, err := config.Load()
	if err != nil {
		fail(c, 500, err.Error())
		return nil, nil, false
	}
	eng, err := newEngine(cfg)
	if err != nil {
		fail(c, 500, err.Error())
		return nil, nil, false
	}
	return eng, cfg, true
}

func ListContainers(c *gin.Context) {
	eng, _, ok2 := loadEngine(c)
	if !ok2 {
		return
	}
	list, err := eng.List()
	if err != nil {
		fail(c, 500, err.Error())
		return
	}
	ok(c, list)
}

type createReq struct {
	Image     string   `json:"image"`
	Name      string   `json:"name"`
	Ports     []string `json:"ports"`
	Softwares []string `json:"softwares"`
}

func CreateContainer(c *gin.Context) {
	var req createReq
	if err := c.ShouldBindJSON(&req); err != nil {
		fail(c, 400, err.Error())
		return
	}
	eng, cfg, ok2 := loadEngine(c)
	if !ok2 {
		return
	}
	name := req.Name
	if name == "" {
		name = strings.ReplaceAll(strings.Split(req.Image, ":")[0], "/", "-")
	}
	if err := eng.Run(req.Image, name, req.Ports, nil); err != nil {
		fail(c, 500, err.Error())
		return
	}
	for _, sw := range req.Softwares {
		_ = eng.Exec(name, []string{"apt-get", "install", "-y", sw}, true)
	}
	var portMaps []config.PortMap
	for _, p := range req.Ports {
		parts := strings.SplitN(p, ":", 2)
		if len(parts) == 2 {
			ext, _ := strconv.Atoi(parts[0])
			in, _ := strconv.Atoi(parts[1])
			portMaps = append(portMaps, config.PortMap{Ext: ext, Int: in})
		}
	}
	_ = config.SaveContainer(&config.ContainerConfig{Name: name, Image: req.Image, Engine: cfg.Engine, Ports: portMaps})
	if ip, err := eng.GetIP(name); err == nil && ip != "" {
		_ = forward.ApplyContainerRules(ip, portMaps)
	}
	ok(c, gin.H{"name": name})
}

func GetContainer(c *gin.Context) {
	eng, _, ok2 := loadEngine(c)
	if !ok2 {
		return
	}
	name := c.Param("name")
	info, err := eng.Info(name)
	if err != nil {
		fail(c, 404, fmt.Sprintf("container %s not found: %v", name, err))
		return
	}
	ok(c, info)
}

func RemoveContainer(c *gin.Context) {
	eng, _, ok2 := loadEngine(c)
	if !ok2 {
		return
	}
	name := c.Param("name")
	if err := eng.Remove(name); err != nil {
		fail(c, 500, err.Error())
		return
	}
	_ = config.DeleteContainer(name)
	ok(c, nil)
}

func StartContainer(c *gin.Context) {
	eng, _, ok2 := loadEngine(c)
	if !ok2 {
		return
	}
	if err := eng.Start(c.Param("name")); err != nil {
		fail(c, 500, err.Error())
		return
	}
	ok(c, nil)
}

func StopContainer(c *gin.Context) {
	eng, _, ok2 := loadEngine(c)
	if !ok2 {
		return
	}
	if err := eng.Stop(c.Param("name")); err != nil {
		fail(c, 500, err.Error())
		return
	}
	ok(c, nil)
}

func RestartContainer(c *gin.Context) {
	eng, _, ok2 := loadEngine(c)
	if !ok2 {
		return
	}
	if err := eng.Restart(c.Param("name")); err != nil {
		fail(c, 500, err.Error())
		return
	}
	ok(c, nil)
}

type execReq struct {
	Cmd    []string `json:"cmd"`
	Detach bool     `json:"detach"`
}

func ExecContainer(c *gin.Context) {
	var req execReq
	if err := c.ShouldBindJSON(&req); err != nil {
		fail(c, 400, err.Error())
		return
	}
	eng, _, ok2 := loadEngine(c)
	if !ok2 {
		return
	}
	if err := eng.Exec(c.Param("name"), req.Cmd, req.Detach); err != nil {
		fail(c, 500, err.Error())
		return
	}
	ok(c, nil)
}

type passwdReq struct{ Password string `json:"password"` }

func SetPassword(c *gin.Context) {
	var req passwdReq
	if err := c.ShouldBindJSON(&req); err != nil {
		fail(c, 400, err.Error())
		return
	}
	eng, _, ok2 := loadEngine(c)
	if !ok2 {
		return
	}
	if err := eng.SetPassword(c.Param("name"), req.Password); err != nil {
		fail(c, 500, err.Error())
		return
	}
	ok(c, nil)
}
