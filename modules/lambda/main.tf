resource "null_resource" "install_dependencies" {
  provisioner "local-exec" {
    command = "docker run --rm -v $(pwd):/${var.source_directory} -w /${var.source_directory} lambci/lambda:build-python3.8 pip3 install -r ${var.source_directory}/requirements.txt -t ${var.source_directory}/"
  }
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = var.source_directory
  output_path = "zip"
  depends_on  = [null_resource.install_dependencies]
}

resource "aws_lambda_function" "python_task" {
  filename         = data.archive_file.lambda.output_path
  function_name    = "${var.product}-${var.environment}"
  role             = aws_iam_role.lambda_role.arn
  handler          = var.handler
  runtime          = var.runtime
  source_code_hash = data.archive_file.lambda.output_base64sha256
  environment {
    variables = {
      GITHUB_API_TOKEN         = var.github_api_token
      GITHUB_TARGET_REPOSITORY = var.github_target_repository
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.product}-${var.environment}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_cloudwatch_log_group" "function_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.python_task.function_name}"
  retention_in_days = 7
}

resource "aws_iam_policy" "policy" {
  name = "${var.product}-${var.environment}-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect : "Allow",
        Resource : "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role       = aws_iam_role.lambda_role.id
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_cloudwatch_event_rule" "schedule_rule" {
  name                = "${var.product}-${var.environment}-rule"
  schedule_expression = "cron(${var.schedule})"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.schedule_rule.name
  target_id = "${var.product}-${var.environment}-target"
  arn       = aws_lambda_function.python_task.arn
}

