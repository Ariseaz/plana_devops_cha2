terraform {
  
  backend "s3" {
       bucket = "s3_bucket_name"
       key    = "Prod_S3_state_Bucket"
       region = "eu-central-1"
   }

}