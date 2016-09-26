--Create term table

DROP TABLE IF EXISTS kmeans_demo.term_vectors;
CREATE TABLE kmeans_demo.term_vectors AS SELECT * FROM gptext.terms(TABLE(SELECT 1 SCATTER BY 1), 'demo.kmeans_demo.messages', 'message_body', '*', null) DISTRIBUTED BY(id);

--Create dictionary table
DROP TABLE IF EXISTS kmeans_demo.dictionary;
CREATE TABLE kmeans_demo.dictionary AS
    SELECT
       row_number() OVER( ORDER BY term ASC ) - 1 AS dic,
       term
    FROM kmeans_demo.term_vectors WHERE term IS NOT NULL GROUP BY term DISTRIBUTED RANDOMLY;


