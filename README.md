# Kafka_Es_Grafana
A data pipeline made to present realtime data in grafana. 

Note : Some of the commands in this tutorial is based on the assumption that docker-machine is being used. 

### Update max_map_count for Elasticsearch to prevent it from failing
```sudo sysctl -w vm.max_map_count=262144```

### Boot up docker
```docker-compose up -d ```

#### Create topic

``docker-compose exec broker kafka-topics --create --zookeeper zookeeper:2181 --replication-factor 1 --partitions 1 --topic measurements ``



#### Load dynamic elastic template to ensure that _TS fields are used

```
curl -XPUT "http://localhost:9200/_template/kafkaconnect/" -H 'Content-Type: application/json' -d'
{
  "template": "*",
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  },
  "mappings": {
    "_default_": {
      "dynamic_templates": [
        {
          "dates": {
            "match": "EXTRACT_TS",
            "mapping": {
              "type": "date"
            }
          }
        },
        {
          "non_analysed_string_template": {
            "match": "*",
            "match_mapping_type": "long",
            "mapping": {
              "type": "keyword"
            }
          }}
      ]
    }
  }
}'

```

#### Load the elasticsearch-sink connector
```
curl -X POST \
  http://localhost:8083/connectors/ \
  -H 'Accept: application/json' \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "elasticsearch-sink",
    "config": {
      "schema.ignore": "true",
      "topics": "measurements",
      "key.converter": "org.apache.kafka.connect.storage.StringConverter",
      "value.converter.schemas.enable": false,
      "connector.class": "io.confluent.connect.elasticsearch.ElasticsearchSinkConnector",
      "key.ignore": "true",
      "value.converter": "org.apache.kafka.connect.json.JsonConverter",
      "type.name": "type.name=kafkaconnect",
      "topic.index.map": "measurements:measurements_index",
      "connection.url": "http://elasticsearch:9200",
      "transforms": "ExtractTimestamp",
      "transforms.ExtractTimestamp.type": "org.apache.kafka.connect.transforms.InsertField$Value",
      "transforms.ExtractTimestamp.timestamp.field" : "EXTRACT_TS"
    }
}'
```

#### Generate random data w/ksql-datagen
``docker-compose exec ksql-datagen ksql-datagen quickstart=users format=json topic=measurements maxInterval=1000 ``
