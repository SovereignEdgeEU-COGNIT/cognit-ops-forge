# COGNIT OpsForge

A Cognitive Serverless Framework for the Cloud-Edge Continuum. With OpsForge you can deploy the COGNIT Stack on AWS.

![Alt text](images/cognit_arch.png)

Currently it is ready to automatically deploy the following components:

- [OpenNebula Frontend node](https://docs.opennebula.io/STS/installation_and_configuration/frontend_installation/overview.html)
- [Provision Engine](https://github.com/SovereignEdgeEU-COGNIT/provisioning-engine)
- [Serverless Runtime](https://github.com/SovereignEdgeEU-COGNIT/serverless-runtime)

The missing components that need to be deployed manually are

- [AI Orchestrator](https://github.com/SovereignEdgeEU-COGNIT/ai-orchestrator). opsforge will create an instance dedicated to the AI Orchestration role. The installation should be done manually for the time being.

Also you'll need a device client to make use of the infrastructure from your application

- [Device Client Python](https://github.com/SovereignEdgeEU-COGNIT/device-runtime-py)
- [Device Client C](https://github.com/SovereignEdgeEU-COGNIT/device-runtime-c)

The resulting solution deployed in AWS has the following architecture:


## How to use

opsforge is a CLI application that runs in your local machine. It will

- setup AWS infrastructure using terraform
- install and configure OpenNebula and the COGNIT services using ansible
- populate the frontend with content required by the COGNIT use cases using the opennebula terraform provider

As such, there are some requirements that need to be met in order to run the program

- [ruby](https://www.ruby-lang.org/en/documentation/installation/)
- [awscli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [terraform](https://developer.hashicorp.com/terraform/install?product_intent=terraform)
- [ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- a valid [ssh key](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) to connect to AWS EC2 instances

### Deploy

The deployment will create it's own VPC, Internet Gateway and subnets with the proper network configuration for the EC2 instances to communicate with each other. It can be done in any region.

Run `./opsforge deploy <opsforge_template>`

Template contents in yaml format

```yaml
:aws:
  :region: "us-east-1" # Defaults to eu-central-1 if missing
  :instance_type: t2.medium # EC2 instance type. Defaults to t2.medium if missing
  :volume_size: 125 # EBS size for EC2 instances. Defaults to 125 if missing
  :ssh_key: <ssh_user> # MANDATORY. your SSH key on AWS on the key list when creating an EC2 instance
  :ssh_key_path: "~/.ssh/id_rsa" # private SSH key path on your local machine. Defaults to ~/.ssh/id_rsa if missing
:one:
  :version: 6.8 # OpenNebula version to install. Defaults to 6.8 if missing
  :password: "opennebula" # password for the oneadmin user. Defaults to opennebula if missing
  :ee_token: <your_ee_token> # OpenNebula Enterprise Edition token. If missing Prometheus integration will not exist.
:cognit:
  :engine_port: 1337 # The port where the Provisioning Engine will be bound to onits instance. Defaults to 1337.
```

When finished, you should receive information about how to connect to each instance. For example

```
Setting up infrastructure on AWS
Infrastructure on AWS has been deployed
Took 60.673237 seconds
Installing Frontend and Provisioning Engine
Frontend and Provisioning Engine installed
Took 402.92903 seconds
Setting up Frontend for Cognit
Frontend ready for Cognit
Took 29.167263 seconds

Infrastructure
{
  "frontend": "ec2-18-210-28-170.compute-1.amazonaws.com",
  "engine": "ec2-44-221-73-110.compute-1.amazonaws.com",
  "ai_orchestrator": "ec2-3-230-155-179.compute-1.amazonaws.com"
}

[INFO] Connect to these hosts with the <ubuntu> user using the provided ssh key'
[INFO] Logs available at ./opsforge.log'
[POSTINSTALL] Take a look at AWS cluster provisioning in order to setup your KVM cluster
https://docs.opennebula.org/stable/provision_clusters/providers/aws_provider.html#aws-provider
[POSTINSTALL] After that, take a look at the Energy Consumption extension
https://github.com/SovereignEdgeEU-COGNIT/opennebula-extensions?tab=readme-ov-file#scaphandre-extension
```

##  Terminate

Once you no longer need the COGNIT deployment, you can easily delete the provisioned resources by issuing `./opsforge clean`.

For example

```
./opsforge clean
Destroying resources created on AWS
COGNIT deployment succesfully destroyed
```


