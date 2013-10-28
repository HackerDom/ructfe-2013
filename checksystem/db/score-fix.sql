CREATE OR REPLACE VIEW score AS 
 SELECT teams.id, teams.name, ( SELECT sum(flags.score_secret) AS sum
           FROM flags
          WHERE flags.team_id = teams.id) AS privacy, ( SELECT sum(access_checks.score_access) AS sum
           FROM access_checks
          WHERE access_checks.team_id = teams.id) AS availability, ( SELECT sum(stolen_flags.score_attack) AS sum FROM stolen_flags
          WHERE stolen_flags.team_id = teams.id) AS attack, ( SELECT sum(advisories.score_advisory) AS sum FROM advisories
          WHERE advisories.team_id = teams.id) AS advisories,

          ( SELECT sum(tasks.score) AS sum FROM 
		(SELECT distinct task_id FROM solved_tasks WHERE team_id=teams.id AND solved_tasks.status) AS id_set
			JOIN tasks ON id_set.task_id = tasks.id ) AS tasks
   FROM teams
  WHERE teams.enabled = true;
