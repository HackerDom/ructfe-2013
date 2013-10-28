package ructf.daemon;

import org.apache.log4j.Logger;

import ructf.main.CheckerExitCode;
import ructf.main.CheckerFailureException;

public class Worker implements Runnable{

	private Task task;
	private WorkerManager workerManager;
	
	public Worker(Task task, WorkerManager workerManager) {
		this.task = task;
		this.workerManager = workerManager;
	}

	public void run() {
		String stage = "not started";
		String failComment = "";
		int status = CheckerExitCode.OK.toInt();
		boolean newFlagSuccess = false;
		boolean randomFlagSuccess = false;
		
		logger.debug(task);
		
		try{			
			Checker checker = CheckersSettings.checkers.get(task.serviceId);			
			CheckerWrapper2 wrapper = new CheckerWrapper2(checker.checkerFilePath, checker.timeout);
			
			stage = "1. General check";	// TODO: переделать на Enum-ы
			wrapper.ExecuteOrFail(new String[]{"check", task.vulnBoxIp});
			
			stage = "2. Put new flag";
			ProcessResult result = wrapper.ExecuteOrFail(new String[]{"put", task.vulnBoxIp, task.newId, task.newFlag});

			String newFlagId = result.getStdout();
			if (newFlagId.length() > 0)
				task.newId = newFlagId;
			
			stage = "3. Get new flag";
			wrapper.ExecuteOrFail(new String[]{"get", task.vulnBoxIp, task.newId, task.newFlag});
			newFlagSuccess = true;		
			
			stage = "4. Check random previous flag";
			if (!(task.randomId == null || task.randomId.equals("") || task.randomFlag == null || task.randomFlag.equals("")))
				wrapper.ExecuteOrFail(new String[]{"get", task.vulnBoxIp, task.randomId, task.randomFlag});			
			randomFlagSuccess = true;						
			
			stage = "";
			
			logger.info(String.format("Successfully processed task '%s'", task.id));
		}
		catch(CheckerFailureException ce){
			logger.debug(String.format("Failed to successfully process task %s: %d (%s)", task.id, ce.serviceStatus, ce.details));
			failComment = ce.details;
			status = ce.serviceStatus;
		}
		catch (Exception e){
			logger.error(String.format("Unexpected error while processing task '%s'",task.id), e);
			failComment = "Worker error";
			status = CheckerExitCode.CheckerError.toInt();
		}
		finally{			
			workerManager.finishTask(task.id, task.newId, status, stage, failComment, newFlagSuccess, randomFlagSuccess);
		}		
	}
	private static Logger logger = Logger.getLogger("ructf.daemon");
}
