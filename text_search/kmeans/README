   =====================================================
   ====     KMEANS CLUSTERING DEMO USING GPTEXT     ====
   =====================================================
   
   This file contains the steps required to perform Kmeans algorithm 
   using GPText. Sample dataset used is present in kmeans.csv.
  
   1) Create message table.
	psql demo -e -f kmeans.ddl

   2) Insert data into message table.
 	gpload -f load.yaml

   3) Create Solr index.
	psql demo -e -f create_index.sql

   4) Index data present in message table.
	psql demo -e -f index_data.sql

   5) Create term vectors for each message. Empty documents will be ignored. Create dictionary of terms.
	psql demo -e -f create_corpus.sql

   6) Create sparse vector representation for each document. 
	psql demo -e -f create_sparse_vector.sql

   7) Run kmeans algorithm.
	psql demo -f kmeans_run.sql

   Analyzing results from Kmeans:

   1) Generate the cluster info (cluster assignments, num of docs in clusters and top terms for clusters)
	psql demo -f gen_cluster_info.sql

   2) To get the count of document in each cluster.
	psql demo -f num_docs_in_clusters.sql

   3) To get the top words in each cluster.
	psql demo -f top_terms_in_clusters.sql

   4) To get the clusters alongwith the documents (ids) belonging to each cluster.
	psql demo -f show_clusters.sql
