<!--
  Copyright (C) 2023 Cambridge Epigenetix. All rights reserved.
-->
# Biomodal Terraform AWS Bootstrap

## Overview

This Terraform module deploys a complete AWS infrastructure for running bioinformatics pipelines and computational workloads. It creates an EC2 bastion instance with optional AWS Batch compute environment for scalable job execution.

### Key Features

* **EC2 Bastion Instance**: Configurable compute instance for pipeline management and job submission
* **AWS Batch Environment** (optional): Managed compute environment with SPOT instances for cost-effective job execution
* **S3 Storage** (optional): Nextflow-optimized bucket with lifecycle policies for workflow artifacts
* **IAM Roles & Policies**: Comprehensive permissions for ECR, Batch, ECS, S3, and CloudWatch Logs
* **SSH Key Management**: Automatic generation and management of SSH key pairs
* **Security Groups**: Configurable ingress/egress rules for bastion and batch resources
* **Elastic IP** (optional): Static IP addressing for the bastion host

### Architecture

The module deploys the following resources when fully configured:

* **Compute**: EC2 instance with configurable instance type, EBS volumes, and metadata options
* **Batch**: AWS Batch compute environment with launch template, job queue, and security group
* **Storage**: S3 bucket with 14-day lifecycle policy for `nf-work/` prefix
* **Networking**: Security groups with customizable rules, VPC integration, and optional EIP
* **Identity**: IAM role, instance profile, and policies for AWS service access
* **SSH**: TLS-generated key pair with local file storage for private/public keys

## Tests

* Runs terraform `fmt` and `validate` for basic error checking.

## Usage

### Basic Example - EC2 Bastion Only

```hcl
module "bootstrap" {
  source = "github.com/cegx-ds/terraform-aws-bootstrap"

  # Required variables
  name       = "bioinformatics-bastion"
  account_id = "123456789012"
  vpc_id     = "vpc-0123456789abcdef0"
  subnet_id  = "subnet-0123456789abcdef0"

  # Optional configurations
  instance_type = "t3.medium"
  tags = {
    Environment = "production"
    Project     = "genomics-pipeline"
  }
}
```

### Full Example - With AWS Batch and S3

```hcl
module "bootstrap" {
  source = "github.com/cegx-ds/terraform-aws-bootstrap"

  # Required variables
  name       = "genomics-platform"
  account_id = "123456789012"
  vpc_id     = "vpc-0123456789abcdef0"
  subnet_id  = "subnet-0123456789abcdef0"

  # Enable AWS Batch for scalable compute
  deploy_batch = true
  batch_additional_ingress_cidr_blocks = ["10.0.0.0/16"]

  # Enable S3 bucket for Nextflow work directory
  create_bucket        = true
  bucket_force_destroy = true

  # EC2 instance configuration
  instance_type                    = "t3.large"
  root_block_device_volume_size    = 100
  ebs_block_device_volume_size     = 500
  ebs_device_name                  = "/dev/sdh"

  # Enable Elastic IP for stable addressing
  eip_enabled = true

  # Security configuration
  security_group_rules = [
    {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = "0.0.0.0/0"
      description = "Allow all outbound traffic"
    },
    {
      type        = "ingress"
      protocol    = "tcp"
      from_port   = 22
      to_port     = 22
      cidr_blocks = "203.0.113.0/24"  # Replace with your IP range
      description = "SSH access from corporate network"
    }
  ]

  # Tags
  tags = {
    Environment = "production"
    Project     = "genomics-pipeline"
    ManagedBy   = "terraform"
  }
}

# Outputs
output "bastion_public_ip" {
  value = module.bootstrap.public_ip
}

output "ssh_key_path" {
  value = module.bootstrap.private_key_filename
}

output "s3_bucket_name" {
  value = module.bootstrap.bucket_id
}
```

### Connecting to the Bastion

After deployment, connect to your bastion instance:

```bash
# SSH key is automatically generated and saved locally
ssh -i .ssh/<instance-name>.pem ec2-user@<public-ip>
```

### Using with Existing S3 Bucket

```hcl
module "bootstrap" {
  source = "github.com/cegx-ds/terraform-aws-bootstrap"

  name       = "pipeline-runner"
  account_id = "123456789012"
  vpc_id     = "vpc-0123456789abcdef0"
  subnet_id  = "subnet-0123456789abcdef0"

  # Use existing S3 bucket
  existing_bucket_name = "my-existing-nextflow-bucket"
}
```

## Devcontainer

This repo contains config to run a `devcontainer` development environment
in VS Code. It's highly recommended you use this enclosed `devcontainer`
when testing or developing this module for a consistent environment.

Please feel free to add any missing tools and submit a PR.

## To do

* Style guide for modules

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| local | n/a |
| tls | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| batch_security_group | terraform-aws-modules/security-group/aws | 5.3.0 |
| s3-bucket | terraform-aws-modules/s3-bucket/aws | ~> 4.4 |
| security_group | terraform-aws-modules/security-group/aws | 5.3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_batch_compute_environment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/batch_compute_environment) | resource |
| [aws_batch_job_queue.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/batch_job_queue) | resource |
| [aws_eip.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_iam_instance_profile.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_instance.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_key_pair.generated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [local_file.public_key_openssh](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_sensitive_file.private_key_pem](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [tls_private_key.default](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_ami.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_subnet.provided](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| account_id | id for AWS account to deploy into | `string` | n/a | yes |
| ami | AMI to use for the instance. Setting this will ignore `ami_filter` and `ami_owners`. | `string` | `null` | no |
| ami_filter | List of maps used to create the AMI filter for the action runner AMI. | `map(list(string))` | `{"name": ["amzn2-ami-hvm-2.*-x86_64-ebs"]}` | no |
| ami_owners | The list of owners used to select the AMI of action runner instances. | `list(string)` | `["amazon"]` | no |
| batch_additional_ingress_cidr_blocks | any additional cidr blocks to apply to batch ingress rules | `list(string)` | `[]` | no |
| bucket_force_destroy | Setting force destroy on Nextflow bucket | `bool` | `true` | no |
| create_bucket | Whether to create a Nextflow bucket | `bool` | `false` | no |
| deploy_batch | Whether to deploy a batch pipeline and associated resources | `bool` | `false` | no |
| disable_api_termination | Enable EC2 Instance Termination Protection | `bool` | `false` | no |
| ebs_block_device_encrypted | Whether to encrypt the EBS block device | `bool` | `true` | no |
| ebs_block_device_volume_size | The volume size (in GiB) to provision for the EBS block device. Creation skipped if size is 0 | `number` | `0` | no |
| ebs_delete_on_termination | Whether the EBS volume should be destroyed on instance termination | `bool` | `true` | no |
| ebs_device_name | The name of the EBS block device to mount on the instance | `string` | `"/dev/sdh"` | no |
| eip_enabled | Whether an eip is enabled for the bastion host | `string` | `false` | no |
| existing_bucket_name | Can be provided along with create bucket variable. Ensures policy for S3 covers existing bucket access | `string` | `""` | no |
| instance_profile | A pre-defined profile to attach to the instance (default is to build our own) | `string` | `""` | no |
| instance_type | Bastion instance type | `string` | `"t2.micro"` | no |
| key_name | Key name | `string` | `""` | no |
| metadata_http_endpoint_enabled | Whether the metadata service is available | `bool` | `true` | no |
| metadata_http_put_response_hop_limit | The desired HTTP PUT response hop limit (between 1 and 64) for instance metadata requests. | `number` | `1` | no |
| metadata_http_tokens_required | Whether or not the metadata service requires session tokens, also referred to as Instance Metadata Service Version 2. | `bool` | `true` | no |
| monitoring | Launched EC2 instance will have detailed monitoring enabled | `bool` | `true` | no |
| name | name to give instance. Also uses this value for naming all other related resources in this module | `string` | n/a | yes |
| root_block_device_encrypted | Whether to encrypt the root block device | `bool` | `true` | no |
| root_block_device_volume_size | The volume size (in GiB) to provision for the root block device. It cannot be smaller than the AMI it refers to. | `number` | `8` | no |
| security_group_description | The Security Group description. | `string` | `"Bastion host security group"` | no |
| security_group_enabled | Whether to create default Security Group for bastion host. | `bool` | `true` | no |
| security_group_rules | A list of maps of Security Group rules. The values of map is fully complated with `aws_security_group_rule` resource. See [AWS docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | `list(any)` | See default rules below | no |
| security_group_use_name_prefix | Whether to create a default Security Group with unique name beginning with the normalized prefix. | `bool` | `false` | no |
| security_groups | A list of Security Group IDs to associate with bastion host. | `list(string)` | `[]` | no |
| ssh_key_algorithm | SSH key algorithm | `string` | `"RSA"` | no |
| ssh_public_key_path | dir for public key | `string` | `".ssh"` | no |
| ssh_user | Needed to pass to output for backwards compatibility | `string` | `""` | no |
| subnet_id | id for subnet to launch instance on | `string` | n/a | yes |
| tags | map of tags to apply to all resources | `map(any)` | `{}` | no |
| user_data_base64 | The Base64-encoded user data to provide when launching the instances. If this is set then `user_data` will not be used. | `string` | `""` | no |
| vpc_id | VPC ID | `string` | n/a | yes |

**Default security_group_rules:**

```json
[
  {
    "type": "egress",
    "from_port": 0,
    "to_port": 0,
    "protocol": -1,
    "cidr_blocks": "0.0.0.0/0",
    "description": "Allow all outbound traffic"
  },
  {
    "type": "ingress",
    "protocol": "tcp",
    "from_port": 22,
    "to_port": 22,
    "cidr_blocks": "0.0.0.0/0",
    "description": "Allow all inbound to SSH"
  }
]
```

## Outputs

| Name | Description |
|------|-------------|
| arn | ARN of the instance |
| bucket_arn | S3 bucket ARN (if created) |
| bucket_id | S3 bucket ID (if created) |
| id | Disambiguated ID of the instance |
| instance_id | Instance ID |
| private_dns | Private DNS of instance |
| private_ip | Private IP of the instance |
| private_key_filename | Path to the generated private key file |
| public_ip | Public IP of the instance (or EIP) |
| security_group_arn | Bastion host Security Group ARN |
| security_group_id | Bastion host Security Group ID |
| security_group_ids | IDs on the AWS Security Groups associated with the instance |
| security_group_name | Bastion host Security Group name |
| ssh_user | SSH user |
