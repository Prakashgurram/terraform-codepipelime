resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "bucketforcodepipeline122"
  acl    = "private"
  versioning {
    enabled = true
  }
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }
}

output "tflambda_bucket" {
  value = "${aws_s3_bucket.codepipeline_bucket.bucket}"
}

resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-automationrole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codebuild.amazonaws.com",
          "codedeploy.amazonaws.com",
          "codepipeline.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
]
}
EOF
}

data "aws_iam_policy_document" "codepipeline_policy_doc" {
  statement {
    sid = "1"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"
    ]
}

  statement {
    actions = [
      "iam:*"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "ec2:*"
    ]

    resources = [
      "*"
    ]
  }
  statement {
    actions = [
    "codecommit:* "
    ]
    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "s3:*"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "sns:*"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "lambda:*",
    ]

    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "ecr:*"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "codebuild:*"

    ]

    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "codepipeline:*"
    ]

    resources = [
      "*"
    ]
  }

}

resource "aws_iam_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  path = "/"
  policy = data.aws_iam_policy_document.codepipeline_policy_doc.json

}

resource "aws_iam_role_policy_attachment" "codepipeline_attach" {
  role = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_policy.arn
}

output "role_arn" {
  value = aws_iam_role.codepipeline_role.arn
}

