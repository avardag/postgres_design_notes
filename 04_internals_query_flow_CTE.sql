--https://explain.dalibo.com -->visualize query execution
/*
 PostgreSQL Query Processing
Parser
Analyzer
Rewriter
Planner
Executor

Query Processing
• Parser
	▪ Check the query string for valid syntax
• Analyzer
	▪ Add detailed info
	▪ Database lookups
• Rewriter
	▪ Apply rewrite rules
	▪ Rewrite the client's query to the base table referenced in the view
• Planner
	▪ Choose the  best plan
	Planner is responsible for creating an optimal execution plan
		1. Create all possible plans
		2. Estimate the cost for each plan
		3. Choose the lowest cost plan and return it to Executor
• Executor
	▪ Step through the plan tree
	▪ Retrieve tuples in the way given by the plan tree
	▪ Outputs a result
*/

/*
 Query statistics  
 EXPLAIN - build a query plan and display info about it
 EXPLAIN ANALYZE - build a query plan , run it , and display info about it.
 
 Do explain analyze often to see if PG is using my indexes at all, or doin gjust sequenatial scans of rows. 
 If in is not being used by planner, just drop index of that column
 */

 SELECT  username, contents FROM users 
 JOIN COMMENTS ON COMMENTS.user_id = users.id 
 WHERE username = 'Alyson14';

 EXPLAIN ANALYZE SELECT  username, contents FROM users 
 JOIN COMMENTS ON COMMENTS.user_id = users.id 
 WHERE username = 'Alyson14';

 --
SELECT username, u.created_at FROM (
	SELECT user_id, created_at FROM photo_tags
UNION all
SELECT user_id, created_at FROM caption_tags
) AS u
 JOIN users ON u.user_id = users.id 
WHERE u.created_at < '2010-01-07';


SELECT username, tags.created_at
FROM users 
JOIN ( 
	SELECT user_id, created_at FROM photo_tags
	UNION all
	SELECT user_id, created_at FROM caption_tags
) AS tags ON tags.user_id = users.id 
WHERE tags.created_at < '2010-01-07';

--Commont Table expressions

--1st above solution as CTE
WITH tags AS (
	SELECT user_id, created_at FROM photo_tags
	UNION all
	SELECT user_id, created_at FROM caption_tags
)
SELECT username, tags.created_at FROM tags
JOIN users ON tags.user_id = users.id 
WHERE tags.created_at < '2010-01-07';
--2nd solution as CTE
WITH tags AS ( 
	SELECT user_id, created_at FROM photo_tags
	UNION all
	SELECT user_id, created_at FROM caption_tags
)
SELECT username, tags.created_at
FROM users 
JOIN tags ON tags.user_id = users.id 
WHERE tags.created_at < '2010-01-07';


/*
 there are 2 forms of common table expressions
 1)Simple form used to make a query easier to understand
 2)Recursive form used to write queries taht are otherwise impossible to write
 
  */

WITH RECURSIVE cte_q AS (
	SELECT 0 AS n 		--<--Initial, non-recursive query.
	UNION ALL			--<--needs UNION expression
	SELECT n+2 	FROM cte_q		--<--Recursive query	
	WHERE n<10			--<--Termination check
)
SELECT n 				--<--Invocation
FROM cte_q;

--Factorial
WITH RECURSIVE fact AS (
	SELECT 1 AS n, 1 AS res
	UNION ALL 
	SELECT n+1,  res*(n+1)
	FROM fact
	WHERE n<10
)
SELECT n, res 
FROM fact;

SELECT * FROM followers;


--using RTE RECURSIVE to list all followers of a user, their followers, and their followers' followers
WITH RECURSIVE suggestions(leader_id, follower_id, depth) AS (
		SELECT  leader_id, follower_id, 1 AS depth  
		FROM followers 
		WHERE follower_id = 1
	UNION 
		SELECT followers.leader_id, followers.follower_id, DEPTH+1
		FROM followers 
		JOIN suggestions ON suggestions.leader_id = followers.follower_id 
	WHERE DEPTH <2
)
SELECT DISTINCT users.id, users.username 
FROM suggestions 
JOIN users ON users.id = suggestions.leader_id 
WHERE DEPTH > 1
ORDER BY users.id;

/*In general recursive queries come in handy when working with self-referential data or graph/tree-like data structures.
 Just a few examples of these use cases are:
    Self-referential data:
        Manager -> Subordinate (employee) relationship
        Category -> Subcategory -> Product relationship
        Graphs - Flight (Plane Travel) map
    Trees:
        Any taxonomy system - books, animals, genetics...
        Links between articles - for example on Wikipedia
        Comment section - for example threads on Reddit*/