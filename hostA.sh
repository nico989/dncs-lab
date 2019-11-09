export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y tcpdump
ip link set enp0s8 up
ip addr add 192.168.1.2/23 dev enp0s8
ip route add 192.168.0.0/21 via 192.168.1.1 
