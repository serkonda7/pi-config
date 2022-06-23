#!/bin/bash

# Script to automate setup as wifi access point
# https://github.com/serkonda7/pi-config (2022-06-23)

sudo apt update
sudo apt upgrade

sudo apt install hostapd
sudo systemctl unmask hostapd
sudo systemctl enable hostapd

sudo apt install dnsmasq
sudo DEBIAN_FRONTEND=noninteractive apt install -y netfilter-persistent iptables-persistent


echo "interface wlan0
static ip_address=192.168.4.1/24
nohook wpa_supplicant
" | tee -a  /etc/dhcpcd.conf


echo "# Enable IPv4 routing
net.ipv4.ip_forward=1
" > /etc/sysctl.d/routed-ap.conf


sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo netfilter-persistent save


sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
echo "interface=wlan0 # Listening interface
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h # Pool of IP addresses served via DHCP
domain=wlan     # Local wireless DNS domain
address=/gw.wlan/192.168.4.1 # Alias for this router
" > /etc/dnsmasq.conf


sudo rfkill unblock wlan

# TODO configure hostapd and get ssid, pw from cmd arg

# TODO reboot
