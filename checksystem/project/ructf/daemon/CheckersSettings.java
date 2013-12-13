package ructf.daemon;

import java.io.File;
import java.util.Scanner;
import java.util.concurrent.ConcurrentHashMap;

import org.apache.log4j.Logger;

public class CheckersSettings {
	
	public static ConcurrentHashMap<Integer, Checker> checkers = new ConcurrentHashMap<Integer, Checker>();

	public static void Initialize(String filePath) throws Exception{
		filePath = filePath.trim();
		
		Scanner scanner = new Scanner(new File(filePath));
		logger.info("Parsing checkers settings file '" + filePath + "'");		
		
		int lineNumber = 0;
		while (scanner.hasNext()){
			lineNumber++;
			String line = scanner.nextLine();
			if (line.isEmpty() || line.startsWith("#") || line.matches("\\s+"))
				continue;
			
			String[] tokens = line.split("\\t+");
			if (tokens.length != 3)
				throw new Exception("Bad line number " + lineNumber + " in config. Must contain exactly three tokens: name<tab>path<tab>timeout");					
			
			if (checkers.containsKey(tokens[0]))
				logger.warn("Duplicate parameter  " + tokens[0] + " in config, using last one");					
			
			int serviceId = Integer.parseInt(tokens[0]);
			String name = tokens[1];
			int timeout = Integer.parseInt(tokens[2]);
			
			logger.info(String.format("Adding checker: id=%d, name=%s, timeout=%d ms", serviceId));
			checkers.put(serviceId, new Checker(name, timeout));			
		}		
	}

	private static Logger logger = Logger.getLogger("ructf.daemon");
}
