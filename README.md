# DNCS-LAB

This repository contains the Vagrant files required to run the virtual lab environment used in the DNCS course.
```


        +----------------------------------------------------------+
        |                                                          |
        |                                                          |enp0s3
        +--+--+                +------------+               +------------+
        |     |                |            |               |            |
        |     |          enp0s3|            |ensp0s9  enp0s9|            |
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
        |  R  |               |enps0s8      |enp0s8                |
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
The third subnet (Hub) inludes the host-c and it must have 81 addresses. So I selected for subnet 192.168.5.0/25 and the mask 255.255.255.128. This subnet has 126 usable addresses and the broadcast address is 192.168.5.127.
The last is a point-to-point subnet (PTP), because it connects only two routers (router-1 and router-2). For this I wanted to use private class A of IP addresses. Which is why I chose 10.10.0.0/30 like subnet address and the mask 255.255.255.252. Then it has only 2 usable addresses and the broadcast address is 10.10.0.3/30.

## Subnets

| Subnet | Subnet address | Prefix | Mask | Usable addresses |
| :---: |  :---: | :---: | :---: | :---: | :---: |
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

Previously I introduced my choice to use tagged VLANs to separate logically host-a and host-b on two different subnets. The two hosts are connected each other by switch, so I had to configure the switch for VLANs. Then I had to assign two different tag to the two different interfaces that are connected to host-a and host-b. The switch's interface enp0s9 has tag=9, instead interface epn0s10 has tag=10. Then last interface enp0s8 is connected to router and it will be a trunk port.
At the end I configured router's interface enp0s8, that is connected to switch, like two different logical interface and for this in the previous IP address table there are two interface (enp0s8.9 and enp0s9.10) with two different IP addresses. Intuitively enpos8.9 belongs to VLAN tag=9 and enp0s9.10 belongs to VLAN tag=10.

| VLAN TAG | Switch Interface | Router Interface | Subnet |
| :---: |  :---: | :---: | :---: | :---: |
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
First line sets up interface enp0s8, then the seconds assigns IP address to interface.

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
With the first line I said to virtual machine it is router, then it will forward packets. Interesting where I divided logically interface enp0s8 into two interfaces enp0s8.9 and enp0s8.10, therefore I assigned them VLAN tag (lines4,5). At the end I gave to two logical interfaces, two different IP addresses, relatives to two different IP subnets (line 8,9).

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
The first line creates switch called switch. Next three lines set interfaces of switch up. Then I added ports to interfaces, instead of IP addresses given that switch works on Data Link level. In the lasts two lines I added a port to interface with a tag, because refers to VLAN.

# Routing

After deciding subnetting and IP addresses, I had to make hosts communicate each other. So I opted for routes which where the most generic possible.

## Script routes

- hostA.sh:
```
ip route add 192.168.0.0/21 via 192.168.1.1
```
Route to 192.168.0.0/21 through 192.168.1.1, that is IP address of router-1's interface enp0s8.9. I chose generic subnet 192.168.0.0/21, because it takes the subnets up to 192.168.7.255. Therefore this router will take subnet 192.168.3.0/23, where there is host-b, and 192.168.5.0/25, where there is host-c.

- hostB.sh:
```
ip route add 192.168.0.0/21 via 192.168.3.1
```
Route to 192.168.0.0/21 through 192.168.3.1, that is IP address of router-1's interface enp0s8.10.

- hostC.sh:
```
ip route add 192.168.0.0/22 via 192.168.5.1
```
Route to 192.168.0.0/22 through 192.168.5.1, that is IP address of router-2's interface enp0s8. I changed generic route, because from host-c I need to reach only host-a and host-b. So 192.168.0.0/22 takes subnet up to 192.168.3.255.

- router1.sh:
```
ip route add 192.168.5.0/25 via 10.10.0.2 
```
Route to 192.168.5.0/25 through 10.10.0.2, that is IP address of router-2's interface enp0s9. From router-1 I have to forward all traffic to router-2, to reach host-c. Then it is enough to use 192.168.5.0/25.

- router2.sh:
```
ip route add 192.168.0.0/22 via 10.10.0.1
```
Route to 192.168.0.0/22 through 10.10.0.1, that is IP address of router-1's interface enp0s8. From router-2 I have to forward all traffic to router-1, to reach host-a and host-b. So that is enough for me generic subnet 192.168.0.0/22.

## Routing tables

- host-a routing table:

| Destination | Prefix | Gateway | Interface |
| :---: |  :---: | :---: | :---: |
| 192.168.0.0 | /21 | 192.168.1.1 | enp0s8 |

- host-b routing table:

| Destination | Prefix | Gateway | Interface |
| :---: |  :---: | :---: | :---: |
| 192.168.0.0 | /21 | 192.168.3.1 | enp0s8 |

- host-c routing table:

| Destination | Prefix | Gateway | Interface |
| :---: |  :---: | :---: | :---: |
| 192.168.0.0 | /22 | 192.168.5.1 | enp0s8 |

- router-1 routing table:

| Destination | Prefix | Gateway | Interface |
| :---: |  :---: | :---: | :---: |
| 192.168.5.0 | /25 | 10.10.0.2 | enp0s9 |

- router-2 routing table:

| Destination | Prefix | Gateway | Interface |
| :---: |  :---: | :---: | :---: |
| 192.168.0.0 | /22 | 10.10.0.2 | enp0s9 |

# Docker

The assignment required to run a simple web server on docker container on host-c. Initially I installed docker on the host-c with the following commands:
```
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce
```

Then I thought to check if there were some container already active and if so stop them and remove them:
```
docker stop $(docker ps –a -q)
docker rm $(docker ps -a -q)
```

Therefore I created a folder where I put my index.html, which is the web page mounted on web server:
```
mkdir /webserver
echo "
<!DOCTYPE html>
<html>
<body>
    <h1>Hello world!</h1>
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

You have to wait some minutes and after you can check the correct creation of six virtual machines with:
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

For the last thing you have to connect to host-a or host-b through ssh connection and then try to curl the web page:
```
~/dncs-lab$ vagrant ssh host-a
vagrant@host-a:~$ curl 192.168.5.2:80
```
You have to see the web page:
```

<!DOCTYPE html>
<html>
<body>
    <h1>Hello world!</h1>
</body>
</html>

```

## Test all net

If you want you can test all net. Firstly you shoul test the connection between host-a and host-b. Simply you have to connect to host-a or host-b through ssh connection and then you have to ping host-b or host-a through their respective IP addresses.
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
Which confirms that host-b is reacheable by host-a. 

Then you can test the viceversa, that is host-a is reacheable by host-b:
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