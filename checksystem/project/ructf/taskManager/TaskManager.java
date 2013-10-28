package ructf.taskManager;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.UUID;

import org.apache.log4j.Logger;

import ructf.dbObjects.Service;
import ructf.dbObjects.Team;
import ructf.main.CheckerExitCode;
import ructf.main.Constants;
import ructf.main.DatabaseManager;
import ructf.main.FlagManager;
import ructf.main.IdFlagPair;
import ructf.sql.AccessChecksInserter;
import ructf.utils.StringUtils;

public class TaskManager extends Thread{

	private List<Service> services = DatabaseManager.getServices();
	private List<Team> teams = DatabaseManager.getTeams();
	
	private HashMap<Integer, List<Task>> newTasksAll = new HashMap<Integer, List<Task>>(); 
	private HashMap<Integer, HashMap<UUID, Task>> processingTasksAll = new HashMap<Integer, HashMap<UUID, Task>>();
	private HashMap<Integer, List<Task>> doneTasksAll = new HashMap<Integer, List<Task>>();

	public TaskManager() {
		for (Service service : services) {
			int id = service.getId();
			newTasksAll.put(id, new LinkedList<Task>());
			processingTasksAll.put(id, new HashMap<UUID, Task>());
			doneTasksAll.put(id, new LinkedList<Task>());
		}
	}
	
	public void run(){	// TODO: Отделить мух от котлет (поток от логики)
		while (true){
			try {
				while (true){
					failLeftTasks();
					int round = DatabaseManager.startNextRound();
					logger.info(String.format("New round: %d", round));
					regenerateTasks(round);					
					Thread.sleep(Constants.roundLength * 1000);					
				}			
			} catch (Exception e) {
				logger.error(e);
				try {
					Thread.sleep(10000);
				} catch (InterruptedException e1) {
					e1.printStackTrace();
					logger.fatal(e1);
				}
			}			
		}		
	}
			
	public List<Task> getTasks(List<Integer> serviceIds, int maxCount){
		List<Task> result = new LinkedList<Task>();
	
		for (Integer serviceId : serviceIds) {
			List<Task> newTasks;
			if ((newTasks = newTasksAll.get(serviceId)) == null)
				continue;
			
			synchronized (newTasks) {
				if (newTasks.isEmpty())
					continue;
				
				int cnt = newTasks.size();
				for (int i=0; i < cnt; i++) {					
					if (result.size() >= maxCount)
						break;
					
					result.add(newTasks.remove(0));					
				}				
			}
		}
		
				
		for (Task task : result) 
			synchronized (processingTasksAll.get(task.serviceId))			
			{
				processingTasksAll.get(task.serviceId).put(task.id, task);
			}
		
		return result;	
	}
	
	// TODO: убрать ненужные newFlagSuccess и randomFlagSuccess, смотреть на failStage (переделанный в Enum) 
	public void finishTask(UUID taskId, String newFlagId, int status, String failStage, String failComment, boolean newFlagSuccess, boolean randomFlagSuccess) throws SQLException{	
		Task task = null;
		
		for (int serviceId : processingTasksAll.keySet()) {					// Может, стоит по GUID сразу получать task?
			HashMap<UUID, Task> tasks = processingTasksAll.get(serviceId);
			synchronized (tasks) {
				if (tasks.containsKey(taskId)){
					task = tasks.get(taskId);
					break;
				}
			}
		}		
		
		if (task == null)	// Если демон опоздал
		{
			logger.warn(String.format("Task with id %s not found in processingTasks", taskId));
			return;
		}
		
		task.newIdFlag = new IdFlagPair(newFlagId, task.newIdFlag.getFlagData());
		task.status = status;
		
		Connection connection = DatabaseManager.CreateConnection();
		connection.setAutoCommit(false);
		
		try{
			FlagManager flagManager = new FlagManager(connection);
			AccessChecksInserter dbAccessChecks = new AccessChecksInserter(connection);
			
			if (newFlagSuccess){
				flagManager.InsertFlag(task.team.getId(), task.serviceId, task.newIdFlag.getFlagId(), task.newIdFlag.getFlagData());
			}
			
			int accessScore = 0;
			if (status == CheckerExitCode.OK.toInt())
				accessScore = 1;

			// TODO: Писать в базу не  строку failStage, а Enum
			dbAccessChecks.Insert(task.team.getId(), task.serviceId, status, failStage, failComment, accessScore, task.id);
					
			synchronized (processingTasksAll.get(task.serviceId)) {
				processingTasksAll.get(task.serviceId).remove(task.id);
			}
			synchronized (doneTasksAll.get(task.serviceId)){
				doneTasksAll.get(task.serviceId).add(task);
			}			
			
			connection.commit();
		}
		catch(SQLException e){
			connection.rollback();
			throw e;
		}
		finally{
			connection.close();
		}		
	}
	
	private void failLeftTasks() throws SQLException{		
		Connection connection = DatabaseManager.CreateConnection();
		connection.setAutoCommit(false);
		
		try{
			AccessChecksInserter dbAccessChecks = new AccessChecksInserter(connection);
			for (Service service : services) {
				int serviceId = service.getId();
				
				List<Task> newTasks = newTasksAll.get(serviceId);
				synchronized (newTasks){					
					for (Task task : newTasks)
						dbAccessChecks.Insert(task.team.getId(), task.serviceId, CheckerExitCode.CheckerError.toInt(), "In newTasks queue", "Round timeout", 0, task.id);						
										
					newTasks.clear();
					connection.commit();
				}		
				
				HashMap<UUID, Task> processingTasks = processingTasksAll.get(serviceId);
				synchronized (processingTasks) {
					for (Task task : processingTasks.values())
						dbAccessChecks.Insert(task.team.getId(), task.serviceId, CheckerExitCode.Down.toInt(), "In processingTasks queue", "Round timeout", 0, task.id);
					
					processingTasks.clear();
					connection.commit();
				}
				List<Task> doneTasks = doneTasksAll.get(serviceId);
				synchronized (doneTasks) {			
					doneTasks.clear();
				}
			}		
		}
		catch(SQLException e){
			connection.rollback();
			throw e;
		}
		finally{
			connection.close();
		}			
	}
	
	private void regenerateTasks(int round) throws SQLException{					
		Connection connection = DatabaseManager.CreateConnection();
		try{
			FlagManager flagManager = new FlagManager(connection);
			
			for (Service service : services) {
				int serviceId = service.getId();
				List<Task> tasks = newTasksAll.get(serviceId);
				synchronized (tasks){						
					for (Team team : teams) {
						int teamId = team.getId();
						
						IdFlagPair newIdFlag = new IdFlagPair(flagManager.CreateId(), flagManager.CreateFlag());
						IdFlagPair randomIdFlag = flagManager.GetRandomAliveFlag(teamId, serviceId);						
						
						Task task = new Task(serviceId, round, team, newIdFlag, randomIdFlag);
						tasks.add(task);
					}
				}
			}	
		}
		finally{
			connection.close();
		}
	}
	
	public String GetTasksJSON(){
		StringBuffer resultSb = new StringBuffer();
		resultSb.append("{\r\n");
		
		ArrayList<String> serviceJSONs = new ArrayList<String>();
		for (Service service : services)
		{
			StringBuilder sb = new StringBuilder();
			sb.append(String.format("\t\"%s\":\r\n", service.getName()));
			sb.append("\t[\r\n");
			
			List<String> taskJSONs = new ArrayList<String>();
			
			int serviceId = service.getId();
			
			Collection<Task> tasks = doneTasksAll.get(serviceId);
			synchronized (tasks) {
				taskJSONs.addAll(GetTasksJSONs(tasks, "done"));				
			}
			
			tasks = processingTasksAll.get(serviceId).values();
			synchronized (tasks) {
				taskJSONs.addAll(GetTasksJSONs(tasks, "processing"));
			}
			
			tasks = newTasksAll.get(serviceId);
			synchronized (tasks) {
				taskJSONs.addAll(GetTasksJSONs(tasks, "new"));				
			}
			
			sb.append(StringUtils.join(taskJSONs.toArray(), 0, ",\r\n") + "\r\n");
			sb.append("\t]");
			serviceJSONs.add(sb.toString());
		}
		resultSb.append(StringUtils.join(serviceJSONs.toArray(), 0, ",\r\n") + "\r\n");
		resultSb.append('}');
		return resultSb.toString();
	}
	
	private List<String> GetTasksJSONs(Collection<Task> tasks, String state){
		List<String> tasksJSONs = new ArrayList<String>();
		for (Task task : tasks) {
			tasksJSONs.add(task.SerializeToJSON(state));
		}
		return tasksJSONs;		
	}
	
	private static Logger logger = Logger.getLogger("ructf.taskManager");
}
