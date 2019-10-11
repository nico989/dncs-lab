export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y tcpdump
ip addr add 10.10.128.64/23 dev enp0s8
ip link set enp0s8 up
ip route add 172.16.64.0/23 via 10.10.128.1 #raggiunge la rete dell'host-b su VLAN 10 tramite sottointerfaccia 10.10.128.1

# Startup commands for host-a go here