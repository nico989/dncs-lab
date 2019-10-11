export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y tcpdump
sysctl net.ipv4.ip_forward=1
ip addr add 10.10.0.2/30 dev enp0s9
ip addr add 192.168.32.1/25 dev enp0s8
ip link set enp0s9 up
ip link set enp0s8 up

# Startup commands for router-2 go here