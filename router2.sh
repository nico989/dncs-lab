export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y tcpdump
sysctl net.ipv4.ip_forward=1
ip link set enp0s9 up
ip link set enp0s8 up
ip addr add 10.10.0.2/30 dev enp0s9 # indirizzo rete punto punto con rotuer-1
ip addr add 192.168.5.1/25  dev enp0s8 # indirizzo per rete dell'host-c
# ip route add 10.10.128.0/23 via 10.10.0.1 # rotta verso la vlan dell'host-a verso indirizzo router-1
# ip route add 172.16.64.0/23 via 10.10.0.1 # rotta verso la vlan dell'host-b verso indirizzo router-1
ip route add 192.168.0.0/22 via 10.10.0.1 # rotta generale che raggiunge host-a e host-b verso router-1

# Startup commands for router-2 go here
