package ructf.taskManager;

import java.io.IOException;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.apache.log4j.Logger;

import ructf.utils.HttpResponseCodes;
import ructf.utils.QueryStringParser;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;

public class GetTasksHttpHandler implements HttpHandler {

	private static Logger logger = Logger.getLogger("ructf.taskManager");
	private TaskManager taskManager;
	
	public GetTasksHttpHandler(TaskManager taskManager) {
		this.taskManager = taskManager;
	}

	public void handle(HttpExchange exchange) throws IOException {
		try{
			String queryStr = exchange.getRequestURI().toString();
			logger.info(String.format("client '%s', query '%s'", exchange.getRemoteAddress().toString(), queryStr));

			Map<String, List<String>> query;
			try {
				query = QueryStringParser.parse(queryStr);
			} catch (Exception e) {			
				throw new IllegalArgumentException("Can't parse query string", e);
			}
						
			int maxTasks = getMaxTasks(query);			
	    	List<Integer> serviceIds = getServiceIds(query);	    	
	    	
	    	List<Task> tasks = taskManager.getTasks(serviceIds, maxTasks);
	    	
			StringBuffer sb = new StringBuffer();
			for (Task task : tasks) {
				sb.append(task);
				sb.append("\r\n");
			}			    	
	    	
    		byte[] result = sb.toString().getBytes();	    	
    		exchange.sendResponseHeaders(HttpResponseCodes.OK, result.length);	// Убрать дублирование
    		OutputStream responseBody = exchange.getResponseBody();
    		responseBody.write(result);
    		responseBody.close();	    			
		}
		catch ( IllegalArgumentException ee){
			logger.warn("Failed to process request", ee);
			byte[] result = ee.toString().getBytes();
			exchange.sendResponseHeaders(HttpResponseCodes.BadRequest, result.length);
			OutputStream responseBody = exchange.getResponseBody();
    		responseBody.write(result);  
    		responseBody.close();
		}
		catch (Exception e) {
			logger.error("Failed to process request", e);
			byte[] result = e.toString().getBytes();
			exchange.sendResponseHeaders(HttpResponseCodes.InternalServerError, result.length);
    		OutputStream responseBody = exchange.getResponseBody();
    		responseBody.write(result);  
    		responseBody.close();
		}

	}

	private int getMaxTasks(Map<String, List<String>> query) {
		if (!query.containsKey("maxTasks")){
			throw new IllegalArgumentException("query string must contain param 'maxTasks'");
		}
		
		try{
			return Integer.parseInt(query.get("maxTasks").get(0));
		}
		catch (Exception e) {
			throw new IllegalArgumentException("param 'maxTasks' is malformed (can't be parsed as integer)");
		}
	}
	
	public static List<Integer> getServiceIds(Map<String, List<String>> query) throws IllegalArgumentException{		
		if (!query.containsKey("serviceIds")){
			throw new IllegalArgumentException("query string must contain param 'serviceIds'");
		}	
		
		List<Integer> result = new LinkedList<Integer>();
		for (String serviceIdStr : query.get("serviceIds").get(0).split(",")) {
			try{
				result.add(Integer.parseInt(serviceIdStr));				
			}
			catch(NumberFormatException e){
				throw new IllegalArgumentException("param 'serviceIds' is malformed (values can't be parsed as integers)");
			}						
		}	
		return result;				
	}	

}
