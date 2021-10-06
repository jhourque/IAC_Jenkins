resource "aws_cloudwatch_event_rule" "scheduler" {
  name                = "jenkins-scheduler-event"
  description         = "Jenkins scheduler event"
  schedule_expression = "cron(0 6/12 ? * MON-FRI *)"
  depends_on          = [aws_lambda_function.scheduler]
}

resource "aws_cloudwatch_event_target" "scheduler" {
  target_id = "jenkins-scheduler-event-target"
  rule      = aws_cloudwatch_event_rule.scheduler.name
  arn       = aws_lambda_function.scheduler.arn
}

resource "aws_iam_role" "scheduler" {
  name               = "jenkins-scheduler-lambda-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

data "aws_iam_policy_document" "scheduler" {
  statement {
    actions = [
      "ec2:DescribeInstances",
      "ec2:StopInstances",
      "ec2:StartInstances",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "ssm:GetParameter",
    ]
    resources = [
      aws_ssm_parameter.jenkins.arn
    ]
  }
}

resource "aws_iam_policy" "scheduler" {
  name   = "jenkins-scheduler-lambda-policy"
  policy = data.aws_iam_policy_document.scheduler.json
}

resource "aws_iam_role_policy_attachment" "scheduler" {
  role       = aws_iam_role.scheduler.name
  policy_arn = aws_iam_policy.scheduler.arn
}

resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole" {
  role       = aws_iam_role.scheduler.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "aws-scheduler" {
  type        = "zip"
  source_file = "${path.module}/scheduler.py"
  output_path = "${path.module}/scheduler.zip"
}

resource "aws_lambda_function" "scheduler" {
  filename         = data.archive_file.aws-scheduler.output_path
  function_name    = "jenkins-scheduler"
  role             = aws_iam_role.scheduler.arn
  handler          = "scheduler.lambda_handler"
  runtime          = "python3.9"
  timeout          = 300
  source_code_hash = data.archive_file.aws-scheduler.output_base64sha256
}

resource "aws_lambda_permission" "scheduler_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.scheduler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.scheduler.arn
}
