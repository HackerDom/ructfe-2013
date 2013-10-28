package ructf.dbObjects;

import java.sql.*;
import java.util.*;

public class Service
{
	private int id;
	private String name;
	private String checker;
	private boolean delayFlagGet;

	public static Vector<Service> LoadServices(Statement st) throws Exception
	{
		Vector<Service> services = new Vector<Service>();
		ResultSet rs = st.executeQuery(loadQuery);
		while (rs.next())
			services.add(new Service(rs));
		return services;
	}

	private Service(int id, String name, String checker, boolean delayFlagGet)
	{
		this.id = id;
		this.name = name;
		this.checker = checker;
		this.delayFlagGet = delayFlagGet;
	}

	private Service(ResultSet rs) throws SQLException
	{
		this(rs.getInt(1), rs.getString(2), rs.getString(3), rs.getBoolean(4));
	}

	public String toString()
	{
		return String.format("Service(%d, '%s', '%s', delay='%b')", id, name, checker, delayFlagGet);
	}

	public int getId()
	{
		return id;
	}

	public String getName()
	{
		return name;
	}

	public String getChecker()
	{
		return checker;
	}
	
	public boolean getDelayFlagGet()
	{
		return delayFlagGet;
	}

	private static String loadQuery = "SELECT id, name, checker, delay_flag_get FROM services";
}
