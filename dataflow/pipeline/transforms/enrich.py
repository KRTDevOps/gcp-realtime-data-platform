import apache_beam as beam
from datetime import datetime, timezone

class EnrichData(beam.DoFn):
    def process(self, element):
        # Emit RFC3339 UTC timestamp for BigQuery/Bigtable consistency.
        element["processed_at"] = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
        element["event_type"] = element.get("event", "unknown")
        yield element