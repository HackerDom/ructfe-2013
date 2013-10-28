package ructf.sql;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;

import ructf.executor.Executor;

public class CheckerRunLogInserter
{
	private PreparedStatement st;
	
	public CheckerRunLogInserter(Connection dbConnection) throws SQLException
	{
		st = dbConnection.prepareStatement(sqlQuery);
	}
	
	public void Insert(long start, long finish, int teamId, int serviceId, String args, Executor ex)
	{
		try {
			st.setTimestamp(1, new Timestamp(start));
			st.setFloat(2, (float)(finish - start)/1000);
			st.setInt(3, teamId);
			st.setInt(4, serviceId);
			st.setString(5, args);
			st.setInt(6, ex.GetExitCode());
			st.setString(7, ex.GetStdout());
			st.setString(8, ex.GetStderr());
			st.executeUpdate();
		}
		catch (SQLException e) {
			System.err.println("Query: " + st );
			System.err.println("  failed: " + e.getMessage());
		}
	}
	
	private static String sqlQuery = "INSERT INTO checker_run_log " +
			"(time, duration, team_id, service_id, args, retval, stdout, stderr) "+
			"VALUES (?,?,?,?,?,?,?,?)";
}
