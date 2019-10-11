export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y tcpdump
ip addr add 172.16.64.64/23 dev enp0s8
ip link set enp0s8 up
ip add route 10.10.128.0/23 via 172.16.64.1 #raggiunge rete dell'host-a sulla VLAN 9 tramite sottointerfaccia 172.16.64.1 del router

# Startup commands fro host-b go here