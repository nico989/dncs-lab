export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y tcpdump
sysctl net.ipv4.ip_forward=1
ip link set enp0s9 up
ip link set enp0s8 up
ip link add link enp0s8 name enp0s8.9 type vlan id 9
ip link add link enp0s8 name enp0s8.10 type vlan id 10
ip link set enp0s8.9 up
ip link set enp0s8.10 up
ip addr add 192.168.1.1/23 dev enp0s8.9
ip addr add 192.168.3.1/23 dev enp0s8.10
ip addr add 10.10.0.1/30 dev enp0s9 
ip route add 192.168.5.0/25 via 10.10.0.2 
