# Genea DevSecOps Assignment

## 🚀 Terraform Deployment Guide (Dev Environment)

This repository provisions **AWS infrastructure using Terraform** with a **remote S3 backend** for secure and collaborative state management.

The project follows a **multi-environment IaC layout**, with **`dev`** as the active environment.

---

## 🗺️ Application Architecture Diagram

<img width="1459" height="696" alt="image" src="https://github.com/user-attachments/assets/7a6ccffb-314b-4e2d-9143-d72d1a095066" />

> 🧠 **Architecture Highlights**
>
> * Amazon **EKS** for container orchestration
> * Amazon **RDS** for managed database services
> * Modular Terraform design for reusability
> * Remote backend for state locking & versioning

---

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

---

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

---

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
---

## ⚙️ Step 2: Configure Terraform Backend

Update the backend configuration file:

📄 **`env/dev/backend.config.hcl`**

```hcl
bucket  = "tfstate-dev-<unique-name>"
key     = "eks/dev/terraform.tfstate"
region  = "ap-south-1"
encrypt = true
```
---

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

---

## 🧪 Step 4: Plan & Apply Infrastructure

### Generate Execution Plan

```bash
terraform plan \
  -var-file=../../vars/dev.terraform.tfvars \
  -out=tfplan
```

<img width="480" height="471" alt="image" src="https://github.com/user-attachments/assets/1e09a766-5013-44c5-88f6-9652af509f88" />

---

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

---

## ☸️ Step 5: Access EKS & Deploy Application

Update kubeconfig:

```bash
aws eks update-kubeconfig \
  --name <your-eks-cluster-name> \
  --region ap-south-1
```

Verify cluster access:

```bash
kubectl cluster-info
```

---

## ♻️ Rollback, Updates & Cleanup

### 🔄 Infrastructure Changes

* Modify Terraform code
* Re-run `terraform plan` and `terraform apply`
* Terraform safely performs **incremental updates**

### 🧨 Destroy Infrastructure (If Required)

```bash
terraform destroy \
  -var-file=../../vars/dev.terraform.tfvars
```
