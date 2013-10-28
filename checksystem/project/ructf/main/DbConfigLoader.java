package ructf.main;
import java.io.*;

public class DbConfigLoader
{
	private String dbConnectionString;
	private String dbUser;
	private String dbPass;

	public DbConfigLoader(String fileName) throws IOException
	{
		BufferedReader in = new BufferedReader(new FileReader(fileName));
		dbConnectionString = in.readLine();
		dbUser = in.readLine();
		dbPass = in.readLine();
		in.close();
	}

	public String getConnectionString()
	{
		return dbConnectionString;
	}

	public String getDbPass()
	{
		return dbPass;
	}

	public String getDbUser()
	{
		return dbUser;
	}
}
