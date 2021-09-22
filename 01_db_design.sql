--SQL Schema designers
/*
 * dbdiagram.io
 * drawsql.app
 * sqldbm.com
 * quickdatabasediagrams.com
 * dbdiffo.com
 * dbdesigner.net
 
 */

--Like Sysytem
/*
 
  Bad design. for many reasons
 			Database 
 	users										posts
 	table										table
 |id		|username	|			|id		|url			|likes	|
 |int		|varchar	|			|int	|varchar		|int	|
 ------------------------			---------------------------------	
 |23		|Alex20		|			|12		|djfld.jpg		|243	|
 |24		|Sammy		|			|13		|jfkdld.co.uk	|89		|
 ___________________________________________________________________________________________________
 
Good design:

 			Database 
 	users							likes									posts
 	table							table									table
 |id		|username	|		|id		|user_id|post_id|				|id		|url			|
 |int		|varchar	|		|int	|int	|int	|				|int	|varchar		|
 ------------------------		-------------------------				-------------------------	
 |23		|Alex20		|		|78		|12		|36		|				|12		|djfld.jpg		|
 |24		|Sammy		|		|79		|23		|13		|				|13		|jfkdld.co.uk	|
 			  
 can add primary key (user_id, post_id) or add a constraint UNIQUE(user_id, post_id)
 good design for likes, bookmarks, favourites  
 _____________________________________________________________________________________________________
 
 Reactions like facebook has:
  			Database 
 	users							reactions										posts
 	table							table											table
 |id		|username	|		|id		|user_id|post_id|type	|				|id		|url			|
 |int		|varchar	|		|int	|int	|int	|enum	|				|int	|varchar		|
 ------------------------		--------------------------------				-------------------------	
 |23		|Alex20		|		|78		|12		|36		|like	|				|12		|djfld.jpg		|
 |24		|Sammy		|		|79		|23		|13		|funny	|				|13		|jfkdld.co.uk	|
 
 and type COLUMN in reactins TABLE can be of type enum:
 	CREATE TYPE reaction AS ENUM ('like', 'love', 'care', 'sad', 'funny');
	CREATE TABLE reactions (
   		 id SERIAL PRIMARY KEY,
   		 user_id INTEGER NOT NULL, 
   		 post_id INTEGER NOT NULL,
    	type mood NOT NULL
    	CONSTRAINT user_post_unique UNIQUE(user_id, post_id)
	);
______________________________________________________________________________________________________

if I want to add comments likes: Each type of likes gets its won table, easy maintanance. Best
 			Database 
 	users							posts_likes							comments_likes				
 	table							table								table						
|id			|username	|		|id		|user_id|post_id|			|id		|user_id|comment_id|	
|int		|varchar	|		|int	|int	|int	|			|int	|int	|int		|	
------------------------		-------------------------			----------------------------	
|23			|Alex20		|		|78		|12		|36		|			|34		|12		|432		|		
|24			|Sammy		|		|79		|23		|13		|			|34		|23		|987		|		
	
posts			comments
table 			table

 ___________________________________________________________________________________________________
 
Good design:

 			Database 
 	users								likes									posts		comments
 	table								table									table		table
 |id		|username	|		|id		|user_id|post_id|comment_id		|
 |int		|varchar	|		|int	|int	|int	|int			|
 ------------------------		----------------------------------------
 |23		|Alex20		|		|78		|12		|36		|NULL			|
 |24		|Sammy		|		|79		|23		|NULL	|22				|
 			  
 Each type of relation gets its own FK column
But add CHECK to get thta either post or comment gets value, other gets null,
but never both gets null or both gets value
CHECK(
	COALESCE((post_id)::BOOLEAN::INTEGER, 0) + COALESCE((comment_id)::BOOLEAN::INTEGER, 0) = 1
)
COALESCE(m,n) gives first non null value. Like ?? operator in JS
COALESCE(10, NULL) returns 10
COLASCE(NULL, 2938) returns 2938 
The COALESCE function accepts an unlimited number of arguments. It returns the first argument that is not null. 
If all arguments are null, the COALESCE function will return null.
The COALESCE function evaluates arguments from left to right until it finds the first non-null argument.
 */



--########################
--Tag/mention system design
/*

 1-One single tags table
  
 		tags
 		table
|id		|user_id	|post_id	|x		|y		|
-------------------------------------------------
|1		|12			|456		|352	|224	|
|2		|12			|389		|NULL	|NULL	|
|3		|78			|589		|690	|234	|
|4		|29			|493		|NULL	|NULL	|
|5		|90			|863		|NULL	|NULL	|

NULL values in x, y means its a tag in a caption of  a post.
nonNull values in x, y means mention on a pic, location of popup on an image.

2-Two separate tables for tags in caption and tag in a photo

 		photo_tags
 		   table
|id		|user_id	|post_id	|x		|y		|
-------------------------------------------------
|1		|12			|456		|352	|224	|
|2		|12			|389		|389	|120	|
|3		|78			|589		|690	|234	|


 	caption_tag										
 	   table										
|id		|user_id	|post_id	|
|int	|int		|int		|
---------------------------------	
|12		|12			|243		|
|13		|45			|89			|

if meaning and queries in photo_tag may change in future, 
and if i expect to query for caption_tags & photo_tags at different rates, and indexing the more frequent, 
and easier optimization
better solution 2.
 */

--#####################3
--Hashtags
/*
 --1st solution: One hashtags table 
  	hashtags										
 	   table										
|id		|title		|post_id	|
|int	|varchar	|int		|
---------------------------------	
|12		|happy			|32		|
|13		|love			|19		|
|14		|birthday		|456	|
|15		|love			|190	|
|16		|love			|89		|
 
works, but not very efficient, not performant
--2nd solution: one table for hashtags dictionary, another as a join betwen posts and hashtags dictionary
better normalized, optimized, no string duplication
  	hashtags										
 	   table										
|id		|title		|
|int	|varchar	|
-------------------------	
|34		|birthday	|
|35		|newyork	|
|36		|rain		|
|37		|funny		|
|38		|birhtday	|

  	hashtags_posts										
 	   table										
|id		|hashtag_id	|post_id	|
|int	|int		|int		|
---------------------------------	
|12		|34		|32			|
|13		|56		|19			|
|13		|38		|456		|
|13		|34		|190		|
|13		|34		|89			|

*/

--#####################################
--Num of Followers and number of posts
/*
 this can be calculated by running a query on data that already xists in DB
 this is a derived data
 and storing derived data is bad design
 */

--###########################33
--Followers TABLE 


/*
   	followers										
 	   table										
|id		|leader_id	|follower_id|
|int	|int		|int		|
---------------------------------	
|12		|34			|32			|
|13		|56			|19			|
|13		|38			|456		|
|13		|34			|190		|
|13		|34			|89			|

where leader_id and follower_id are both user_id FK,
need add CHECH(leader_id != follower_id) so that one cant follow himself
and UNIQUE(leader_id, follower_id)

 * */

/*
 * https://dbdiagram.io/d 
 Table users {
  id serial [pk, increment]
  created_at timestamp
  updated_at timestamp
  username varchar(32)
  bio varchar(400)
  avatar varchar(200)
  password varchar(50)
  phone varchar(25)
  email varchar(64)
  status varchar(15)
}

Table posts {
  id serial [pk, increment]
  created_at timestamp
  updated_at timestamp
  url varchar(200)
  user_id integer [ref:> users.id]
  caption varchar(255)
  lat real
  lng real 
}

Table comments {
  id serial [pk, increment]
  created_at timestamp
  updated_at timestamp
  contents varchar(255)
  user_id integer [ref: > users.id]
  post_id integer [ref: > posts.id]
}

Table likes {
  id serial [pk, increment]
  created_at timestamp
  contents varchar(255)
  user_id integer [ref: > users.id]
  post_id integer [ref: > posts.id]
  comment_id integer [ref:> comments.id]
}

Table photo_tags{
  id serial [pk, increment]
  user_id integer [ref: > users.id]
  post_id integer [ref: > posts.id]
  x integer
  y integer
  created_at timestamp
  updated_at timestamp
}

Table caption_tags{
  id serial [pk, increment]
  user_id integer [ref: > users.id]
  post_id integer [ref: > posts.id]
  created_at timestamp
}

Table hashtags {
 id serial [pk, increment]
 title varchar(32)
 created_at timestamp
}

Table hashtags_posts{
  id serial [pk, increment]
  hashtag_id integer [ref: > hashtags.id]
  post_id integer [ref: > posts.id]
}

Table followers{
  id serial [pk, increment]
  user_id integer [ref: > users.id]
  follower_id integer [ref: > users.id]
  created_at timestamp
}
 */






