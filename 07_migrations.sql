--Many migration tools and libs can automatically generate migrations for you

--writing manually 

/*
 --2) enter in package.json file
 "scripts": {
    "migrate": "node-pg-migrate"
  }, 
 
 --3)
 run in terminal:
 $ npm run migrate create table comments

> photo_share_sql@1.0.0 migrate /home/avardag/photo_share_sql
> node-pg-migrate "create" "table" "comments"

Created migration -- /home/avardag/photo_share_sql/migrations/1632938179895_table-comments.js

it created  migration file 

--4) edit the file like :
exports.up = (pgm) => {
  pgm.sql(`
    CREATE TABLE comments (
      id SERIAL PRIMARY KEY,
      created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
      contents VARCHAR(240) NOT NULL
    );
  `);
};

exports.down = (pgm) => {
  pgm.sql(`
    DROP TABLE comments;
  `);
};

--5)
then run in terminal :
avardag@avardag:~/photo_share_sql$ DATABASE_URL=postgres://adminname:password@localhost:5432/socialnetwork npm run migrate up

> photo_share_sql@1.0.0 migrate /home/avardag/photo_share_sql
> node-pg-migrate "up"

> Migrating files:
> - 1632938179895_table-comments
### MIGRATION 1632938179895_table-comments (UP) ###

    CREATE TABLE comments (
      id SERIAL PRIMARY KEY,
      created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
      contents VARCHAR(240) NOT NULL
    );
  ;
INSERT INTO "public"."pgmigrations" (name, run_on) VALUES ('1632938179895_table-comments', NOW());


Migrations complete!
--6)
in our BD: 
socialnetwork=# \dt

              List of relations
 Schema |     Name     | Type  |    Owner     
--------+--------------+-------+--------------
 public | comments     | table | avardagadmin
 public | pgmigrations | table | avardagadmin

--7)
to undo the migrations  run in terminal :
avardag@avardag:~/photo_share_sql$ DATABASE_URL=postgres://adminname:password@localhost:5432/socialnetwork npm run migrate down

> photo_share_sql@1.0.0 migrate /home/avardag/photo_share_sql
> node-pg-migrate "down"

> Migrating files:
> - 1632938179895_table-comments
### MIGRATION 1632938179895_table-comments (DOWN) ###

    DROP TABLE comments;
  ;
DELETE FROM "public"."pgmigrations" WHERE name='1632938179895_table-comments';


Migrations complete!

--------------------------------
adding another migration
--1)
$ npm run migrate create rename contents to body

> photo_share_sql@1.0.0 migrate /home/avardag/photo_share_sql
> node-pg-migrate "create" "rename" "contents" "to" "body"

Created migration -- /home/avardag/photo_share_sql/migrations/1632940642984_rename-contents-to-body.js

--2)
socialnetwork=# \dt
              List of relations
 Schema |     Name     | Type  |    Owner     
--------+--------------+-------+--------------
 public | comments     | table | avardagadmin
 public | pgmigrations | table | avardagadmin
(2 rows)




















 */