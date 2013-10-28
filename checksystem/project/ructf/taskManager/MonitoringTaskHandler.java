package ructf.taskManager;

import java.io.IOException;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.apache.log4j.Logger;

import ructf.main.CheckerExitCode;
import ructf.utils.HttpResponseCodes;
import ructf.utils.QueryStringParser;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;

public class MonitoringTaskHandler  implements HttpHandler {
	private static Logger logger = Logger.getLogger("ructf.taskManager");
	private TaskManager taskManager;
	
	public MonitoringTaskHandler(TaskManager taskManager) {
		this.taskManager = taskManager;
	}
	
	public void handle(HttpExchange exchange) throws IOException {
		try{
			String queryStr = exchange.getRequestURI().toString();
			
			// TODO: query здесь не используется, выпилить
			Map<String, List<String>> query;
			try {
				query = QueryStringParser.parse(queryStr);
			} catch (UnsupportedEncodingException e) {			
				throw new IllegalArgumentException("Can't parse query string", e);
			}
					
			// TODO: Copy&Paste detected
			byte[] result = taskManager.GetTasksJSON().getBytes();	
    		exchange.sendResponseHeaders(HttpResponseCodes.OK, result.length);
    		OutputStream responseBody = exchange.getResponseBody();
    		responseBody.write(result);
    		responseBody.close();	  
    		exchange.close();
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
}
