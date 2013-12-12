package ructf.scoresCache;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Hashtable;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

import org.apache.log4j.Logger;

import ructf.main.CheckerExitCode;
import ructf.main.Constants;
import ructf.main.DatabaseManager;

public class SLAworker extends Thread{
	
	private static String sqlGetLastSla = "SELECT sla.team_id, sla.successed, sla.failed, sla.time FROM (SELECT team_id, MAX(time) AS time FROM sla GROUP BY team_id) last_times INNER JOIN sla ON last_times.time=sla.time AND last_times.team_id=sla.team_id";
	private static String sqlGetLastAccessChecks = "SELECT team_id, status, count(*), max(time) FROM access_checks WHERE time > ? GROUP BY team_id, status";
	private static String sqlInsertSla = "INSERT INTO sla (team_id, successed, failed, time) VALUES (?, ?, ?, ?)";
	private static PreparedStatement stGetLastSla;
	private static PreparedStatement stGetLastAccessChecks;
	private static PreparedStatement stInsertSla;
	
	
	private Logger logger = Logger.getLogger("ructf.scoresCache");
	private Connection conn;
	
	public SLAworker() throws SQLException {		
		this.conn = DatabaseManager.CreateConnection();
		PrepareStatements(conn);		
	}
	
	private Hashtable<Integer, SLA> GetStateFromDb() throws SQLException {
		ResultSet res = stGetLastSla.executeQuery();
		
		Hashtable<Integer, SLA> result = new Hashtable<Integer, SLA>(); 
		
		while(res.next()){
			int team = res.getInt(1);
			int successed = res.getInt(2);			
			int failed = res.getInt(3);
			Timestamp time = res.getTimestamp(4);
			
			result.put(team, new SLA(team, successed, failed, time));
		}
		return result;	
	}

	public void run() {
		try
		{
			Hashtable<Integer,SLA> stateFromDb = GetStateFromDb();
			Timestamp lastKnownTime = GetLastKnownTime(stateFromDb);
			logger.info(String.format("LastKnownTime: %s", lastKnownTime.toString()));			
			DoJobLoop(stateFromDb, lastKnownTime);
		}
		catch(Exception e){
			logger.fatal("General error in SLA thread", e);
			e.printStackTrace();
			System.exit(2);
		}		
	}
	
	private void DoJobLoop(Hashtable<Integer, SLA> state, Timestamp lastKnownTime) throws SQLException, InterruptedException {
		if (lastKnownTime == null)
			lastKnownTime = new Timestamp(0);
		
		conn.setAutoCommit(false);
		
		
		while (true) {
			stGetLastAccessChecks.setTimestamp(1, lastKnownTime);
			ResultSet res = stGetLastAccessChecks.executeQuery();
			
			Hashtable<Integer, SLA> stateDelta = new Hashtable<Integer, SLA>();
			
			while (res.next()) {				
				int team = res.getInt(1);
				int status = res.getInt(2);
				if(CheckerExitCode.isUnknown(status))
					status = CheckerExitCode.Down.toInt();				
				int count = res.getInt(3);
				Timestamp time = res.getTimestamp(4);
				
				if(!stateDelta.containsKey(team))
					stateDelta.put(team, new SLA(team, 0, 0, time));
				SLA slaDelta = stateDelta.get(team);

				if(status == CheckerExitCode.OK.toInt())
					slaDelta.successed+=count;
				else
					slaDelta.failed+=count;
				slaDelta.time = Max(slaDelta.time, time);
			}			
			
			for (int team : stateDelta.keySet()) {
				SLA slaDelta = stateDelta.get(team);
				if(!state.containsKey(team))
					state.put(team, slaDelta);
				else {
					SLA sla = state.get(team);					 
					sla.successed += slaDelta.successed;
					sla.failed += slaDelta.failed;
					sla.time = slaDelta.time;					
				}
				lastKnownTime = Max(state.get(team).time, lastKnownTime);
				logger.info(String.format("Team %d delta: successed = %d, failed = %d, time = %s)", slaDelta.team, slaDelta.successed, slaDelta.failed, slaDelta.time.toString()));
			}
			
			try {
				for (SLA sla : state.values()) {
					stInsertSla.setInt(1, sla.team);
					stInsertSla.setInt(2, sla.successed);
					stInsertSla.setInt(3, sla.failed);
					stInsertSla.setTimestamp(4, sla.time);
					stInsertSla.execute();					
					
					int total = sla.successed + sla.failed;
					
					logger.info(String.format("Team %d result: successed = %d, failed = %d (SLA %f), time = %s)", sla.team, sla.successed, sla.failed, total > 0 ? ((double) sla.successed) / total : 0.0d, sla.time.toString()));
				}				
				
				conn.commit();
			}
			catch (SQLException exception)
			{
				try {
					conn.rollback();
					throw exception;
				} catch (SQLException rollbackException) {
					logger.error("Failed to rollback sla transaction", rollbackException);
				}
				logger.error("Failed to insert sla data in database", exception);
			}					
			
			logger.info("Sleeping SLA ... ");
			
			Thread.sleep(10000);
		}
	}
	
	private static Timestamp Max(Timestamp t1, Timestamp t2){
		return new Timestamp(Math.max(t1.getTime(),t2.getTime()));
	}

	private static Timestamp GetLastKnownTime(Hashtable<Integer, SLA> stateFromDb) {
		Timestamp max = null;
		for (SLA ts : stateFromDb.values()) {
			if (max == null || max.before(ts.time))
				max = ts.time;
		}
		return max;
	}
	
	private void PrepareStatements(Connection conn) throws SQLException{		
		stGetLastAccessChecks = conn.prepareStatement(sqlGetLastAccessChecks);
		stGetLastSla = conn.prepareStatement(sqlGetLastSla);
		stInsertSla = conn.prepareStatement(sqlInsertSla);
	}
}
