
#创建CloudWatchAgent Policy
data "aws_iam_policy_document" "cloudwatch_agent_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
      "logs:DescribeLogGroups",
      "logs:DeleteLogGroup",
      "logs:DeleteLogStream",
      "logs:PutRetentionPolicy",
      "logs:ListTagsLogGroup",
      "logs:TagLogGroup",
      "logs:UntagLogGroup"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "cloudwatch_agent_policy" {
  name        = "cloudWatchAgentPolicy_new_tmp"
  description = "Policy to allow CloudWatch Agent operations"
  policy      = data.aws_iam_policy_document.cloudwatch_agent_policy.json
}


# 允许ec2 代入角色
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions   = ["sts:AssumeRole"]
    effect    = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# 创建 ec2_instance_role，角色会在 AWS Console 中显示
resource "aws_iam_role" "ec2_instance_role" {
  name               = "ec2_instance_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

# 附加 CloudWatch Agent 自定义权限
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy_attachment" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = aws_iam_policy.cloudwatch_agent_policy.arn
}

# 附加 AWS 管理的 CloudWatchAgentServerPolicy
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_role_policy_attachment" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# 附加 webapp 权限（包括 S3、EC2、RDS 访问权限）
resource "aws_iam_policy" "webapp_policy" {
  name        = "webapp_policy"
  description = "Policy for EC2 instance role with S3, EC2, and RDS permissions"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "ObjectOperations",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = "${aws_s3_bucket.webappbucket.arn}/*"
      },

      {
        Sid    = "ConfigBucketAccess",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          # "arn:aws:s3:::configbucket261447",
          # "arn:aws:s3:::configbucket261447/*"

          "arn:aws:s3:::configbucket261447demo",
          "arn:aws:s3:::configbucket261447demo/*"
        ]
      },
      
      {
        Sid    = "EC2Operations",
        Effect = "Allow",
        Action = [
          "ec2:AssociateRouteTable",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:CreateRouteTable",
          "ec2:CreateSecurityGroup",
          "ec2:CreateSubnet",
          "ec2:DescribeInstances",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeRouteTables",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:ModifyNetworkInterfaceAttribute",
          "ec2:RevokeSecurityGroupEgress",
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      },
      {
        Sid    = "RDSAccess",
        Effect = "Allow",
        Action = [
          "rds:DescribeDBInstances",
          "rds:DescribeDBSnapshots",
          "rds:DescribeDBLogFiles"
        ],
        Resource = "${aws_db_instance.rds_instance.arn}"
      }
    ]
  })
}

# 附加 webapp_policy
resource "aws_iam_role_policy_attachment" "webapp_policy_attachment" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = aws_iam_policy.webapp_policy.arn
}
