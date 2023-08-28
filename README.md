# Terraform-modules
This is the repository to store terraform modules
# Terraform AWS VPC Module

This Terraform module creates a Virtual Private Cloud (VPC) in AWS with public and private subnets across multiple availability zones. The VPC includes an internet gateway for public access and appropriate route tables.

## Usage

```hcl
module "my_vpc" {
  source                 = "path/to/your/module"
  vpc_cidr               = ""
  project_name           = "my-project"
  environment            = "Stag"
  public_subnet_az1_cidr = ""
  public_subnet_az2_cidr = ""
  private_app_subnet_az1_cidr = ""
  private_app_subnet_az2_cidr = ""
  private_data_subnet_az1_cidr = ""
  private_data_subnet_az2_cidr = ""
}

