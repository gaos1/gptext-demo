#!/bin/bash

echo "drop table if exists newsgroup;"
echo "create table newsgroup(id serial primary key, group_name varchar(200), post text, created_time timestamp default now());"

tar zxf mini_newsgroups.tar.gz
for group in `ls -1 mini_newsgroups`;
do
   for f in `ls -1 mini_newsgroups/$group`;
   do 
      echo "insert into newsgroup(group_name, post) select '$group',  CAST(pg_read_file(E'mini_newsgroups/$group/$f',0, 100000000) AS TEXT);"
   done
done
