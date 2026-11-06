# Servarr kubernetes setup

This repository contains the Kubernetes manifests for deploying the Servarr suite of applications (Sonarr, Radarr,
Lidarr, Readarr, and Prowlarr) in a Kubernetes cluster. The setup is designed to be simple and modular, allowing you to
easily deploy and manage these applications in your environment.

The Prowlarr chart reuses the Cloudflare GCP Secret Manager entries configured in `infra-cluster`:
`cloudflare-account-id` and `cloudflare-api-token`, read through `gcp-cluster-secret-store`. External Secrets Operator
creates the `cloudflare-gateway-creds` Kubernetes Secret in the chart's release namespace, as required by its
Cloudflare Gateway. These are the chart defaults; override `gateway.externalSecret` only if your cluster uses different
secret names or a different ClusterSecretStore.

Grafana dashboards are generated from `dashboards/main.jsonnet`. Put infrastructure dashboards in the
`infra-dashboards` ConfigMap; its `grafana_folder: infra` annotation places them in Grafana's `infra` folder once the
corresponding Grafana sidecar settings in `infra-cluster` are applied.