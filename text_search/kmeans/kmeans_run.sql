
/* Run MADlib kmeans algorithm */
DROP TABLE IF EXISTS kmeans_demo.kmeanspp;
DROP EXTERNAL TABLE IF EXISTS kmeans_demo.kmeanspp_ext;
CREATE EXTERNAL TABLE kmeans_demo.kmeanspp_ext(
    centroids float8[],
    objective_fn float8,
    frac_reassigned float8,
    num_iterations int) location('gpfdist://localhost:10000/kmeanspp_ext') format 'csv';
CREATE TABLE kmeans_demo.kmeanspp(
    centroids float8[],
    objective_fn float8,
    frac_reassigned float8,
    num_iterations int)
    DISTRIBUTED RANDOMLY;

INSERT INTO kmeans_demo.kmeanspp SELECT * FROM kmeans_demo.kmeanspp_ext;
\x
SELECT * FROM madlib.kmeanspp(
	'kmeans_demo.tfidf',
	'sparse_vector',
	4,
	'madlib.dist_angle',
	'madlib.avg',
	30,
	0.01);
