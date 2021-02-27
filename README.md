# piAP
Build an AP and DNS redirect on a Pi.  Built out from: https://jerryryle.github.io/rogue_ap/.

- If using Ubuntu then set a static IP on the Ethernet interface.  
  - Might be using Netplan so disable the cloud yaml file (instructions are in /etc/netplan/<some file>).
  - Create a new netplan and then netplan generate and apply

- Check open ports for 53: netstat -tulpn or lsof -i -P -n

- Remove the DNS stub listener:
  - Edit /etc/systemd/resolved.conf and set DNSStubListener = no
  - systemctl stop and then disable systemd-resolved
  - rm /etc/resolv.conf
  - add local nameserver to dnsmasq.conf (server=<name server>)
  - Reboot
  
- Install packages:
  git 
  macchanger 
  dnsmasq (use lsof -i -P -n to make sure dns is using dnsmasq and not networkd)
  hostapd 
  iptables-persistent <<<need to see if using ufw, if so then ufw enable and ufw allow 22
  bridge-utils <<do not think we need this with netplan

- Configure hostapd
  - Identify name of wireless card (if link show)
  - Update /etc/hostapd/hostapd.conf with the following;
    interface=wlan0
    bridge=br0
    ssid=<pick an SSID>
    hw_mode=g
    channel=<pick a number 1-15>
    wmm_enabled=0
    auth_algs=1
  - Edit /etc/default/hostapd to use above confifguration by setting DAEMON_CONF="/etc/hostapd/hostapd.conf"
  - Run systemctl unmask then enable hostapd

- Create bridge interface, use to host web server
  - Do this with netplan by creating /etc/netplan/20-bridges.yaml
    network:
      version: 2
      renderer: networkd
      bridges:
        br0:
          dhcp4: no
          addresses: [192.168.2.25/24]
          gateway4: 192.168.2.1
          mtu: 1500
          nameservers:
            addresses: [192.168.1.1]
          parameters:
            stp: true
            forward-delay: 4

