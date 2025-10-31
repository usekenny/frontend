resource "aws_iam_policy" "amplify_ssr_role_policy" {
  name = "${var.project_name}-${var.profile}-compute-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # CloudWatch Logs permissions - Required for Lambda/ECS logging
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:eu-west-3:${data.aws_caller_identity.current.account_id}:log-group:/aws/amplify/${data.external.amplify_app_id.result.app_id}:"
      },
      {
        Effect = "Allow"
        Action = [
          # SSM Parameter Store permissions - Used for OpenRouter API keys
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:PutParameter",
          "ssm:DeleteParameter"
        ]
        Resource = [
          "arn:aws:ssm:eu-west-3:${data.aws_caller_identity.current.account_id}:/amplify/shared/${data.external.amplify_app_id.result.app_id}/",
          "arn:aws:ssm:eu-west-3:685993304778:parameter/openrouter/*",
          "arn:aws:ssm:eu-west-3:685993304778:parameter/composio/*",
          "arn:aws:ssm:eu-west-3:685993304778:parameter/openai/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          # Secrets Manager permissions
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets",
          "secretsmanager:CreateSecret",
          "secretsmanager:UpdateSecret",
          "secretsmanager:PutSecretValue",
          "secretsmanager:DeleteSecret",
          "secretsmanager:TagResource",
          "secretsmanager:UntagResource"
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role" "amplify_ssr_role" {
  name = "${var.project_name}-${var.profile}-compute-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "amplify.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "amplify_ssr_role_policy_attachment" {
  role       = aws_iam_role.amplify_ssr_role.name
  policy_arn = aws_iam_policy.amplify_ssr_role_policy.arn
}
