package ructf.historyWeb;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.HashMap;

import org.apache.log4j.Logger;

import ructf.main.Constants;
import ructf.main.DatabaseManager;

public class LogUpdater extends Thread{
		
	private static String sGetFlagNews = "SELECT team_id, victim_team_id, victim_service_id, score_attack, time FROM stolen_flags WHERE time>?";
	private static String sGetStatusNews = "SELECT team_id, service_id, status, time FROM access_checks WHERE time>?";
	private static String sGetScoresNews = "SELECT 'at', team_id, score_attack, time FROM stolen_flags WHERE score_attack>0 AND time>? UNION ALL " +
	   "(SELECT 'se', team_id, score_secret, time FROM secret_flags WHERE score_secret>0 AND time>? ORDER BY time ASC) UNION ALL " +
	   "(SELECT 'ac', team_id, score_access, time FROM access_checks WHERE score_access>0 AND time>? ORDER BY time ASC) UNION ALL " +
	   "SELECT 'ad', team_id, score_advisory, time FROM advisories WHERE score_advisory>0 AND time>? UNION ALL " +
	   "SELECT 'ta', solved_tasks.team_id, tasks.score, solved_tasks.time FROM solved_tasks INNER JOIN tasks ON solved_tasks.task_id=tasks.id WHERE solved_tasks.status=true AND tasks.score>0 AND solved_tasks.time>?";
		
	
	private static PreparedStatement stGetFlagNews;
	private static PreparedStatement stGetStatusNews;
	private static PreparedStatement stGetScoresNews;
	
	private Timestamp flagTime = new Timestamp(0);
	private Timestamp statusTime = new Timestamp(0);
	private Timestamp scoresTime = new Timestamp(0);
	
	private Log log;	 	
	private HashMap<String, Integer> lastStatuses = new HashMap<String, Integer>();
	
	public LogUpdater(Log log) throws Exception{
		this.log = log;		
	}
	
	public void run()
	{
		while(true){
			try {
				DatabaseManager.Initialize();
				Connection conn = DatabaseManager.CreateConnection();
				PrepareStatements(conn);
				while(true){					
					UpdateFlagLog();
					UpdateStatusLog();
					UpdateScoresLog();
					Thread.sleep(Constants.cacheUpdateInterval * 1000);
				}
			}
			catch (Exception e){
				logger.error(String.format("LogUpdater: error. Waiting %s seconds and retrying...", errorSleepTimeout), e);								
				try {
					Thread.sleep(errorSleepTimeout * 1000);					
				} catch (Exception e1) {					
					e1.printStackTrace();
				}				
			}		
		}			
	}
	
	private void UpdateFlagLog() throws SQLException{
		stGetFlagNews.setTimestamp(1, flagTime);
		ResultSet flagNews = stGetFlagNews.executeQuery();
		
		Timestamp maxFlagTime = flagTime;
		int lines = 0;
		while (flagNews.next()) {
			int attacker_id = flagNews.getInt(1);
			int victim_id = flagNews.getInt(2);
			int victim_service_id = flagNews.getInt(3);
			int score_attack = flagNews.getInt(4);
			Timestamp timestamp = flagNews.getTimestamp(5);
			
			String s = String.format("f %d %d %d %d %d", timestamp.getTime(), attacker_id, victim_id, victim_service_id, score_attack);
			log.insertFlag(timestamp.getTime(), s);
			
			if (timestamp.after(maxFlagTime))
				maxFlagTime = timestamp;
			++lines;
		}
		flagTime = maxFlagTime;
		logger.info(String.format("  %d new events in stolen_flags", lines));
	}
	
	private void UpdateStatusLog() throws SQLException{
		stGetStatusNews.setTimestamp(1, statusTime);
		ResultSet statusNews = stGetStatusNews.executeQuery();
		
		Timestamp maxStatusTime = statusTime;
		int lines = 0;
		while (statusNews.next()) {
			int team_id = statusNews.getInt(1);
			int service_id = statusNews.getInt(2);
			int service_status = statusNews.getInt(3);
			Timestamp timestamp = statusNews.getTimestamp(4);
			
			String key = String.format("%d %d", team_id, service_id);
			String s = String.format("s %d %d %d %d %s", timestamp.getTime(), team_id, service_id, service_status, "");

			if (!lastStatuses.containsKey(key) || lastStatuses.get(key) != service_status)
			{
				log.insertStatus(timestamp.getTime(), s);
				lastStatuses.put(key, service_status);				
			}			

			if (timestamp.after(maxStatusTime))
				maxStatusTime = timestamp;
			++lines;
		}
		statusTime = maxStatusTime;
		logger.info(String.format("  %d new events in access_checks", lines));
	}
	
	private void UpdateScoresLog() throws SQLException{
		//говнокопипаст
		stGetScoresNews.setTimestamp(1, scoresTime);
		stGetScoresNews.setTimestamp(2, scoresTime);
		stGetScoresNews.setTimestamp(3, scoresTime);
		stGetScoresNews.setTimestamp(4, scoresTime);
		stGetScoresNews.setTimestamp(5, scoresTime);
		ResultSet scoresNews = stGetScoresNews.executeQuery();				
				
		Timestamp maxScoresTime = scoresTime;
		int lines = 0;
		while (scoresNews.next())
		{
			String prefix = scoresNews.getString(1);
			int team_id = scoresNews.getInt(2);
			int score = scoresNews.getInt(3);
			Timestamp timestamp = scoresNews.getTimestamp(4);
			
			String s = String.format("%s %d %d %d", prefix.equals("se") || prefix.equals("ac") ? "de" : prefix, timestamp.getTime(), team_id, score);
			log.insertScores(timestamp.getTime(), s, prefix);
			
			if (timestamp.after(maxScoresTime))
				maxScoresTime = timestamp;
			++lines;
		}
		scoresTime = maxScoresTime;
		logger.info(String.format("  %d new events in scores", lines));
	}

	private static void PrepareStatements(Connection conn) throws SQLException {
		stGetFlagNews = conn.prepareStatement(sGetFlagNews);
		stGetStatusNews = conn.prepareStatement(sGetStatusNews);
		stGetScoresNews = conn.prepareStatement(sGetScoresNews);		
	}
	
	private final int errorSleepTimeout = 30;	
	private Logger logger = Logger.getLogger("ructf.historyWeb");	
}
