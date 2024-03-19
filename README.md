# Cognit OpsForge

A Cognitive Serverless Framework for the Cloud-Edge Continuum. With OpsForge you can deploy the Cognit Stack on AWS.

Currently it is ready to automatically deploy the following components:

- OpenNebula Frontend node
- Provision Engine

The missing components that need to be deployed manually are, please follow the links to learn how to install them:

- [AI Orchestrator](https://github.com/SovereignEdgeEU-COGNIT/ai-orchestrator)
- [Serverless Runtime](https://github.com/SovereignEdgeEU-COGNIT/serverless-runtime)

Also you'll need a device client to make use of the infrasrudtucture from your application

- [Device Client Python](https://github.com/SovereignEdgeEU-COGNIT/device-runtime-py)
- [Device Client C](https://github.com/SovereignEdgeEU-COGNIT/device-runtime-c)

The resulting solution deployed in AWS has the following architecture:


# Deploy

The deployment will create it's own VPC, Internet Gateway and subnets with the proper network configuration for the EC2 instances to communicate with each other. It can be done in any region, by default `eu-central-1`.

Requirements

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

Run `./opsforge clean` to
- destroy the instances from AWS
- delete the generated ansible inventory
- delete the logfile


