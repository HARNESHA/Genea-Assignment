# Genea DevSecOps Assignment

## 📌 Architecture Overview

**High-level flow**

```
Terraform (IaC)
   │
   ├── Provision AWS Infra (EKS, RDS, IAM, ECR)
   │
   ├── Export Infra Outputs
   │
   ├── CI Pipeline
   │     ├── Build Docker Images
   │     ├── Push to Amazon ECR
   │
   ├── CD Pipeline
   │     ├── Update Kubernetes Deployments
   │     ├── Trigger Rolling Updates
   │
   └── Rollback Workflow
         ├── Rollback Backend / Frontend / All
         └── Rollback to Specific Revision (Optional)
```

## 🚀 Provision AWS Infra 

This repository provisions **AWS infrastructure using Terraform** with a **remote S3 backend** for secure and collaborative state management.

The project follows a **multi-environment IaC layout**, with **`dev`** as the active environment.

## 🗺️ Application Architecture Diagram

<img width="1459" height="696" alt="image" src="https://github.com/user-attachments/assets/7a6ccffb-314b-4e2d-9143-d72d1a095066" />

> 🧠 **Architecture Highlights**
>
> * Amazon **EKS** for container orchestration
> * Amazon **RDS** for managed database services
> * Modular Terraform design for reusability
> * Remote backend for state locking & versioning

## ✅ Prerequisites

Before proceeding, ensure the following tools and permissions are available:

### 🛠️ Tools

* **Terraform ≥ 1.6**
* **AWS CLI ≥ v2**
* **kubectl** (for EKS access)

### 🔐 AWS IAM Permissions

Your AWS identity (IAM user or assumed role) must be able to:

* Create & manage **S3 buckets**
* Provision **EKS, RDS, IAM, VPC**, and supporting resources
* Read/write Terraform state objects

<img width="848" height="155" alt="image" src="https://github.com/user-attachments/assets/7c58ddb9-5e8d-4660-9927-b0673e1d125d" />

## 📁 Directory Structure (Relevant)

```text
Iac/
├── env
│   └── dev
│       ├── backend.config.hcl
│       ├── data.tf
│       ├── locals.tf
│       ├── main.tf
│       ├── output.tf
│       ├── provider.tf
│       └── varible.tf
├── modules
│   ├── eks
│   │   ├── data.tf
│   │   ├── main.tf
│   │   ├── output.tf
│   │   └── varible.tf
│   └── rds
│       ├── main.tf
│       ├── output.tf
│       └── varible.tf
└── vars
    └── dev.terraform.tfvars
```

> 🧩 **Design Approach**
>
> * `modules/` → Reusable infrastructure components
> * `env/dev/` → Environment-specific orchestration
> * `vars/` → Environment-specific values (kept separate for safety)

## 🪣 Step 1: Create S3 Backend Bucket (One-Time Setup)

Terraform state is stored remotely in **Amazon S3** to support:

* Team collaboration
* State versioning
* Disaster recovery

Create the bucket **once** before running Terraform:

```bash
aws s3api create-bucket \
  --bucket tfstate-dev-<unique-name> \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1
```

### 🔄 Enable Versioning (Highly Recommended)

```bash
aws s3api put-bucket-versioning \
  --bucket tfstate-dev-<unique-name> \
  --versioning-configuration Status=Enabled
```
## ⚙️ Step 2: Configure Terraform Backend

Update the backend configuration file:

📄 **`env/dev/backend.config.hcl`**

```hcl
bucket  = "tfstate-dev-<unique-name>"
key     = "eks/dev/terraform.tfstate"
region  = "ap-south-1"
encrypt = true
```
## 🔍 Step 3: Initialize & Validate Terraform

Run the following commands from `env/dev`:

```bash
terraform init -backend-config=backend.config.hcl
terraform validate
```

This will:

* 🔐 Configure the **remote S3 backend**
* 📦 Download required providers
* 🧱 Initialize Terraform modules
* ✅ Validate configuration syntax

<img width="1695" height="962" alt="image" src="https://github.com/user-attachments/assets/74934c5a-cd4b-4173-80a9-210a9715a811" />

## 🧪 Step 4: Plan & Apply Infrastructure

### Generate Execution Plan

```bash
terraform plan \
  -var-file=../../vars/dev.terraform.tfvars \
  -out=tfplan
```

<img width="480" height="471" alt="image" src="https://github.com/user-attachments/assets/1e09a766-5013-44c5-88f6-9652af509f88" />

### 🚀 Apply Infrastructure

After reviewing the plan:

```bash
terraform apply tfplan
terraform output
```

Terraform will:

* Provision AWS infrastructure
* Persist state securely in S3
* Output important values (EKS cluster name, endpoints, etc.)

> 📝 **Note**
> Save the Terraform outputs — they are required for:
>
> * Kubernetes access
> * CI/CD pipelines
> * Application deployment

## ☸️ Step 5: Access EKS & Create a Backed env Secrets

Update kubeconfig:

```bash
aws eks update-kubeconfig \
  --name <your-eks-cluster-name> \
  --region ap-south-1
kubectl cluster-info
```
<img width="1848" height="130" alt="image" src="https://github.com/user-attachments/assets/624147b5-bc63-41ff-a3c6-59779325a842" />

```bash
kubectl create secret generic backend-secret \
    --from-literal=DOMAIN=localhost \
    --from-literal=ENVIRONMENT=local \
    --from-literal=PROJECT_NAME="Full Stack FastAPI Project" \
    --from-literal=STACK_NAME=full-stack-fastapi-project \
    --from-literal=BACKEND_CORS_ORIGINS="http://localhost,http://localhost:5173,http://assignment.jay.cloud-ip" \
    --from-literal=SECRET_KEY=harnesha2244 \
    --from-literal=FIRST_SUPERUSER=harnesha22@gmail.com \
    --from-literal=FIRST_SUPERUSER_PASSWORD=harnesha22 \
    --from-literal=USERS_OPEN_REGISTRATION=True \
    --from-literal=SMTP_HOST= \
    --from-literal=SMTP_USER= \
    --from-literal=SMTP_PASSWORD= \
    --from-literal=EMAILS_FROM_EMAIL=info@example.com \
    --from-literal=SMTP_TLS=True \
    --from-literal=SMTP_SSL=False \
    --from-literal=SMTP_PORT=587 \
    --from-literal=POSTGRES_SERVER=database-1.xxx.ap-south-1.rds.amazonaws.com \
    --from-literal=POSTGRES_PORT=5432 \
    --from-literal=POSTGRES_DB=assignmentdevdb \
    --from-literal=POSTGRES_USER=postgres \
    --from-literal=POSTGRES_PASSWORD= \
 --dry-run=client -o yaml > secret.yaml
 kubectl apply -f secret.yaml
```

## 🚀 CI/CD & Application Rollback Workflow (Automated)

After infrastructure deployment, take a notes of **Terraform outputs** to configure env in workflows.

### ⚙️ GitHub Actions – Configuration

* The following environment variables needs to be configured in both relative ci-cd workflow & rollback workflow to make automated deployment.
* Make sure to add updated role from aws account to perform automated deployment with setting up [OIDC for github actions.](https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws?versionId=free-pro-team%40latest&productId=apps)
* The pipeline iam role should be mapped to the EKS cluster authentication layer.
```
env:
  AWS_REGION: ap-south-1
  ECR_REGISTRY: 935456168005.dkr.ecr.ap-south-1.amazonaws.com
  ECR_BACKEND_REPO: assignment-backend
  ECR_FRONTEND_REPO: assignment-frontend
  EKS_CLUSTER_NAME: assignment-cluster
  VITE_API_URL: http://assignment-api.jay.cloud-ip.cc
  IMAGE_TAG: ${{ github.sha }}
```
```
  - name: Configure AWS credentials
    uses: aws-actions/configure-aws-credentials@v4
    with:
      role-to-assume: arn:aws:iam::935456168005:role/GitHubAction-AssumeRoleWithAction
      aws-region: ${{ env.AWS_REGION }}
```

### CI-CD Pipeline (Automated)

* Once the all env & workflow configuration is done click on the below links to trigger the workflows.
* Manual trigger (workflow dispatch)
* [CI-CD Pipeline workflow](https://github.com/HARNESHA/Genea-Assignment/actions/workflows/pipeline.yaml) 

### 🧪 CI Phase – Image Lifecycle

During CI execution:

* Backend and frontend Docker images are built
* Images are versioned using:

  * Git commit SHA
  * `latest` tag
* Images are pushed to **Amazon ECR**

### ☸️ CD Phase – Application Deployment

After image build:

* Kubernetes deployments are updated automatically
* Rolling updates are triggered in EKS
* Previous versions are retained as revisions


### ♻️ Rollback Workflow (Controlled & Safe)

* To deploy the application to specific version [**Rollback**](https://github.com/HARNESHA/Genea-Assignment/actions/workflows/rollback.yaml) workflow can be trigger mannual mode.
* Select the requried input to rollback deployment to specific version.

| Input       | Description                  |
| ----------- | ---------------------------- |
| `component` | backend / frontend / all     |
| `revision`  | Optional Kubernetes revision |

### 🔁 Supported Rollback Scenarios

#### 🔹 Rollback to Previous Version

* Automatically reverts the selected component
* No revision input required

#### 🔹 Rollback to Specific Version

* Reverts to a known stable Kubernetes revision
* Used for controlled recovery
* Backend and frontend rolled back together
* Ensures compatibility between services

### Configure ALB Ingress

Create an [Ingress resource](https://docs.aws.amazon.com/eks/latest/userguide/lbc-helm.html) configured for AWS ALB:

#### Access the Application

Once the Ingress is applied:

* AWS automatically provisions an **Application Load Balancer**
* ALB DNS name becomes available
* Custom domain (optional) can be mapped via Route53
<img width="1216" height="682" alt="image" src="https://github.com/user-attachments/assets/04a3a35a-09eb-460a-93e9-6e6b4b95600b" />


## 🧠 Key Takeaways

| Area               | Implementation              |
| ------------------ | --------------------------- |
| Infra Provisioning | Terraform                   |
| CI/CD Automation   | GitHub Actions              |
| Container Registry | Amazon ECR                  |
| Orchestration      | Amazon EKS                  |
| Rollback Strategy  | Kubernetes Revision Control |
| Security           | IAM + OIDC                  |

---

