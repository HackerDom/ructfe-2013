package ructf.main;

import java.sql.*;

import ructf.dbObjects.*;
import ructf.executor.Executor;
import ructf.sql.*;

public class CheckerWrapper
{
	/*	Обертка над чекером.
	 * 
	 * 	Запускает чекер (с заданным таймаутом),
	 *  записывает результат в checker_run_log,
	 *  кидает Exception, если чекер вернул не OK. 
	 */
	
	private CheckerRunLogInserter	checkerRunLogInserter;
	private Executor				executor;
	private Team					team;
	private Service 				service;
	
	public CheckerWrapper(Team team, Service service, CheckerRunLogInserter checkerRunLogInserter) throws SQLException
	{
		this.team = team;
		this.service = service;
		this.checkerRunLogInserter = checkerRunLogInserter;
		executor = new Executor(service.getChecker(), Constants.checkerRunTimeout);
	}
	
	public void ExecuteAction(String action, String params) throws Exception
	{
		String args = String.format("%s %s %s", action, team.getVulnBox(), params); 

		long start = System.currentTimeMillis();
		executor.Execute(args);
		long finish = System.currentTimeMillis();
		
		System.out.println(String.format("  (%s, %s, %s) -> %d", team.getName(), service.getName(), action, executor.GetExitCode()));
		checkerRunLogInserter.Insert(start, finish, team.getId(), service.getId(), args, executor);
		
		if (executor.WasKilled())
			throw new CheckerFailureException("Timeout", CheckerExitCode.Down.toInt());
		if (CheckerExitCode.isUnknown(executor.GetExitCode()))
			throw new CheckerFailureException("Unknown exitCode: " + executor.GetExitCode(), executor.GetExitCode());
		if (executor.GetExitCode() != CheckerExitCode.OK.toInt())
			throw new CheckerFailureException(executor.GetStdout(), executor.GetExitCode());
	}
	
	public String GetStdout()
	{
		return executor.GetStdout();
	}
}
