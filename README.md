# Platform infrastructure – Kubernetes, Helm & Terraform showcase

Infrastructure samples written for **Telemaco**, a multi-tenant conversational AI platform, plus a generic
Azure module that reflects how I build enterprise AKS platforms. All names, IDs and endpoints are placeholders.

## Contents

```
helm/chatbot-engine/                   Helm chart: API Deployment, Redis StatefulSet, reminder CronJob, NetworkPolicies
terraform/modules/aks-private/         Terraform module: private AKS for a hub-and-spoke Landing Zone
terraform/examples/aks/                Example usage with AcrPull role assignment
pipelines/terraform-plan-approve-apply.yml   Azure DevOps: plan → manual approval → apply the reviewed plan
```

## Helm chart highlights

- **Separate selector labels per component** (`app.kubernetes.io/component: api | redis`): the API Service can never
  route traffic to Redis. This fixed real intermittent connection errors caused by shared selectors.
- **Stateless API pods**: sessions and quotas live in Redis, so any replica serves the next turn.
- **Zero-downtime rolling updates** (`maxUnavailable: 0`) with readiness and liveness probes.
- **Redis password generated once** and preserved across upgrades with `lookup` + `resource-policy: keep`.
- **Reminder CronJob** every 10 minutes, `concurrencyPolicy: Forbid`, token-protected internal endpoint.
- **NetworkPolicies**: API reachable only from the gateway namespace, Redis only from the API.
- Non-root containers, dropped capabilities, secrets only via existing Kubernetes Secrets.

```bash
helm lint helm/chatbot-engine
helm template demo helm/chatbot-engine
```

## Terraform AKS module highlights

- Private API server with the central `privatelink` DNS zone of the hub.
- Entra ID with Azure RBAC, local accounts disabled, **Workload Identity** (OIDC issuer) instead of secrets.
- Azure CNI **Overlay** with Azure network policy; egress forced through the hub firewall (`userDefinedRouting`).
- Zonal system pool restricted to critical add-ons, autoscaling user pools from a map.
- Container Insights, Managed Prometheus metrics and control-plane diagnostics to Log Analytics.

## Pipeline highlights

- One service connection and one Terraform state per environment.
- `fmt` and `validate` gates, plan published as an artifact, **manual approval**, then apply of exactly the reviewed plan.
- Self-hosted agents inside the private network, so deployments reach private endpoints.
# telemaco-platform-infra
