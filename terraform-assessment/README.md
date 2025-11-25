# Infrastructure Deployment Guide

## Prerequisites

* AWS CLI installed and configured

* Terraform installed (v1.0 or later recommended)

* Access to an AWS account with sufficient permissions to deploy resources

* SSH key pair (if required by the infrastructure)

## Deployment Steps

1. Clone the repository

2. Navigate to the Terraform directory

3. Initialize Terraform:

   `terraform init`
   
4. Review the execution plan:

   
   `terraform plan`
   
5. Deploy the infrastructure:

   
   `terraform apply`
   

   Confirm with `yes` when prompted.

## Accessing the Resources

* After deployment, Terraform will output relevant information such as Bastion public IP, VPC ID, and Load Balancer DNS name.

* Use the generated outputs to connect to servers or services.

## Cleanup Instructions (Destroy Infrastructure)

1. Navigate to the Terraform directory (if not already there).

2. Run the destroy command to delete all resources:

   `terraform destroy`
   
3. Confirm with `yes` when prompted.

## Notes

* Ensure no manual changes are made in the AWS console to avoid state conflicts.

* Always run `terraform plan` before applying or destroying changes to understand the impact.
