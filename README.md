# E-commerce Terraform Infrastructure

## Overview

This project sets up cloud infrastructure for an e-commerce platform using Terraform. It provisions and configures resources such as compute instances, databases, networking, and storage.
## Architecture

![arcitecture_diagram](https://github.com/user-attachments/assets/7b514b8f-fc40-489a-afef-3f9a38c111bb)

## Key Components

- Compute: Amazon EC2 instances

- Networking: VPC, Subnets, Security Groups, Route Tables

- Storage: Amazon S3

- Load Balancing: Application Load Balancer

- Automation: CI/CD with Terraform
- 
## AWS Services Used
- Amazon EC2 with Auto Scaling Groups
- Application Load Balancer
- AWS CodePipeline
- AWS CodeBuild
- AWS CodeDeploy
- Amazon CloudWatch


## Features

- Infrastructure as Code (IaC) with Terraform

- Scalable and secure cloud architecture

- Automated deployment using CI/CD

- Load balancing and high availability

## Prerequisites
Before you begin, ensure you have the following installed:
- AWS Account with appropriate permissions
- Terraform (latest version)
- GitHub account
- AWS CLI configured 
- Git


## Setup Instructions

1. Clone the Repository
```sh
git clone https://github.com/your-username/ecommerce-terraform-infra.git
cd ecommerce-terraform-infra
```
2. Initialize Terraform
```sh
terraform init
```
3. Plan the Infrastructure
```sh
terraform plan
```
4. Apply Changes
```sh
terraform apply -auto-approve
```
4. Destroy Infrastructure (if needed)
```sh
terraform destroy
```
Confirm with yes when prompted.

