package ructf.roundsCache;

import java.io.FileWriter;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Hashtable;

import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;

import ructf.main.Constants;
import ructf.main.DatabaseManager;

public class Main {

	private static Logger logger = Logger.getLogger("ructf.roundsCache");
	
	private static String sGetStartedRounds = "SELECT n, time FROM rounds WHERE n >= ? ORDER BY n ASC";
		
	private static String sGetScore = "SELECT teams.id, " +
	"(SELECT sum(score_secret) FROM secret_flags WHERE team_id=teams.id AND time >= ? AND time < ?)," +
	"(SELECT sum(score_access) FROM access_checks WHERE team_id=teams.id AND time >= ? AND time < ?)," +	
	"(SELECT sum(score_attack) FROM stolen_flags WHERE team_id=teams.id AND time >= ? AND time < ?)," +
	"(SELECT sum(score_advisory) FROM advisories WHERE team_id=teams.id AND score_advisory > 0 AND check_time >= ? AND check_time < ?)," +
	"(SELECT sum(tasks.score) FROM solved_tasks INNER JOIN tasks ON solved_tasks.task_id=tasks.id WHERE solved_tasks.team_id=teams.id AND solved_tasks.status=true AND solved_tasks.check_time >= ? AND solved_tasks.check_time < ?)" +
	"FROM teams WHERE enabled=true";
		
		
	private static String sUpdateCache = "UPDATE rounds_cache SET privacy = ?, availability = ?, attack = ?, advisories = ?, tasks = ? WHERE round = ? AND team_id = ?";
	private static String sInsertCache = "INSERT INTO rounds_cache (round, time, team_id, privacy, availability, attack, advisories, tasks) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
	
	private static String sDeleteCache = "DELETE FROM rounds_cache";
	
	public static PreparedStatement stDeleteCache;
	public static PreparedStatement stUpdateCache;
	public static PreparedStatement stInsertCache;
	public static PreparedStatement stGetStartedRounds;
	public static PreparedStatement stGetScore;
	
	
	
	public static void main(String[] args) {
		PropertyConfigurator.configure(Constants.log4jConfigFile);
		logger.info("Started");
		try
		{
			if (args.length > 0)
				Constants.Initialize(args[0]);
			
			DatabaseManager.Initialize();
			Connection conn = DatabaseManager.CreateConnection();
			
			stDeleteCache = conn.prepareStatement(sDeleteCache);
			stUpdateCache = conn.prepareStatement(sUpdateCache);
			stInsertCache = conn.prepareStatement(sInsertCache);
			stGetStartedRounds = conn.prepareStatement(sGetStartedRounds);			
			stGetScore = conn.prepareStatement(sGetScore);
			
			
			Hashtable<Integer, Hashtable<Integer, TeamScores>> scoresCache = new Hashtable<Integer, Hashtable<Integer, TeamScores>>();
			
			stDeleteCache.executeUpdate();
			logger.info("Cleared cache in database");
			
			UpdateCacheLoop(conn, 0, scoresCache);			
		} catch (Exception e) {
			logger.fatal("General error", e);
			e.printStackTrace();
		}
	}


	private static void UpdateCacheLoop(Connection conn, int lastCachedRound, Hashtable<Integer, Hashtable<Integer, TeamScores>> scoresCache) throws SQLException, InterruptedException, IOException
	{	
		int lastStartedRound = lastCachedRound;
		Hashtable<Integer, Timestamp> roundTimes = new Hashtable<Integer, Timestamp>();	
		ScoreboardWriter scoreboardWriter = new ScoreboardWriter(conn);
		
		while (true)
		{			
			stGetStartedRounds.setInt(1, lastCachedRound);
			ResultSet res = stGetStartedRounds.executeQuery();		

			while (res.next())
			{
				lastStartedRound = res.getInt(1);					
				roundTimes.put(lastStartedRound, res.getTimestamp(2));
			}			
			
			logger.info(String.format("Trying to get new data, lastCachedRound = %s, lastStartedRound = %s", lastCachedRound, lastStartedRound));
			Hashtable<Integer, Hashtable<Integer, TeamScores>> lastRounds = new Hashtable<Integer, Hashtable<Integer, TeamScores>>();
			
			for (int round = lastCachedRound; round <= lastStartedRound; round++)
			{
				Timestamp startTime =  roundTimes.get(round);
				Timestamp endTime = round != lastStartedRound ? roundTimes.get(round + 1) : new Timestamp(((1l << 31) - 1)* 1000l);
								
				Hashtable<Integer, TeamScores>  teamsScores = new Hashtable<Integer, TeamScores>();
				
				//TODO костыль жоский - убрать дублирование
				stGetScore.setTimestamp(1, startTime);
				stGetScore.setTimestamp(2, endTime);
				stGetScore.setTimestamp(3, startTime);
				stGetScore.setTimestamp(4, endTime);
				stGetScore.setTimestamp(5, startTime);
				stGetScore.setTimestamp(6, endTime);
				stGetScore.setTimestamp(7, startTime);
				stGetScore.setTimestamp(8, endTime);
				stGetScore.setTimestamp(9, startTime);
				stGetScore.setTimestamp(10, endTime);
							
				res = stGetScore.executeQuery();
				while (res.next())
				{
					int team_id = res.getInt(1);
					int privacy = res.getInt(2);
					int availability = res.getInt(3);
					int attack = res.getInt(4);
					int advisories = res.getInt(5);
					int tasks = res.getInt(6);
					TeamScores teamScores = new TeamScores(privacy, availability, attack, advisories, tasks);
					teamsScores.put(team_id, teamScores);						
				}
				lastRounds.put(round, teamsScores);			
			}	
			
			AddToCache(scoresCache, lastRounds, lastCachedRound, lastStartedRound);
			UpdateCacheInDb(conn, scoresCache, roundTimes, lastCachedRound, lastStartedRound);
			
			scoreboardWriter.WriteFiles();		//подтянет данные из базы
						
			lastCachedRound = lastStartedRound;
			logger.info("Sleeping for " + Constants.cacheUpdateInterval + " sec ...");
			Thread.sleep(Constants.cacheUpdateInterval * 1000);
		}
	}
	
	private static void UpdateCacheInDb(Connection conn, Hashtable<Integer, Hashtable<Integer, TeamScores>> scoresCache, Hashtable<Integer, Timestamp> roundTimes, int lastCachedRound, int lastStartedRound) throws SQLException
	{
		try{			
			conn.setAutoCommit(false);

			//UPDATE
			int rowsCount = 0;
			Hashtable<Integer, TeamScores> teamsScores = scoresCache.get(lastCachedRound);
			for (Integer team_id : teamsScores.keySet()) {
				TeamScores teamScores = teamsScores.get(team_id);
				stUpdateCache.setInt(1, teamScores.privacy);
				stUpdateCache.setInt(2, teamScores.availability);
				stUpdateCache.setInt(3, teamScores.attack);
				stUpdateCache.setInt(4, teamScores.advisories);
				stUpdateCache.setInt(5, teamScores.tasks);
				stUpdateCache.setInt(6, lastCachedRound);
				stUpdateCache.setInt(7, team_id);
				rowsCount += stUpdateCache.executeUpdate();
			}
			if (rowsCount == 0)
			{				
				for (Integer team_id : teamsScores.keySet()) {
					TeamScores teamScores = teamsScores.get(team_id);
					stInsertCache.setInt(1, lastCachedRound);
					stInsertCache.setTimestamp(2, roundTimes.get(lastCachedRound));// roundTimes.get(lastCachedRound));
					stInsertCache.setInt(3, team_id);
					stInsertCache.setInt(4, teamScores.privacy);
					stInsertCache.setInt(5, teamScores.availability);
					stInsertCache.setInt(6, teamScores.attack);
					stInsertCache.setInt(7, teamScores.advisories);
					stInsertCache.setInt(8, teamScores.tasks);				
					stInsertCache.execute();
				}	
			}
			
			//INSERT
			for (int round = lastCachedRound + 1; round <= lastStartedRound; round++)
			{
				teamsScores = scoresCache.get(round);
				for (Integer team_id : teamsScores.keySet()) {
					TeamScores teamScores = teamsScores.get(team_id);
					stInsertCache.setInt(1, round);
					stInsertCache.setTimestamp(2, roundTimes.get(round));
					stInsertCache.setInt(3, team_id);
					stInsertCache.setInt(4, teamScores.privacy);
					stInsertCache.setInt(5, teamScores.availability);
					stInsertCache.setInt(6, teamScores.attack);
					stInsertCache.setInt(7, teamScores.advisories);
					stInsertCache.setInt(8, teamScores.tasks);				
					stInsertCache.execute();
				}		
			}
			conn.commit();			
		}
		catch (SQLException exception)
		{
			try {
				conn.rollback();
			} catch (SQLException rollbackException) {
				logger.error("Failed to rollback transaction", rollbackException);
			}
			logger.error("Failed to update cache in database", exception);
		}
		finally
		{
			try {
				conn.setAutoCommit(true);
			} catch (SQLException e) {
				logger.error("Failed to set autoCommit in database to true", e);
				throw e;
			}
		}
	}

	private static void AddToCache(Hashtable<Integer, Hashtable<Integer, TeamScores>> roundSums, Hashtable<Integer, Hashtable<Integer, TeamScores>> lastRounds, int lastCachedRound, int lastStartedRound)
	{
		for (int i = lastCachedRound; i <= lastStartedRound; i++)
		{
			Hashtable<Integer, TeamScores> prevRoundTeamsScores = roundSums.get(i - 1);
			Hashtable<Integer, TeamScores> teamsScores = lastRounds.get(i);
			
			if (prevRoundTeamsScores != null)
			{
				Hashtable<Integer, TeamScores> curRoundTeamsScores = new Hashtable<Integer, TeamScores>();
				for(Integer team_id: prevRoundTeamsScores.keySet())
					curRoundTeamsScores.put(team_id, prevRoundTeamsScores.get(team_id).Clone());
				
				if (teamsScores != null)
				{
					for(Integer team_id: teamsScores.keySet())
					{
						TeamScores teamScores = curRoundTeamsScores.get(team_id);
						if (teamScores != null)
							teamScores.Add(teamsScores.get(team_id));
						else
							curRoundTeamsScores.put(team_id, teamsScores.get(team_id));
					}					
				}				
				roundSums.put(i, curRoundTeamsScores);
			}
			else if (teamsScores != null)
				roundSums.put(i, teamsScores);										
		}
	}
	
}
