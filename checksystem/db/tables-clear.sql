DELETE FROM news;
DELETE FROM rounds;
DELETE FROM checker_run_log;
DELETE FROM access_checks;
DELETE FROM advisories;
ALTER SEQUENCE adv_seq RESTART 1;
DELETE FROM solved_tasks;
ALTER SEQUENCE stask_seq RESTART 1;
DELETE FROM stolen_flags;
DELETE FROM secret_flags;
DELETE FROM flags;
DELETE FROM cache;
DELETE FROM tasks;
DELETE FROM services;
DELETE FROM teams;

INSERT INTO rounds(n) VALUES(0);

