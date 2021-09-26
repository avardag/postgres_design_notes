--show where my machine stores PG data and DB info
SHOW data_directory; --returned /var/lib/postgresql/12/main

--ALL DBs are inside base directory, there folders with id numbers

--command TO see 
--display all DBs with internal identifiers
SELECT oid, datname
FROM pg_database;

--pg_class catalogs tables and most everything else that has columns or is otherwise similar to a table.
-- This includes indexes (but see also pg_index), sequences, views, materialized views, composite types, and TOAST tables.
--Below, when we mean all of these kinds of objects we speak of "relations".
SELECT * FROM  pg_class;

--see everything related to users table
SELECT oid, relname 
FROM pg_class
WHERE relname = 'users';

/*
 |oid 	| relname	|
 --------------------
 |16924	|users		|
  so file 16924 in photo_share db in  base dir is everytging related to users table
  file 16924 is HEAP file for users table
 */

SELECT oid, relname 
FROM pg_class
WHERE relname = 'posts'; --16938

/*
 
  file 16938 is HEAP file for posts table
  ----------------------------------------------------------------------------------------
  Heap (Heap file)- file that containes all the data (rows)from one particular table
  Block(or page) - 	The heap file is divided into many different blocks or pages.
  					Each page/block stores some number of rows.
    				Block represents a 8kb segment information the file storing the table. 
  Tuple (or Item)-	Individual row from the table
  ----------------------------------------------------------------------------------------	
  Many pages inside heap and many tuples inside pages and each page not bigger than 8KB
  A page can be empty or contain tuples.
  Heap file >pages > tuples
   ----------------------------------------------------------------------------------------
    
 */

--INDEXES 
/*
  Indexes are essential to efficiently navigate the table data storage (the heap).  
  Indexing is the creation of a book of records where each index references points to where (in which block/page) that item is located.  
  An Index is the structure or object by which we can retrieve specific rows or data faster. 
  Indexes can be created using one or multiple columns or by using the partial data depending on your query requirement conditions.
  Index will create a pointer to the actual rows in the specified table.
  syntax
  CREATE index "users_name_idx" on public."users"("name");
  1)-By default a B-tree index will get created. If the indexed column is used to perform the comparison by using comparison operators such as <, <=, =, >=, and >,
   then the  Postgres optimizer uses the index created by the B-tree option for the specified column. 99% of the time B-Tree indexes are used
  2)-The Hash index can be used only if the equality condition = is being used in the query. Speeds up equality checks.
  syntax
  CRAETE index "hashtags_title_idx" on public."hashtags" using HASH ("title");
  3)-GIN - for columns that contain arrays or JSON data
  4)-GiST - Geometry, full-text search
  -----------------------------------------------------------------------------------------------------------------
  1. Indexes add overhead to the database system as a whole, so they should be used sensibly.
For Example: The INSERT and UPDATE statements take more time on tables having indexes, whereas the SELECT statements become fast on those tables. 
The reason is that while doing INSERT or UPDATE, a database needs to insert or update the index values as well.
2. You may need to run the ANALYZE command regularly to update statistics to allow the query planner to update the decisions planner.
3. You need to maintain the index properly so that it will not get bloated. You can REINDEX or you can also re-create the index concurrently.
4. A GIN index is expected to run slower than a B-tree because of the flexibility it provides.
5. Can be large. PG will keep index data in addition and it will add up storage in HD space. It costs $$$
6. Index might not actually get used.
-----------------------
    Indexes should not be used on small tables.
    Tables that have frequent, large batch update or insert operations.
    Indexes should not be used on columns that contain a high number of NULL values.
    Columns that are frequently manipulated should not be indexed.

  ------------------------------------------------------------------------------------------------------------------------
  EXPLAIN SELECT *
FROM users
WHERE username = 'Kenyatta_Dicki';

 Seq Scan on users  (cost=0.00..175.81 rows=1 width=202) (actual time=5.551..8.877 rows=1 loops=1)
   Filter: ((username)::text = 'Kenyatta_Dicki'::text)
   Rows Removed by Filter: 5344
 Planning Time: 0.212 ms
 Execution Time: 8.949 ms
(5 rows)
------------------------------------------------------
after creating index on useername column
  EXPLAIN SELECT *
FROM users
WHERE username = 'Kenyatta_Dicki';

 Index Scan using users_username_idx on users  (cost=0.28..8.30 rows=1 width=202) (actual time=0.057..0.061 rows=1 loops=1)
   Index Cond: ((username)::text = 'Kenyatta_Dicki'::text)
 Planning Time: 0.191 ms
 Execution Time: 0.106 ms
(4 rows)

  */

--creating index on users username
CREATE INDEX ON users(username);

--SELECT * FROM users where id = 2020;

--analze query
EXPLAIN ANALYZE SELECT * FROM users WHERE username ='Emil30';

--show storage size used by users table on HD
SELECT pg_size_pretty(pg_relation_size('users')); -- > returned 872KB

--show storage size used by index on users('username')
SELECT pg_size_pretty(pg_relation_size('users_username_idx')); -- > returned 184KB



--list of all indexes used inside the DB
SELECT relname, relkind
FROM pg_class 
WHERE relkind='i'; --> i FOR index

/*
 PG creates by default indexes for columns which are PRIMARY KEYs and columns with UNIQUE constraint
 So no need in indexing ID columns or columns with unique values.
 */

EXPLAIN ANALYZE SELECT username, contents
FROM users 
JOIN COMMENTS ON COMMENTS.user_id = users.id 
WHERE username= 'Alyson24';











