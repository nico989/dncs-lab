export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y tcpdump

# install docker
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce

docker stop $(docker ps –a -q) # stop container già presenti
docker rm $(docker ps -a -q) # remove container già presenti

mkdir /webserver
echo "
<!DOCTYPE html>
<html>
<body>
    <h1>Hello world!</h1>
</body>
</html>
" > /webserver/index.html

docker run --name nico_nginx -v /webserver:/usr/share/nginx/html:ro -p 80:80 -d nginx

ip link set enp0s8 up
ip addr add 192.168.5.2/25 dev enp0s8
# ip route add 10.10.128.0/23 via 192.168.32.1 # rotta per raggiungere vlan dell'host-a
# ip route add 172.16.64.0/23 via 192.168.32.1 # rotta per raggiungere vlan dell'host-b
ip route add 192.168.0.0/22 via 192.168.5.1 # rotta generale per raggiungere host-a e host-b

# Startup commands for host-c go here
