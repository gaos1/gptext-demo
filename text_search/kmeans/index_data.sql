
--Index table data

SELECT * FROM gptext.index(table(SELECT * FROM kmeans_demo.messages),'demo.kmeans_demo.messages');

--Index commit

SELECT * FROM gptext.commit_index('demo.kmeans_demo.messages');
