## Automated deployments with GitHub Actions for Amazon ECS Express Mode service

This project demonstrates deploying the [AWS Containers Retail Sample](https://github.com/aws-containers/retail-store-sample-app/tree/main) UI Application Deployment to Amazon ECS Express Mode with automated deployment pipeline using Amazon ECS "Deploy Express Service" Action for GitHub Actions

The UI original Dockerfile is available [here](https://github.com/aws-containers/retail-store-sample-app/blob/main/src/ui/Dockerfile)

**This project is intended for educational purposes only and not for production use**

![Screenshot](screenshot.png)

### Architecture Overview

![Minimal ECS Express Mode - Code Source](ecs-express-mode-github-actions-arch.png)

### Project Structure

```bash
your-app/
├── Dockerfile
└── .github/
    └── workflows/
        └── deploy.yml
```

### Features

- **Containerized Deployment**: Docker-based deployment with Nginx
- **CI/CD Pipeline**: Automated build and deployment using GitHub Actions
- **ECS Integration**: Seamless deployment to Amazon ECS Express Mode
- **Health Monitoring**: Built-in health check endpoint

### Quick Start

#### Prerequisites

- [AWS Command Line Interface (AWS CLI)](https://aws.amazon.com/cli/) installed and configured with credentials for your AWS account
- Docker installed locally
- A default [Amazon Virtual Private Cloud](https://aws.amazon.com/vpc/) (Amazon VPC) and default subnets, otherwise, see [Create a default VPC](https://docs.aws.amazon.com/vpc/latest/userguide/work-with-default-vpc.html#create-default-vpc)
- First, [create an OpenID Connect provider to allow GitHub Actions](https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws) to assume an [IAM role](https://github.com/marketplace/actions/amazon-ecs-deploy-express-service-action-for-github-actions#github-actions-role), then create the IAM Role with [ECS Express](https://github.com/marketplace/actions/amazon-ecs-deploy-express-service-action-for-github-actions#github-actions-role) and [ECR Permissions](https://docs.aws.amazon.com/AmazonECR/latest/userguide/ECR_on_ECS.html).
- Create the [two IAM roles](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/express-service-getting-started.html) required by an Express Mode service. The Task Execution Role and the Infrastructure Role.
- Configure GitHub repository variables

Your GitHub Actions workflow references your AWS account details and resource names through repository variables. Since these values aren’t sensitive, you can store them as variables rather than secrets, making them easier to reference in your workflow file.
Navigate to your GitHub repository on the GitHub website. Go to **Settings** → **Secrets and variables** → **Actions** → **Variables** tab, then add each of the following variables by clicking **New repository variable**:

| Variable Name | Example Value | Description |
|---|---|---|
| `AWS_REGION` | `us-east-1` | AWS region where your resources are deployed |
| `AWS_ACCOUNT_ID` | `123456789012` | Your 12-digit AWS account ID |
| `ECR_REPOSITORY` | `my-app` | Name of your Amazon ECR repository |
| `ECS_SERVICE` | `my-app-service` | Name for your Amazon ECS service |
| `ECS_CLUSTER` | `default` | Name for your Amazon ECS cluster |


**** 
**Estimated time:** 20-30 minutes
**Estimated cost:** Costs vary based on usage. You’ll incur charges for Amazon ECS tasks, Amazon ECR storage, and data transfer. GitHub Actions usage is free for public repositories. Remember to clean up resources after testing.
****

#### Docker Deployment

```bash
# Build Docker image
docker build -t retail-store-sample-ui .

# Run container locally
docker run -p 8080:8080 retail-store-sample-ui
```

## 🚀 Ready to Deploy to ECS Express Mode?

If you're familiar with ECS and just want to get started:

```bash
# 1. Clone the repository
git clone https://github.com/aws-samples/sample-amazon-ecs-express-github-actions.git
cd sample-amazon-ecs-express-github-actions

# 2. Create ECR repository
REPO_NAME="retail-store-sample-ui"
echo "🏗️  Creating ECR repository: $REPO_NAME"
aws ecr create-repository \
    --repository-name $REPO_NAME \
    --region $REGION \
    --image-scanning-configuration scanOnPush=true \
    --encryption-configuration encryptionType=AES256 \
    2>/dev/null || echo "Repository already exists"

# 3. Fork the repository on GitHub
# 4. Configure GitHub repository variables (see table above)
# 5. Push changes to your main branch to trigger deployment
git add .
git commit -m "Initial deployment"
git push origin main
```

The GitHub Actions workflow will automatically:

- Build the Docker image
- Push to ECR
- Deploy to ECS Express Mode
- Provide the service URL in the deployment logs

## Learn More

- [Amazon ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [Amazon ECS "Deploy Express Service" Action for GitHub Actions](https://github.com/marketplace/actions/amazon-ecs-deploy-express-service-action-for-github-actions#overview)
- [Best practices for Amazon ECS Express Mode services](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/express-service-best-practices.html)

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

## Security Scan Suppressions

This project contains suppressed security findings from Checkov and Semgrep static analysis tools. All suppressions have been reviewed and documented with technical justifications.

### Summary of Suppressions

| Finding | Tool | Justification | Risk |
|---------|------|---------------|------|
| CKV_DOCKER_3: User creation | Checkov | Base image already implements non-root user ([source](https://github.com/aws-containers/retail-store-sample-app/blob/main/src/ui/Dockerfile)) | ✅ Low |
| CKV_DOCKER_2: HEALTHCHECK | Checkov | Health checks handled by ECS/ALB at infrastructure layer | ✅ Low |
| CKV2_GHA_1: GHA Permissions | Checkov | Write permissions required for deployment with branch protection | ✅ Low |
| third-party-action-not-pinned | Semgrep | Official AWS actions pinned to semantic versions for maintainability | ✅ Low |
| dockerfile-source-not-pinned | Semgrep | Base image pinned to version 1.3.0 from official AWS ECR Public | ✅ Low |

**📄 Full Details:** See [SECURITY-SCAN-SUPPRESSIONS.md](./SECURITY-SCAN-SUPPRESSIONS.md) for complete technical justifications and risk assessments.
