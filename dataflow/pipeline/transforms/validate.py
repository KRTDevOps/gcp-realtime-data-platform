import json
import apache_beam as beam
import logging
from datetime import datetime
from utils.schema import REQUIRED_FIELDS, MAX_EVENT_LENGTH


def _parse_timestamp(value):
    if isinstance(value, (int, float)):
        raise ValueError("timestamp must be an ISO-8601 string, not epoch number")
    if not isinstance(value, str):
        raise ValueError("timestamp must be a string")

    normalized = value.replace("Z", "+00:00")
    try:
        datetime.fromisoformat(normalized)
    except ValueError as exc:
        raise ValueError("timestamp must be a valid ISO-8601 datetime") from exc


def _validate_record(record):
    if not isinstance(record, dict):
        raise ValueError("message payload must be a JSON object")

    for field in REQUIRED_FIELDS:
        if field not in record:
            raise ValueError(f"Missing field: {field}")

    try:
        user_id = int(record["user_id"])
    except (TypeError, ValueError) as exc:
        raise ValueError("user_id must be an integer") from exc

    if user_id <= 0:
        raise ValueError("user_id must be > 0")

    event = record["event"]
    if not isinstance(event, str):
        raise ValueError("event must be a string")
    event = event.strip()
    if not event:
        raise ValueError("event must be non-empty")
    if len(event) > MAX_EVENT_LENGTH:
        raise ValueError(f"event length exceeds {MAX_EVENT_LENGTH}")

    _parse_timestamp(record["timestamp"])

    # Normalize values so downstream sinks receive strongly typed/clean values.
    record["user_id"] = user_id
    record["event"] = event
    return record

class ValidateAndParse(beam.DoFn):
    def process(self, element):
        try:
            record = json.loads(element.decode("utf-8"))
            record = _validate_record(record)
            yield record

        except Exception as e:
            logging.error(f"Validation failed: {e}")
            if isinstance(element, bytes):
                dead_letter_payload = element
            else:
                dead_letter_payload = str(element).encode("utf-8")
            yield beam.pvalue.TaggedOutput("dead_letter", dead_letter_payload)