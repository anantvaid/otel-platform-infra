# SRE Observability Platform (GKE + OpenTelemetry)

![Terraform](https://img.shields.io/badge/Terraform-1.5+-purple?style=flat-square&logo=terraform)
![Kubernetes](https://img.shields.io/badge/Kubernetes-1.27+-blue?style=flat-square&logo=kubernetes)
![GCP](https://img.shields.io/badge/GCP-GKE-green?style=flat-square&logo=google-cloud)
![Status](https://img.shields.io/badge/Status-Active_Development-orange?style=flat-square)

**A production-grade Internal Developer Platform (IDP) built on GKE, designed under strict real-world constraints: cost optimization (Spot VMs), keyless security, and VPC-native networking.**

This project is a capstone journey to build a complete SRE platform from scratch — moving beyond “Hello World” tutorials to tackle real engineering challenges such as quota management, secret rotation, and circular dependencies during GitOps bootstrapping.

---

## Architecture

- **Infrastructure:** GKE (Spot Instances) provisioned via **Terraform**
- **GitOps:** ArgoCD using the App-of-Apps pattern
- **Observability:** LGTM Stack (Loki, Grafana, Tempo, Mimir / Prometheus)
- **Reliability:** Istio Service Mesh and Chaos Mesh

---

## Getting Started

### Prerequisites

- Google Cloud SDK (gcloud)
- Terraform 1.14+
- A GCP Project

### 1. Clone the Repository

```bash
git clone https://github.com/anantvaid/otel-platform-infra
cd otel-platform-infra
```

### 2. Create a Dedicated Terraform Service Account (Recommended)

Terraform should not run using personal credentials or application-default credentials (ADC).
Instead, create a **dedicated service account** with scoped permissions.

```bash
export GOOGLE_CLOUD_PROJECT="your-gcp-project-id"

gcloud iam service-accounts create terraform-deployer \
  --display-name="Terraform Infrastructure Deployer"
```

Grant only the required roles:

```bash
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
  --member="serviceAccount:terraform-deployer@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com" \
  --role="roles/container.admin"

gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
  --member="serviceAccount:terraform-deployer@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com" \
  --role="roles/compute.admin"

gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
  --member="serviceAccount:terraform-deployer@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"

gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
  --member="serviceAccount:terraform-deployer@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com" \
  --role="roles/storage.admin"
```

Generate a service account key for Terraform:

```bash
gcloud iam service-accounts keys create tf-key.json \
  --iam-account=terraform-deployer@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com
```

> **Security Note:**
> - Store `tf-key.json` securely
> - Ensure it is listed in `.gitignore`
> - Never commit this file to Git

---

### 3. Configure Secrets (The Secure Way)

Sensitive variables are never committed to Git.

1. Rename the example variables file:

```bash
mv terraform/terraform.tfvars.example terraform/terraform.tfvars
```

2. Update the project ID:

```terraform
project_id = "your-gcp-project-id"
```

Terraform uses the `tf-key.json` file for authentication via the Google provider.

---

### 4. Provision Infrastructure

```bash
cd terraform
terraform init
terraform apply
```

---

### 5. Connect to the Cluster

```bash
gcloud container clusters get-credentials sre-portfolio-cluster --zone us-central1-a
kubectl get nodes
```

---

## Repository Structure

```text
.
├── terraform/          # Infrastructure as Code
│   ├── gke.tf          # Cluster & Node configuration
│   ├── vpc.tf          # Networking & firewall rules
│   ├── argocd.tf       # GitOps bootstrap
│   ├── variables.tf   # Variable definitions
│   └── ...
├── kubernetes/         # Kubernetes manifests
│   └── platform/       # App-of-Apps bootstrap manifests
└── README.md
```

---

## Roadmap

- [x] GKE infrastructure with Spot nodes
- [ ] GitOps bootstrap with ArgoCD
- [ ] External Secrets with GCP Secret Manager
- [ ] LGTM observability stack
- [ ] Service Mesh (Istio)
- [ ] SLOs and alerting
- [ ] Chaos engineering

---

## License

This project is intended for learning and demonstration purposes.
