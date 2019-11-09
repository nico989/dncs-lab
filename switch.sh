export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y tcpdump
apt-get install -y openvswitch-common openvswitch-switch apt-transport-https ca-certificates curl software-properties-common
ovs-vsctl add-br switch
ip link set enp0s8 up
ip link set enp0s9 up
ip link set enp0s10 up
ovs-vsctl add-port switch enp0s8
ovs-vsctl add-port switch enp0s9 tag=9
ovs-vsctl add-port switch enp0s10 tag=10
