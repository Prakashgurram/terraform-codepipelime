resource "aws_sns_topic" "pipeline_updates" {
  name  = "codepipeline-updates-topic"
}

resource "aws_sns_topic_subscription" "subscription" {
  topic_arn = "${aws_sns_topic.pipeline_updates.arn}"
  protocol  = "email"
  endpoint  = "prakashch1223@gmail.com"
}

resource "aws_codepipeline" "codepipeline" {
  name     = "automation-pipeline"
  role_arn = "${var.role_arn}"

  artifact_store {
    location = "${var.tflambda_bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source"]

      configuration = {
        RepositoryName = "my-first-repo"
        BranchName  = "main"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source"]
      output_artifacts = ["build"]

      configuration = {
        ProjectName = "${aws_codebuild_project.codepipeline_plan_project.name}"
      }
    }
  }


  stage {
    name = "Approval"


    action {
      name     = "Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration = {
        NotificationArn = "${aws_sns_topic.pipeline_updates.arn}"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "Deploy"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["build"]
      output_artifacts = ["Deploy"]

      configuration = {
        ProjectName = "${aws_codebuild_project.codepipeline_apply_project.name}"
      }
    }
  }

 }

data "template_file" "buildspec" {
  template = file("buildspec.yml")

}


data "template_file" "buildspec-2" {
  template = file("buildspec-apply.yml")

}


resource "aws_codebuild_project" "codepipeline_plan_project" {
  name          = "codepipeline-plan-project"
  description   = "$codebuild_project"
  build_timeout = "5"
  service_role  = "${var.role_arn}"

  artifacts {
    type           = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

  }
  source {
    buildspec           = data.template_file.buildspec.rendered
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }

}

resource "aws_codebuild_project" "codepipeline_apply_project" {
  name          = "code-pipeline-apply-project"
  description   = "codebuild_project"
  build_timeout = "5"
  service_role  = "${var.role_arn}"

  artifacts {
    type           = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

  }

  source {
    type      = "CODEPIPELINE"
    buildspec           = data.template_file.buildspec-2.rendered
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false

  }


}
