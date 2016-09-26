--Creating solr index for test table
SELECT * FROM gptext.drop_index('demo.kmeans_demo.messages');
SELECT * FROM gptext.create_index('kmeans_demo','messages','id','message_body');

--Enabling term vectors on c2 column

SELECT * FROM gptext.enable_terms('demo.kmeans_demo.messages','message_body');

