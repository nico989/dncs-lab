# DNCS-LAB

This repository contains the Vagrant files required to run the virtual lab environment used in the DNCS course.
```


        +----------------------------------------------------------+
        |                                                          |
        |                                                          |enp0s3
        +--+--+                +------------+               +------------+
        |     |                |            |               |            |
        |     |          enp0s3|            |enp0s9   enp0s9|            |
        |     +----------------+  router-1  +---------------+  router-2  |
        |     |                |            |               |            |
        |     |                |            |               |            |
        |  M  |                +------------+               +------------+
        |  A  |                      |enp0s8                       |enp0s8
        |  N  |                      |                             |
        |  A  |                      |                             |enp0s8
        |  G  |                      |                       +-----+----+
        |  E  |                      |enp0s8                 |          |
        |  M  |            +-------------------+             |          |
        |  E  |      enp0s3|                   |             |  host-c  |
        |  N  +------------+      SWITCH       |             |          |
        |  T  |            |                   |             |          |
        |     |            +-------------------+             +----------+
        |  V  |               |enp0s9       |enp0s10               |enp0s3
        |  A  |               |             |                      |
        |  G  |               |             |                      |
        |  R  |               |enp0s8       |enp0s8                |
        |  A  |        +----------+     +----------+               |
        |  N  |        |          |     |          |               |
        |  T  |  enp0s3|          |     |          |               |
        |     +--------+  host-a  |     |  host-b  |               |
        |     |        |          |     |          |               |
        |     |        |          |     |          |               |
        ++-+--+        +----------+     +----------+               |
        | |                              |enp0s3                   |
        | |                              |                         |
        | +------------------------------+                         |
        |                                                          |
        |                                                          |
        +----------------------------------------------------------+



```

# Requirements
 - Python 3
 - 10GB disk storage
 - 2GB free RAM
 - Virtualbox
 - Vagrant (https://www.vagrantup.com)
 - Internet

# How-to
 - Install Virtualbox and Vagrant
 - Clone this repository
`git clone https://github.com/dustnic/dncs-lab`
 - You should be able to launch the lab from within the cloned repo folder.
```
cd dncs-lab
[~/dncs-lab] vagrant up
```
Once you launch the vagrant script, it may take a while for the entire topology to become available.
 - Verify the status of the 4 VMs
 ```
 [dncs-lab]$ vagrant status                                                                                                                                                                
Current machine states:

router                    running (virtualbox)
switch                    running (virtualbox)
host-a                    running (virtualbox)
host-b                    running (virtualbox)
```
- Once all the VMs are running verify you can log into all of them:
`vagrant ssh router`
`vagrant ssh switch`
`vagrant ssh host-a`
`vagrant ssh host-b`
`vagrant ssh host-c`

# Assignment
This section describes the assignment, its requirements and the tasks the student has to complete.
The assignment consists in a simple piece of design work that students have to carry out to satisfy the requirements described below.
The assignment deliverable consists of a Github repository containing:
- the code necessary for the infrastructure to be replicated and instantiated
- an updated README.md file where design decisions and experimental results are illustrated
- an updated answers.yml file containing the details of 

## Design Requirements
- Hosts 1-a and 1-b are in two subnets (*Hosts-A* and *Hosts-B*) that must be able to scale up to respectively 349 and 339 usable addresses
- Host 2-c is in a subnet (*Hub*) that needs to accommodate up to 81 usable addresses
- Host 2-c must run a docker image (dustnic82/nginx-test) which implements a web-server that must be reachable from Host-1-a and Host-1-b
- No dynamic routing can be used
- Routes must be as generic as possible
- The lab setup must be portable and executed just by launching the `vagrant up` command

## Tasks
- Fork the Github repository: https://github.com/dustnic/dncs-lab
- Clone the repository
- Run the initiator script (dncs-init). The script generates a custom `answers.yml` file and updates the Readme.md file with specific details automatically generated by the script itself.
  This can be done just once in case the work is being carried out by a group of (<=2) engineers, using the name of the 'squad lead'. 
- Implement the design by integrating the necessary commands into the VM startup scripts (create more if necessary)
- Modify the Vagrantfile (if necessary)
- Document the design by expanding this readme file
- Fill the `answers.yml` file where required (make sure that is committed and pushed to your repository)
- Commit the changes and push to your own repository
- Notify the examiner that work is complete specifying the Github repository, First Name, Last Name and Matriculation number. This needs to happen at least 7 days prior an exam registration date.

# Notes and References
- https://rogerdudler.github.io/git-guide/
- http://therandomsecurityguy.com/openvswitch-cheat-sheet/
- https://www.cyberciti.biz/faq/howto-linux-configuring-default-route-with-ipcommand/
- https://www.vagrantup.com/intro/getting-started/


# Design

# IP subnetting and IP address
First of all I decided the CIDR (Class Inter-Domain Routing), that is how to assign IP addresses to hosts and routers and how to define routes of them. The topology is divided into four subnet. I preferred to use private class C of IP addresses. The first subnet (Hosts-A) is a tagged VLAN and it includes the host-a. It must have 349 addresses, so I chose the subnet 192.168.1.0/23 and the mask 255.255.254.0. Therefore the subnet has 510 addresses available and broadcast address is 192.168.2.255/23. The next subnet (Hosts-B) is another tagged VLAN and it includes the host-b. Given that it must have 339 addresses I opted for subnet 192.168.3.0/23 with a mask 255.255.254.0. So the subnet has 510 addresses available, like the previous subnet, and broadcast address is 192.168.4.255/23. Despite host-a and host-b are connected each other through the same switch, I had to do two tagged VLANs because the assignment required that they were in two different subnets.
The third subnet (Hub) includes the host-c and it must have 81 addresses. So I selected the subnet 192.168.5.0/25 and the mask 255.255.255.128. This subnet has 126 usable addresses and the broadcast address is 192.168.5.127.
The last is a point-to-point subnet (PTP), because it connects only two routers (router-1 and router-2). For this I wanted to use private class A of IP addresses. Which is why I chose 10.10.0.0/30 like subnet address and the mask 255.255.255.252. Then it has only 2 usable addresses and the broadcast address is 10.10.0.3/30.

## Subnets

| Subnet | Subnet address | Prefix | Mask | Usable addresses |
| :---: |  :---: | :---: | :---: | :---: |
| Hosts-A | 192.168.1.0 | /23 | 255.255.254.0 | 510 |
| Hosts-B | 192.168.3.0 | /23 | 255.255.254.0 | 510 |
| Hub | 192.168.5.0 | /25 | 255.255.255.128 | 126 |
| PTP | 10.10.0.0 | /30 | 255.255.255.252 | 2 |

## IP address

| Device | IP address | Interface | Tag |
| :---: |  :---: | :---: | :---: |
| host-a | 192.168.1.2/23 | enp0s8 | 9| 
| host-b | 192.168.3.2/23 | enp0s8 | 10| 
| host-c | 192.168.5.2/25 | enp0s8 | / |
| router-1 | 192.168.1.1/23| enp0s8.9 | / | 
| router-1 | 192.168.3.1/23 | enp0s8.10 | / |
| router-1 | 10.10.0.1/30| enp0s9 | / |
| router-2 | 192.168.5.1/25 | enp0s8 | / |
| router-2 | 10.10.0.0.2/30 | enp0s9 | / |

## VLANs

Previously I introduced my choice to use tagged VLANs to separate logically host-a and host-b on two different subnets. The two hosts are connected each other by switch, so I had to configure the switch for VLANs. Then I had to assign two different tags to the two different interfaces that are connected to host-a and host-b. The switch's interface enp0s9 has tag=9, instead interface enp0s10 has tag=10. Then last interface enp0s8 is connected to router and it will be a trunk port.
At the end I configured router's interface enp0s8, that is connected to switch, like two different logical interfaces and for this in the previous IP addresses table there are two interface (enp0s8.9 and enp0s9.10) with two different IP addresses. Intuitively enpos8.9 belongs to VLAN tag=9 and enp0s9.10 belongs to VLAN tag=10.

| VLAN TAG | Switch Interface | Router Interface | Subnet |
| :---: |  :---: | :---: | :---: |
| 9 | enp0s9 | enp0s8.9 | 192.168.1.0/23 |
| 10 | enp0s10 | enp0s8.10 | 192.168.3.0/23 |

| Switch Interface | Tag | Connected Device |
| :---: |  :---: | :---: |
| enp0s8 | / | router-1 |
| enp0s9 | 9 | host-a |
| enp0s10 | 10 | host-b |

## Script IP address and switch 

In Vagrantfile there is a line of code:
```
[VirtualMachine].vm.provision "shell", path: "[NameFile].sh"
```
It allows me to run scripts, as root, saved in [NameFile].sh, when [VirtualMachine] starts. So I can set immediately IP adresses, routes and other things.

To set up interfaces and to assign IP addresses or to add ports to switch:

- In hostA.sh:
```
ip link set enp0s8 up
ip addr add 192.168.1.2/23 dev enp0s8
```
In first line I set up interface enp0s8, then in the second I assign IP address to interface.

- In hostB.sh:
```
ip link set enp0s8 up
ip addr add 192.168.3.2/23 dev enp0s8
```

- In hostC.sh:
```
ip link set enp0s8 up
ip addr add 192.168.5.2/25 dev enp0s8
```

- In router1.sh:
```
sysctl net.ipv4.ip_forward=1
ip link set enp0s9 up
ip link set enp0s8 up
ip link add link enp0s8 name enp0s8.9 type vlan id 9
ip link add link enp0s8 name enp0s8.10 type vlan id 10
ip link set enp0s8.9 up
ip link set enp0s8.10 up
ip addr add 192.168.1.1/23 dev enp0s8.9
ip addr add 192.168.3.1/23 dev enp0s8.10
ip addr add 10.10.0.1/30 dev enp0s9
```
With the first line I said to virtual machine that it is router, then it must forward packets. Interesting where I divided logically interface enp0s8 into two interfaces enp0s8.9 and enp0s8.10, therefore I assigned them VLAN tag (lines 4,5). At the end I gave to two logical interfaces, two different IP addresses, relatives to two different IP subnets (line 8,9).

- In router2.sh:
```
sysctl net.ipv4.ip_forward=1
ip link set enp0s9 up
ip link set enp0s8 up
ip addr add 10.10.0.2/30 dev enp0s9
ip addr add 192.168.5.1/25  dev enp0s8
```

- In switch.sh:
```
ovs-vsctl add-br switch
ip link set enp0s8 up
ip link set enp0s9 up
ip link set enp0s10 up
ovs-vsctl add-port switch enp0s8
ovs-vsctl add-port switch enp0s9 tag=9
ovs-vsctl add-port switch enp0s10 tag=10
```
The first line creates switch called switch. In the next three lines I set interfaces of switch up. Then I added ports to interfaces, instead of IP addresses given that switch works on Data Link level. In the last two lines I added ports to interfaces with their respective tags, because they refer to VLAN.

# Routing

After deciding subnetting and IP addresses, I had to make hosts communicate each other. So I opted for routes that are as generic as possible.

## Script routes

- hostA.sh:
```
ip route add 192.168.0.0/21 via 192.168.1.1
```
Route to 192.168.0.0/21 through 192.168.1.1, that is IP address of router-1's interface enp0s8.9. I chose generic subnet 192.168.0.0/21, because it takes the subnets up to 192.168.7.255. Therefore I can reach the subnet 192.168.3.0/23, where the host-b is located, and 192.168.5.0/25, where the host-c is located, with this route.

- hostB.sh:
```
ip route add 192.168.0.0/21 via 192.168.3.1
```
Route to 192.168.0.0/21 through 192.168.3.1, that it is IP address of router-1's interface enp0s8.10.

- hostC.sh:
```
ip route add 192.168.0.0/22 via 192.168.5.1
```
Route to 192.168.0.0/22 through 192.168.5.1, that it is IP address of router-2's interface enp0s8. I changed generic route, because from host-c I need to reach only host-a and host-b. So 192.168.0.0/22 takes the subnets up to 192.168.3.255.

- router1.sh:
```
ip route add 192.168.5.0/25 via 10.10.0.2 
```
Route to 192.168.5.0/25 through 10.10.0.2, that it is IP address of router-2's interface enp0s9. I have to forward all traffic to router-2 to reach host-c from router-1. Then it is enough to use 192.168.5.0/25.

- router2.sh:
```
ip route add 192.168.0.0/22 via 10.10.0.1
```
Route to 192.168.0.0/22 through 10.10.0.1, that it is IP address of router-1's interface enp0s8. I have to forward all traffic to router-1 to reach host-a and host-b from router-2. It is enough for me the generic subnet 192.168.0.0/22.

## Routing tables

- host-a routing table:

| Destination | Gateway | Genmask | Interface |
| :---: |  :---: | :---: | :---: |
| 192.168.0.0 | 0.0.0.0 | 255.255.254.0 | enp0s8 |
| 192.168.0.0 | 192.168.1.1 | 255.255.248.0 | enp0s8 |

- host-b routing table:

| Destination | Gateway | Genmask | Interface |
| :---: |  :---: | :---: | :---: |
| 192.168.2.0 | 0.0.0.0 | 255.255.254.0 | enp0s8 |
| 192.168.0.0 | 192.168.3.1 | 255.255.248.0 | enp0s8 | 

- host-c routing table:

| Destination | Gateway | Genmask | Interface |
| :---: |  :---: | :---: | :---: |
| 192.168.5.0 | 0.0.0.0 | 255.255.255.128 | enp0s8 |
| 192.168.0.0 | 192.168.5.1 | 255.255.252.0 | enp0s8 | 

- router-1 routing table:

| Destination | Gateway | Genmask | Interface |
| :---: |  :---: | :---: | :---: |
| 10.10.0.0 | 0.0.0.0 | 255.255.255.252 | enp0s9 |
| 192.168.0.0 | 0.0.0.0 | 255.255.254.0 | enp0s8.9 |
| 192.168.2.0 | 0.0.0.0 | 255.255.254.0 | enp0s8.10 |
| 192.168.5.0 | 10.10.0.2 | 255.255.255.128 | enp0s9 |

- router-2 routing table:

| Destination | Gateway | Genmask | Interface |
| :---: |  :---: | :---: | :---: |
| 10.10.0.0 | 0.0.0.0 | 255.255.255.252 | enp0s9 |
| 192.168.5.0 | 0.0.0.0 | 255.255.255.128 | enp0s8 |
| 192.168.0.0 | 10.10.0.1 | 255.255.252.0 | enp0s9 |

# Docker

The assignment required to run a simple web server on docker container on host-c. Initially I installed docker on the host-c with the following commands:
```
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce
```

Therefore I created a folder where I put my index.html, where inside is the web page mounted on web server:
```
mkdir /webserver
echo "
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
" > /webserver/index.html
```

At the end I ran the docker container using nginx like docker image. Nginx acts as web server and the external port is 80:
```
docker run --name nico_nginx -v /webserver:/usr/share/nginx/html:ro -p 80:80 -d nginx
```

You can check if container is running:
```
vagrant@host-c:~$ sudo docker container ls
```

If container is running correctly, you will see:
```
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                NAMES
bffa945debbb        nginx               "nginx -g 'daemon of…"   29 minutes ago      Up 29 minutes       0.0.0.0:80->80/tcp   nico_nginx
```

In future if you want to kill the container, you have to stop it and then kill it with follow commands:
```
docker stop $(docker ps –a -q)
docker rm $(docker ps -a -q)
```

# Firewall

To have a minimum of protection on the host-c and on the container, I tried to make a small firewall. So I added some rules to decide who can access to host-c and the container. I used the command ``` iptables ``` as root to create my custom rules. I made rules to choose which protocols and services could reach the host-c and separately I added rules to manage who could access to container. This because the container is an isolated entity. If you want to see the rules that already exist, you have to type:
```
vagrant@host-c:~$ sudo iptables -L
```
By default there are not custom rules and you should see this:
```
Chain INPUT (policy ACCEPT)
target     prot opt source               destination

Chain FORWARD (policy DROP)
target     prot opt source               destination
DOCKER-USER  all  --  anywhere             anywhere
DOCKER-ISOLATION-STAGE-1  all  --  anywhere             anywhere
ACCEPT     all  --  anywhere             anywhere             ctstate RELATED,ESTABLISHED
DOCKER     all  --  anywhere             anywhere
ACCEPT     all  --  anywhere             anywhere
ACCEPT     all  --  anywhere             anywhere

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination

Chain DOCKER (1 references)
target     prot opt source               destination
ACCEPT     tcp  --  anywhere             172.17.0.2           tcp dpt:http

Chain DOCKER-ISOLATION-STAGE-1 (1 references)
target     prot opt source               destination
DOCKER-ISOLATION-STAGE-2  all  --  anywhere             anywhere
RETURN     all  --  anywhere             anywhere

Chain DOCKER-ISOLATION-STAGE-2 (1 references)
target     prot opt source               destination
DROP       all  --  anywhere             anywhere
RETURN     all  --  anywhere             anywhere

Chain DOCKER-USER (1 references)
target     prot opt source               destination
RETURN     all  --  anywhere             anywhere
```
You can observe three chains: the input chain, it manages packets in input, the output chain, it manages packets in output, and the chain forward, it is for packets that are forwarded through the system. The other chains refer to the container. I added rules for the input chain to allow me to decide which protocols or services could reach the host-c. Then I made some rules for the docker-user chain to decide who could reach the container and consequently the web server.

Rules added in the input chain:

- Allow all incoming SSH:
```
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
```

- Allow all incoming HTTP:
```
iptables -A INPUT -p tcp --dport 80 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
```

- Allow all incoming HTTPS:
```
iptables -A INPUT -p tcp --dport 443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
```

- Allow loopback connections:
```
iptables -A INPUT -i lo -j ACCEPT
```

- Allow ICMP echo-request (for input ping):
```
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
```

- Allow ICMP echo-reply (to reply echo-request):
```
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
```

- Drop all packets that do not match any of the rules described above:
```
iptables -A INPUT -j DROP
```
After adding these rules, if you type ```iptables -L```, you should see in the input chain:
```
Chain INPUT (policy ACCEPT)
target     prot opt source               destination
ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:ssh ctstate NEW,ESTABLISHED  
ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:http ctstate NEW,ESTABLISHED 
ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:https ctstate NEW,ESTABLISHED
ACCEPT     all  --  anywhere             anywhere
ACCEPT     icmp --  anywhere             anywhere             icmp echo-request
ACCEPT     icmp --  anywhere             anywhere             icmp echo-reply
DROP       all  --  anywhere             anywhere
```
So the policy remains ACCEPT, but with last rules I drop all packets that do not match any of the rules.

Now I have to add rules to manage in docker-user chain to manage the container:

- Drop all the other requests:
```
iptables -I DOCKER-USER -i enp0s8 -j DROP
```

- Allow subnet 192.168.1.0/25 to reach the container:
```
iptables -I DOCKER-USER -i enp0s8 -s 192.168.1.0/25 -j ACCEPT
```

- Allow subnet 192.168.3.0/25 to reach the container:
```
iptables -I DOCKER-USER -i enp0s8 -s 192.168.3.0/25 -j ACCEPT
```
Then if you type ```iptables -L```, you should see in the docker-user chain:
```
Chain DOCKER-USER (1 references)
target     prot opt source               destination
ACCEPT     all  --  192.168.3.0/25       anywhere
ACCEPT     all  --  192.168.1.0/25       anywhere
DROP       all  --  anywhere             anywhere
RETURN     all  --  anywhere             anywhere
```
So the web server mounted on the container will be reachable only by the two subnets. The order of the rules is important. The two drop rules must be at the bottom of the chain.

# Test

First of all you have to install Vagrant and Virtual Machine. Then you can clone my repository:
```
git clone https://github.com/nico989/dncs-lab
```

Then you should come in the folder dncs-lab and run vagrant up:
```
cd dncs-lab
~/dncs-lab$ vagrant up
```

You wait some minutes and after you can check the correct creation of six virtual machines with:
```
~/dncs-lab$ vagrant status
```

If everything went well, you will see:
```
Current machine states:

router-1                  running (virtualbox)
router-2                  running (virtualbox)
switch                    running (virtualbox)
host-a                    running (virtualbox)
host-b                    running (virtualbox)
host-c                    running (virtualbox)
```

For the last thing you connect to host-a or host-b through ssh connection and then try to curl the web page:
```
~/dncs-lab$ vagrant ssh host-a
vagrant@host-a:~$ curl 192.168.5.2:80
```
You should see the web page:
```

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

```

## Test all net

If you want you can test all net. Firstly you should test the connection between host-a and host-b. Simply you connect to host-a or host-b through ssh connection and then you ping host-b or host-a through their respective IP addresses.
```
~/dncs-lab$ vagrant ssh host-a
vagrant@host-a:~$ ping 192.168.3.2
```
As answer you should have:
```
PING 192.168.3.2 (192.168.3.2) 56(84) bytes of data.
64 bytes from 192.168.3.2: icmp_seq=1 ttl=63 time=1.38 ms
64 bytes from 192.168.3.2: icmp_seq=2 ttl=63 time=2.43 ms
64 bytes from 192.168.3.2: icmp_seq=3 ttl=63 time=0.961 ms
64 bytes from 192.168.3.2: icmp_seq=4 ttl=63 time=2.70 ms
64 bytes from 192.168.3.2: icmp_seq=5 ttl=63 time=3.96 ms
--- 192.168.3.2 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4006ms
rtt min/avg/max/mdev = 0.961/2.289/3.965/1.056 ms
```
Which it confirms that host-b is reacheable by host-a. 

Then you can test that host-a is reacheable by host-b:
```
~/dncs-lab$ vagrant ssh host-b
vagrant@host-b:~$ ping 192.168.1.2
PING 192.168.1.2 (192.168.1.2) 56(84) bytes of data.
64 bytes from 192.168.1.2: icmp_seq=1 ttl=63 time=1.30 ms
64 bytes from 192.168.1.2: icmp_seq=2 ttl=63 time=2.88 ms
64 bytes from 192.168.1.2: icmp_seq=3 ttl=63 time=1.54 ms
64 bytes from 192.168.1.2: icmp_seq=4 ttl=63 time=2.74 ms
64 bytes from 192.168.1.2: icmp_seq=5 ttl=63 time=2.65 ms
--- 192.168.1.2 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4006ms
rtt min/avg/max/mdev = 1.302/2.223/2.880/0.664 ms
```

Therefore you should test if host-c can reach host-b or host-a, always in the same way before. This is to test if host-c can reach host-a:
```
~/dncs-lab$ vagrant ssh host-c
vagrant@host-c:~$ ping 192.168.1.2
PING 192.168.1.2 (192.168.1.2) 56(84) bytes of data.     
64 bytes from 192.168.1.2: icmp_seq=1 ttl=62 time=1.23 ms
64 bytes from 192.168.1.2: icmp_seq=2 ttl=62 time=3.08 ms
64 bytes from 192.168.1.2: icmp_seq=3 ttl=62 time=3.18 ms
64 bytes from 192.168.1.2: icmp_seq=4 ttl=62 time=3.11 ms
--- 192.168.1.2 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3008ms
rtt min/avg/max/mdev = 1.234/2.655/3.184/0.822 ms
```

Instead this is to test if host-c can reach host-b:
```
~/dncs-lab$ vagrant ssh host-c
vagrant@host-c:~$ ping 192.168.3.2
PING 192.168.3.2 (192.168.3.2) 56(84) bytes of data.     
64 bytes from 192.168.3.2: icmp_seq=1 ttl=62 time=1.25 ms
64 bytes from 192.168.3.2: icmp_seq=2 ttl=62 time=2.90 ms
64 bytes from 192.168.3.2: icmp_seq=3 ttl=62 time=3.20 ms
64 bytes from 192.168.3.2: icmp_seq=4 ttl=62 time=2.87 ms
--- 192.168.3.2 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3010ms
rtt min/avg/max/mdev = 1.256/2.559/3.204/0.766 ms
```
