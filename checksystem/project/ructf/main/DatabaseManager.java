package ructf.main;

import java.sql.*;
import java.util.*;

import ructf.dbObjects.*;

public class DatabaseManager
{
	private static DbConfigLoader dbConfigLoader;
	private static List<Service> services;
	private static List<Team> teams;
	private static Connection internalDbConnection;
	
	private static PreparedStatement stNextRound;
	private static PreparedStatement stGetRound;
	
	private static HashMap<Integer, String> teamNamesHash = new HashMap<Integer, String>(); 
	private static HashMap<Integer, String> serviceNamesHash = new HashMap<Integer, String>();

	public static void Initialize() throws Exception
	{
		System.out.println("DatabaseManager.Initialize(): starting...");
		LoadDriver();
		dbConfigLoader = new DbConfigLoader(Constants.dbConfigFile);
		System.out.println("DatabaseManager.Initialize(): creating DB connection ...");
		internalDbConnection = CreateConnection();
		System.out.println("DatabaseManager.Initialize(): DB connection created");
		stNextRound = internalDbConnection.prepareStatement("INSERT INTO rounds(n) SELECT max(n)+1 FROM rounds");
		stGetRound = internalDbConnection.prepareStatement("SELECT MAX(n) FROM rounds");
		LoadGameObjects();
		PrintObjectsCount();
		System.out.println("DatabaseManager.Initialize(): Finished.");
	}

	public static Connection CreateConnection() throws SQLException
	{
		return DriverManager.getConnection(
				dbConfigLoader.getConnectionString(),
				dbConfigLoader.getDbUser(),
				dbConfigLoader.getDbPass()
			);
	}
	
	public static int startNextRound() throws SQLException
	{
		stNextRound.executeUpdate();
		ResultSet r = stGetRound.executeQuery();
		if (!r.next())
			throw new SQLException("no rows");
		int round = r.getInt(1);
		System.out.println("Round: " + round);
		return round;
	}
	
	public static void ShowDbException(Statement st, Exception ex) {
		System.err.println("Statement: " + st );
		System.err.println("  failed: " + ex.getMessage());
	}
	
	public static String getServiceName(int serviceId)
	{
		return serviceNamesHash.get(serviceId);
	}
	
	public static String getTeamName(int teamId)
	{
		return teamNamesHash.get(teamId);
	}

	public static List<Service> getServices()
	{
		return services;
	}

	public static List<Team> getTeams()
	{
		return teams;
	}

	private static void PrintObjectsCount()
	{
		System.out.println(String.format("Database: %d service(s)", services.size()));
		System.out.println(String.format("Database: %d enabled team(s)", teams.size()));
	}

	private static void LoadGameObjects() throws Exception
	{
		Statement statement = internalDbConnection.createStatement();
		services = Service.LoadServices(statement);
		for (Service service : services)
			serviceNamesHash.put(service.getId(), service.getName());
		teams = Team.LoadTeams(statement);
		for (Team team : teams)
			teamNamesHash.put(team.getId(), team.getName());
		statement.close();
	}

	private static void LoadDriver() throws ClassNotFoundException
	{
		Class.forName("org.postgresql.Driver");
	}
}
