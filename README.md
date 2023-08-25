### Description

This was an recent interview project and a timed exercise. The Terraform deploys a lambda for finding the last release of an application, increases the patch version, creates a new branch, tag, and release in the repository. 

### Requirements

Make sure you have the following installed via brew:

* terraform
* python3.8
* pip3

You will also need a working installation of Docker. 

### Deploying the entire stack in lambda via Terraform


Export the value of your GITHUB api token :

```
export TF_VAR_github_api_token=***********
```

Make sure you a currently logged in to AWS via the CLI. Next, you will need to edit environments/production/main.tf file with the correct repository to test against:

```
module "releaser" {
  source = "../../modules/lambda/"
  source_directory = "source"  
  product = "releaser"
  environment = "demo"
  schedule = "0 8 1 * ? *"
  github_target_repository = "meg23/release-bumper-demo" <- changeme here
  github_api_token = sensitive(var.github_api_token)
  handler = "lambda_function.lambda_handler"
}

```

Next, inside the environments/production/ directory, run the following:

```
terraform init
terraform apply
```

Log into the AWS console and trigger a test with the Lambda dashboard. 

### Improvements

* The github api token is exposed as environment variable. This should be in secrets manager and exposed by an IAM role. 
