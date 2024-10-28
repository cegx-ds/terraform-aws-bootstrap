#
# Copyright (C) 2022 biomodal. All rights reserved.
#

#
# https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest
#

module "batch_security_group" {
  #checkov:skip=CKV_TF_1:Ensure Terraform module sources use a commit hash in GitHub
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"
  count   = var.deploy_batch ? 1 : 0

  name        = "${var.name}-batch"
  description = "Security group for Batch compute resources"
  vpc_id      = var.vpc_id

  # TODO: review this
  ingress_cidr_blocks = local.batch_ingress_cidr_blocks
  ingress_rules       = ["all-all"]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}

#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template
#

resource "aws_launch_template" "this" {
  #checkov:skip=CKV_AWS_79:Nextflow requires metadata service v1 (https://github.com/nextflow-io/nextflow/blob/9e6c994ce399c0d43f50617c0465e829699710d7/plugins/nf-amazon/src/main/nextflow/cloud/aws/AmazonClientFactory.groovy#L137)

  count = var.deploy_batch ? 1 : 0
  name  = "${var.name}-batch-launch-template"

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 500
      volume_type = "gp2"
    }
  }
}

#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/batch_compute_environment
#

resource "aws_batch_compute_environment" "this" {

  count                    = var.deploy_batch ? 1 : 0
  compute_environment_name = var.name
  service_role             = "arn:aws:iam::${var.account_id}:role/aws-service-role/batch.amazonaws.com/AWSServiceRoleForBatch"
  type                     = "MANAGED"

  compute_resources {
    type                = "SPOT"
    allocation_strategy = "SPOT_CAPACITY_OPTIMIZED"
    bid_percentage      = 100
    min_vcpus           = 0
    max_vcpus           = 256
    desired_vcpus       = 0
    instance_type       = ["optimal"]
    instance_role       = "arn:aws:iam::${var.account_id}:instance-profile/${var.name}"

    security_group_ids = [
      module.batch_security_group[count.index].security_group_id
    ]
    subnets = [
      var.subnet_id,
      # TODO: multiple subnets for three AZs? We should review this
    ]

    launch_template {
      launch_template_id = aws_launch_template.this[count.index].id
    }

    tags = var.tags
  }

  tags = var.tags
}

#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/batch_job_queue
#

resource "aws_batch_job_queue" "this" {
  count                = var.deploy_batch ? 1 : 0
  name                 = "${var.name}-job-queue"
  state                = "ENABLED"
  priority             = 1
  compute_environments = [aws_batch_compute_environment.this[count.index].arn]

  tags = var.tags
}
