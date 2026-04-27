FROM apache/beam_python3.10_sdk:latest

WORKDIR /app

COPY . .

RUN pip install -r requirements.txt

ENTRYPOINT ["python", "pipeline/main.py"]