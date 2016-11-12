
--Create schema
DROP SCHEMA IF EXISTS kmeans_demo CASCADE;
CREATE SCHEMA kmeans_demo;

CREATE TABLE kmeans_demo.messages(
	id bigint,
	message_body text
) DISTRIBUTED BY(id);
