from airflow import DAG
from airflow.providers.google.cloud.operators.dataflow import DataflowStartFlexTemplateOperator
from airflow.utils.dates import days_ago
from datetime import timedelta
from airflow.models import Variable

PROJECT_ID = Variable.get("project_id", default_var="your-project-id")
REGION = Variable.get("region", default_var="us-central1")
BUCKET = Variable.get("composer_bucket", default_var="your-bucket-name")
TEMPLATE_PATH = f"gs://{BUCKET}/templates/dataflow.json"

default_args = {
    "owner": "data-engineering",
    "depends_on_past": False,
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    dag_id="dataflow_streaming_dag",
    default_args=default_args,
    description="Launch streaming Dataflow pipeline",
    schedule_interval=None,  # Trigger manually or via API
    start_date=days_ago(1),
    catchup=False,
    tags=["dataflow", "streaming"],
) as dag:

    start_streaming_job = DataflowStartFlexTemplateOperator(
        task_id="start_streaming_dataflow",
        body={
            "launchParameter": {
                "jobName": "realtime-streaming-job",
                "containerSpecGcsPath": TEMPLATE_PATH,
                "parameters": {
                    "input_topic": f"projects/{PROJECT_ID}/topics/realtime-topic",
                    "dead_letter_topic": f"projects/{PROJECT_ID}/topics/dead-letter-topic",
                    "output_table": f"{PROJECT_ID}:realtime_dataset.events",
                    "bigtable_instance_id": "realtime-instance",
                    "bigtable_table_id": "events",
                },
                "environment": {
                    "maxWorkers": 10,
                    "machineType": "n1-standard-2"
                },
            }
        },
        location=REGION,
        project_id=PROJECT_ID,
    )

    start_streaming_job