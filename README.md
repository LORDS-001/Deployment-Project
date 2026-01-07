# The Cloud Resume Challenge (AWS)

This project is a full-stack serverless application to host my professional resume. It demonstrates my ability to build and deploy cloud-native applications using Industry-standard DevOps practices.

## 🌐 Project Overview

The goal of this project was to move beyond a simple static website and build a dynamic "visitor counter" using a serverless backend. The entire infrastructure is managed as code (IaC) to ensure consistency and automation.

Live Project: https://d2wmaqebqzqcc0.cloudfront.net/

## 🏗️ The Tech Stack

Layer            |           Technology
_________________|_________________________________________________
Frontend         |    "HTML5, CSS3, JavaScript"
Hosting          |    Amazon S3 (Static Website Hosting)
CDN              |    Amazon CloudFront (HTTPS & Global Caching)
DNS              |    Amazon Route 53
Backend          |    AWS Lambda (Python 3.9)
Database         |    Amazon DynamoDB
IaC              |    Terraform
CI/CD            |    GitHub Actions

## 🛠️ Implementation Journey

### Phase 1: Frontend & CDN

I started by hosting my resume as a static site in Amazon S3. To ensure the site was secure and fast, I configured Amazon CloudFront to serve the content over HTTPS via a global Content Delivery Network.

### Phase 2: The Serverless Backend

I developed a Python-based AWS Lambda function to act as the API.

- Used Lambda Function URLs for a direct HTTP endpoint.
- Implemented DynamoDB to store the visitor count.
- Wrote "Atomic" update logic to ensure the counter increments correctly even when multiple people visit at once.

### Phase 3: Infrastructure as Code (Terraform)

Instead of clicking through the AWS Console, I defined the entire environment in Terraform. This included:

- IAM Roles and Least-Privilege Policies.
- DynamoDB tables and Lambda configurations.
- S3 Bucket policies for public/private access.

### Phase 4: CI/CD Pipeline

I built a GitHub Actions workflow that triggers on every push:

1.  Automatically zips the Python backend.
2.  Runs terraform plan to preview changes.
3.  Executes terraform apply to update the cloud infrastructure.
4.  Syncs the frontend files to S3.

## 🧠 Lessons Learned & Troubleshooting

Building this wasn't without its hurdles. Here are the key technical challenges I overcame:

- CORS Configuration: Faced a Multiple values '*, *' error. I learned how headers from the Lambda Function URL settings and the Python code can conflict, and resolved it by centralizing CORS logic in the Python code.
- IAM Permissions: Debugged AccessDeniedException by refining the Lambda's Execution Role to grant specific UpdateItem permissions to the DynamoDB ARN.
- Recursive Zipping: Fixed an issue where Terraform was zipping its own output, leading to corrupted Lambda packages.

## 📈 Next Steps

- [ ] Add a "Top Referred From" table to see where visitors are coming from.
- [ ] Implement unit testing for the Python Lambda function.
- [ ] Add Cypress end-to-end tests for the frontend.

## Author

Adedokun Daniel Adewole

www.linkedin.com/in/daniel-adedokun