--creating users tabke
CREATE TABLE users (
	id SERIAL PRIMARY KEY,
	created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
	username VARCHAR(32) NOT NULL,
    bio VARCHAR(400),
    avatar VARCHAR(200),
    password VARCHAR(50),
    phone VARCHAR(25),
    email VARCHAR(64),
    status VARCHAR(15),
    CHECK(COALESCE(phone, email) IS NOT NULL ) --either phone or email has to be entered    
);
--creating posts table
CREATE TABLE posts (
	id SERIAL PRIMARY KEY,
	created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
	url VARCHAR(200) NOT NULL,
	caption VARCHAR(240),
	lat REAL CHECK(lat IS NULL OR (lat >= -90 AND lat <= 90 )), --lat NULL IS ok,but IF provided it must be BETWEEN -90 & 90
	lng REAL CHECK(lng IS NULL OR (lng >= -180 AND lng <= 180 )), --lng NULL IS ok,IF provided it must be BETWEEN -90 & 90
	user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE   
);

--creatng comments table
CREATE TABLE comments (
	id SERIAL PRIMARY KEY,
	created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
	contents VARCHAR(255) NOT NULL,
	user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE, 
	post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE
);

--creatng likes table
CREATE TABLE likes (
	id SERIAL PRIMARY KEY,
	created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
	user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE, 
	post_id INTEGER REFERENCES posts(id) ON DELETE CASCADE,
	comment_id INTEGER REFERENCES comments(id) ON DELETE CASCADE, 
	CHECK(COALESCE((post_id)::BOOLEAN::INTEGER, 0) + COALESCE((comment_id)::BOOLEAN::INTEGER, 0) = 1) --explained in design file
);

--creatng photo_tags table
CREATE TABLE photo_tags (
	id SERIAL PRIMARY KEY,
	created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
	user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE, 
	post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
	x INTEGER NOT NULL, 
	y INTEGER NOT NULL, 
	CONSTRAINT user_in_post_uniq UNIQUE(user_id, post_id)
);

--creatng caption_tags table
CREATE TABLE caption_tags (
	id SERIAL PRIMARY KEY,
	created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
	user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE, 
	post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
	CONSTRAINT user_in_caption_uniq UNIQUE(user_id, post_id)
);

--creatng hashtags table
CREATE TABLE hashtags (
	id SERIAL PRIMARY KEY,
	created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
	title VARCHAR(32) NOT NULL UNIQUE
);

--creatng hashtags_posts table
CREATE TABLE hashtags_posts (
	id SERIAL PRIMARY KEY,
	hashtag_id INTEGER NOT NULL REFERENCES hashtags(id) ON DELETE CASCADE, 
	post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
	CONSTRAINT hasht_in_post_uniq UNIQUE(hashtag_id, post_id)
);



--creatng followers table
CREATE TABLE followers (
	id SERIAL PRIMARY KEY,
	created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
	leader_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE, 
	follower_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE, 
    CONSTRAINT user_not_follow_hims CHECK(leader_id != follower_id), --so that one cant follow himself
    CONSTRAINT leader_follower_uniq UNIQUE(leader_id, follower_id)
);

SELECT * FROM followers;







