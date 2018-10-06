--Highest hierarchy of streams
--All streams used in the dashboard should be derived from the main stream.
DROP STREAM IF EXISTS m_stream;

CREATE STREAM m_stream (measurement_time BIGINT, measurement_id VARCHAR, component_id VARCHAR, voltage BIGINT) \
WITH (KAFKA_TOPIC='measurements', VALUE_FORMAT='JSON');

---------------------------------------------

--Number of anomalies per min. Anomaly is defined if the voltage is higher than 750. The window is within 60 seconds. This is again grouped by each component_id
DROP TABLE IF EXISTS anomalies_per_min DELETE TOPIC;
CREATE table anomalies_per_min AS SELECT component_id, count(*) FROM m_stream window TUMBLING (size 60 second) WHERE voltage >750 GROUP BY component_id;





--Create a new stream derived from the main_stream
DROP TABLE IF EXISTS main_stream DELETE TOPIC;
CREATE STREAM main_stream AS SELECT * from m_stream;

