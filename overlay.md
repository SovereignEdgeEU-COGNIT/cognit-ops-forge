
              EVPN VXLAN
         +-----------------+
         |                 |
    +-------------+ +-------------+
    |     KVM1    | |     KVM2    |
    +-------------+ +-------------+
    | public ipv4 | | public ipv4 |
    +-------------+ +-------------+
            |                |
            |                |
    +---------------+        |
    |Public Internet|--------+
    +---------------+
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

# Env Prep

## oneprovision
- Edge Cluster1 can be deployed with 2 Elastic IP
- Edge Cluster2 can be deployed with 2 Elastic IP
- allow root access to KVM1 with `ssh -i /var/lib/one/.ssh-oneprovision/id_rsa ubuntu@KVM1`
- allow root access to KVM2 `ssh -i /var/lib/one/.ssh-oneprovision/id_rsa ubuntu@KVM2`
- check hosts are ON

KVM 1
  - region: london
  - public IP: 18.134.246.200
  - private IP: 10.0.0.4

KVM 2
  - region: north california
  - public IP: 18.144.25.41
  - private IP: 10.0.0.4

## Create OpenNebula multi edge cluster with
- create EVPN VXLAN private vnet using edge cluster vnet template as a reference
  - set Gateway to 1st IP lease (will be used by VR)
- ssh image and system datastores 1 and 0
- KVM1 and KVM2
- EVPN VXLAN vnet
- KVM1 Elastic IP public vnet
- KVM2 Elastic IP public vnet

# Setup BGP

- Backup provision config `/etc/frr`

Combination 1
- router on KVM1
- router on KVM2
- reflector on Ingress Controller

Combination 2
- router and reflector on KVM1
- router and reflector on KVM2


## Import from marketapp
- VR
- Alpine
- Instantiate VR to KVM 1
  - KVM1 Elastic IP public vnet
  - EVPN VXLAN vnet
- Instantiate alpine to KVM 1
  - EVPN VXLAN vnet
- Instantiate alpine to KVM 2
  - EVPN VXLAN vnet

# Tests

## Overlay network works across multi edge cluster
- VR has public IP - Elastic IP
- VR has private IP - EVPN VXLAN Gateway Address
- VR can reach private IP of VM on KVM1
- VR can reach private IP of VM on KVM2

# VM can migrate live between edge clusters with overlay network
- VM can `migrate --live` from KVM1 to KVM2
- VM can `migrate --live` from KVM2 to KVM1
- Caveats
  - PHYDEV name across edge cluster
  - 6.8.3 live migration changed

## VR SDNAT works across multi edge cluster
- VR SDNAT to VM 1
- VR SDNAT to VM 2

