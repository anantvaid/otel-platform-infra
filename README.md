# SRE Observability Platform (GKE + OpenTelemetry)

![Terraform](https://img.shields.io/badge/Terraform-1.14+-purple?style=flat-square&logo=terraform)
![Kubernetes](https://img.shields.io/badge/Kubernetes-1.27+-blue?style=flat-square&logo=kubernetes)
![GCP](https://img.shields.io/badge/GCP-GKE-green?style=flat-square&logo=google-cloud)
![Status](https://img.shields.io/badge/Status-Active_Development-orange?style=flat-square)

**A production-grade Internal Developer Platform (IDP) built on GKE,
designed under strict real-world constraints: cost optimization (Spot
VMs), keyless security, and VPC-native networking.**

This project is a capstone journey to build a complete SRE platform from
scratch --- moving beyond "Hello World" tutorials to tackle real
engineering challenges such as quota management, secret rotation, and
circular dependencies during GitOps bootstrapping.

------------------------------------------------------------------------

## Architecture

-   **Infrastructure:** GKE (Spot Instances) provisioned via
    **Terraform**
-   **GitOps:** ArgoCD using the App-of-Apps pattern
-   **Observability:** LGTM Stack (Loki, Grafana, Tempo, Mimir /
    Prometheus)
-   **Reliability:** Istio Service Mesh and Chaos Mesh

------------------------------------------------------------------------

## Getting Started

### Prerequisites

-   Google Cloud SDK (gcloud)
-   Terraform 1.14+
-   A GCP Project

### 1. Clone the Repository

``` bash
git clone https://github.com/anantvaid/otel-platform-infra
cd otel-platform-infra
```

### 2. Configure Secrets (The Secure Way)

Sensitive variables are never committed to Git.

1.  Rename the example variables file:

``` bash
mv terraform/terraform.tfvars.example terraform/terraform.tfvars
```

2.  Update the project ID:

``` terraform
project_id = "your-gcp-project-id"
```

### 3. Provision Infrastructure

``` bash
cd terraform
terraform init
terraform apply
```

### 4. Connect to the Cluster

``` bash
gcloud container clusters get-credentials sre-portfolio-cluster --zone us-central1-a
kubectl get nodes
```

------------------------------------------------------------------------

## Repository Structure

``` text
.
├── terraform/                # Infrastructure as Code
│   ├── gke.tf                # Cluster & Node configuration
│   ├── outputs.tf            # Output Variables
│   ├── vpc.tf                # Networking & firewall rules
│   ├── providers.tf          # Providers configuration
│   ├── variables.tf          # Variable definitions
│   └── ...
├── kubernetes/               # Kubernetes manifests
│   └── platform/             # App-of-Apps bootstrap manifests
└── README.md
```

------------------------------------------------------------------------

## Roadmap

-   [x] GKE infrastructure with Spot nodes
-   [ ] GitOps bootstrap with ArgoCD
-   [ ] External Secrets with GCP Secret Manager
-   [ ] LGTM observability stack
-   [ ] Service Mesh (Istio)
-   [ ] SLOs and alerting
-   [ ] Chaos engineering

------------------------------------------------------------------------

## License

This project is intended for learning and demonstration purposes.
