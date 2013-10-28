package ructf.daemon;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;
import java.util.Random;
import java.util.Set;
import java.util.UUID;

import org.apache.log4j.Logger;

import ructf.utils.Base64Coder;
import ructf.utils.StringUtils;
import sun.swing.StringUIClientPropertyKey;


public class TaskManagerClient {

	public static void finishTask(UUID taskId, String newFlagId, int status, String failStage, String failComment, boolean newFlagSuccess, boolean randomFlagSuccess) throws Exception{
		URL url = new URL(String.format("%s/doneTask?id=%s&status=%d&newFlagId=%s&failStage=%s&failComment=%s&newFlagSuccess=%b&randomFlagSuccess=%b",
				DaemonSettings.taskManagerUrl, taskId, status, URLEncoder.encode(newFlagId, "UTF-8"), URLEncoder.encode(failStage, "UTF-8"), URLEncoder.encode(failComment, "UTF-8"), newFlagSuccess, randomFlagSuccess));
		
		HttpURLConnection taskManagerConnection = (HttpURLConnection) url.openConnection();
		//taskManagerConnection.setDoInput(true);
		taskManagerConnection.setDoOutput(false);
		taskManagerConnection.connect();
		try{
			int responseCode = taskManagerConnection.getResponseCode();
			if (responseCode != HttpURLConnection.HTTP_OK){
				BufferedReader reader = new BufferedReader(new InputStreamReader(taskManagerConnection.getErrorStream()));				
				try{
					StringBuffer sb = new StringBuffer();
					
					String line;					
					while ((line = reader.readLine()) != null)
						sb.append(line);					
					
					throw new Exception(String.format("TaskManager returned responseCode %d.\n\n%s", sb.toString(), sb.toString()));
				}
				finally{
					reader.close();
				}				
			}			
		}
		finally{			
			taskManagerConnection.disconnect();	
		}			
	}
	
	public static List<Task> getTasks(int maxThreads) throws IOException{
		URL url = new URL(String.format("%s/getTasks?maxTasks=%s&serviceIds=%s", DaemonSettings.taskManagerUrl, maxThreads, getServiceIds()));
		
		HttpURLConnection taskManagerConnection = (HttpURLConnection) url.openConnection();
		taskManagerConnection.connect();			
		BufferedReader reader = new BufferedReader(new InputStreamReader(taskManagerConnection.getInputStream()));
		
		try{
			List<Task> result = new LinkedList<Task>();
			String line;
			while ((line = reader.readLine()) != null) {
				try{
					line = line.trim();
					if (line.length() > 0)
						result.add(new Task(line));	
				}
				catch (Exception e){
					logger.error(String.format("failed to deserialize task from string '%s'", line), e);
				}
			}
			return result;
		}
		finally{
			reader.close();
			taskManagerConnection.disconnect();
		}				
	}
	
	private static String getServiceIds() {
		Set<Integer> ids = CheckersSettings.checkers.keySet();
		List<Integer> result = new ArrayList<Integer>(ids.size()); 
		for (int id : ids){
			result.add(id);
		}
		Collections.shuffle(result);
		return StringUtils.join(result.toArray(), 0, ",");
	}	
	
		
	private static Logger logger = Logger.getLogger("ructf.daemon");
}