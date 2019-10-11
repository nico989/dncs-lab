export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y tcpdump
ip addr add 192.168.32.64/25 dev enp0s9
ip link set enp0s8 up

# Startup commands for host-c go here