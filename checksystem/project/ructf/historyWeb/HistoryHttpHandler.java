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

public class HistoryHttpHandler implements HttpHandler {
	
	private Cache cache;
	private Random random = new Random();
	private long seed = random.nextLong();
	
	private static Logger logger = Logger.getLogger("ructf.historyWeb");
	
	public HistoryHttpHandler(Cache cache){
		this.cache = cache;
	}
	
	public void handle(HttpExchange exchange) throws IOException {
		try{
			String queryStr = exchange.getRequestURI().toString();
			logger.info(String.format("client '%s', query '%s'", exchange.getRemoteAddress().toString(), queryStr));
			String requestMethod = exchange.getRequestMethod();
		    if (requestMethod.equalsIgnoreCase("GET")) {
		    	Map<String, List<String>> query = QueryStringParser.parse(queryStr);
		    	if (!query.containsKey("round")){
		    		exchange.sendResponseHeaders(HttpResponseCodes.BadRequest, 0);
		    		OutputStream responseBody = exchange.getResponseBody();
		    		responseBody.write("Param 'round' is not set".getBytes());  
		    		responseBody.close();	    	    
		    		return;
		    	}
		    	
		    	String roundString = (query.get("round")).get(0);
		    	String gotSeedString = ((Long)random.nextLong()).toString();
		    	if (query.containsKey("seed"))
		    		gotSeedString = (query.get("seed")).get(0);
		    	
		    	int round;
		    	long gotSeed;
		    	
		    	try{
		    		round = Integer.parseInt(roundString);
		    		gotSeed = Long.parseLong(gotSeedString);
		    	}
		    	catch (NumberFormatException e) {
					exchange.sendResponseHeaders(HttpResponseCodes.BadRequest, 0);
					OutputStream responseBody = exchange.getResponseBody();
		    		responseBody.write("Params 'round' and 'seed' must be integers".getBytes());
		    		responseBody.close();
					return;
				}
		    	
		    	
	    		byte[] result = cache.GetCacheJSON(gotSeed == seed ? round : 0, seed).getBytes();	    	
	    		exchange.sendResponseHeaders(HttpResponseCodes.OK, result.length);
	    		OutputStream responseBody = exchange.getResponseBody();
	    		responseBody.write(result);
	    		responseBody.close();
	    	    	
		    }
		}
		catch (Exception e) {
			logger.error("failed to process request", e);
		}	
	}
}
