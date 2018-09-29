# Kafka_Es_Grafana
A data pipeline made to present realtime data in grafana

### Update max_map_count for Elasticsearch to prevent it from failing
```sudo sysctl -w vm.max_map_count=262144```

### Boot up docker
```docker-compose up -d ```

### Create topic "Measurements"
``docker-compose exec kafka kafka-topics --create --zookeeper zookeeper:2181 --replication-factor 1 --partitions 1 --topic measurements ``


### Generate random data w/ksql-datagen
