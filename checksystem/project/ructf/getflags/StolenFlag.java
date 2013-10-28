package ructf.getflags;

import java.sql.*;

public class StolenFlag {
	
	// OK: sqlGetFlag - INDEX SCAN при больших объемах (т.к. flags.flag_data - PRIMARY KEY)
	private static String sqlGetFlag = "SELECT EXTRACT(EPOCH FROM NOW()-time), team_id, service_id FROM flags WHERE flag_data = ?";
	// OK: sqlGetStolenFlag - INDEX SCAN при больших объемах (есть индекс по (flag_data,team_id))
	private static String sqlGetStolenFlag = "SELECT * FROM stolen_flags WHERE flag_data=? AND team_id=?";
	
	private static PreparedStatement stGetFlag;
	private static PreparedStatement stGetStolenFlag;
	
	private int ageSeconds;
	private int ownerTeamId;
	private int serviceId;
	private String flagData;
	private boolean noSuchFlag;
	
	public StolenFlag(String flagData, Connection dbConnection) throws SQLException {
		stGetStolenFlag = dbConnection.prepareStatement(sqlGetStolenFlag);
		stGetStolenFlag.setString(1, flagData);
		
		stGetFlag = dbConnection.prepareStatement(sqlGetFlag);
		stGetFlag.setString(1, flagData);
		ResultSet result = stGetFlag.executeQuery();
		if (!result.next()) {
			noSuchFlag = true;
			return;
		}
		noSuchFlag = false;
		ageSeconds = result.getInt(1);
		ownerTeamId = result.getInt(2);
		serviceId = result.getInt(3);
		this.flagData = flagData;
	}
	
	public String getFlagData() {
		return flagData;
	}

	public boolean noSuchFlag() {
		return noSuchFlag;
	}
	
	public int getAgeSeconds() {
		return ageSeconds;
	}
	
	public int getOwnerTeamId() {
		return ownerTeamId;
	}

	public int getServiceId() {
		return serviceId;
	}
	
	public boolean wasStolenByTeam(int teamId) throws SQLException {
		stGetStolenFlag.setInt(2, teamId);
		return stGetStolenFlag.executeQuery().next();
	}
}
