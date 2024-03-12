# opsforge

Deploy the Cognit Infrastructure on AWS

Infra
- Frontend node
- Provision Engine

# Deploy

The deployment will create it's own VPC, Internet Gateway and subnets with the proper network configuration for the EC2 instances to communicate with each other. It can be done in any region, by default `eu-central-1`.

## Requirements

- terraform
- awscli
- ansible
- a valid ssh key to connect to AWS EC2 instances


Run `./opsforge deploy <opsforge_template>`

Template contents in yaml format

```yaml
:aws:
  :region: "us-east-1"
  :instance_type: t2.medium
  :volume_size: 125
  :ssh_key: "dann1" # your SSH key on AWS on the key list when creating an EC2 instance
  :ssh_key_path: "~/.ssh/id_rsa"
:one:
  :version: 6.8
  :password: "opennebula"
  :ee_token: <your_ee_token>
  :sunstone_port: 9869
  :fireedge_port: 2616
:cognit:
  :engine_port: 1337
```

When finished, you should receive information about how to connect to each instance.

The only mandatory setting is the `ssh_key`. The rest uses default values. You can check those at `./terraform/aws/variables.tf` and `./terraform/one/variables.tf`

# Terminate

Run `./opsforge clean` to destroy the instances from AWS and the generated ansible inventory.


