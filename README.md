# SRE Observability Platform (GKE + OpenTelemetry)

![Terraform](https://img.shields.io/badge/Terraform-1.5+-purple?style=flat-square&logo=terraform)
![Kubernetes](https://img.shields.io/badge/Kubernetes-1.27+-blue?style=flat-square&logo=kubernetes)
![GCP](https://img.shields.io/badge/GCP-GKE-green?style=flat-square&logo=google-cloud)
![GitOps](https://img.shields.io/badge/GitOps-ArgoCD-red?style=flat-square&logo=argo)
![Gateway API](https://img.shields.io/badge/Gateway%20API-GKE-blue?style=flat-square&logo=google-cloud)

![Loki](https://img.shields.io/badge/Logs-Loki-blueviolet?style=flat-square&logo=grafana)
![Grafana](https://img.shields.io/badge/Dashboards-Grafana-orange?style=flat-square&logo=grafana)
![Tempo](https://img.shields.io/badge/Tracing-Tempo-yellow?style=flat-square&logo=grafana)
![Prometheus](https://img.shields.io/badge/Metrics-Prometheus-red?style=flat-square&logo=prometheus)

![Status](https://img.shields.io/badge/Status-Active_Development-orange?style=flat-square)

**A production-grade Internal Developer Platform (IDP) built on GKE, designed under strict real-world constraints: cost optimization, keyless identity, GitOps workflows, and VPC-native networking.**

This repository documents the evolution of a real-world SRE platform — starting from infrastructure, then bootstrapping identity, ingress, and GitOps, and progressively layering in observability and reliability primitives.

---

## Platform Capabilities (As of Phase 2)

- **Keyless Workload Identity** using GCP Workload Identity Federation  
- **GitOps-driven deployments** via ArgoCD (App-of-Apps pattern)  
- **Modern ingress** using GKE Gateway API with managed load balancers  
- **Automated TLS** using Cert-Manager and Let’s Encrypt  
- **Secure secret management** with Google Secret Manager + External Secrets  
- **Cost-constrained by design**, running on Spot nodes  

---

## Observability Stack (Phase 3 – In Progress)

- **Metrics:** Prometheus  
- **Logs:** Loki  
- **Traces:** Tempo  
- **Visualization:** Grafana  
- **Instrumentation:** OpenTelemetry  

---

## Architecture Overview

- **Infrastructure:** GKE (Spot Instances) provisioned via Terraform  
- **Identity:** Workload Identity Federation (Keyless)  
- **Ingress:** GKE Gateway API + Cert-Manager  
- **GitOps:** ArgoCD  
- **Observability:** LGTM Stack  

---

## Getting Started (Fresh Installation)

### Prerequisites

- Google Cloud SDK (`gcloud`)
- Terraform 1.14+
- A GCP Project

---

### 1. Create Terraform Identity (One-Time Setup)

Terraform should not run using personal credentials or application-default credentials (ADC).

```bash
export GOOGLE_CLOUD_PROJECT="sre-portfolio-platform"

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
```

Generate a short-lived key:

```bash
gcloud iam service-accounts keys create tf-key.json \
  --iam-account=terraform-deployer@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com
```

> Never commit `tf-key.json`. It must be listed in `.gitignore`.

---

### 2. Provision Infrastructure

```bash
terraform init
terraform plan
terraform apply
```

Configure kubectl access:

```bash
gcloud container clusters get-credentials sre-portfolio-cluster \
  --zone us-central1-a \
  --project sre-portfolio-platform
```

---

### 3. Bootstrap Gateway API (HTTP Only)

To avoid the HTTPS / certificate deadlock, the Gateway and ArgoCD routes are bootstrapped **without HTTPS first**.

> Comment out HTTPS-related sections in:
> - `kubernetes/platform/gateway-api/gateway.yaml`
> - `kubernetes/platform/gateway-api/argocd-route.yaml`

```bash
kubectl apply -f kubernetes/platform/gateway-api/gateway.yaml
kubectl apply -f kubernetes/platform/gateway-api/argocd-route.yaml
kubectl apply -f kubernetes/platform/gateway-api/argocd-health-policy.yaml
```

---

### 4. Update DNS

Point your domain’s **A record** to the static IP address created by the Gateway.

---

### 5. Bootstrap TLS with Cert-Manager

```bash
kubectl apply -f kubernetes/platform/cert-management/cluster-issuer.yaml
kubectl apply -f kubernetes/platform/cert-management/certificate.yaml
```

Wait **3–5 minutes** for the TLS certificate to be created.

---

### 6. Enable HTTPS on the Gateway

Uncomment HTTPS sections and re-apply:

```bash
kubectl apply -f kubernetes/platform/gateway-api/argocd-route.yaml
kubectl apply -f kubernetes/platform/gateway-api/gateway.yaml
```

Wait another **3–5 minutes** for SSL propagation across edge routers.

---

### 7. Access ArgoCD

```bash
kubectl get secret argocd-initial-admin-secret \
  -n argocd \
  -o jsonpath='{.data.password}' | base64 -d
```

---

## Repository Structure

```text
.
├── terraform/                  # Infrastructure & identity bootstrap
│   ├── gke.tf                  # GKE cluster and node pools
│   ├── vpc.tf                  # VPC & subnet definitions
│   ├── iam.tf                  # Service accounts & IAM bindings
│   ├── argocd.tf               # ArgoCD installation
│   ├── cert-manager.tf         # Cert-Manager installation
│   ├── external_secrets.tf     # External Secrets installation
│   ├── providers.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── kubernetes/                 # GitOps-managed manifests
│   ├── bootstrap/              # ArgoCD App-of-Apps bootstrap
│   │   ├── root-app.yaml
│   │   ├── apps.yaml
│   │   └── observability.yaml
│   │
│   ├── platform/               # Platform-level components
│   │   ├── gateway-api/         # Gateway, routes & health checks
│   │   ├── cert-management/     # ClusterIssuer & Certificates
│   │   ├── external-secrets/    # SecretStore & ExternalSecrets
│   │   └── observability/       # Grafana & observability routing
│   │
│   └── apps/                   # Application workloads
│       ├── otel-demo.yaml
│       ├── otel-demo-values.yaml
│       ├── shop-route.yaml
│       └── shop-health-check.yaml
│
└── README.md
```

---

## Roadmap

- [x] GKE infrastructure (Spot nodes, VPC-native)
- [x] Keyless identity with Workload Identity
- [x] GitOps bootstrap with ArgoCD
- [x] Gateway API + TLS bootstrapping
- [x] LGTM observability stack
- [ ] SLOs & alerting
- [ ] Service mesh (Istio)
- [ ] Chaos engineering

---

## The Dev Log

I am documenting the entire build process, including the architectural decisions and trade-offs, in a technical blog series.

Part 1: [Designing a Cost-Constrained, Production-Grade GKE Cluster](https://techtalkswithanant.hashnode.dev/designing-a-cost-constrained-production-grade-gke-cluster-with-terraform)

Part 2: [Beyond Ingress: Building a "Keyless" Platform with GKE Gateway API](https://techtalkswithanant.hashnode.dev/beyond-ingress-building-a-keyless-platform-with-gke-gateway-api)

---

## License

This project is intended for learning, experimentation, and platform design reference.
