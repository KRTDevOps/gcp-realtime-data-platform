import apache_beam as beam

def to_bigtable_mutation(row):
    return (
        str(row["user_id"]).encode(),
        {
            b"cf1": {
                b"event": row["event"].encode(),
                b"timestamp": str(row["timestamp"]).encode(),
                b"processed_at": row["processed_at"].encode()
            }
        }
    )

def write_to_bigtable(pcollection, project_id, instance_id, table_id):

    return (
        pcollection
        | "Format Bigtable" >> beam.Map(to_bigtable_mutation)
        | "Write Bigtable" >> beam.io.WriteToBigTable(
            project_id=project_id,
            instance_id=instance_id,
            table_id=table_id
        )
    )