### IAM Roles and Policies for CI/CD ###

# 🔹 CodePipeline IAM Role
resource "aws_iam_role" "codepipeline_role" {
  name = "CodePipelineServiceRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "codepipeline.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "codepipeline_codebuild_policy" {
  name        = "CodePipelineCodeBuildPolicy"
  description = "Allows CodePipeline to trigger AWS CodeBuild"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds",
          "codebuild:BatchGetProjects",
          "codebuild:ListBuilds"
        ]
        Resource = "arn:aws:codebuild:us-east-1:273485968355:project/NodeJSBuild"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_codebuild_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_codebuild_policy.arn
}


# Attach AWS Managed Policies
resource "aws_iam_role_policy_attachment" "codepipeline_policy" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"
}

#  CodePipeline Full Access to CodeDeploy
resource "aws_iam_policy" "codepipeline_codedeploy_full_access" {
  name        = "CodePipelineCodeDeployFullAccess"
  description = "Grants CodePipeline full access to AWS CodeDeploy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "codedeploy:*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_codedeploy_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_codedeploy_full_access.arn
}

# 🔹 CodeBuild IAM Role
resource "aws_iam_role" "codebuild_role" {
  name = "CodeBuildServiceRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
}

#  Additional Permissions for CodeBuild (CloudWatch Logs, S3)
resource "aws_iam_role_policy_attachment" "codebuild_s3_full_access" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "codebuild_logs_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# 🔹 CodeDeploy IAM Role
resource "aws_iam_role" "codedeploy_role" {
  name = "CodeDeployServiceRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "codedeploy.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_policy" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"
}



# Attach an inline policy to grant necessary permissions, including autoscaling:DescribeLifecycleHooks
resource "aws_iam_policy" "codedeploy_policy" {
  name        = "CodeDeployPolicy"
  description = "Policy for CodeDeploy to access necessary AWS services"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeLifecycleHooks",
          "autoscaling:CompleteLifecycleAction",
          "autoscaling:PutLifecycleHook",
          "autoscaling:DeleteLifecycleHook",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:GetConsoleOutput",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach IAM Policy to CodeDeploy Role
resource "aws_iam_role_policy_attachment" "codedeploy_policy_attach" {
  policy_arn = aws_iam_policy.codedeploy_policy.arn
  role       = aws_iam_role.codedeploy_role.name
}

#  Updated Auto Scaling Policy with Describe permissions
resource "aws_iam_policy" "codedeploy_autoscale" {
  name        = "CodeDeployAutoScaling"
  description = "Allows CodeDeploy to control Auto Scaling lifecycle hooks and describe groups"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:CompleteLifecycleAction",
          "autoscaling:PutLifecycleHook",
          "autoscaling:DeleteLifecycleHook",
          "autoscaling:RecordLifecycleActionHeartbeat",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_autoscale_attachment" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = aws_iam_policy.codedeploy_autoscale.arn
}

resource "aws_iam_policy" "codepipeline_s3_full_access" {
  name        = "CodePipelineS3FullAccess"
  description = "Allows CodePipeline to store and retrieve artifacts from the S3 bucket"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::ecommerce-pipeline-artifacts-f97972bd772ebd39",
          "arn:aws:s3:::ecommerce-pipeline-artifacts-f97972bd772ebd39/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_s3_full_access_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_s3_full_access.arn
}

resource "aws_iam_policy" "codepipeline_s3_policy" {
  name        = "CodePipelineS3AccessPolicy"
  description = "Policy for CodePipeline to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::ecommerce-pipeline-artifacts-bc7ef2c18be94cb5",
          "arn:aws:s3:::ecommerce-pipeline-artifacts-bc7ef2c18be94cb5/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_s3_attach" {
  policy_arn = aws_iam_policy.codepipeline_s3_policy.arn
  role       = aws_iam_role.codepipeline_role.name
}


resource "aws_iam_policy" "codedeploy_ec2_permissions" {
  name        = "CodeDeployEC2Permissions"
  description = "Allows CodeDeploy to interact with EC2 instances"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:GetConsoleOutput",
          "ec2:AssociateIamInstanceProfile",
          "ec2:DescribeIamInstanceProfileAssociations"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_ec2_attachment" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = aws_iam_policy.codedeploy_ec2_permissions.arn
}

resource "aws_iam_policy" "codepipeline_codeconnections_policy" {
  name        = "CodePipelineCodeConnectionsPolicy"
  description = "Allows CodePipeline to use AWS CodeConnections"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codestar-connections:UseConnection",
          "codestar-connections:GetConnection",
          "codestar-connections:ListConnections"
        ]
        Resource = "arn:aws:codeconnections:us-east-1:273485968355:connection/c4424a1b-d3f9-4ad6-a53d-762d668f87b5"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_codeconnections_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_codeconnections_policy.arn
}













### `codedeploy.tf` - CodeDeploy Application and Deployment Group ###

resource "aws_codedeploy_app" "nodejs_app" {
  name = "NodeJSApp"
}

resource "aws_codedeploy_deployment_group" "nodejs_dg" {
  app_name               = aws_codedeploy_app.nodejs_app.name
  deployment_group_name  = "NodeJSDeploymentGroup"
  service_role_arn       = aws_iam_role.codedeploy_role.arn
  autoscaling_groups     = [aws_autoscaling_group.nodejs_asg.name]
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
}










### `codebuild.tf` - CodeBuild Project ###
resource "aws_codebuild_project" "nodejs_build" {
  name         = "NodeJSBuild"
  service_role = aws_iam_role.codebuild_role.arn

  # 🔹 Fix: Use CODEPIPELINE for both source & artifact
  source {
    type = "CODEPIPELINE"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:5.0"
    type         = "LINUX_CONTAINER"
  }
}








### `pipeline.tf` - CodePipeline ###
resource "aws_codepipeline" "nodejs_pipeline" {
  name     = "NodeJSPipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn    = "arn:aws:codeconnections:us-east-1:273485968355:connection/c4424a1b-d3f9-4ad6-a53d-762d668f87b5"
        FullRepositoryId = "amithroshan/CCS3316_Cloud_infrastucture-Group_Project"
        BranchName       = "main"
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
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      configuration = {
        ProjectName = aws_codebuild_project.nodejs_build.name
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      version         = "1"
      input_artifacts = ["build_output"]
      configuration = {
        ApplicationName     = aws_codedeploy_app.nodejs_app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.nodejs_dg.deployment_group_name
      }
    }
  }
}

