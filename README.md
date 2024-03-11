# Terraform AWS Jenkins Setup

This repository contains Terraform configurations to set up Jenkins on AWS infrastructure.

## Overview

This project automates the deployment of a Jenkins server on AWS using Terraform. It provisions necessary resources such as EC2 instance, security groups, and IAM roles.

## Prerequisites

Before you begin, ensure you have the following installed:

- Terraform (version X.X.X)
- AWS CLI
- Access to an AWS account with appropriate permissions
- SSH keypair for accessing the EC2 instance

## Getting Started

1. Clone this repository:

   ```bash
   git clone https://github.com/your-username/terraform_aws_jenkins_setup.git
   ```

2. Navigate to the project directory:

   ```bash
   cd terraform_aws_jenkins_setup
   ```

3. Initialize Terraform:

   ```bash
   terraform init
   ```

4. Modify `terraform.tfvars` file to configure your AWS credentials and other settings.

5. Review and apply Terraform changes:

   ```bash
   terraform plan
   terraform apply
   ```

6. Once the deployment is complete, Jenkins will be accessible at `http://<ec2_public_ip>:8080`.

## Verify Execution:

After the EC2 instance is created, you can SSH into the instance and check the `/var/log/cloud-init-output.log` file to verify that the user data script executed successfully.

## Configuration

You can customize the Jenkins setup by modifying the Terraform variables in `variables.tf` or by providing values in `terraform.tfvars`.

## Cleanup

To tear down the resources created by Terraform, run:

```bash
terraform destroy
```
