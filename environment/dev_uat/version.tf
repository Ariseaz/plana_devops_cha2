terraform {
  
  backend "s3" {
       bucket = "s3_bucket_name"
       key    = "UAT_S3_state_Bucket"
       region = "eu-central-1"
   }

}