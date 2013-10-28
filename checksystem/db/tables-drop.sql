--DROP VIEW xmlcachedscoreboard_last;
DROP VIEW xmlCachedScoreboard ;
DROP VIEW cached_score ;
DROP VIEW xmlFlags;
DROP VIEW services_flags_stolen ;
DROP VIEW xmlScoreboard ;
DROP VIEW service_status ;
DROP VIEW score ;

DROP INDEX idx_solved_tasks;
DROP INDEX idx_advisories;
DROP INDEX idx_stolen_flags_2;
DROP INDEX idx_access_checks_3;
DROP INDEX idx_secret_flags;

DROP INDEX idx_access_checks_2;
DROP INDEX idx_access_checks_1;
DROP INDEX idx_checker_run_log_2;
DROP INDEX idx_checker_run_log_1;
DROP INDEX idx_rounds_cache_2;
DROP INDEX idx_rounds_cache;
DROP INDEX idx_stolen_flags;

DROP TRIGGER solved_tasks_check_dups    ON solved_tasks;
DROP TRIGGER set_score_attack		ON stolen_flags;
DROP TRIGGER set_round_flags            ON flags;
DROP TRIGGER set_round_delayed_flags	ON delayed_flags;
DROP TRIGGER set_round_access_checks    ON access_checks;
DROP TRIGGER set_round_ck_run_log       ON checker_run_log;

DROP TRIGGER set_time_news              ON news          ;
DROP TRIGGER set_time_solved_tasks	ON solved_tasks  ;
DROP TRIGGER set_time_access_checks	ON access_checks ;
DROP TRIGGER set_time_advisories	ON advisories	 ;
DROP TRIGGER set_time_stolen_flags	ON stolen_flags	 ;
DROP TRIGGER set_time_secret_flags	ON secret_flags	 ;
DROP TRIGGER set_time_delayed_flags	ON delayed_flags ;
DROP TRIGGER set_time_flags		ON flags	 ;
DROP TRIGGER set_time_rounds		ON rounds        ;

DROP FUNCTION check_dups();
DROP FUNCTION set_score_attack();
DROP FUNCTION set_round();
DROP FUNCTION set_time();
DROP FUNCTION ISNULL(arg bigint, def integer);

DROP TABLE news;
DROP TABLE rounds;
DROP TABLE checker_run_log;
DROP TABLE access_checks;
DROP TABLE solved_tasks;
DROP SEQUENCE stask_seq;
DROP TABLE advisories;
DROP SEQUENCE adv_seq;
DROP TABLE delayed_flags;
DROP TABLE stolen_flags;
DROP TABLE secret_flags;
DROP TABLE flags;
DROP TABLE rounds_cache;
DROP TABLE tasks;
DROP TABLE services;
DROP TABLE advauths;
DROP TABLE teams;


