## Realtime Data Platform (GCP)

### Project Flow

`Pub/Sub -> Dataflow (parse -> validate -> enrich) -> BigQuery + Bigtable`

`BigQuery raw events -> dbt staging -> dbt marts -> BI`

`Cloud Composer (Airflow) -> triggers Dataflow Flex template jobs`

### Deploy

Set variables and run the deployment script:

```bash
export PROJECT_ID="your-gcp-project-id"
export REGION="us-central1"
export BUCKET="your-dataflow-artifact-bucket"

chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

The script automates:

`Terraform infra -> Docker build/push -> Flex template build -> Dataflow run -> dbt run (optional) -> DAG upload (optional)`

### Run dbt

```bash
cd dbt
dbt debug
dbt run
dbt test
```

### Terraform Version + Lock Strategy

Keep Terraform and providers deterministic in CI and local runs:

- Pin CLI/provider constraints in `terraform/versions.tf`.
- Commit `.terraform.lock.hcl` to source control.
- Refresh lock file intentionally when upgrading providers.

Generate/update lock file locally:

```bash
cd terraform
terraform init
terraform providers lock \
  -platform=linux_amd64 \
  -platform=darwin_amd64 \
  -platform=darwin_arm64 \
  -platform=windows_amd64
```

### Optional Terraform CI Checks

Recommended non-deploy checks (safe to run on PRs):

```bash
cd terraform
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
tflint --init
tflint
```

### Optional GKE Setup

If you also need GKE for serving APIs or custom workloads, enable it via Terraform variables:

```bash
cd terraform
terraform apply \
  -var="project_id=<your-project-id>" \
  -var="bucket_name=<your-dataflow-bucket>" \
  -var="enable_gke=true"
```

New Terraform files:

- `terraform/gke.tf`: optional GKE cluster and node pool.
- `terraform/outputs.tf`: cluster name and endpoint outputs.

Baseline Kubernetes manifests (edit image and env values before apply):

- `k8s/realtime-api-deployment.yaml`
- `k8s/realtime-api-service.yaml`

Example apply:

```bash
gcloud container clusters get-credentials realtime-gke --region us-central1 --project <your-project-id>
kubectl apply -f k8s/realtime-api-deployment.yaml
kubectl apply -f k8s/realtime-api-service.yaml
```

### CI/CD Kubernetes Promotion

`cicd/github-actions.yml` now deploys Kubernetes overlays automatically:

- PR merged to `main` -> deploys `k8s/overlays/dev`
- tag push `v*` (example: `v1.0.0`) -> deploys `k8s/overlays/prod`

Required GitHub secrets:

- `GCP_PROJECT_ID`
- `GCP_SA_KEY`

### Governance and Security

- `GOVERNANCE.md`: repository governance and change-control policy
- `SECURITY.md`: vulnerability reporting and security baseline
- `.github/CODEOWNERS`: code ownership and mandatory reviewer mapping
- `.github/dependabot.yml`: automated dependency update configuration
- `.github/pull_request_template.md`: PR checklist including security controls

### IAM, Networking, and Production Workflow

Terraform additions:

- `terraform/iam.tf`: service accounts and baseline IAM role bindings
- `terraform/networking.tf`: optional custom VPC/subnet/firewall controls
- `terraform/versions.tf`: pinned `google` and `google-beta` provider versions

Production deployment workflow:

- `.github/workflows/production-infra.yml`: tag-based or manual production Terraform plan/apply

Additional required GitHub secret for production workflow:

- `GCP_TERRAFORM_BUCKET`