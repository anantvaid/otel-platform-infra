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

![Status](https://img.shields.io/badge/Status-Completed-success?style=flat-square)

**A production-grade Internal Developer Platform (IDP) built on GKE, designed under strict real-world constraints: cost optimization, keyless identity, GitOps workflows, and VPC-native networking.**

This repository documents the evolution of a real-world SRE platform — starting from infrastructure, then bootstrapping identity, ingress, and GitOps, and progressively layering in observability and reliability primitives.

---

## Architecture & Platform Capabilities (Phases 1-8 Complete)

* **Infrastructure & Compute:** GKE running on preemptible/Spot Instances, provisioned via Terraform.
* **Security & Identity:** Keyless Workload Identity Federation (GCP), automated TLS via Cert-Manager (Let's Encrypt), and policy enforcement via **Kyverno** (blocking root containers/privilege escalation).
* **Modern Networking:** Native GKE Gateway API (`HTTPRoute`) utilizing managed Google Cloud Load Balancers.
* **GitOps Delivery:** 100% declarative state managed by **ArgoCD** using the App-of-Apps pattern.
* **Progressive Deployment:** Canary release automation managed by **Argo Rollouts**.
* **Observability (LGTM Stack):** Full-stack monitoring featuring Prometheus (Metrics), Loki (Logs), Tempo (Traces), and Grafana (Dashboards).
* **FinOps & Cost Visibility:** Real-time workload allocation and cluster cost monitoring via **Kubecost**.
* **Reliability & Chaos Engineering:** Continuous resilience testing and automated failure injection via **Chaos Mesh**.

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

### 8. Initialize Root App (App of Apps)

```bash
kubectl apply -f kubernetes/bootstrap/root-app.yaml
```

---

## Repository Structure

```text
.
├── kubernetes
│   ├── apps
│   │   ├── go-app.yaml
│   │   ├── manifest-gen
│   │   │   ├── deployment.yaml.disabled
│   │   │   ├── namespace.yaml
│   │   │   ├── networking.yaml
│   │   │   ├── rollout.yaml
│   │   │   └── service.yaml.disabled
│   │   ├── otel-demo-values.yaml
│   │   ├── otel-demo.yaml
│   │   ├── shop-health-check.yaml
│   │   └── shop-route.yaml
│   ├── bootstrap
│   │   ├── apps.yaml
│   │   ├── chaos.yaml
│   │   ├── finops.yaml
│   │   ├── manifest-gen.yaml
│   │   ├── observability.yaml
│   │   ├── rollouts.yaml
│   │   ├── root-app.yaml
│   │   ├── security.yaml
│   │   └── updater.yaml
│   ├── deployments
│   │   └── go-app
│   │       ├── deployment.yaml
│   │       ├── healthcheck.yaml
│   │       ├── kustomization.yaml
│   │       ├── namespace.yaml
│   │       ├── route.yaml
│   │       └── service.yaml
│   └── platform
│       ├── cert-management
│       │   ├── certificate.yaml
│       │   └── cluster-issuer.yaml
│       ├── chaos
│       │   ├── Chart.yaml
│       │   └── values.yaml
│       ├── external-secrets
│       │   ├── cluster-secret-store.yaml
│       │   ├── db-secret.yaml
│       │   └── github-pat.yaml
│       ├── finops
│       │   └── kubecost
│       │       ├── Chart.yaml
│       │       ├── httproute.yaml
│       │       └── values.yaml
│       ├── gateway-api
│       │   ├── argocd-health-policy.yaml
│       │   ├── argocd-route.yaml
│       │   └── gateway.yaml
│       ├── image-updater
│       │   ├── Chart.yaml
│       │   └── values.yaml
│       ├── observability
│       │   ├── Chart.yaml
│       │   ├── templates
│       │   │   ├── grafana-health-check.yaml
│       │   │   └── grafana-route.yaml
│       │   └── values.yaml
│       ├── rollouts
│       │   ├── Chart.yaml
│       │   └── values.yaml
│       └── security
│           ├── istio
│           │   ├── Chart.yaml
│           │   └── values.yaml
│           ├── istio-quota.yaml
│           ├── istio.yaml
│           ├── kyverno
│           │   ├── Chart.yaml
│           │   ├── disallow-root.yaml
│           │   └── values.yaml
│           └── kyverno.yaml
├── README.md
├── src
│   └── go-app
│       ├── Dockerfile
│       ├── go.mod
│       └── main.go
└── terraform
    ├── argocd.tf
    ├── cert-manager.tf
    ├── external_secrets.tf
    ├── github-oidc.tf
    ├── gke.tf
    ├── iam.tf
    ├── outputs.tf
    ├── providers.tf
    ├── registry.tf
    ├── terraform.tfstate
    ├── terraform.tfstate.1769454707.backup
    ├── terraform.tfstate.1769454708.backup
    ├── terraform.tfstate.1769972678.backup
    ├── terraform.tfstate.backup
    ├── terraform.tfvars
    ├── tf-key.json
    ├── variables.tf
    └── vpc.tf
```

---

## Roadmap

- [x] GKE infrastructure (Spot nodes, VPC-native) via Terraform
- [x] Keyless identity (Workload Identity) & Gateway API setup
- [x] GitOps bootstrap with ArgoCD
- [x] Gateway API + TLS bootstrapping
- [x] LGTM observability stack
- [x] Service mesh (Istio)
- [x] Security & Governance (Kyverno policy enforcement)
- [x] Progressive Deployment (Argo Rollouts for Canary releases)
- [x] FinOps (Kubecost implementation)
- [x] Chaos engineering (Chaos Mesh resilience testing)

---

## The Dev Log

I am documenting the entire build process, including the architectural decisions and trade-offs, in a technical blog series.

Part 1: [Designing a Cost-Constrained, Production-Grade GKE Cluster](https://techtalkswithanant.hashnode.dev/designing-a-cost-constrained-production-grade-gke-cluster-with-terraform)

Part 2: [Beyond Ingress: Building a "Keyless" Platform with GKE Gateway API](https://techtalkswithanant.hashnode.dev/beyond-ingress-building-a-keyless-platform-with-gke-gateway-api)

Part 3: [The LGTM Stack: From Blind Containers to Full Visibility](https://techtalkswithanant.hashnode.dev/the-lgtm-stack-from-blind-containers-to-full-visibility)

Part 4: [The CI/CD Factory: Zero-Touch GKE Deployments with ArgoCD & GitHub Actions](https://techtalkswithanant.hashnode.dev/zero-touch-gke-deployments)

Part 5: [Zero Trust Security in Kubernetes: Kyverno & Istio Ambient](https://techtalkswithanant.hashnode.dev/zero-trust-security-in-kubernetes)

Part 6: [Progressive Delivery in Kubernetes: Argo Rollouts & Istio](https://techtalkswithanant.hashnode.dev/progressive-delivery-in-kubernetes)

Part 7: [FinOps in Kubernetes - Taming the Cloud Bill with Kubecost](https://techtalkswithanant.hashnode.dev/kubernetes-finops-cost-optimization-kubecost)

Part 8: [Chaos Engineering - Proving Resilience in Kubernetes Platform](https://techtalkswithanant.hashnode.dev/chaos-engineering-proving-resilience-in-kubernetes-platform)

---

## License

This project is intended for learning, experimentation, and platform design reference.
