import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.options.pipeline_options import SetupOptions
from transforms.enrich import EnrichData
from transforms.validate import ValidateAndParse
from sinks.bigquery import write_to_bq
from sinks.bigtable import write_to_bigtable

class RuntimeOptions(PipelineOptions):
    @classmethod
    def _add_argparse_args(cls, parser):
        parser.add_argument("--input_topic", required=True)
        parser.add_argument("--dead_letter_topic", required=True)
        parser.add_argument("--output_table", required=True)
        parser.add_argument("--bigtable_instance_id", required=True)
        parser.add_argument("--bigtable_table_id", required=True)

def run():
    options = PipelineOptions(
        streaming=True,
        runner="DataflowRunner"
    )
    options.view_as(SetupOptions).save_main_session = True
    runtime_options = options.view_as(RuntimeOptions)
    project_id = options.get_all_options().get("project")
    input_topic = runtime_options.input_topic
    dead_letter_topic = runtime_options.dead_letter_topic
    output_table = runtime_options.output_table
    bigtable_instance_id = runtime_options.bigtable_instance_id
    bigtable_table_id = runtime_options.bigtable_table_id

    with beam.Pipeline(options=options) as p:

        parsed = (
            p
            | "Read PubSub" >> beam.io.ReadFromPubSub(
                topic=input_topic
            )
            | "Validate" >> beam.ParDo(ValidateAndParse()).with_outputs("dead_letter", main="valid")
        )

        valid = parsed.valid | "Enrich" >> beam.ParDo(EnrichData())
        invalid = parsed.dead_letter

        write_to_bq(valid, output_table)
        write_to_bigtable(valid, project_id, bigtable_instance_id, bigtable_table_id)

        invalid | "DLQ" >> beam.io.WriteToPubSub(
            topic=dead_letter_topic
        )

if __name__ == "__main__":
    run()