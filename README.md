# SRE Observability Platform (GKE + OpenTelemetry)

![Terraform](https://img.shields.io/badge/Terraform-1.5+-purple?style=flat-square&logo=terraform)
![Kubernetes](https://img.shields.io/badge/Kubernetes-1.27+-blue?style=flat-square&logo=kubernetes)
![GCP](https://img.shields.io/badge/GCP-GKE-green?style=flat-square&logo=google-cloud)
![Status](https://img.shields.io/badge/Status-Active_Development-orange?style=flat-square)

A production-ready Internal Developer Platform (IDP) implementing **GitOps principles** and the **OpenTelemetry Observability standard**.

## Architecture
* **Infrastructure:** GKE (Spot Instances) provisioned via **Terraform**.
* **GitOps:** ArgoCD managing the "App of Apps" pattern.
* **Observability:** Full LGTM Stack (Loki, Grafana, Tempo, Mimir/Prometheus).
* **Reliability:** Service Mesh (Istio) and Chaos Engineering (Chaos Mesh).
