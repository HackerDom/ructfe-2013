package ructf.scoresCache;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Hashtable;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;

import ructf.main.Constants;
import ructf.main.DatabaseManager;

public class Main {
	
	private static Logger logger = Logger.getLogger("ructf.scoresCache");
	
	private static String sqlGetLastScores = "SELECT score.team, score.score, score.time FROM (SELECT team,MAX(time) AS time FROM score GROUP BY team) qqq INNER JOIN score ON qqq.time=score.time AND qqq.team=score.team";
	private static String sqlCreateInitState = "INSERT INTO score SELECT 0, '2009-01-01', teams.id, 1000 FROM teams";
	private static String sqlGetStealsOfRottenFlags = "SELECT flags.flag_data,flags.time,stolen_flags.victim_team_id,stolen_flags.team_id FROM flags INNER JOIN stolen_flags ON flags.flag_data=stolen_flags.flag_data WHERE flags.time>?";
	private static String sqlInsertScore = "INSERT INTO score (round, time, team, score) VALUES (?,?,?,?)";
		
	private static PreparedStatement stGetLastScores;	
	private static PreparedStatement stCreateInitState;
	private static PreparedStatement stGetStealsOfRottenFlags;
	private static PreparedStatement stInsertScore;
	
	public static void main(String[] args) {
		PropertyConfigurator.configure(Constants.log4jConfigFile);
		logger.info("Started");
		try
		{
			if (args.length > 0)
				Constants.Initialize(args[0]);
			
			DatabaseManager.Initialize();
						
			Connection conn = DatabaseManager.CreateConnection();
			PrepareStatements(conn);
			
			Hashtable<Integer,TeamScore> stateFromDb = GetStateFromDb();
			if (stateFromDb.isEmpty()) {
				CreateInitStateInDb();
				logger.info("CreateInitStateInDb completed");
				stateFromDb = GetStateFromDb();
			}
								
			Timestamp lastKnownTime = GetLastKnownTime(stateFromDb);
			logger.info(String.format("LastKnownTime: %s", lastKnownTime.toString()));
			
			DoJobLoop(conn, stateFromDb, lastKnownTime);
						
		} catch (Exception e) {
			logger.fatal("General error", e);
			e.printStackTrace();
		}
	}
	
	private static List<RottenStolenFlag> GetRottenStolenFlags(Timestamp ts) throws SQLException
	{
		List<RottenStolenFlag> result = new LinkedList<RottenStolenFlag>();
		
		stGetStealsOfRottenFlags.setTimestamp(1, ts);
		ResultSet res = stGetStealsOfRottenFlags.executeQuery();
		
		while (res.next()) {
			String flagData = res.getString(1);
			Timestamp time = res.getTimestamp(2);
			int owner = res.getInt(3);
			int attacker = res.getInt(4);
			
			result.add(new RottenStolenFlag(flagData, time, owner, attacker));
		}
		
		return result;
	}
	
	private static void DoJobLoop(Connection conn, Hashtable<Integer,TeamScore> state, Timestamp lastKnownTime) throws SQLException, InterruptedException {
		Timestamp lastCreationTime = new Timestamp(lastKnownTime.getTime() - Constants.flagExpireInterval*1000);
		int totalTeamsCount = DatabaseManager.getTeams().size();
		
		conn.setAutoCommit(false);
		while (true) {
			List<RottenStolenFlag> flags = GetRottenStolenFlags(lastCreationTime);
			
			Hashtable<String, ArrayList<RottenStolenFlag>> grouped = new Hashtable<String, ArrayList<RottenStolenFlag>>();
			for (RottenStolenFlag flag : flags) {
				String flagData = flag.flagData;
				if (!grouped.containsKey(flagData))
					grouped.put(flagData, new ArrayList<RottenStolenFlag>());
				
				ArrayList<RottenStolenFlag> list = grouped.get(flagData);
				list.add(flag);
			}
			
			Set<RottenStolenFlag> flagTimes = new TreeSet<RottenStolenFlag>(new Comparator<RottenStolenFlag>(){
				public int compare(RottenStolenFlag a, RottenStolenFlag b){
	                return a.time.compareTo(b.time);
	            }
			});
			flagTimes.addAll(flags);
			
			for (RottenStolenFlag flag : flagTimes) {
				lastCreationTime = flag.time;
				
				int owner = flag.owner;
				double ownerTotalScore = state.get(owner).score;				
				
				ArrayList<RottenStolenFlag> list = grouped.get(flag.flagData);
				int attackersCount = list.size();				

				double scoreFromOwner = Math.min(totalTeamsCount, ownerTotalScore);
				double scoreToEachAttacker = scoreFromOwner / attackersCount;
				
				Timestamp rottenTime = new Timestamp(flag.time.getTime() + Constants.flagExpireInterval*1000);
				
				try {
					for (RottenStolenFlag attackerFlag : list) {
						int attacker = attackerFlag.attacker;
						
						double attackerOldScore = state.get(attacker).score;
						double attackerNewScore = attackerOldScore + scoreToEachAttacker;
						InsertScore(0, rottenTime, attacker, attackerNewScore);
						state.put(attacker, new TeamScore(attacker, attackerNewScore, rottenTime));
						logger.info(String.format("Flag %s: attacker %d: score %f -> %f (delta = %f)", flag.flagData, attacker, attackerOldScore, attackerNewScore, scoreToEachAttacker));
					}
					double ownerNewScore = ownerTotalScore - scoreFromOwner;
					InsertScore(0, rottenTime, owner, ownerNewScore);
					state.put(owner, new TeamScore(owner, ownerNewScore, rottenTime));
					logger.info(String.format("Flag %s: owner %d: score %f -> %f (delta = %f)", flag.flagData, owner, ownerTotalScore, ownerNewScore, -scoreFromOwner));
					
					conn.commit();
				}
				catch (SQLException exception)
				{
					try {
						conn.rollback();
						throw exception;
					} catch (SQLException rollbackException) {
						logger.error("Failed to rollback transaction", rollbackException);
					}
					logger.error("Failed to insert score data in database", exception);
				}
			}
			
			logger.info("Sleeping ... ");
			Thread.sleep(10000);
		}
	}
	
	private static void InsertScore(int round, Timestamp time, int team, double score) throws SQLException
	{
		stInsertScore.setInt(1, round);
		stInsertScore.setTimestamp(2, time);
		stInsertScore.setInt(3, team);
		stInsertScore.setDouble(4, score);
		stInsertScore.execute();
	}

	private static Timestamp GetLastKnownTime(Hashtable<Integer, TeamScore> stateFromDb) {
		Timestamp max = null;
		for (TeamScore ts : stateFromDb.values()) {
			if (max == null || max.before(ts.time))
				max = ts.time;
		}
		return max;
	}

	private static void CreateInitStateInDb() throws SQLException {
		stCreateInitState.execute();
	}

	private static void PrepareStatements(Connection conn) throws SQLException{		
		stGetLastScores = conn.prepareStatement(sqlGetLastScores);
		stCreateInitState = conn.prepareStatement(sqlCreateInitState);
		stGetStealsOfRottenFlags = conn.prepareStatement(sqlGetStealsOfRottenFlags);
		stInsertScore = conn.prepareStatement(sqlInsertScore);
	}
	
	private static Hashtable<Integer, TeamScore> GetStateFromDb() throws SQLException{
		ResultSet res = stGetLastScores.executeQuery();
		
		Hashtable<Integer, TeamScore> result = new Hashtable<Integer, TeamScore>(); 
		
		while(res.next()){
			int team = res.getInt(1);
			double score = res.getDouble(2);			
			Timestamp time = res.getTimestamp(3);
			
			result.put(team, new TeamScore(team, score, time));
		}
		return result;		
	}
}
