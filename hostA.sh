export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y tcpdump
ip link set enp0s8 up
ip addr add 192.168.1.2/23 dev enp0s8
# ip route add 172.16.64.0/23 via 10.10.128.1 # raggiunge la rete dell'host-b su VLAN 10 tramite sottointerfaccia 10.10.128.1
# ip route add 192.168.32.0/25 via 10.10.128.1 # raggiunge rete dell'host-c
ip route add 192.168.0.0/21 via 192.168.1.1 # rotta generale che raggiunge host-b e host-c

# curl 192.168.5.2:8080

# Startup commands for host-a go here
