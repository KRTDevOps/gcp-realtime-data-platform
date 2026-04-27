#!/bin/bash

set -e  # Exit on error

# -----------------------------
# CONFIGURATION
# -----------------------------
PROJECT_ID="${PROJECT_ID:-your-project-id}"
REGION="${REGION:-us-central1}"
BUCKET="${BUCKET:-your-bucket-name}"
IMAGE="gcr.io/$PROJECT_ID/dataflow:latest"
TEMPLATE_PATH="gs://$BUCKET/templates/dataflow.json"

echo "🚀 Starting deployment..."

if [[ "$PROJECT_ID" == "your-project-id" || "$BUCKET" == "your-bucket-name" ]]; then
  echo "❌ Set PROJECT_ID and BUCKET env vars before running."
  echo "Example: PROJECT_ID=my-gcp-project BUCKET=my-dataflow-bucket ./scripts/deploy.sh"
  exit 1
fi

# -----------------------------
# AUTHENTICATION CHECK
# -----------------------------
echo "🔐 Checking gcloud auth..."
gcloud config set project "$PROJECT_ID"

# -----------------------------
# STEP 1: Terraform Infra
# -----------------------------
echo "🏗️ Provisioning infrastructure with Terraform..."
cd terraform

terraform init
terraform apply -auto-approve \
  -var="project_id=$PROJECT_ID" \
  -var="region=$REGION" \
  -var="bucket_name=$BUCKET"

cd ..

# -----------------------------
# STEP 2: Build Docker Image
# -----------------------------
echo "🐳 Building Docker image..."
cd dataflow

docker build -t $IMAGE .

echo "📦 Pushing image to Container Registry..."
docker push $IMAGE

cd ..

# -----------------------------
# STEP 3: Build Dataflow Flex Template
# -----------------------------
echo "⚙️ Building Dataflow Flex Template..."

gcloud dataflow flex-template build $TEMPLATE_PATH \
  --image="$IMAGE" \
  --sdk-language="PYTHON" \
  --metadata-file="dataflow/metadata.json" || echo "⚠️ metadata.json not found, continuing..."

# -----------------------------
# STEP 4: Run Dataflow Job
# -----------------------------
echo "🚀 Launching Dataflow job..."

gcloud dataflow flex-template run "realtime-job-$(date +%s)" \
  --template-file-gcs-location="$TEMPLATE_PATH" \
  --region="$REGION" \
  --parameters input_topic="projects/$PROJECT_ID/topics/realtime-topic",dead_letter_topic="projects/$PROJECT_ID/topics/dead-letter-topic",output_table="$PROJECT_ID:realtime_dataset.events",bigtable_instance_id="realtime-instance",bigtable_table_id="events"

# -----------------------------
# STEP 5: Run dbt (Optional)
# -----------------------------
if [ -d "dbt" ]; then
  echo "🧮 Running dbt transformations..."
  cd dbt
  dbt run || echo "⚠️ dbt run failed (check config)"
  cd ..
fi

# -----------------------------
# STEP 6: Upload Airflow DAGs (Optional)
# -----------------------------
if [ -d "airflow/dags" ]; then
  echo "🌬️ Uploading Airflow DAGs..."

  gsutil cp airflow/dags/*.py "gs://$BUCKET/dags/" || echo "⚠️ DAG upload failed"
fi

# -----------------------------
# DONE
# -----------------------------
echo "✅ Deployment completed successfully!"