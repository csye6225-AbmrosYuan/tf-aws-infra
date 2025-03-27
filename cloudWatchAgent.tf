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

# 创建 IAM 策略
resource "aws_iam_policy" "cloudwatch_agent_policy" {
  name        = "cloudWatchAgentPolicy_new"
  description = "Policy to allow CloudWatch Agent operations"
  policy      = data.aws_iam_policy_document.cloudwatch_agent_policy.json
}

# 创建 IAM 角色
resource "aws_iam_role" "cloudwatch_agent_role" {
  name               = "cloudWatchAgentRole_new"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

# 定义角色的信任策略
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


# 为 webapp 用户创建并附加策略，允许其假设 cloudWatchAgentRole 角色
resource "aws_iam_policy" "webapp_assume_role_policy" {
  name        = "WebappAssumeCloudWatchAgentRolePolicy"
  description = "Policy to allow webapp user to assume cloudWatchAgentRole"
  policy      = data.aws_iam_policy_document.webapp_assume_role_policy.json
}

data "aws_iam_policy_document" "webapp_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    resources = [aws_iam_role.cloudwatch_agent_role.arn]
  }
}


resource "aws_iam_user_policy_attachment" "webapp_assume_role_policy_attachment" {
  user       = "webapp"
  policy_arn = aws_iam_policy.webapp_assume_role_policy.arn
}