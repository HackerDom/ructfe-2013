package ructf.main;

import java.io.IOException;
import java.sql.*;
import java.util.*;

import ructf.dbObjects.*;

public class Checksystem
{
	public static void main(String[] args)
	{
		try	{
			if (args.length > 0)
				Constants.Initialize(args[0]);
			
			DatabaseManager.Initialize();
			DatabaseManager.startNextRound();
			List<Service> services = DatabaseManager.getServices();
			CheckerTester.CheckAllOrDie(services);
			
			List<Thread> threadsList = new LinkedList<Thread>();
			List<Connection> connectionList = new LinkedList<Connection>();
			
			for (Team team: DatabaseManager.getTeams())
			{
				Connection conn = DatabaseManager.CreateConnection();
				connectionList.add(conn);
				
				TeamCheckThread teamThread = new TeamCheckThread(team, services, conn);
				threadsList.add(teamThread);
			}
		
			StartThreads(threadsList);
			JoinThreads(threadsList);
			CloseConnections(connectionList);
		}
		catch (Exception ex) {
			System.err.println("   *** FATAL ERROR ***");
			System.err.println();
			ex.printStackTrace();
		}
	}

	private static void StartThreads(List<Thread> threadsList)
	{
		System.out.println("Teams threads: starting...");
		for (Thread t : threadsList)
			t.start();
	}

	private static void JoinThreads(List<Thread> threadsList)
	{
		for (Thread t : threadsList)
			try {
				t.join();
			} catch (InterruptedException ignore){}
		System.out.println("Teams threads: finished.");
	}
	
	private static void CloseConnections(List<Connection> connectionList)
	{
		for (Connection conn : connectionList)
			try {
				conn.close();
			} catch (SQLException ignore){}
	}
}

