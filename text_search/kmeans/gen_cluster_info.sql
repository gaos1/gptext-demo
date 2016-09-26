\timing
/* Create the assignment table assigning documents to the 
   closest centroid found in kmeans execution 
*/  
DROP TABLE IF EXISTS kmeans_demo.kmeans_assignments;
CREATE TABLE kmeans_demo.kmeans_assignments AS
        SELECT doc_id,
               madlib.closest_column(c, sparse_vector::float8[], 'madlib.dist_angle')
        FROM kmeans_demo.tfidf,
             (SELECT centroids c FROM kmeans_demo.kmeanspp) t
        DISTRIBUTED BY(doc_id);

/* The following steps provides an approach that could be used to find 
   the top terms for the clusters, using TF-IDF scores. First we treat 
   all the documents for respective clusters as if they represent a single 
   document and then we do TF-IDF calculations on those documents (Note:
   No. of documents will be equal to no. of clusters) */

/* Create an aggregate table aggregating documents from the single 
   cluster forming one document for each cluster 
*/
DROP TABLE IF EXISTS kmeans_demo.result_agg;
CREATE TABLE kmeans_demo.result_agg AS
	SELECT
	    (closest_column).column_id cluster_id,
            madlib.svec_sum(sparse_vector) agg
	FROM kmeans_demo.kmeans_assignments t,
             kmeans_demo.tfidf q
        WHERE t.doc_id = q.doc_id
	GROUP BY cluster_id --(closest_column).column_id;
    DISTRIBUTED BY(cluster_id);

/* Calculate TF-IDF scores on the documents formed from the 
   previous step
*/
DROP TABLE IF EXISTS kmeans_demo.result_tfidf;
CREATE TABLE kmeans_demo.result_tfidf AS
	SELECT cluster_id,
	       madlib.svec_mult(agg::madlib.svec, logidf) tf_idf
	FROM
	       kmeans_demo.result_agg,
               (SELECT madlib.svec_log(madlib.svec_div(
			count(agg)::madlib.svec, madlib.svec_count_nonzero(agg::madlib.svec))
		) logidf FROM kmeans_demo.result_agg) foo
	ORDER BY cluster_id
	DISTRIBUTED RANDOMLY;

/* Unnest the TF-IDF score array formed for clusters from the previous
   step. This will be used to pick top k terms acc. to TF-IDF in the final
   cluster info table.
*/ 
DROP TABLE IF EXISTS kmeans_demo.tfidf_unnest;
CREATE TABLE kmeans_demo.tfidf_unnest AS
	SELECT cluster_id,
	       generate_series(1, array_upper(tf_idf::float8[], 1)) term_id,
               unnest(tf_idf::float8[]) tf_idf
	FROM kmeans_demo.result_tfidf
	DISTRIBUTED RANDOMLY;

/* Generate the final cluster info table using the results from the previous
   steps. It contains following columns: 
   1. cluster_id
   2. No. of documents in the cluster
   3. Array of document ids for the cluster
   4. Top k (here k = 10, note rank<11 in the following query) terms for the cluster
*/
DROP TABLE IF EXISTS kmeans_demo.clusters_info;
CREATE TABLE kmeans_demo.clusters_info AS
	SELECT cluster_id,
	       (SELECT count(*) FROM kmeans_demo.kmeans_assignments 
		 WHERE (closest_column).column_id = cluster_id) num_docs,
	       (SELECT array_agg(doc_id) FROM kmeans_demo.kmeans_assignments
		 WHERE (closest_column).column_id = cluster_id) docs,
	       array_agg(term) top_terms
          FROM 
	       (SELECT * FROM kmeans_demo.dictionary t,
                              (SELECT *, row_number() OVER(partition by cluster_id ORDER BY tf_idf DESC) rank
				 FROM kmeans_demo.tfidf_unnest) q
                 WHERE rank<11 AND t.dic = q.term_id) t
	  GROUP BY cluster_id
      DISTRIBUTED BY(cluster_id);    	 						
	
