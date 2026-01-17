# Serverless Cloud Infrastructure & Observability Suite

A production-grade serverless web application architected on AWS, featuring fully automated CI/CD and real-time observability. This project demonstrates the transition from manual cloud provisioning to a Self-Reporting Infrastructure model.

## 🌐 Project Overview

The goal of this project was to move beyond a simple static website, build a dynamic "visitor counter" using a serverless backend and monitor/observe how well it is working using Grafana. The entire infrastructure is managed as code (IaC) to ensure consistency and automation.

Live Project: https://d2wmaqebqzqcc0.cloudfront.net/

## 🛠️ Tech Stack

| Layer             | Technology           | Purpose                                             |
| :---------------- | :------------------- | :-------------------------------------------------- |
| **Frontend**      | HTML, CSS            | Responsive UI and asynchronous API fetching         |
| **Hosting**       | Amazon S3            | High-availability static website hosting            |
| **CDN**           | Amazon CloudFront    | Global content delivery and SSL/TLS encryption      |
| **Backend**       | AWS Lambda           | Serverless Python API for visitor logic             |
| **Database**      | Amazon DynamoDB      | NoSQL storage for atomic visitor increments         |
| **IaC**           | Terraform            | Declarative infrastructure management               |
| **CI/CD**         | GitHub Actions       | Automated testing and deployment pipeline           |
| **Monitoring**    | Grafana Cloud        | Observability and Monitoring                        |

## 🛠️ Implementation Journey

### Phase 1: Frontend & CDN

I started by hosting my HTML/CSS code as a static site in Amazon S3. To ensure the site was secure and fast, I configured Amazon CloudFront to serve the content over HTTPS via a global Content Delivery Network.

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

## Phase 5: Observability & Proactive Monitoring

I moved beyond "Basic Cloud Hosting" to "Managed Operations" by implementing a full observability suite. Using Grafana Cloud, I transformed raw AWS data into an actionable operational dashboard.

- Centralized Data: Connected Grafana to AWS CloudWatch via a least-privilege IAM role to aggregate metrics from Lambda, DynamoDB, and CloudFront.
- Custom Dashboards: Built a "Single Pane of Glass" to visualize:
- Lambda Performance: Tracking cold starts and execution duration (latency).
- Traffic Trends: Real-time visitor counts and API invocation spikes.
- Database Health: Monitoring DynamoDB read/write capacity units (RCU/WCU).
- Automated Guardrails: Configured Grafana Alerts to trigger email notifications the moment a "5XX Error" is detected or if the Lambda latency exceeds 2 seconds.
- Why this matters: This phase proves the infrastructure is "Production-Ready." I don't need to manually check the site to see if it’s healthy; the system tells me when it's hurting.

![Grafana Dashboard](<images/Screenshot 2026-01-07 044714.png>)

## 🧠 Technical Challenges & Solutions

- The CORS Conflict: Initially faced Multiple values '*, *' errors. I learned that having CORS enabled on both the Lambda Function URL and inside the Python code creates a header conflict.    Solution: Centralized all CORS logic within the Python application for cleaner control.

- Least-Privilege Security: To follow AWS best practices, I moved away from "FullAccess" roles. I wrote custom IAM Policies in Terraform that only allow the Lambda to UpdateItem on one specific DynamoDB ARN.

- Recursive Zipping: My CI/CD was accidentally zipping the entire repository into the Lambda package. 
Solution: Refined the GitHub Action to target only the backend/ directory, reducing deployment size by 90%.

## 🚀 How to Run Locally

Clone the Repo: git clone https://github.com/[YOUR-USERNAME]/[YOUR-REPO]
Initialize Infrastructure: ```bash cd terraform terraform init terraform apply
Deploy Frontend: Sync your website/ folder to the S3 bucket created by Terraform.

## Author

Adedokun Daniel Adewole

www.linkedin.com/in/daniel-adedokun

Cloud Engineer | DevOps Enthusiast