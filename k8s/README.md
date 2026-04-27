# Kubernetes Deployment Guide

This folder contains a Kustomize base and environment overlays for deploying `realtime-api` to GKE.

## Structure

- `k8s/kustomization.yaml`: base resources
- `k8s/realtime-api-deployment.yaml`: base deployment
- `k8s/realtime-api-service.yaml`: base service
- `k8s/overlays/dev`: dev overrides (namespace, name prefix, replicas, image tag)
- `k8s/overlays/prod`: prod overrides (namespace, name prefix, replicas, resources)

## Prerequisites

- `gcloud` authenticated to the target project
- `kubectl` installed
- `kustomize` installed (or use `kubectl apply -k`)
- GKE cluster created (Terraform optional GKE module can provision this)

## Configure Cluster Access

```bash
gcloud container clusters get-credentials realtime-gke --region us-central1 --project <your-project-id>
```

## Deploy

Deploy to development:

```bash
kubectl create namespace realtime-dev --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -k k8s/overlays/dev
```

Deploy to production:

```bash
kubectl create namespace realtime-prod --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -k k8s/overlays/prod
```

## Update

1. Update image tag in:
   - `k8s/overlays/dev/deployment-patch.yaml` or
   - `k8s/overlays/prod/deployment-patch.yaml`
2. Re-apply the target overlay:

```bash
kubectl apply -k k8s/overlays/dev
# or
kubectl apply -k k8s/overlays/prod
```

Rolling restart (if config changed but image tag did not):

```bash
kubectl rollout restart deployment/dev-realtime-api -n realtime-dev
# or
kubectl rollout restart deployment/prod-realtime-api -n realtime-prod
```

## Verify

```bash
kubectl get pods -n realtime-dev
kubectl get svc -n realtime-dev
kubectl rollout status deployment/dev-realtime-api -n realtime-dev
```

## Rollback

View rollout history:

```bash
kubectl rollout history deployment/dev-realtime-api -n realtime-dev
```

Rollback to previous revision:

```bash
kubectl rollout undo deployment/dev-realtime-api -n realtime-dev
```

Rollback to a specific revision:

```bash
kubectl rollout undo deployment/dev-realtime-api --to-revision=2 -n realtime-dev
```

> For production, replace `dev-realtime-api` and `realtime-dev` with `prod-realtime-api` and `realtime-prod`.
