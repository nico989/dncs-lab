export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y tcpdump
sysctl net.ipv4.ip_forward=1
ip link set enp0s9 up
ip link set enp0s8 up
ip link add link enp0s8 name enp0s8.9 type vlan id 9 #sottointerfaccia VLAN 9
ip link add link enp0s8 name enp0s8.10 type vlan id 10 #sottointerfaccia VLAN 10
ip addr add 10.10.128.1/23 dev enp0s8.9
ip addr add 172.16.64.1/ dev enp0s8.10
ip link set enp0s8.9 up
ip link set enp0s8.10 up

# Startup commands for router-1 go here