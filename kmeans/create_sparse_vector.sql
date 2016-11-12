
--Create corpus table

--Create tfidf table

DROP TABLE IF EXISTS kmeans_demo.tfidf;
SELECT madlib.gen_doc_svecs('kmeans_demo.tfidf', 'kmeans_demo.dictionary', 'dic', 'term', 'kmeans_demo.term_vectors', 'id', 'term', 'positions');
