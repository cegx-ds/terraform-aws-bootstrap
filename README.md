<!--
  Copyright (C) 2023 Cambridge Epigenetix. All rights reserved.
-->
# Biomodal Terraform AWS Bootstrap

## Overview

Public module for use within the cli bootstrapping tool.
Deploys an ec2 bastion instance for running pipelines
remotely. Also deploys an AWS batch compute environment
(optional but defaults to `true`).

## Current modules managed by this repo

| Name            | Description                                                           | Version | Path                                | Platform | Notes |
|-----------------|-----------------------------------------------------------------------|---------|-------------------------------------|----------|-------|
| `aws-bootstrap` | Used to deploy ec2 bastion instance and associated pipeline resources | 0.0.1   | [./terraform/modules/aws-bootstrap](terraform/modules/aws-bootstrap/) | aws      |       |

## Tests

* Runs terraform `fmt` and `validate` for basic error checking.

## Devcontainer

This repo contains config to run a devcontainer development environment
in VS Code. It's highly recommended you use this enclosed devcontainer
when testing or developing this module for a consistent environment.

Please feel free to add any missing tools and submit a PR.

## To do

* Style guide for modules

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_batch_security_group"></a> [batch\_security\_group](#module\_batch\_security\_group) | terraform-aws-modules/security-group/aws | 5.1.0 |
| <a name="module_s3-bucket"></a> [s3-bucket](#module\_s3-bucket) | terraform-aws-modules/s3-bucket/aws | 3.15.1 |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | terraform-aws-modules/security-group/aws | 5.1.0 |

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
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | id for AWS account to deploy into | `string` | n/a | yes |
| <a name="input_ami"></a> [ami](#input\_ami) | AMI to use for the instance. Setting this will ignore `ami_filter` and `ami_owners`. | `string` | `null` | no |
| <a name="input_ami_filter"></a> [ami\_filter](#input\_ami\_filter) | List of maps used to create the AMI filter for the action runner AMI. | `map(list(string))` | <pre>{<br>  "name": [<br>    "amzn2-ami-hvm-2.*-x86_64-ebs"<br>  ]<br>}</pre> | no |
| <a name="input_ami_owners"></a> [ami\_owners](#input\_ami\_owners) | The list of owners used to select the AMI of action runner instances. | `list(string)` | <pre>[<br>  "amazon"<br>]</pre> | no |
| <a name="input_batch_additional_ingress_cidr_blocks"></a> [batch\_additional\_ingress\_cidr\_blocks](#input\_batch\_additional\_ingress\_cidr\_blocks) | any additional cidr blocks to apply to batch ingress rules | `list(string)` | `[]` | no |
| <a name="input_bucket_force_destroy"></a> [bucket\_force\_destroy](#input\_bucket\_force\_destroy) | Setting force destroy on Nextflow bucket | `bool` | `true` | no |
| <a name="input_create_bucket"></a> [create\_bucket](#input\_create\_bucket) | Whether to create a Nextflow bucket | `bool` | `false` | no |
| <a name="input_deploy_batch"></a> [deploy\_batch](#input\_deploy\_batch) | Whether to deploy a batch pipeline and associated resources | `bool` | `false` | no |
| <a name="input_disable_api_termination"></a> [disable\_api\_termination](#input\_disable\_api\_termination) | Enable EC2 Instance Termination Protection | `bool` | `false` | no |
| <a name="input_ebs_block_device_encrypted"></a> [ebs\_block\_device\_encrypted](#input\_ebs\_block\_device\_encrypted) | Whether to encrypt the EBS block device | `bool` | `true` | no |
| <a name="input_ebs_block_device_volume_size"></a> [ebs\_block\_device\_volume\_size](#input\_ebs\_block\_device\_volume\_size) | The volume size (in GiB) to provision for the EBS block device. Creation skipped if size is 0 | `number` | `0` | no |
| <a name="input_ebs_delete_on_termination"></a> [ebs\_delete\_on\_termination](#input\_ebs\_delete\_on\_termination) | Whether the EBS volume should be destroyed on instance termination | `bool` | `true` | no |
| <a name="input_ebs_device_name"></a> [ebs\_device\_name](#input\_ebs\_device\_name) | The name of the EBS block device to mount on the instance | `string` | `"/dev/sdh"` | no |
| <a name="input_eip_enabled"></a> [eip\_enabled](#input\_eip\_enabled) | Whether an eip is enabled for the bastion host | `string` | `false` | no |
| <a name="input_instance_profile"></a> [instance\_profile](#input\_instance\_profile) | A pre-defined profile to attach to the instance (default is to build our own) | `string` | `""` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Bastion instance type | `string` | `"t2.micro"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Key name | `string` | `""` | no |
| <a name="input_metadata_http_endpoint_enabled"></a> [metadata\_http\_endpoint\_enabled](#input\_metadata\_http\_endpoint\_enabled) | Whether the metadata service is available | `bool` | `true` | no |
| <a name="input_metadata_http_put_response_hop_limit"></a> [metadata\_http\_put\_response\_hop\_limit](#input\_metadata\_http\_put\_response\_hop\_limit) | The desired HTTP PUT response hop limit (between 1 and 64) for instance metadata requests. | `number` | `1` | no |
| <a name="input_metadata_http_tokens_required"></a> [metadata\_http\_tokens\_required](#input\_metadata\_http\_tokens\_required) | Whether or not the metadata service requires session tokens, also referred to as Instance Metadata Service Version 2. | `bool` | `true` | no |
| <a name="input_monitoring"></a> [monitoring](#input\_monitoring) | Launched EC2 instance will have detailed monitoring enabled | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | name to give instance. Also uses this value for naming all other related resources in this module | `string` | n/a | yes |
| <a name="input_root_block_device_encrypted"></a> [root\_block\_device\_encrypted](#input\_root\_block\_device\_encrypted) | Whether to encrypt the root block device | `bool` | `true` | no |
| <a name="input_root_block_device_volume_size"></a> [root\_block\_device\_volume\_size](#input\_root\_block\_device\_volume\_size) | The volume size (in GiB) to provision for the root block device. It cannot be smaller than the AMI it refers to. | `number` | `8` | no |
| <a name="input_security_group_description"></a> [security\_group\_description](#input\_security\_group\_description) | The Security Group description. | `string` | `"Bastion host security group"` | no |
| <a name="input_security_group_enabled"></a> [security\_group\_enabled](#input\_security\_group\_enabled) | Whether to create default Security Group for bastion host. | `bool` | `true` | no |
| <a name="input_security_group_rules"></a> [security\_group\_rules](#input\_security\_group\_rules) | A list of maps of Security Group rules.<br>The values of map is fully complated with `aws_security_group_rule` resource.<br>To get more info see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule . | `list(any)` | <pre>[<br>  {<br>    "cidr_blocks": "0.0.0.0/0",<br>    "description": "Allow all outbound traffic",<br>    "from_port": 0,<br>    "protocol": -1,<br>    "to_port": 0,<br>    "type": "egress"<br>  },<br>  {<br>    "cidr_blocks": "0.0.0.0/0",<br>    "description": "Allow all inbound to SSH",<br>    "from_port": 22,<br>    "protocol": "tcp",<br>    "to_port": 22,<br>    "type": "ingress"<br>  }<br>]</pre> | no |
| <a name="input_security_group_use_name_prefix"></a> [security\_group\_use\_name\_prefix](#input\_security\_group\_use\_name\_prefix) | Whether to create a default Security Group with unique name beginning with the normalized prefix. | `bool` | `false` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | A list of Security Group IDs to associate with bastion host. | `list(string)` | `[]` | no |
| <a name="input_ssh_key_algorithm"></a> [ssh\_key\_algorithm](#input\_ssh\_key\_algorithm) | n/a | `string` | `"RSA"` | no |
| <a name="input_ssh_public_key_path"></a> [ssh\_public\_key\_path](#input\_ssh\_public\_key\_path) | dir for public key | `string` | `".ssh"` | no |
| <a name="input_ssh_user"></a> [ssh\_user](#input\_ssh\_user) | Needed to pass to output for backwards compatibility | `string` | `""` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | id for subnet to launch instance on | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | map of tags to apply to all resources | `map(any)` | `{}` | no |
| <a name="input_user_data_base64"></a> [user\_data\_base64](#input\_user\_data\_base64) | The Base64-encoded user data to provide when launching the instances. If this is set then `user_data` will not be used. | `string` | `""` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the instance |
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | n/a |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | n/a |
| <a name="output_id"></a> [id](#output\_id) | Disambiguated ID of the instance |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | Instance ID |
| <a name="output_private_dns"></a> [private\_dns](#output\_private\_dns) | Private DNS of instance |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | Private IP of the instance |
| <a name="output_private_key_filename"></a> [private\_key\_filename](#output\_private\_key\_filename) | n/a |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | Public IP of the instance (or EIP) |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | Bastion host Security Group ARN |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Bastion host Security Group ID |
| <a name="output_security_group_ids"></a> [security\_group\_ids](#output\_security\_group\_ids) | IDs on the AWS Security Groups associated with the instance |
| <a name="output_security_group_name"></a> [security\_group\_name](#output\_security\_group\_name) | Bastion host Security Group name |
| <a name="output_ssh_user"></a> [ssh\_user](#output\_ssh\_user) | SSH user |
