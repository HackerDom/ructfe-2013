package ructf.daemon;

import java.io.File;
import java.util.HashMap;
import java.util.Scanner;

import org.apache.log4j.Logger;

public class DaemonSettings {	
	
	public static int maxThreads;
	public static String taskManagerUrl;
	public static String xmlServicesUrl;	// TODO: Как это выпилить ???
	
	public static void Initialize(String filePath) throws Exception{		
		HashMap<String, String> settings = new HashMap<String, String>();
		
		filePath = filePath.trim();
		Scanner scanner = new Scanner(new File(filePath));
		logger.info("Parsing daemon settings file '" + filePath + "'");		
		
		int lineNumber = 0;
		while (scanner.hasNext()){
			lineNumber++;
			String line = scanner.nextLine();
			if (line.isEmpty() || line.startsWith("#") || line.matches("\\s+"))
				continue;
			
			String[] tokens = line.split("\\s+\\=\\s+");
			if (tokens.length != 2)
				throw new Exception("Malformed line number " + lineNumber + " in config");				
								
			if (settings.containsKey(tokens[0]))
				logger.warn("Duplicate parameter  " + tokens[0] + " in config, using last one");					
			
			settings.put(tokens[0], tokens[1]);			
		}
		
		if (!settings.containsKey("maxThreads"))
			throw new Exception("Obligatory param 'maxThreads' not specified in settings file");		
		String maxThreadsString = settings.get("maxThreads");		
		try {
			maxThreads = Integer.parseInt(maxThreadsString);
		}
		catch (Exception e) {
			throw new Exception("Can't parse param 'maxThreads' as integer");
		}
		
		if (!settings.containsKey("taskManagerUrl"))
			throw new Exception("Obligatory param 'taskManagerUrl' not specified in settings file");		
		taskManagerUrl = settings.get("taskManagerUrl");
		
		if (!settings.containsKey("xmlServicesUrl"))
			throw new Exception("Obligatory param 'xmlServicesUrl' not specified in settings file");
		xmlServicesUrl = settings.get("xmlServicesUrl");		
	}
	
	private static Logger logger = Logger.getLogger("ructf.daemon");
}
