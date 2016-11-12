SELECT (closest_column).column_id cluster_id,
       count(*) num_docs
FROM kmeans_demo.kmeans_assignments
GROUP BY (closest_column).column_id 
ORDER BY (cluster_id);	 
