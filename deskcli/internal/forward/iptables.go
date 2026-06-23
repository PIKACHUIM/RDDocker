package forward

import (
	"fmt"
	"os/exec"

	"github.com/pikachuim/deskcli/internal/config"
)

func AddDNAT(containerIP string, extPort, intPort int) error {
	return iptables("-A", containerIP, extPort, intPort)
}

func RemoveDNAT(containerIP string, extPort, intPort int) error {
	return iptables("-D", containerIP, extPort, intPort)
}

func iptables(action, containerIP string, extPort, intPort int) error {
	return exec.Command("iptables", "-t", "nat", action, "PREROUTING",
		"-p", "tcp", "--dport", fmt.Sprintf("%d", extPort),
		"-j", "DNAT", "--to-destination",
		fmt.Sprintf("%s:%d", containerIP, intPort)).Run()
}

func ApplyContainerRules(containerIP string, ports []config.PortMap) error {
	for _, p := range ports {
		if err := AddDNAT(containerIP, p.Ext, p.Int); err != nil {
			return fmt.Errorf("iptables DNAT %d->%d: %w", p.Ext, p.Int, err)
		}
	}
	return nil
}
