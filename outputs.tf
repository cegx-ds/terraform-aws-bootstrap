variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

output "instance_id" {
  value       = join("", aws_instance.default.*.id)
  description = "Instance ID"
}

output "security_group_ids" {
  description = "IDs on the AWS Security Groups associated with the instance"
  value = compact(
    concat(
      formatlist("%s", module.security_group.security_group_id),
      var.security_groups
    )
  )
}

output "public_ip" {
  value       = concat(aws_eip.default.*.public_ip, aws_instance.default.*.public_ip, [""])[0]
  description = "Public IP of the instance (or EIP)"
}

output "private_ip" {
  value       = join("", aws_instance.default.*.private_ip)
  description = "Private IP of the instance"
}

output "private_dns" {
  description = "Private DNS of instance"
  value       = join("", aws_instance.default.*.private_dns)
}

output "id" {
  description = "Disambiguated ID of the instance"
  value       = join("", aws_instance.default.*.id)
}

output "arn" {
  description = "ARN of the instance"
  value       = join("", aws_instance.default.*.arn)
}

output "security_group_id" {
  value       = module.security_group.security_group_id
  description = "Bastion host Security Group ID"
}

output "security_group_arn" {
  value       = module.security_group.security_group_arn
  description = "Bastion host Security Group ARN"
}

output "security_group_name" {
  value       = module.security_group.security_group_name
  description = "Bastion host Security Group name"
}

output "ssh_user" {
  value       = var.ssh_user
  description = "SSH user"
}

output "bucket_arn" {
  value = module.s3-bucket.0.s3_bucket_arn
}

output "bucket_id" {
  value = module.s3-bucket.0.s3_bucket_id
}

output "private_key_filename" {
  value = local_sensitive_file.private_key_pem.filename
}
