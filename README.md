# Terraform-modules
This is the repository to store terraform modules
# Terraform AWS VPC Module

This Terraform module creates a Virtual Private Cloud (VPC) in AWS with public and private subnets across multiple availability zones. The VPC includes an internet gateway for public access and appropriate route tables.

## Usage

```hcl
module "my_vpc" {
  source                 = "path/to/your/module"
  vpc_cidr               = "10.0.0.0/16"
  project_name           = "my-project"
  environment            = "dev"
  public_subnet_az1_cidr = "10.0.1.0/24"
  public_subnet_az2_cidr = "10.0.2.0/24"
  private_app_subnet_az1_cidr = "10.0.3.0/24"
  private_app_subnet_az2_cidr = "10.0.4.0/24"
  private_data_subnet_az1_cidr = "10.0.5.0/24"
  private_data_subnet_az2_cidr = "10.0.6.0/24"
}

