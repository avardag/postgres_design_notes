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







/*
 * https://dbdiagram.io/d 
 Table users {
  id serial [pk, increment]
  created_at timestamp
  updated_at timestamp
  username varchar(32)
}

Table posts {
  id serial [pk, increment]
  created_at timestamp
  updated_at timestamp
  url varchar(200)
  user_id integer [ref:> users.id] 
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


 * */





