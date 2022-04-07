# PlanA Challenge 2

## To deploy the infrastructure

Step 1: Configure AWS CLI with a credential with appropriate permission
```aws config```

Step 2: Create an S3 bucket to store your state file, name it "s3_bucket_name" for simplicity

Step 3: Navigate to the approprate environment/directory then Initiate Terraform

```
cd environment/dev_uat
terraform init
```

Step 3: Apply the config
```terraform apply```

NB:
I am using spot instances in this configuration because of the cost saving it provides.

There is an IAM policy that I am curated for this cluster in order to give easy access/API calls to the EKS service and other services relevant to the cluster.
