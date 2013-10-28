DELETE FROM rounds;
DELETE FROM checker_run_log;
DELETE FROM access_checks;
DELETE FROM advisories;
DELETE FROM solved_tasks;
DELETE FROM stolen_flags;
DELETE FROM secret_flags;
DELETE FROM delayed_flags;
DELETE FROM flags;
DELETE FROM cache;

INSERT INTO rounds(n) VALUES(0);
