package ructf.daemon;

import java.util.List;
import java.util.UUID;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import org.apache.log4j.Logger;

public class WorkerManager extends Thread{
	
	private ExecutorService threadPool;
	private int freeThreads;
	
	public WorkerManager(){
		freeThreads = DaemonSettings.maxThreads;
		threadPool = Executors.newFixedThreadPool(DaemonSettings.maxThreads);		
	}
	
	public void finishTask(UUID taskId, String newFlagId, int status, String failStage, String failComment, boolean newFlagSuccess, boolean randomFlagSuccess){
		try{
			TaskManagerClient.finishTask(taskId, newFlagId, status, failStage, failComment, newFlagSuccess, randomFlagSuccess);
		}
		catch (Exception e) {
			logger.error(e);
		}
		finally{
			freeThreads++;				
		}		
	}
	
	public void run(){
		while (true){
			try{
				newTasksManagingLoop();
			}
			catch (Exception e) {
				logger.error(String.format("Error while getting next bunch of work from %s. Sleeping for %d milliseconds and retrying.", DaemonSettings.taskManagerUrl, fatalErrorTimeout), e);				
				try {
					Thread.sleep(fatalErrorTimeout);
				} catch (InterruptedException e1) {
					logger.info(String.format("InterruptedException got while sleeping fatalTimeout %d. Retrying", fatalErrorTimeout), e1);					
				}
			}			
		}
	}

	private void newTasksManagingLoop() throws Exception {
		while (true){			
			if (freeThreads > 0){
				List<Task> tasks = TaskManagerClient.getTasks(freeThreads);							
				for (Task task : tasks) {
					Worker worker = new Worker(task, this);
					threadPool.execute(worker);
					freeThreads--;
				}
			}
		
			Thread.sleep(nextPollTimeout);
		}
	}	 
	
	private static final int fatalErrorTimeout = 30000; 
	private static final int nextPollTimeout = 1000;
	private static Logger logger = Logger.getLogger("ructf.daemon");
}
