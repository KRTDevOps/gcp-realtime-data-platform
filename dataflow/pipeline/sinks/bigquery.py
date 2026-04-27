import apache_beam as beam

def write_to_bq(pcollection, output_table):

    return (
        pcollection
        | "Write to BigQuery" >> beam.io.WriteToBigQuery(
            table=output_table,
            schema="""
                user_id:INTEGER,
                event:STRING,
                timestamp:TIMESTAMP,
                processed_at:STRING,
                event_type:STRING
            """,
            write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND,
            additional_bq_parameters={
                "timePartitioning": {
                    "type": "DAY",
                    "field": "timestamp"
                }
            }
        )
    )