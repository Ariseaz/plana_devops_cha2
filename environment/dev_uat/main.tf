module "dev_uat_cluster" {
  source        = "../../cluster"
  instance_types = ["t3a.large"]
  environment   = "dev_uat"
  desired_capacity  = "2"
  min_capacity      = "2"
}