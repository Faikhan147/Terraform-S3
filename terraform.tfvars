region = "ap-southeast-2"
s3_bucket_name = "terraform-backend-all-envss"
dynamodb_tables = ["terraform-locks-prod", "terraform-locks-staging", "terraform-locks-qa", "terraform-locks-values-prod", "terraform-locks-values-staging", "terraform-locks-values-qa", "terraform-locks-vpc", "terraform-locks-jenkins-sonarqube-values", "terraform-locks-jenkins", "terraform-locks-sonarqube"]

