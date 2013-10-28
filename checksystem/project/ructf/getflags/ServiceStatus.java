package ructf.getflags;

import java.sql.*;

import ructf.main.*;

public class ServiceStatus {
	
	private int status;
	private String serviceName;

	public ServiceStatus(int teamId, int serviceId, Connection dbConnection) throws SQLException {
		serviceName = DatabaseManager.getServiceName(serviceId);
		
		PreparedStatement st = dbConnection.prepareStatement("SELECT status FROM service_status WHERE team_id=? AND service_id=?");
		st.setInt(1, teamId);
		st.setInt(2, serviceId);
		ResultSet res = st.executeQuery();
		if (!res.next())
			status = CheckerExitCode.Down.toInt();
		else
			status = res.getInt(1);
	}
	
	public String getServiceName() {
		return serviceName;
	}
	
	public int getStatus() {
		return status;
	}
}
