package ructf.historyWeb;

import java.io.IOException;
import java.io.OutputStream;

import org.apache.log4j.Logger;

import ructf.utils.HttpResponseCodes;


import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;

public class ClientAccessPolicyHandler implements HttpHandler {

	private static Logger logger = Logger.getLogger("ructf.historyWeb");
	
	private static String str = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<access-policy>\n<cross-domain-access>\n<policy>\n<allow-from http-request-headers=\"*\">\n<domain uri=\"*\"/>\n</allow-from>\n<grant-to>\n<resource path=\"/\" include-subpaths=\"true\"/>\n</grant-to>\n</policy>\n</cross-domain-access>\n</access-policy>";
	
	public void handle(HttpExchange exchange) throws IOException {
		try{
			exchange.sendResponseHeaders(HttpResponseCodes.OK, 0);
			OutputStream responseBody = exchange.getResponseBody();
			responseBody.write(str.getBytes());  
    		responseBody.close();	    	    
    		return;
		}
		catch (Exception e) {
			logger.error("failed to process request", e);
		}		
	}
}
