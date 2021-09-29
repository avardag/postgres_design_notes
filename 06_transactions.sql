 --Transactions
 
 /*
  A transaction is a logical unit of work that contains one or more than one SQL statements where either all statements will succeed or all will fail.
   The SQL statements are NOT visible to other user sessions, and if something goes wrong, it won’t affect the database. 
  
  A transaction is a unit of work that is performed against a database. Transactions are units or sequences of work accomplished in a logical order,
   whether in a manual fashion by a user or automatically by some sort of a database program.

A transaction is the propagation of one or more changes to the database. For example, if you are creating a record, updating a record, or deleting 
a record from the table, then you are performing transaction on the table. It is important to control transactions to ensure data integrity and 
to handle database errors.
Practically, you will club many PostgreSQL queries into a group and you will execute all of them together as a part of a transaction.
Properties of Transactions

Transactions have the following four standard properties, usually referred to by the acronym ACID −

    # - Atomicity − Ensures that all operations within the work unit are completed successfully;
     otherwise, the transaction is aborted at the point of failure and previous operations are rolled back to their former state.
     cant be partially completed

    # - Consistency − Ensures that the database properly changes states upon a successfully committed transaction.

    # - Isolation − Enables transactions to operate independently of and transparent to each other.

    # - Durability − Ensures that the result or effect of a committed transaction persists in case of a system failure.

Transaction Control:
The following commands are used to control transactions −
    BEGIN TRANSACTION (or BEGIN) − To start a transaction.
    COMMIT − To save the changes, alternatively you can use END TRANSACTION command.
    ROLLBACK − To rollback the changes.

Transactional control commands are only used with the DML commands INSERT, UPDATE and DELETE only.
 They cannot be used while creating tables or dropping them because these operations are automatically committed in the database.
  * */
 
 CREATE TABLE accounts(
 	id serial PRIMARY KEY, 
 	name varchar(32) NOT NULL , 
 	balance integer NOT NULL DEFAULT 0 check(balance >0)
 );
 
INSERT INTO accounts(name, balance)
VALUES ('Alex', 200),
('Maga', 200);


SELECT * FROM ACCOUNTS ;

/*
The BEGIN TRANSACTION Command
Transactions can be started using BEGIN TRANSACTION or simply BEGIN command. 
Such transactions usually persist until the next COMMIT or ROLLBACK command is encountered. 
But a transaction will also ROLLBACK if the database is closed or if an error occurs.
*/

--Withdraw 50 dollars from Alex's acount and deposit that to Maga's
--1)
BEGIN; --started a TRANSACTION SESSION
--another query to update a record . Done within a transaction session. before commiting
--2)
UPDATE accounts 
SET balance = balance -50 
WHERE name = 'Alex';
--3)
UPDATE accounts 
SET balance = balance +50
WHERE name='Maga';

--now if I do select * from accounts using another connection or another sql query window , nothing is changed in a DB regarding 
--the above query. Until i do COMMIT 
--COMMIT merges the changes from this transaction pool to main data pool.

/*The ROLLBACK Command
The ROLLBACK command is the transactional command used to undo transactions that have not already been saved to the database.
The ROLLBACK command can only be used to undo transactions since the last COMMIT or ROLLBACK command was issued.
The syntax for ROLLBACK command is as follows:
ROLLBACK;
Also. Running a bad command will put the transaction in an aborted state. So you must do ROLLBACK
*/

ROLLBACK;

--let's commit a transaction:
COMMIT;

--now changes are in main DB
SELECT * FROM accounts;


--##############################
--when server craches or connetion to the DB is lost , postgres does automatic rollback 
--1)start a transaction
BEGIN;
--2)update one row
UPDATE accounts 
SET balance = balance + 50
WHERE name = 'Alex';
--3)imitating crash by manually closing DB connection

--4) after carsh 
--no changes were committed to DB, Postgres did ROLLBACK itsef
SELECT * FROM accounts;


--##############################
--when entered wrong command , need to do ROLLBACK
--1)start a transaction
BEGIN;
--2)send an invalid command
UPDATE ljlkjflkflds;
--3)sending another validcommand gives error --> ERROR: current transaction is aborted, commands ignored until end of transaction block
SELECT * FROM accounts;
--4) so need to do manual ROLLBACK
ROLLBACK;

--5)Now everything works as it should
SELECT * FROM accounts;

