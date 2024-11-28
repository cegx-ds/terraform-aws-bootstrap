#
# Copyright (C) 2022 biomodal. All rights reserved.
#


data "aws_iam_policy_document" "default" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "main" {

  dynamic "statement" {
    #checkov:skip=CKV_AWS_108:Allow any bucket
    #checkov:skip=CKV_AWS_111:Allow any bucket
    #checkov:skip=CKV_AWS_356:IAM policies documents allow "*"
    for_each = toset(local.create_s3_iam)
    content {
      effect = "Allow"

      actions = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListObjectsV2",
        "s3:ListBucket",
      ]

      resources = [
        "arn:aws:s3:::${module.s3-bucket[0].s3_bucket_id}/*",
      module.s3-bucket[0].s3_bucket_arn, ]
    }
  }

  dynamic "statement" {
    #checkov:skip=CKV_AWS_108:Allow any bucket
    #checkov:skip=CKV_AWS_111:Allow any bucket
    #checkov:skip=CKV_AWS_356:IAM policies documents allow "*"
    for_each = toset(local.existing_bucket_iam)
    content {
      effect = "Allow"

      actions = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListObjectsV2",
        "s3:ListBucket",
      ]

      resources = [
        "arn:aws:s3:::${var.existing_bucket_name}/*",
      "arn:aws:s3:::${var.existing_bucket_name}", ]
    }
  }


  statement {
    #checkov:skip=CKV_AWS_356:IAM policies documents allow "*"
    effect = "Allow"

    actions = [
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeImageScanFindings",
      "ecr:DescribeRepositories",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetLifecyclePolicy",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:ListTagsForResource",
      "ecr:CreateRepository",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
    ]

    resources = [
      "*"
    ]
  }

  statement {
    #checkov:skip=CKV_AWS_356:IAM policies documents allow "*"
    effect = "Allow"

    actions = [
      "batch:DescribeComputeEnvironments",
      "batch:DescribeJobDefinitions",
      "batch:DescribeJobQueues",
      "batch:DescribeJobs",
      "batch:ListJobs",
      "batch:RegisterJobDefinition",
      "batch:SubmitJob",
      "batch:TagResource",
      "batch:TerminateJob",
    ]

    resources = [
      "*"
    ]
  }

  statement {
    #checkov:skip=CKV_AWS_356:IAM policies documents allow "*"
    effect = "Allow"

    actions = [
      "ecs:DescribeTasks",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeInstanceAttribute",
      "ecs:DescribeContainerInstances",
      "ec2:DescribeInstanceStatus",
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_instance_profile" "default" {
  name = var.name
  role = aws_iam_role.default.name
}

resource "aws_iam_role" "default" {
  name               = var.name
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.default.json
}

resource "aws_iam_role_policy" "main" {
  name   = var.name
  role   = aws_iam_role.default.id
  policy = data.aws_iam_policy_document.main.json
}
