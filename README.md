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