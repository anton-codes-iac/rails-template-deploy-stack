# rails-template-deploy-stack ☁️🚀

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

The official **[deploy-stack](https://github.com/anton-codes-iac/deploy-stack)** application template for Ruby on Rails.

This Rails template acts as an invisible bridge between your new Rails application and AWS. By simply appending a `-m` flag when generating a new Rails app, it automatically scaffolds a production-ready AWS architecture directly into your repository.

**What it generates under the hood:**
* **Compute & Networking:** An AWS ECS Fargate cluster, Application Load Balancer, and an optional managed Amazon RDS PostgreSQL database.
* **DevSecOps CI/CD:** A GitHub Actions workflow utilizing keyless IAM OIDC and automated Trivy container vulnerability scanning.
* **Container Hardening:** Automatically patches the generated Rails `Dockerfile` to upgrade the Alpine OS and securely bump default Ruby standard library gems to guarantee a 0-CVE vulnerability scan.
* **Secrets Management:** Securely extracts your Rails Master Key and syncs it with AWS Systems Manager (SSM) so your Fargate tasks can decrypt credentials seamlessly.
* **State Management:** Native Terraform templates with an encrypted S3 remote state backend.

---

## 📦 Usage (Zero Installation)

You do not need to clone this repository or install any gems. You can pass the raw template URL directly to the standard `rails new` command.

```bash
rails new my_app -m https://raw.githubusercontent.com/anton-codes-iac/rails-template-deploy-stack/main/template.rb
```

During generation, you will be prompted for:
1. `aws_region`: Target AWS region for deployment (e.g., `us-east-2`).
2. `include_managed_rds`: Select `y` to automatically inject the `pg` gem, update `database.yml`, and provision a secure Amazon RDS PostgreSQL instance.
3. `port`: The port your Rails app listens on (default: `3000`).

Once the standard Rails scaffolding completes, the template automatically runs `deploy-stack` in headless mode, patches the `Dockerfile` for DevSecOps compliance, and safely injects your `RAILS_MASTER_KEY` into the Terraform state.

## 🚀 Deployment (Day 1)

Navigate into your newly created application directory. Before pushing to GitHub, provision your AWS infrastructure and sync your secrets:

```bash
cd my_app

npx --yes deploy-stack apply

```

## 🔄 Automation (Day 2)

Push your code to GitHub. The generated GitHub Actions CI/CD pipeline will automatically build your Docker image, scan it for vulnerabilities using Trivy, and deploy the new task definition to AWS Fargate securely via IAM OIDC.

```bash
git branch -M main
git remote add origin https://github.com/your-username/my_app.git
git add .
git commit -m "ci: 0-CVE deployment with synchronized master keys"
git push -u origin main
```

## 🗑️ Teardown (Stopping AWS Billing)

To remove all provisioned infrastructure, destroy the database, and stop billing, run:
```bash
npx --yes deploy-stack destroy
```

## 🧠 Powered by deploy-stack

This Rails template is a headless automation wrapper around the core `deploy-stack` engine. For custom architectures, full CLI flags, or supporting other web frameworks, visit the main [deploy-stack repository](https://github.com/anton-codes-iac/deploy-stack).

## 💰 AWS Costs & Disclaimer
**This tool provisions real AWS resources which will incur charges on your AWS bill.** An ECS Fargate cluster with an Application Load Balancer running 24/7 typically costs around ~$25 - $35/month minimum, depending on your region. A managed RDS database will add additional monthly costs.

*Disclaimer: The maintainers are not responsible for unexpected AWS charges. Always monitor your AWS Billing Dashboard.*