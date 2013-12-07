package ructf.main;
import java.sql.*;
import java.util.*;

import ructf.dbObjects.*;
import ructf.sql.*;

public class TeamCheckThread extends Thread
{
	private Team team;
	private List<Service>			services;
	
	private AccessChecksInserter	dbAccessChecks;
	private CheckerRunLogInserter	dbCheckerRunLog;
	private FlagManager				flagManager;
	
	public TeamCheckThread(Team team, List<Service> services, Connection dbConnection) throws SQLException
	{
		this.team = team;
		this.services = new Vector<Service>(services);			//создаем копию общего списка сервисов
		dbAccessChecks = new AccessChecksInserter(dbConnection);
		dbCheckerRunLog = new CheckerRunLogInserter(dbConnection);
		flagManager = new FlagManager(dbConnection);
	}

	public void run()
	{
		for (Service s: services)
			CheckService(s);
	}

	private void CheckService(Service service)
	{
		String stage = "Not run";
		try {
			CheckerWrapper wrapper = new CheckerWrapper(team, service, dbCheckerRunLog);
			
			stage = "General check";
			wrapper.ExecuteAction("check", "");
			
			stage = "Put new flag";
			String flagData = flagManager.CreateFlag();
			String flagId = flagManager.CreateId();
			wrapper.ExecuteAction("put", flagId + " " + flagData);

			String newFlagId = wrapper.GetStdout();
			if (newFlagId.length() > 0)
				flagId = newFlagId;

			if (service.getDelayFlagGet())
			{
				// Проверим "отложенный" флаг из предыдущего раунда
				IdFlagPair delayed = flagManager.GetDelayedFlag(team.getId(), service.getId());
				if (delayed != null)
				{
					stage = "Get delayed flag";
					wrapper.ExecuteAction("get", "\"" + delayed.getFlagId() + "\" " + delayed.getFlagData());
					flagManager.InsertFlag(team.getId(), service.getId(), delayed.getFlagId(), delayed.getFlagData());
				}
				
				// Добавим последний сгенерированный флаг в "отложенные" ...
				flagManager.InsertDelayedFlag(team.getId(), service.getId(), flagId, flagData);
			}
			else  {
				stage = "Get new flag";
				wrapper.ExecuteAction("get", "\"" + flagId + "\" " + flagData);
				flagManager.InsertFlag(team.getId(), service.getId(), flagId, flagData);
			}
			
			stage = "Check random previous flag";
			IdFlagPair old = flagManager.GetRandomAliveFlag(team.getId(), service.getId());
			if (old != null) {
				wrapper.ExecuteAction("get", "\"" + old.getFlagId() + "\" " + old.getFlagData());
			}
			
			dbAccessChecks.Insert(team.getId(), service.getId(), CheckerExitCode.OK.toInt(), "", "", 1);
		}
		catch (CheckerFailureException e) {
			dbAccessChecks.Insert(team.getId(), service.getId(), e.serviceStatus, stage, e.details, 0);
		}
		catch (Exception e) {
			System.err.println("CheckerWrapper failed. " + service + ".");
			System.err.println("    Exception: " + e);
			System.err.println("    Message  : " + e.getMessage());
			System.err.println("    Stack    : " );
			e.printStackTrace();
		}
	}
}
