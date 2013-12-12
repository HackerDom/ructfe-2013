-- Configuration

CREATE TABLE rounds (
	time		TIMESTAMP  with time zone	NOT NULL,
	n		INTEGER			PRIMARY KEY
);

INSERT INTO rounds VALUES (NOW(), 0);

CREATE TABLE teams (
	id		INTEGER			PRIMARY KEY,
	name		VARCHAR(256)		UNIQUE,
	network		CIDR,
	vuln_box	INET			NOT NULL,
	enabled		BOOLEAN			NOT NULL DEFAULT TRUE
);

CREATE TABLE advauths (
	id		INTEGER		PRIMARY KEY,
	authstr		VARCHAR(256)	NOT NULL
);

CREATE TABLE services (
	id		INTEGER			PRIMARY KEY,
	name		VARCHAR(256),
	checker		VARCHAR(256)		NOT NULL,
	delay_flag_get	BOOLEAN			NOT NULL DEFAULT FALSE
);

CREATE TABLE tasks (
	id		INTEGER			PRIMARY KEY,
	category        VARCHAR(256),
	checkerpath     VARCHAR(256),
	score		INTEGER			CHECK(score>0)
);

-- Score tables

CREATE TABLE flags (
	round		INTEGER,
	time		TIMESTAMP		NOT NULL,
	team_id		INTEGER,
	service_id	INTEGER,
	flag_id		VARCHAR(1024)		NOT NULL,
	flag_data	CHAR(32)		PRIMARY KEY,
	scored		BOOLEAN			NOT NULL DEFAULT FALSE
);

CREATE TABLE delayed_flags (
	round		INTEGER,
	time		TIMESTAMP		NOT NULL,
	team_id		INTEGER,
	service_id	INTEGER,
	flag_id		VARCHAR(1024)		NOT NULL,
	flag_data	CHAR(32)		PRIMARY KEY
);

CREATE TABLE secret_flags (
	time		TIMESTAMP		NOT NULL,
	team_id		INTEGER,
	flag_fata	CHAR(32),
	score_secret	INTEGER
);

CREATE TABLE stolen_flags (
	time		TIMESTAMP		NOT NULL,
	team_id		INTEGER,
	flag_data	CHAR(32),
	victim_team_id	INTEGER,
	victim_service_id	INTEGER,
	score_attack	INTEGER		CHECK (score_attack BETWEEN 1 AND 2)
);

CREATE SEQUENCE adv_seq INCREMENT 1 START 1;
CREATE TABLE advisories
(
  id integer NOT NULL,
  "time" timestamp without time zone NOT NULL,
  check_time timestamp without time zone,
  team_id integer,
  component character varying(256) NOT NULL,
  text text NOT NULL,
  jury_comment text,
  is_public boolean NOT NULL DEFAULT false,
  score_advisory integer DEFAULT 0,
  manual_closed boolean NOT NULL DEFAULT false,
  "number" character varying(100),
  rejected boolean DEFAULT false,
  max_score integer NOT NULL,
  open_time timestamp with time zone,
  CONSTRAINT advisories_team_id_fkey FOREIGN KEY (team_id)
      REFERENCES teams (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);

CREATE SEQUENCE stask_seq INCREMENT 1 START 1;
CREATE TABLE solved_tasks (
	id              INTEGER                 default nextval('stask_seq'),
	time		TIMESTAMP		NOT NULL,
	check_time	TIMESTAMP		DEFAULT NULL,
	team_id		INTEGER			REFERENCES teams(id),
	task_id		INTEGER			REFERENCES tasks(id),
	status          BOOLEAN                 default(NULL),
	message         TEXT,
	verdict         TEXT
);

CREATE TABLE access_checks (
	round		INTEGER,
	time		TIMESTAMP		NOT NULL,
	team_id		INTEGER,
	service_id	INTEGER,
	status		INTEGER			NOT NULL,
	fail_stage	VARCHAR(256),
	fail_comment	TEXT,
	score_access	INTEGER			CHECK (score_access BETWEEN 0 AND 1),
	task_id		UUID DEFAULT NULL
);

CREATE TABLE sla (
	team_id		INTEGER,
	successed	INTEGER,
	failed		INTEGER,
	time		TIMESTAMP		NOT NULL
);

CREATE TABLE news (
    time TIMESTAMP,
    text TEXT,
    author VARCHAR(256)
);

-- Cache 

CREATE TABLE rounds_cache (
	round		INTEGER,
	time		TIMESTAMP		NOT NULL,
	team_id		INTEGER			REFERENCES teams(id),
	privacy		INTEGER,
	availability	INTEGER,
	attack		INTEGER,
	advisories	INTEGER,
	tasks		INTEGER	
);


-- Log table

CREATE TABLE checker_run_log (
	round		INTEGER,
	time		TIMESTAMP		NOT NULL,
	duration	NUMERIC(6,2)		NOT NULL CHECK( duration >= 0 ),
	team_id		INTEGER,
	service_id	INTEGER,
	args		VARCHAR(256),
	retval		INTEGER,
	stdout		TEXT,
	stderr		TEXT
);

-- Functions

CREATE FUNCTION ISNULL(arg bigint, def integer)
RETURNS integer AS
'
begin
    if (arg is null)
	then return def;
	else return arg;
    end if;
end
'
LANGUAGE plpgsql;

CREATE FUNCTION set_time()
RETURNS "trigger" AS
'
BEGIN
	NEW.time = NOW();
	RETURN NEW;
END
'
LANGUAGE plpgsql;

CREATE FUNCTION set_round()
RETURNS "trigger" AS
'
begin
	SELECT INTO NEW.round MAX(n) FROM ROUNDS;
	RETURN NEW;
end
'
LANGUAGE plpgsql;

CREATE FUNCTION set_score_attack()
RETURNS "trigger" AS
'
declare
	already_stolen INTEGER;
begin
	SELECT INTO already_stolen COUNT(*) FROM stolen_flags WHERE flag_data=NEW.flag_data;
	IF (already_stolen=0)
		THEN NEW.score_attack = 2;
		ELSE NEW.score_attack = 1;
	END IF;
	RETURN NEW;
end
'
LANGUAGE plpgsql;

CREATE FUNCTION check_dups()
RETURNS "trigger" AS
'
declare
	dups INTEGER;
begin
	IF (NEW.status=false)
		THEN RETURN NEW;
	END IF;
	SELECT INTO dups COUNT(*) FROM solved_tasks WHERE team_id=NEW.team_id AND task_id=NEW.task_id AND status=true;
	IF (dups=0)
		THEN RETURN NEW;
		ELSE RAISE EXCEPTION ''Duplicate right answer!'';
	END IF;
	RAISE EXCEPTION ''This must never happen!'';
end
'
LANGUAGE plpgsql;

-- Triggers

CREATE TRIGGER set_time_rounds		BEFORE INSERT ON rounds		FOR EACH ROW EXECUTE PROCEDURE set_time();
CREATE TRIGGER set_time_flags		BEFORE INSERT ON flags		FOR EACH ROW EXECUTE PROCEDURE set_time();
CREATE TRIGGER set_time_delayed_flags	BEFORE INSERT ON delayed_flags	FOR EACH ROW EXECUTE PROCEDURE set_time();
CREATE TRIGGER set_time_secret_flags	BEFORE INSERT ON secret_flags	FOR EACH ROW EXECUTE PROCEDURE set_time();
CREATE TRIGGER set_time_stolen_flags	BEFORE INSERT ON stolen_flags	FOR EACH ROW EXECUTE PROCEDURE set_time();

CREATE TRIGGER set_time_advisories	BEFORE INSERT ON advisories	FOR EACH ROW EXECUTE PROCEDURE set_time();
CREATE TRIGGER set_time_access_checks	BEFORE INSERT ON access_checks	FOR EACH ROW EXECUTE PROCEDURE set_time();
CREATE TRIGGER set_time_solved_tasks	BEFORE INSERT ON solved_tasks	FOR EACH ROW EXECUTE PROCEDURE set_time();
CREATE TRIGGER set_time_news            BEFORE INSERT ON news		FOR EACH ROW EXECUTE PROCEDURE set_time();

CREATE TRIGGER set_round_flags		BEFORE INSERT ON flags		 FOR EACH ROW EXECUTE PROCEDURE set_round();
CREATE TRIGGER set_round_delayed_flags	BEFORE INSERT ON delayed_flags	 FOR EACH ROW EXECUTE PROCEDURE set_round();
CREATE TRIGGER set_round_access_checks	BEFORE INSERT ON access_checks	 FOR EACH ROW EXECUTE PROCEDURE set_round();
CREATE TRIGGER set_round_ck_run_log	BEFORE INSERT ON checker_run_log FOR EACH ROW EXECUTE PROCEDURE set_round();
CREATE TRIGGER set_score_attack		BEFORE INSERT ON stolen_flags	 FOR EACH ROW EXECUTE PROCEDURE set_score_attack();

CREATE TRIGGER solved_tasks_check_dups  BEFORE INSERT ON solved_tasks	 FOR EACH ROW EXECUTE PROCEDURE check_dups();

-- Indexes

CREATE UNIQUE INDEX idx_stolen_flags	ON stolen_flags(flag_data, team_id);
CREATE INDEX idx_rounds_cache		ON rounds_cache(time);
CREATE INDEX idx_rounds_cache_2		ON rounds_cache(team_id ASC, round ASC);
CREATE INDEX idx_checker_run_log_1	ON checker_run_log(time);
CREATE INDEX idx_checker_run_log_2	ON checker_run_log(round);
CREATE INDEX idx_access_checks_1	ON access_checks(time);
CREATE INDEX idx_access_checks_2	ON access_checks(round);

-- FOR cache
CREATE INDEX idx_secret_flags	ON secret_flags(team_id, time);
CREATE INDEX idx_access_checks_3	ON access_checks(team_id, time);
CREATE INDEX idx_stolen_flags_2	ON stolen_flags(team_id, time);
CREATE INDEX idx_advisories	ON advisories(team_id, check_time);
CREATE INDEX idx_solved_tasks	ON solved_tasks(team_id, status, check_time);



-- Views

CREATE VIEW score AS 
	SELECT 
		teams.id,
		teams.name,
		(SELECT sum(score_secret)	FROM secret_flags	WHERE team_id=teams.id) AS "privacy",
		(SELECT sum(score_access)	FROM access_checks	WHERE team_id=teams.id) AS "availability",
		(SELECT sum(score_attack)	FROM stolen_flags	WHERE team_id=teams.id) AS "attack",
		(SELECT sum(score_advisory)	FROM advisories		WHERE team_id=teams.id) AS "advisories",
		(SELECT sum(tasks.score)	
			FROM  solved_tasks INNER JOIN tasks
			ON    solved_tasks.task_id=tasks.id
			WHERE solved_tasks.team_id=teams.id AND solved_tasks.status=true) AS "tasks"
	FROM  teams
	WHERE enabled=true;

	

CREATE VIEW service_status AS
	SELECT 
		last_check.time as "time", a.team_id, t.name as team, a.service_id, s.name as service, a.status, a.fail_comment
	FROM
	(
		SELECT    max(time) as "time", team_id, service_id
		FROM      access_checks
		GROUP BY  team_id, service_id
	) AS last_check
	NATURAL INNER JOIN access_checks as a
	INNER JOIN teams as t ON last_check.team_id = t.id
	INNER JOIN services as s ON last_check.service_id = s.id
	ORDER BY t.name, s.name;
	

CREATE VIEW cached_score AS
	SELECT
		teams.id, teams.name, rounds_cache.privacy, rounds_cache.availability, rounds_cache.attack, rounds_cache.advisories, rounds_cache.tasks
	FROM
		rounds_cache
	JOIN
		teams ON teams.id = rounds_cache.team_id
	WHERE
		rounds_cache.round = ( SELECT max(rounds_cache.round) AS max FROM rounds_cache);
	
CREATE VIEW xmlCachedScoreboard AS
	SELECT xmlroot(
	(SELECT xmlconcat(
		(SELECT xmlpi(name "xml-stylesheet", 'type="text/xsl" href="scoreboard.en.xsl"')),	
		(SELECT
			xmlelement(
				name scoreboard,
				xmlattributes((SELECT to_char(NOW() AT TIME ZONE 'UTC', 'YYYY.MM.DD HH24:MI:SS')) as "genTimeUTC", (SELECT max(n) FROM rounds) as "round", (SELECT to_char(time AT TIME ZONE 'UTC', 'HH24:MI:SS') FROM rounds WHERE n = (SELECT max(n) from rounds)) as "roundStartTimeUTC"),
				(SELECT
					xmlagg(team)
				FROM
					(SELECT
						xmlconcat(
							xmlelement(
								name team, xmlattributes(teams.name as name, teams.vuln_box as "vulnBox"),
								(SELECT		
									xmlelement(
										name scores,
										xmlattributes(ISNULL(privacy,0) + ISNULL(availability,0) as defence, attack, advisories)
									)
								FROM
									cached_score
								WHERE
									name=teams.name
								),
								xmlelement(
									name services,
									(SELECT
										xmlagg(service)
									FROM
										(SELECT
											xmlelement(name service, xmlattributes(service as name, status, fail_comment)) as service
										FROM
											service_status
										WHERE
											team=teams.name) as services
									)
								)
							
							)
						) as team
					FROM teams
					WHERE enabled=true
					) as body
				)
			)
		))
	),
	version '1.0',
	standalone yes
	) as scoreboard;
	

CREATE VIEW xmlScoreboard AS	
	SELECT xmlroot(
	(SELECT xmlconcat(
		(SELECT xmlpi(name "xml-stylesheet", 'type="text/xsl" href="scoreboard.en.xsl"')),	
		(SELECT
			xmlelement(
				name scoreboard,
				xmlattributes((SELECT to_char(NOW() AT TIME ZONE 'UTC', 'YYYY.MM.DD HH24:MI:SS')) as "genTimeUTC", (SELECT max(n) FROM rounds) as "round", (SELECT to_char(time AT TIME ZONE 'UTC', 'HH24:MI:SS') FROM rounds WHERE n = (SELECT max(n) from rounds)) as "roundStartTimeUTC"),
				(SELECT
					xmlagg(team)
				FROM
					(SELECT
						xmlconcat(
							xmlelement(
								name team, xmlattributes(teams.name as name, teams.vuln_box as "vulnBox"),
								(SELECT		
									xmlelement(
										name scores,
										xmlattributes(ISNULL(privacy,0) + ISNULL(availability,0) as defence, attack, advisories)
									)
								FROM
									score
								WHERE
									name=teams.name
								),
								xmlelement(
									name services,
									(SELECT
										xmlagg(service)
									FROM
										(SELECT
											xmlelement(name service, xmlattributes(service as name, status, fail_comment)) as service
										FROM
											service_status
										WHERE
											team=teams.name) as services
									)
								)
							
							)
						) as team
					FROM teams
					WHERE enabled=true
					) as body
				)
			)
		))
	),
	version '1.0',
	standalone yes
	) as scoreboard;


/*
CREATE OR REPLACE VIEW xmlcachedscoreboard_last AS 
SELECT XMLROOT(( SELECT XMLCONCAT(
  (SELECT XMLPI(NAME "xml-stylesheet", 'type="text/xsl" href="scoreboard.xsl"'::text) AS "xmlpi"), 
    (SELECT XMLELEMENT(NAME scoreboard, ( SELECT xmlagg(body.team) AS xmlagg
        FROM ( SELECT XMLCONCAT(XMLELEMENT(NAME team, XMLATTRIBUTES(teams.name AS name, teams.vuln_box AS "vulnBox"),
     XMLELEMENT(NAME services, ( SELECT xmlagg(services.service) AS xmlagg
        FROM ( SELECT XMLELEMENT(NAME service, XMLATTRIBUTES(service_status.service AS name, service_status.status AS status, service_status.fail_comment AS fail_comment)) AS service
           FROM service_status WHERE service_status.team::text = teams.name::text) services)))) AS team
    FROM teams WHERE teams.enabled = true) body)) AS "xmlelement")) AS "xmlconcat"), VERSION '1.0'::text, STANDALONE YES) AS scoreboard;

ALTER TABLE xmlcachedscoreboard_last OWNER TO ructf;
*/


CREATE VIEW services_flags_stolen AS
	SELECT
		t.name as team, s.name as service, count(s.name) as flags
	FROM
		stolen_flags as st
	INNER JOIN
		flags as fl ON st.flag_data = fl.flag_data
	INNER JOIN
		teams t ON st.team_id = t.id
	INNER JOIN
		services as s ON s.id = fl.service_id
	GROUP BY t.name, s.name
	ORDER BY t.name, s.name;
	
CREATE VIEW xmlFlags AS
	SELECT xmlroot(
	(SELECT xmlconcat(
		(SELECT xmlpi(name "xml-stylesheet", 'type="text/xsl" href="flags.en.xsl"')),	
		(SELECT
			xmlelement(
				name "servicesFlagsStolen",
				xmlattributes((SELECT to_char(NOW() AT TIME ZONE 'UTC', 'YYYY.MM.DD HH24:MI:SS')) as "genTimeUTC", (SELECT max(n) FROM rounds) as "round", (SELECT to_char(time AT TIME ZONE 'UTC', 'HH24:MI:SS') FROM rounds WHERE n = (SELECT max(n) from rounds)) as "roundStartTimeUTC"),
				xmlelement(
					name services,
					(SELECT
						xmlagg(service)
					FROM
						(SELECT
							xmlelement(
								name service,
								xmlattributes(s.name)
							) as service
						FROM
							services as s
						) as service
					)
				),
					
				xmlelement(
					name teams,
					(SELECT		
						xmlagg(team)
					FROM
						(SELECT
							xmlelement(
								name team, xmlattributes(teams.name),
								(SELECT
									xmlagg(amount)
								FROM
									(SELECT
										xmlelement(name flags, xmlattributes(sfs.flags as amount, sfs.service)) as amount
									FROM
										services_flags_stolen as sfs
									WHERE
										team=teams.name
									) as flags
								)
							) as team
						FROM teams
						WHERE enabled=true
						) as team
					)
				)					
			)
		))
	),
	version '1.0',
	standalone yes
	);

