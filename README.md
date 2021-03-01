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
  - update /etc/hosts to include 127.0.0.1 to the hostname
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

- Create bridge interface, use to host web server and wlan address
  - br0 by creating /etc/netplan/20-bridges.yaml
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
            addresses: [192.168.1.25]
          parameters:
            stp: true
            forward-delay: 4

  - wlan0 by creating /etc/netplan/30-wlan.yaml
    network:
    version: 2
    renderer: networkd
    ethernets:
      wlan0:
        dhcp4: no
        addresses: [192.168.3.25/24]
        mtu: 1500
        nameservers:
          addresses: [192.168.1.25]
          
- Install nginx and gunicorn.
  - In /var/www/html add a .htaccess file and paste in the following;
    Redirect /library/test/success.html /
    Redirect /hotspot-detect.html /
    Redirect /ncsi.txt /
    Redirect /connecttest.txt /
    Redirect /fwlink/ /
    Redirect /generate_204 /r/204

    RewriteEngine on
    RewriteCond %{HTTP_USER_AGENT} ^CaptiveNetworkSupport(.*)$ [NC]
    RewriteRule ^(.*)$ / [L,R=301]

  - Change to only listen on main eth0.  Edit /etc/nginx/sites-enabled/default to include a listen: <address>:<port> line.  Use address for br0.

- Update dnsmasq (/etc/dnsmasq.conf) to only server DHCP on wlan0
  interface=wlan0
  dhcp-range=192.168.3.50,192.168.3.150,255.255.255.0,1h
  server=192.168.1.1 (for upstream dns)
  listen-address=127.0.0.1
  listen-address=192.168.3.25
  log-queries
  log-dhcp
  
- Update UFW to allow inbound traffic to wlan0
  - dns and dhcp to wlan0
    ufw allow in on wlan0 to 192.168.3.25 proto udp port 67
    ufw allow in on wlan0 to 192.168.3.25 proto tcp port 53









- NOT SURE IF THIS BIT IS CORRECT
*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A PREROUTING -i br0 -p udp -m udp --dport 53 -j DNAT --to-destination 10.1.1.1:53
-A PREROUTING -i br0 -p tcp -m tcp --dport 80 -j DNAT --to-destination 10.1.1.1:80
-A PREROUTING -i br0 -p tcp -m tcp --dport 443 -j DNAT --to-destination 10.1.1.1:80
-A POSTROUTING -j MASQUERADE
COMMIT
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
COMMIT
