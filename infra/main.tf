// Dyanamo DB

resource "aws_dynamodb_table" "makisam_crc_table" {
  name           = "makisam_crc_table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "ID"

  attribute {
    name = "ID"
    type = "S"
  }
  attribute {
    name = "website-viewer"
    type = "N"
  }

  global_secondary_index {
    name            = "website-viewer"
    hash_key        = "website-viewer"
    projection_type = "ALL"
    read_capacity   = 1
    write_capacity  = 1
  }
}

// DynamoDB Item

resource "aws_dynamodb_table_item" "makisam_crc_table_item" {
  table_name = aws_dynamodb_table.makisam_crc_table.name
  hash_key   = aws_dynamodb_table.makisam_crc_table.hash_key
  item       = <<ITEM
  {
  "ID": {"S": "0"},
  "website-viewer": {"N": "1"}
  } 
    ITEM
}

// IAM Role for Lambda to Get and Put to DyanamoDB

// Collection AWS Account ID and Region

data "aws_region" "region" {}
data "aws_caller_identity" "accound_id" {}

// IAM Role for Lambda

resource "aws_iam_role" "makisam_crc_lambda_role" {
  name               = "makisam_crc_lambda_role"
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

resource "aws_iam_policy" "makisam_crc_lambda_policy" {
  name        = "makisam_crc_lambda_policy"
  path        = "/"
  description = "AWS IAM Policy for managing the resume project role"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "dynamodb:UpdateItem",
            "dynamodb:GetItem",
            "dynamodb:PutItem",
          ],
          "Resource" : "arn:aws:dynamodb:${data.aws_region.region.name}:${data.aws_caller_identity.accound_id.account_id}:*"
        },
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.makisam_crc_lambda_role.name
  policy_arn = aws_iam_policy.makisam_crc_lambda_policy.arn
}

// Lambda Session

// Data Archiving Lambda

data "archive_file" "makisam_crc_lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda_function.py"
  output_path = "${path.module}/lambda/lambda_function.zip"
}

// Lambda Function

resource "aws_lambda_function" "makisam_crc_function" {
  function_name = "makisam_crc_function"
  filename      = "${path.module}/lambda/lambda_function.zip"
  role          = aws_iam_role.makisam_crc_lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
}

resource "aws_lambda_function_url" "function_url" {
  function_name      = aws_lambda_function.makisam_crc_function.function_name
  authorization_type = "NONE"
  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}