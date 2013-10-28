package ructf.secureflags;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;

import ructf.main.Constants;
import ructf.main.DatabaseManager;

public class Main
{
	private static String sSelect = "SELECT EXTRACT(EPOCH FROM time), flag_data, EXTRACT(EPOCH FROM NOW()), team_id FROM flags WHERE "+
					"scored = FALSE AND EXTRACT(EPOCH FROM NOW()-time) > ?";
	private static String sWasStolen = "SELECT * FROM stolen_flags WHERE flag_data = ? AND EXTRACT(EPOCH FROM time) < ?";
	
	private static String sSetScored = "UPDATE flags SET scored = TRUE WHERE flag_data = ?";
	private static String sScoreSecret = "INSERT INTO secret_flags (team_id, flag_fata, score_secret) VALUES (?, ?, ?)";
	
	private static Logger logger = Logger.getLogger("ructf.secureflags"); 
	
	public static void main(String[] args)
	{
		PropertyConfigurator.configure(Constants.log4jConfigFile);
		logger.info("Started");
		
		if (args.length > 0)
			Constants.Initialize(args[0]);
		
		while(true){		
			try {				
				wrappedMain();
			} catch (Exception e) {
				logger.error("General error", e);				
				try{
					Thread.sleep(30 * 1000);
				}
				catch (InterruptedException ie) {
					logger.warn(ie);
				}
			}
		}
	}
	
	public static void wrappedMain() throws Exception
	{
		DatabaseManager.Initialize();
		Connection conn = DatabaseManager.CreateConnection();
		conn.setAutoCommit(false);
				
		PreparedStatement stSelect = conn.prepareStatement(sSelect);
		PreparedStatement stWasStolen = conn.prepareStatement(sWasStolen);
		PreparedStatement stSetScored = conn.prepareStatement(sSetScored);
		PreparedStatement stScoreSecret = conn.prepareStatement(sScoreSecret);
		
		while (true) {			
			logger.info("Looking for expired, not scored flags");
			stSelect.setInt(1,Constants.flagExpireInterval);
			ResultSet res = stSelect.executeQuery();
			conn.commit();
			while (res.next())
			{
				try
				{
					int timeCreated = res.getInt(1);
					String flag = res.getString(2);
					int currentDbTime = res.getInt(3);
					int teamId = res.getInt(4);

					long age = currentDbTime - timeCreated;
				
					int timeExpired = timeCreated + Constants.flagExpireInterval;
					stWasStolen.setString(1, flag);
					stWasStolen.setInt(2, timeExpired);
					int scoreSecret = stWasStolen.executeQuery().next() ? 0 : 1;
					conn.commit();
					
					stScoreSecret.setInt(1, teamId);
					stScoreSecret.setString(2, flag);
					stScoreSecret.setInt(3, scoreSecret);
					stScoreSecret.executeUpdate();
					
					stSetScored.setString(1, flag);
					stSetScored.executeUpdate();						
					conn.commit();
				
					logger.info(String.format("created: %d, expired: %d. %s -> %d (age %.2f min)",
						timeCreated, timeExpired, flag, scoreSecret, (float)age/60
					));
				}
				catch (SQLException ex)
				{
					conn.rollback();
					logger.error(ex.getMessage());
					ex.printStackTrace();						
				}
			}
			logger.info("Job done. Sleeping for " + Constants.secureFlagsInterval + " sec ...");
			try{
				Thread.sleep(Constants.secureFlagsInterval * 1000);
			}
			catch (InterruptedException ie) {
				logger.warn(ie);
			}
		}
	}
}
