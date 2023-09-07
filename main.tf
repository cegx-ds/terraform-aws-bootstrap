locals {
  instance_tags = merge(var.tags, {
    Name = var.name
  })
  eip_ip = var.eip_enabled ? [join("/", aws_eip.default.*.public_ip, ["32"])] : []
  batch_ingress_cidr_blocks = concat(
    [data.aws_subnet.provided.cidr_block],
    local.eip_ip,
    var.batch_additional_ingress_cidr_blocks
  )
}


data "aws_ami" "default" {
  count = var.ami == null ? 1 : 0

  most_recent = "true"

  dynamic "filter" {
    for_each = var.ami_filter
    content {
      name   = filter.key
      values = filter.value
    }
  }

  owners = var.ami_owners
}

data "aws_subnet" "provided" {
  id = var.subnet_id
}

module "security_group" {
  source                   = "terraform-aws-modules/security-group/aws"
  version                  = "5.1.0"
  name                     = "${var.name}-sg"
  use_name_prefix          = var.security_group_use_name_prefix
  ingress_with_cidr_blocks = [for rule in var.security_group_rules : rule if rule.type == "ingress"]
  egress_with_cidr_blocks  = [for rule in var.security_group_rules : rule if rule.type == "egress"]
  description              = var.security_group_description
  vpc_id                   = var.vpc_id
}

resource "aws_instance" "default" {
  #bridgecrew:skip=BC_AWS_PUBLIC_12: Skipping `EC2 Should Not Have Public IPs` check. NAT instance requires public IP.
  #bridgecrew:skip=BC_AWS_GENERAL_31: Skipping `Ensure Instance Metadata Service Version 1 is not enabled` check until BridgeCrew support condition evaluation. See https://github.com/bridgecrewio/checkov/issues/793
  ami                     = coalesce(var.ami, join("", data.aws_ami.default.*.id))
  instance_type           = var.instance_type
  user_data               = var.user_data_base64
  vpc_security_group_ids  = compact(concat(module.security_group.*.security_group_id, var.security_groups))
  iam_instance_profile    = aws_iam_instance_profile.default.name
  key_name                = aws_key_pair.generated.key_name
  subnet_id               = var.subnet_id
  monitoring              = var.monitoring
  disable_api_termination = var.disable_api_termination
  tags                    = local.instance_tags

  metadata_options {
    http_endpoint               = (var.metadata_http_endpoint_enabled) ? "enabled" : "disabled"
    http_put_response_hop_limit = var.metadata_http_put_response_hop_limit
    http_tokens                 = (var.metadata_http_tokens_required) ? "required" : "optional"
  }

  root_block_device {
    encrypted   = var.root_block_device_encrypted
    volume_size = var.root_block_device_volume_size
  }

  # Optional block; skipped if var.ebs_block_device_volume_size is zero
  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device_volume_size > 0 ? [1] : []

    content {
      encrypted             = var.ebs_block_device_encrypted
      volume_size           = var.ebs_block_device_volume_size
      delete_on_termination = var.ebs_delete_on_termination
      device_name           = var.ebs_device_name
    }
  }

}

resource "aws_eip" "default" {
  count    = var.eip_enabled ? 1 : 0
  instance = join("", aws_instance.default[*].id)
  domain   = "vpc"
  tags     = var.tags
}
