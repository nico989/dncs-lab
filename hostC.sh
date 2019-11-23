export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y tcpdump

apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce

mkdir /webserver
echo '
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>DNCS-PROJECT</title>
</head>
<body>
	<h1>Web Page</h1>
	<p>Author: <strong>Vinci Nicolò</strong> Student number: <strong>192425</strong></p>
</body>
</html>
' > /webserver/index.html

docker run --name nico_nginx -v /webserver:/usr/share/nginx/html:ro -p 80:80 -d nginx

# firewall host-c solo catena INPUT
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT  # accetta tutte le connessioni ssh 
iptables -A INPUT -p tcp --dport 80 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT # accetto tutte le connessione http porta 80 (scopo didattico non tocca container)
iptables -A INPUT -p tcp --dport 443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT # accetto tutte le connessione https porta 443 (scopo didattico non tocca container)
iptables -A INPUT -i lo -j ACCEPT # è ciò che un computer utilizza per inoltrare le connessioni di rete a se stesso.
									# Ad esempio, se si esegue ping localhost o ping 127.0.0.1, il server eseguirà il ping stesso utilizzando il loopback
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT # accetta il protocollo icmp (per pingare) in ingresso
iptables -A INPUT -j DROP # regola che dice che se non arrivano pacchetti che rispettano le regole sopra devono essere droppati

# firewall container solo catena input
iptables -I DOCKER-USER -i enp0s8 -j DROP # di default droppa le richieste al docker
iptables -I DOCKER-USER -i enp0s8 -s 192.168.1.0/25 -j ACCEPT # accetta le richieste che vengono dalla rete 192.168.1.0/25
iptables -I DOCKER-USER -i enp0s8 -s 192.168.3.0/25 -j ACCEPT # accetta le richieste che vengono dalla rete 192.168.3.0/25

ip link set enp0s8 up
ip addr add 192.168.5.2/25 dev enp0s8
ip route add 192.168.0.0/22 via 192.168.5.1 
