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

| VLAN ID | Switch Interface | Router Interface | Subnet |
| :---: |  :---: | :---: | :---: | :---: |
| 9 | enp0s9 | enp0s8.9 | 192.168.1.0/23 |
| 10 | enp0s10 | enp0s8.10 | 192.168.3.0/23 |

| Switch Interface | Tag | Connected Device |
| :---: |  :---: | :---: |
| enp0s8 | / | router-1 |
| enp0s9 | 9 | host-a |
| enp0s10 | 10 | host-b |