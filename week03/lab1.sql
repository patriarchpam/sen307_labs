-- VUA-SEN307 Week 3 Lab 1
-- Matric number: VUG/SEN/24/12478

-- Part 2C: client-server demo
CREATE DATABASE demo_test;
DROP DATABASE demo_test;

-- Part 3: personal database
SHOW DATABASES;
CREATE DATABASE sen307_vug_sen_24_12478;
USE sen307_vug_sen_24_12478;
SELECT DATABASE();
SHOW DATABASES;

-- Exploration exercise
SELECT VERSION();          -- MySQL server version (8.0.46)
SELECT CURRENT_USER();     -- account in use (root@localhost)
SELECT NOW();              -- server's current date and time
STATUS;                    -- connection and server details
SHOW VARIABLES LIKE 'port'; -- port the server listens on (3306)
SHOW TABLES;               -- empty set: no tables created yet
