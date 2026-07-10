$projectRoot = Resolve-Path "$PSScriptRoot\.."

Write-Host "Starting Spark Streaming inside Docker."
Write-Host "This uses container networking: Kafka=kafka:29092, Cassandra=cassandra."

docker compose -f "$projectRoot\docker\docker-compose.yml" run --rm `
  --user root `
  --entrypoint bash `
  -v "$projectRoot`:/workspace" `
  -w /workspace `
  -e KAFKA_BOOTSTRAP_SERVERS=kafka:29092 `
  -e CASSANDRA_HOSTS=cassandra `
  -e SPARK_MASTER_URL=local[*] `
  -e SPARK_CHECKPOINT_DIR=data/checkpoints/spark-docker `
  -e HOME=/root `
  -e HADOOP_USER_NAME=root `
  -e USER=root `
  -e LOGNAME=root `
  -e JAVA_TOOL_OPTIONS=-Duser.name=root `
  spark-master `
  -lc "grep -E '^(pydantic|python-dotenv|confluent-kafka|cassandra-driver|pyasyncore|pandas|numpy|scikit-learn|joblib)' requirements.txt > /tmp/spark-requirements.txt && /opt/bitnami/python/bin/pip install -r /tmp/spark-requirements.txt && /opt/bitnami/python/bin/python -m app.streaming.spark_streaming_processor"
