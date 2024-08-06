# Multi Edge Cluster private Network

This is the topology of a scenario where the Serverless Runtime instances are run spread across multiple edge clusters. Each each cluster is a group of KVM nodes and is geographically separated from other edge clusters.

The Serverless Runtimes Virtual Machines (SR) will run using an overlay network using the VXLAN driver on EVPN mode. This overlay network creates an L2 network for VMs to run. They'll be able to reach each other regardless of the KVM node where they are running. They will also be able to live Migrate from a KVM node to another while keeping the same IP address on the L2 overlay network.

Access to these instances can be provided with a Virtual Router (VR), provided this VR instance has a public IP4 address provided by the Edge Cluster provision. This VR will have two network interfaces (NICs). The first NIC will use a lease of the public IP virtual network created when provisioning edge clusters. This public network will have at most 5 public IPs, one of which will be used for the VR. The rest can be used to provide SDNAT access to the SR instances.

```
          EVPN VXLAN (private)
         +-----------------+
         |                 |
    +-------------+ +-------------+
    |     EC1     | |     EC2     |
    +-------------+ +-------------+
    |  KVM1 KVM2  | |  KVM1 KVM2  |
    +-------------+ +-------------+
    | public ipv4 | | public ipv4 |
    +-------------+ +-------------+
            |                |
            |                |
    +---------------------------+
    | Public Internet           |
    |                           |
    | +-----------------------+ |
    | | WireGuard Subnet      | |
    | |                       | |
    | | +-------------------+ | |
    | | | EVPN subnet       | | |
    | | | VXLAN (private)   | | |
    | | +-------------------+ | |
    | | | SR1 | | SR2 | SRN | | |
    | | +-------------------+ | |
    | +-----------------------+ |
    +---------------------------+
            |
            |
            |
            |
       +-------------+
       | public ipv4 |
    +-------------------+ +----------------+ +--------------+-------------+
    | Ingress Controller| |  Cloud-Edge    | | Provisioning | Ai          |
    |                   | |    Manager     | | Engine       | Orchestrator|
    | 10.0.1.x          | |   10.0.1.x     | | 10.0.1.x     | 10.0.1.x    |
    +-------------------+ +----------------+ +--------------+-------------+
             |                 |                  |              |
             +-----------------+------------------+--------------+
                                10.0.1.0/24 - Control Subnet
```

## Preparation

- Run opsforge to provision the control plane
- Edge clusters should be created with [oneprovision](https://docs.opennebula.io/6.8/provision_clusters/edge_clusters/overview.html)
- A wireguard VPN should be setup between the edge clusters and the ingress controller instance
  - this VPN results in the creation of the wg0 interface. This interface is used as PHYDEV for the EVPN VXLAN private virtual network.
- The ansible roles `frr.common` and `frr.evpn` from [one-deploy](https://github.com/OpenNebula/one-deploy) will be used to setup the BGP routers and route reflectors.
  - oneprovision already sets up [frr](https://frrouting.org/) on the KVM hosts, but these are setup to act as routers and router reflectos for their private subnet on their VPC.
  - these ansible roles will make it so the KVM nodes are just BGP routers and the Ingress Controller will act as reflector. This BGP traffic will be sent over the wireguard VPN.
  - once the KVM hosts from the edge cluster are created, ssh access is granted only to the onadmin user on the frontend using the key `/var/lib/one/.ssh-oneprovision/id_rsa`. To avoid complicated jumps `ansible -> ingress -> one_frontend -> edge_kvm`, simply allow root access to the ansible controller on the KVM hosts since these have public IPs.
- AWS KVM hosts from oneprovision should have the following rule removed to allow QEMU live migration traffic
  -  `iptables -D INPUT -i enp125s0 -j REJECT --reject-with icmp-host-prohibited`
- Define a virtual network using VXLAN on EVPN mode
  - The first lease of this network will be claimed by the VR
  - The CONTEXT section will use this first lease IP address as GATEWAY
  - The MTU should be set considering the VXLAN + the WireGuard overhead. For example, 1370.
- Create an OpenNebula cluster with
  - Every KVM node from oneprovision
  - The public networks from each Edge Cluster
  - The private EVPN VXLAN network
  - The SSH image and system datastores
- Virtual Router Instance
  - Import form marketplace
  - Instantiate on a KVM host
    - eth0 will use a public IP from the Elastic IP public virtual network created by oneprovision
    - eth1 will be the first lease from the EVPN VXLAN virtual network
    - SDNAT should be enabled with eth0 and eth1 as interfaces

## Practical scenario

Both of these KVM nodes are running on AWS, but in different regions

KVM 1
  - region: london
  - public IP: 18.134.246.200

KVM 2
  - region: north california
  - public IP: 18.144.25.41

Ansible setp to setup frr

Inventory

```yaml
---
all:
  vars:
    evpn_if: wg0 # wireguard interface
    ansible_user: root
    ensure_keys_for: [root]
    one_pass: opennebula
    one_version: '6.8'
    features: { evpn: true }
    ds: { mode: ssh }
    vn:
      private_evpn-vxlan:
        managed: true
        template:
          VN_MAD: vxlan
          VXLAN_MODE: evpn
          IP_LINK_CONF: nolearning=
          PHYDEV: wg0
          AUTOMATIC_VLAN_ID: "YES"
          GUEST_MTU: 1370
          AR:
            TYPE: IP4
            IP: 172.17.2.1
            SIZE: 20
          NETWORK_ADDRESS: 172.17.2.0
          NETWORK_MASK: 255.255.255.0
          GATEWAY: 172.17.2.1
          DNS: 1.1.1.1

router:
  hosts:
    ingress:
      ansible_host: 13.58.199.98

frontend:
  hosts:
    fe1:
      ansible_host: 10.0.1.87
      ansible_ssh_common_args: '-o ProxyJump=root@ec2-13-58-199-98.us-east-2.compute.amazonaws.com'

node:
  hosts:
    kvm_london:
      ansible_host: 18.134.246.200

    kvm_ncalifornia:
      ansible_host: 18.144.25.41

```

Playbook

```yaml
---
- name: Gather facts
  hosts: all
  gather_facts: true
- name: Setup EVPN infra
  hosts: router:node
  roles:
    - role: opennebula.deploy.helper.facts
    - role: opennebula.deploy.frr.common
    - role: opennebula.deploy.frr.evpn

```

Example wireguard configuration

Ingress instance

```
[Interface]
PrivateKey = <Ingress private key>
Address = 192.168.0.1/24
ListenPort = 51820
MTU = 1420

[Peer]
PublicKey = <KVM 1 public key >
AllowedIPs = 192.168.0.2/32
Endpoint = 18.134.246.200:51820

[Peer]
PublicKey = <KVM 2 public key>
AllowedIPs = 192.168.0.3/32
Endpoint = 18.144.25.41:51820
```

KVM1

```
[Interface]
PrivateKey = <KVM 1 private key>
Address = 192.168.0.2/24
ListenPort = 51820
MTU = 1420

[Peer]
PublicKey = <Ingress Public Key>
AllowedIPs = 192.168.0.1/32
Endpoint = 13.58.199.98:51820

[Peer]
PublicKey = <KVM 2 public key>
AllowedIPs = 192.168.0.3/32
Endpoint = 18.144.25.41:51820
```

KVM2

```
PrivateKey = <KVM2 2 private key>
Address = 192.168.0.3/24
ListenPort = 51820
MTU = 1420

[Peer]
PublicKey = <Ingress Public Key>
AllowedIPs = 192.168.0.1/32
Endpoint = 13.58.199.98:51820

[Peer]
PublicKey = <KVM 1 public key >
AllowedIPs = 192.168.0.2/32
Endpoint = 18.134.246.200:51820
```
