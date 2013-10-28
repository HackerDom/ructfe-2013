package ructf.historyWeb;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import ructf.main.Constants;
import ructf.main.DatabaseManager;

public class CacheUpdater extends Thread{

	private static String sGetCache = "SELECT round, time, team_id, privacy + availability, attack, advisories, tasks FROM rounds_cache ORDER BY team_id ASC, round ASC";
	public static PreparedStatement stGetCache;
	
	private Cache cache;
	
	private Logger logger = Logger.getLogger("ructf.historyWeb");
	
	public CacheUpdater(Cache cache) throws Exception{
		this.cache = cache;		
	}
	
	public void run()
	{
		while(true){
			try {
				DatabaseManager.Initialize();
				Connection conn = DatabaseManager.CreateConnection();
				stGetCache = conn.prepareStatement(sGetCache);
				while(true){					
					UpdateCache();
					Thread.sleep(Constants.cacheUpdateInterval * 1000);
				}
			}
			catch (Exception e){
				logger.error(String.format("CacheUpdater: error. Waiting %s seconds and retrying...", errorSleepTimeout), e);								
				try {
					Thread.sleep(errorSleepTimeout * 1000);					
				} catch (Exception e1) {					
					e1.printStackTrace();
				}				
			}		
		}			
	}
	
	public void UpdateCache() throws SQLException{
		ResultSet res = stGetCache.executeQuery();	
		
		int lastTeamId = Integer.MIN_VALUE;
		
		ArrayList<TeamHistory> teamHistories = new ArrayList<TeamHistory>();
		TeamHistory lastTeamHistory = null;
		ArrayList<Integer> rounds = new ArrayList<Integer>();
		ArrayList<Long> roundTimes = new ArrayList<Long>();
		while (res.next())
		{
			int round = res.getInt(1);
			Timestamp timestamp = res.getTimestamp(2);
			int teamId = res.getInt(3);
			int defense = res.getInt(4);
			int attack = res.getInt(5);
			int advisories = res.getInt(6);
			int tasks = res.getInt(7);
			
			if (lastTeamId != teamId){
				if (lastTeamHistory != null)
					teamHistories.add(lastTeamHistory);
				lastTeamHistory = new TeamHistory();				
				lastTeamHistory.teamId = teamId;
				lastTeamHistory.teamName = DatabaseManager.getTeamName(teamId);
				lastTeamId = teamId;
			}
			
			lastTeamHistory.defense.add(defense);
			lastTeamHistory.attack.add(attack);
			lastTeamHistory.advisories.add(advisories);
			lastTeamHistory.tasks.add(tasks);
			
			if (teamHistories.size() == 0){
				rounds.add(round);
				roundTimes.add(timestamp.getTime());	
			}		
		}
		if (lastTeamHistory != null)
			teamHistories.add(lastTeamHistory);
		cache.Reset(rounds, roundTimes, teamHistories);
	}	
	
	private final int errorSleepTimeout = 30;	
}
