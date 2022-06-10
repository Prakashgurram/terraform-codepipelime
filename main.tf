provider "aws" {
  region  = var.aws_region

}

module "prereqs" {
  source   = "./modules/prereqs"
}


module "codepipeline" {
  source   = "./modules/codepipeline"
  tflambda_bucket = module.prereqs.tflambda_bucket
  role_arn        = module.prereqs.role_arn
}
