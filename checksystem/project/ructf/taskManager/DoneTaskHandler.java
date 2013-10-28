package ructf.taskManager;

import java.io.IOException;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.apache.log4j.Logger;

import ructf.main.CheckerExitCode;
import ructf.utils.Base64Coder;
import ructf.utils.HttpResponseCodes;
import ructf.utils.QueryStringParser;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;

public class DoneTaskHandler implements HttpHandler {

	private static Logger logger = Logger.getLogger("ructf.taskManager");
	private TaskManager taskManager;
	
	public DoneTaskHandler(TaskManager taskManager) {
		this.taskManager = taskManager;
	}

	public void handle(HttpExchange exchange) throws IOException {
		try{
			String queryStr = exchange.getRequestURI().toString();
			logger.info(String.format("client '%s', query '%s'", exchange.getRemoteAddress().toString(), queryStr));
			
			Map<String, List<String>> query;
			try {
				query = QueryStringParser.parse(queryStr);
			} catch (UnsupportedEncodingException e) {			
				throw new IllegalArgumentException("Can't parse query string", e);
			}
			
			if (!query.containsKey("id") || !query.containsKey("newFlagId") || !query.containsKey("status") || !query.containsKey("failStage") || !query.containsKey("failComment") || !query.containsKey("newFlagSuccess") || !query.containsKey("randomFlagSuccess")){
				throw new IllegalArgumentException("Params 'id', 'newFlagId', 'status', 'failStage', 'failComment', 'newFlagSuccess', 'randomFlagSuccess' are obligatory");
			}

			UUID id = UUID.fromString(query.get("id").get(0));
			String newFlagId = query.get("newFlagId").get(0);
			int status = Integer.parseInt(query.get("status").get(0));
			String failStage = query.get("failStage").get(0);
			String failComment = query.get("failComment").get(0);
			boolean newFlagSuccess = Boolean.parseBoolean(query.get("newFlagSuccess").get(0));
			boolean randomFlagSuccess = Boolean.parseBoolean(query.get("randomFlagSuccess").get(0));
			
			//TODO костыль, так то лучше убрать возможную неоднозначность, выпилив передачу randomGetSuccess-а
			if (newFlagSuccess && randomFlagSuccess && status != CheckerExitCode.OK.toInt())
			{
				String mes = String.format("Can't process task %s done-request - incompatible status '$d' with both flags get-success", id, status);
				logger.warn(mes);
				exchange.sendResponseHeaders(HttpResponseCodes.BadRequest, 0);
				return;
			}			
			taskManager.finishTask(id, newFlagId, status, failStage, failComment, newFlagSuccess, randomFlagSuccess); 	
    		
    		exchange.sendResponseHeaders(HttpResponseCodes.OK, 0);
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

	private List<UUID> parseRequest(String queryStr) throws IllegalArgumentException {
		Map<String, List<String>> query;
		try {
			query = QueryStringParser.parse(queryStr);
		} catch (UnsupportedEncodingException e) {			
			throw new IllegalArgumentException("Can't parse query string", e);
		}
		
		if (!query.containsKey("ids")){
			throw new IllegalArgumentException("query string must contain param 'ids'");
		}
		
		List<UUID> result = new LinkedList<UUID>();
		for (String id : query.get("ids").get(0).split(",")) {
			result.add(UUID.fromString(id));
		}
		
		return result;
	}

}
