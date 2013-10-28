package ructf.roundsCache;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.sql.*;

import ructf.main.Constants;

public class ScoreboardWriter {
	
	private PreparedStatement stXmlFlags;
	private PreparedStatement stXmlScoreboard;
	
	private static String sqlXmlFlags = "SELECT * FROM xmlFlags";
	private static String sqlXmlScoreboard = "SELECT * FROM xmlCachedScoreboard";
	
	public ScoreboardWriter(Connection dbConnection) throws SQLException {
		stXmlFlags = dbConnection.prepareStatement(sqlXmlFlags);
		stXmlScoreboard = dbConnection.prepareStatement(sqlXmlScoreboard);
	}
	
	public void WriteFiles() throws IOException, SQLException {
		WriteQueryResult(Constants.xmlFlagsFile, stXmlFlags);
		WriteQueryResult(Constants.xmlScoreboardFile, stXmlScoreboard);
	}
	
	private void WriteQueryResult(String outFileName, PreparedStatement st) throws IOException, SQLException {
		String tempFileName = outFileName + ".new";
		BufferedWriter out = new BufferedWriter(new FileWriter(tempFileName));
		out.write(GetString(st));
		out.close();
		File tempFile = new File(tempFileName);
		File outFile = new File(outFileName);
		outFile.delete();
		tempFile.renameTo(outFile);
		System.out.println("File written: " + outFileName);
	}

	private String GetString(PreparedStatement st) throws SQLException {
		ResultSet result = st.executeQuery();
		if (!result.next())
			throw new SQLException("no rows");
		return result.getString(1);
	}
}
