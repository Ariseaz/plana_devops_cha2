module "production_cluster" {
  source        = "../../cluster"
  instance_types = ["t3a.large"]
  environment   = "production"
  desired_capacity  = "2"
  min_capacity      = "2"
}