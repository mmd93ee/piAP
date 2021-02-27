# piAP
Build an AP and DNS redirect on a Pi.

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
iptables-persistent 
bridge-utils

