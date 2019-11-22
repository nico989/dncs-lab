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

ip link set enp0s8 up
ip addr add 192.168.5.2/25 dev enp0s8
ip route add 192.168.0.0/22 via 192.168.5.1 
