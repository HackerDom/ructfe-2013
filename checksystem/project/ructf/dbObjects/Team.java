package ructf.dbObjects;

import java.sql.*;
import java.util.*;

public class Team
{
	private int id;
	private String name;
	private String vulnBox;

	public static Vector<Team> LoadTeams(Statement st) throws Exception
	{
		Vector<Team> teams = new Vector<Team>();
		ResultSet rs = st.executeQuery(loadQuery);
		while (rs.next())
			teams.add(new Team(rs));
		return teams;
	}

	private Team(int id, String name, String vulnBox)
	{
		this.id = id;
		this.name = name;
		this.vulnBox = vulnBox;
	}

	private Team(ResultSet rs) throws SQLException
	{
		this(rs.getInt(1), rs.getString(2), rs.getString(3));
	}

	public String toString()
	{
		return String.format("Team(%d, '%s', '%s')", id, name, vulnBox);
	}

	public int getId()
	{
		return id;
	}

	public String getName()
	{
		return name;
	}

	public String getVulnBox()
	{
		return vulnBox;
	}

	private static String loadQuery = "SELECT id, name, vuln_box FROM teams WHERE enabled=TRUE";
}
