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
  statement {
    #checkov:skip=CKV_AWS_356:IAM policies documents allow "*"
    effect = "Allow"

    actions = [
      "ssm:DescribeAssociation",
      "ssm:GetDeployablePatchSnapshotForInstance",
      "ssm:GetDocument",
      "ssm:DescribeDocument",
      "ssm:GetManifest",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:ListAssociations",
      "ssm:ListInstanceAssociations",
      "ssm:PutInventory",
      "ssm:PutComplianceItems",
      "ssm:PutConfigurePackageResult",
      "ssm:UpdateAssociationStatus",
      "ssm:UpdateInstanceAssociationStatus",
      "ssm:UpdateInstanceInformation"
    ]

    resources = ["*"]
  }

  statement {
    #checkov:skip=CKV_AWS_356:IAM policies documents allow "*"
    effect = "Allow"

    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]

    resources = ["*"]
  }

  statement {
    #checkov:skip=CKV_AWS_356:IAM policies documents allow "*"
    effect = "Allow"

    actions = [
      "ec2messages:AcknowledgeMessage",
      "ec2messages:DeleteMessage",
      "ec2messages:FailMessage",
      "ec2messages:GetEndpoint",
      "ec2messages:GetMessages",
      "ec2messages:SendReply",
    ]

    resources = ["*"]
  }

  statement {
    #checkov:skip=CKV_AWS_108:Allow any bucket
    #checkov:skip=CKV_AWS_111:Allow any bucket
    #checkov:skip=CKV_AWS_356:IAM policies documents allow "*"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListObjectsV2",
      "s3:ListBucket",
    ]

    resources = ["*"]
  }

  statement {
    #checkov:skip=CKV_AWS_356:IAM policies documents allow "*"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:GetLifecyclePolicy",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:ListTagsForResource",
      "ecr:DescribeImageScanFindings",
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
      "batch:DescribeJobQueues",
      "batch:CancelJob",
      "batch:SubmitJob",
      "batch:ListJobs",
      "batch:DescribeComputeEnvironments",
      "batch:TerminateJob",
      "batch:DescribeJobs",
      "batch:RegisterJobDefinition",
      "batch:DescribeJobDefinitions",
      "batch:TagResource",
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
