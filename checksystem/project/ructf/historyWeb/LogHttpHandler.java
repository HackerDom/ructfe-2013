package ructf.historyWeb;

import java.io.IOException;
import java.io.OutputStream;
import java.util.List;
import java.util.Map;
import java.util.Random;

import org.apache.log4j.Logger;

import ructf.utils.HttpResponseCodes;
import ructf.utils.QueryStringParser;


import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;

public class LogHttpHandler implements HttpHandler {

	Log log;
	private Random random = new Random();
	private long seed = random.nextLong();
	
	private static Logger logger = Logger.getLogger("ructf.historyWeb");
	
	public LogHttpHandler(Log log){
		this.log = log;
	}
	
	public void handle(HttpExchange exchange) throws IOException {		
		try{
			String queryStr = exchange.getRequestURI().toString();
			logger.info(String.format("client '%s', query '%s'", exchange.getRemoteAddress().toString(), queryStr));
			String requestMethod = exchange.getRequestMethod();
		    if (requestMethod.equalsIgnoreCase("GET")) {
		    	Map<String, List<String>> query = QueryStringParser.parse(queryStr);
		    	if (!query.containsKey("filter") || !query.containsKey("time")){
		    		exchange.sendResponseHeaders(HttpResponseCodes.BadRequest, 0);
		    		OutputStream responseBody = exchange.getResponseBody();
		    		responseBody.write("Params 'filter' and 'time' must be set".getBytes());  
		    		responseBody.close();	    	    
		    		return;
		    	}
		    	
		    	String filterString = (query.get("filter")).get(0);
		    	if (!filterString.equals("scores") && !filterString.equals("state")){
		    		exchange.sendResponseHeaders(HttpResponseCodes.BadRequest, 0);
		    		OutputStream responseBody = exchange.getResponseBody();
		    		responseBody.write("Param 'filter' must be one of {'scores' or 'state'}".getBytes());  
		    		responseBody.close();	    	    
		    		return;
		    	}		    	
		    	
		    	String timeString = (query.get("time")).get(0);
		    	
		    	String gotSeedString = ((Long)random.nextLong()).toString();
		    	if (query.containsKey("seed"))
		    		gotSeedString = (query.get("seed")).get(0);

		    	long timestamp;
		    	long gotSeed;		    	
		    	try{		    		
		    		gotSeed = Long.parseLong(gotSeedString);
		    		timestamp = Long.parseLong(timeString);
		    	}
		    	catch (NumberFormatException e) {
					exchange.sendResponseHeaders(HttpResponseCodes.BadRequest, 0);
					OutputStream responseBody = exchange.getResponseBody();
		    		responseBody.write("Params 'seed' and 'timestamp' must be integers".getBytes());
		    		responseBody.close();
					return;
				}
		    
		    	byte[] result = new byte[0];
		    	if (filterString.equals("scores"))
		    		result = (seed + log.GetScoresText(gotSeed == seed ? timestamp : 0)).getBytes();
		    	else if (filterString.equals("state"))
		    		result = (seed + log.GetStateText(gotSeed == seed ? timestamp : 0)).getBytes();		    	
		    	
		    	exchange.getResponseHeaders().set("Content-Type", "text/html; charset=utf-8");
	    		exchange.sendResponseHeaders(HttpResponseCodes.OK, result.length);
	    		OutputStream responseBody = exchange.getResponseBody();
	    		responseBody.write(result);
	    		responseBody.close();	    	    	
		    }
		}
		catch (Exception e) {
			logger.error("failed to process request", e);
			exchange.sendResponseHeaders(HttpResponseCodes.InternalServerError, 0);
    		OutputStream responseBody = exchange.getResponseBody();
    		responseBody.write("Internal server error".getBytes());  
    		responseBody.close();
		}		
	}
}
