package ructf.getflags;

import java.net.InetAddress;
import java.sql.*;

public class TeamId {
	
	private static String sqlGetTeamId = "SELECT id FROM TEAMS WHERE ?::text::inet <<= network";
	private int id;
	
	public TeamId(InetAddress addr, Connection dbConnection) throws SQLException, UnknownAddressException {
		PreparedStatement stGetTeamId = dbConnection.prepareStatement(sqlGetTeamId);
		stGetTeamId.setString(1, addr.getHostAddress());
		ResultSet res = stGetTeamId.executeQuery();
		if (!res.next())
			throw new UnknownAddressException(addr);
		id = res.getInt(1);
	}
	
	public int getId() {
		return id;
	}
}
