import json
import apache_beam as beam

class ParseMessage(beam.DoFn):
    def process(self, element):
        yield json.loads(element.decode("utf-8"))