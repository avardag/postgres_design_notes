--show the most popular user, useers who were tagged the most.
WITH tags AS (
	SELECT user_id FROM caption_tags 
	UNION ALL 
	SELECT user_id FROM photo_tags)
SELECT username, count(*) 
FROM tags
JOIN users ON users.id = tags.user_id
GROUP BY user_id , username
ORDER BY COUNT(*) DESC;

--more elegant:
SELECT username, count(*)
FROM users 
JOIN (
 	SELECT user_id FROM photo_tags 
 	UNION ALL 
 	SELECT user_id FROM caption_tags
 ) AS tags ON users.id = tags.user_id 
 GROUP BY username 
 ORDER BY count(*) DESC;
 
 --with views, because caption_tags and photo_tags are frequently used together. Convenient to have a view created 
CREATE VIEW tags AS (
	SELECT id, created_at, user_id, post_id, 'caption_tag' AS type FROM caption_tags 
	UNION ALL 
	SELECT id, created_at, user_id, post_id, 'photo_tag' AS type FROM photo_tags
);

--SELECT * FROM tags;

--solution with views
SELECT username, count(*)
FROM tags
JOIN users ON users.id = tags.user_id
GROUP BY user_id , username
ORDER BY COUNT(*) DESC;

--
--
--some more views for our app
--show the users who created the 10 most recent posts
CREATE VIEW most_recent_posts AS (
	SELECT users.id AS user_id, username, posts.id AS post_id, posts.created_at 
	FROM users 
	JOIN posts ON posts.user_id = users.id
	ORDER BY posts.created_at DESC
	LIMIT 10
);
SELECT * FROM most_recent_posts;

--show the users who were tagged in most recent posts
--show the number of likes each 10 most recent posts received
--show the hashtags used by the 10 most recent posts
--show the total number of comments the 10 most recent posts received
--etc
--for all these , better craete a generic, common view for reuse
CREATE VIEW most_recent AS (
	SELECT * 
	FROM posts
	ORDER BY posts.created_at DESC
	LIMIT 10
) ;


--show the users who created the 10 most recent posts
SELECT username 
FROM users 
JOIN most_recent ON users.id = most_recent.user_id;

--changing  a definition of a view 
--change the most_recent VIEW to show 15 most recent posts
CREATE OR REPLACE VIEW most_recent AS (
	SELECT * 
	FROM posts
	ORDER BY posts.created_at DESC
	LIMIT 15
);

SELECT * FROM most_recent;

--deleting a view 
--delete the first view that shows most recent 10 posts with usernames
DROP VIEW most_recent_posts;


--Materialized views

--for each week, show the number of likes hat posts and comments received. Use the post and comment created_at, not the like received
--expensive query
SELECT 
	date_trunc('week', COALESCE(posts.created_at, COMMENTS.created_at)) AS week ,
	count(posts.id) AS num_likes_f_posts,
	count(COMMENTS.id) AS num_likes_f_comments
FROM likes 
LEFT JOIN posts ON likes.post_id = posts.id 
LEFT JOIN COMMENTS ON likes.comment_id = COMMENTS.id
GROUP BY week
ORDER BY week;

--Use materialzed views
/*
 
   Materialized views are disc-stored views that can be refreshed.
    Like views, they are defined by a database query. Unlike views, their underlying query is not executed every time you access them.
    Materialized views cache the result of a complex and expensive query and allow you to refresh this result periodically.
    
    
    Should the data set be changed, or should the MATERIALIZED VIEW need a copy of the latest data, the MATERIALIZED VIEW can be refreshed:
    Materialized views in PostgreSQL use the rule system like views do, but persist the results in a table-like form. The main differences between:
	CREATE MATERIALIZED VIEW mymatview AS SELECT * FROM mytab;

	and:

	CREATE TABLE mymatview AS SELECT * FROM mytab;

	are that the materialized view cannot subsequently be directly updated and that the query used to create the materialized view is stored in exactly the same way that a view's query is stored, so that fresh data can be generated for the materialized view with:

	REFRESH MATERIALIZED VIEW mymatview;
	
	To create a materialized view, you use the CREATE MATERIALIZED VIEW statement as follows:

CREATE MATERIALIZED VIEW view_name
AS
query
WITH [NO] DATA;

How it works.

    First, specify the view_name after the CREATE MATERIALIZED VIEW clause
    Second, add the query that gets data from the underlying tables after the AS keyword.
    Third, if you want to load data into the materialized view at the creation time,
     use the WITH DATA option; otherwise, you use WITH NO DATA. In case you use WITH NO DATA, the view is flagged as unreadable.
      It means that you cannot query data from the view until you load data into it.

Refreshing data for materialized views:
To load data into a materialized view, you use the  REFRESH MATERIALIZED VIEW statement as shown below:
REFRESH MATERIALIZED VIEW view_name;

When you refresh data for a materialized view, PostgreSQL locks the entire table therefore you cannot query data against it.
 To avoid this, you can use the CONCURRENTLY option:
REFRESH MATERIALIZED VIEW CONCURRENTLY view_name;
  */


--create a materialized view for our expensive query
CREATE MATERIALIZED VIEW  weekly_likes AS (
	SELECT 
		date_trunc('week', COALESCE(posts.created_at, COMMENTS.created_at)) AS week ,
		count(posts.id) AS num_likes_f_posts,
		count(COMMENTS.id) AS num_likes_f_comments
	FROM likes 
	LEFT JOIN posts ON likes.post_id = posts.id 
	LEFT JOIN COMMENTS ON likes.comment_id = COMMENTS.id
	GROUP BY week
	ORDER BY week
) WITH DATA; --withdata : run this query AND HOLD ON TO the results

SELECT * FROM weekly_likes; --fast

--modifying the posts table
DELETE FROM posts WHERE posts.created_at < '2010-02-01';

SELECT * FROM weekly_likes;--RETURNS out of date DATA 

REFRESH MATERIALIZED VIEW weekly_likes;

SELECT * FROM weekly_likes;--now RETURNS NEW refreshed data


