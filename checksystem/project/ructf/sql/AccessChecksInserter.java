package ructf.sql;
import java.sql.*;
import java.util.UUID;

public class AccessChecksInserter
{
	private PreparedStatement st;
	
	public AccessChecksInserter(Connection dbConnection) throws SQLException
	{
		st = dbConnection.prepareStatement(sqlQuery);
	}
	
	public void Insert(int teamId, int serviceId, int status, String failStage, String failComment, int scoreAccess){
		Insert(teamId, serviceId, status, failStage, failComment, scoreAccess, null);
	}
	
	public void Insert(int teamId, int serviceId, int status, String failStage, String failComment, int scoreAccess, UUID uuid)
	{		
		try{
			st.setInt(1, teamId);
			st.setInt(2, serviceId);
			st.setInt(3, status);
			st.setString(4, failStage);
			st.setString(5, failComment);
			st.setInt(6, scoreAccess);
			st.setObject(7, uuid);
			st.executeUpdate();
		}
		catch (SQLException e) {
			System.err.println("Query: " + st );
			System.err.println("  failed: " + e.getMessage());
		}
	}
	
	private static String sqlQuery = "INSERT INTO access_checks " +
		"(team_id, service_id, status, fail_stage, fail_comment, score_access, task_id) "+
		"VALUES (?,?,?,?,?,?,?)";
}
