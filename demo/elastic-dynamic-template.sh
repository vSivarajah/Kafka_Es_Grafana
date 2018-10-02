#!/usr/bin/env bash

#Delete any existing dynamic_templates
curl -XDELETE "http://192.168.99.100:9200/_template/kafkaconnect/"


#Load a dynamic_template with the timefield being "EXTRACT_TS"
curl -XPUT "http://192.168.99.100:9200/_template/kafkaconnect/" -H 'Content-Type: application/json' -d'
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
        }
      ]
    }
  }
}'
