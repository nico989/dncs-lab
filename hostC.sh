export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y tcpdump

#install docker
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce

ip link set enp0s8 up
ip addr add 192.168.32.64/25 dev enp0s8
ip route add 10.10.128.0/23 via 192.168.32.1 #rotta per raggiungere vlan dell'host-a
ip route add 172.16.64.0/23 via 192.168.32.1 #rotta per raggiungere vlan dell'host-b


docker stop $(docker ps –a -q) #stop container già presenti
docker rm  $(docker ps -a -q) #remove container già presenti

docker container run --name my-nginx -p 8080:80 -d nginx #--rm e poi devo stopparlo per autoclean container

# Startup commands for host-c go here