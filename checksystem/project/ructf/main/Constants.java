package ructf.main;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.HashMap;
import java.util.Scanner;

public class Constants
{
	private static String digits = "0123456789";
	private static String smallLetters = "qwertyuiopasdfghjklzxcvbnm";
	private static String capsLetters = smallLetters.toUpperCase();
	public static String idSymbols = digits + smallLetters;
	public static String flagSymbols = digits + capsLetters;
	
	//----------------configurable-------------------
	
	public static String xmlFlagsFile = "../scoreboard/flags.xml";
	public static String xmlScoreboardFile = "../scoreboard/scoreboard.xml";
	public static String xmlTeamsFile = "history-out/teams.xml";
	public static String xmlServicesFile = "history-out/services.xml";
	
	public static String log4jConfigFile = "log4j.cfg";
	public static String dbConfigFile = "database.cfg";
	public static String checkersDir = "checkers/";
	
	public static int secureFlagsInterval = 60;					// seconds
	
	public static int getFlagsClientTimeout = 20;				// seconds
	public static int getFlagsMinReconnectTime = 5;				// seconds (anti-bruteforce)
	//public static int getFlagsDisconnectThreshold = 50;			// bad flags (anti-bruteforce)
	
	public static int historyDumperDelay = 10; 
	
	public static int flagExpireInterval = 900;				// seconds
	public static int checkerRunTimeout = 10000;				// milliseconds
	
	public static int roundLength = 300;					//seconds
	
	public static int cacheUpdateInterval = 30;				//seconds
	
	public static int flagLength = 32;
	
	public static int getFlagsPort = 31337;
	public static String getFlagsIface = "0.0.0.0"; 	
	
	public static void Initialize(String configFilePath){
		try {
			configFilePath = configFilePath.trim();
			Scanner scanner = new Scanner(new File(configFilePath));
			System.out.println("Using config file '" + configFilePath + "'");
			HashMap<String, String> configMap = new HashMap<String, String>();
			int lineNumber = 0;
			while (scanner.hasNext()){
				lineNumber++;
				String line = scanner.nextLine();
				if (line.isEmpty() || line.startsWith("#") || line.matches("\\s+"))
					continue;
				
				String[] tokens = line.split("\\s+\\=\\s+");
				if (tokens.length != 2){
					System.err.println("bad line number " + lineNumber + " in config");
					continue;
				}					
				if (configMap.containsKey(tokens[0])){
					System.err.println("Duplicate parameter  " + tokens[0] + " in config, using last one");					
				}
				configMap.put(tokens[0], tokens[1]);			
			}
			
			String xmlFlagsFile = configMap.get("xmlFlagsFile");
			if (xmlFlagsFile != null)
				Constants.xmlFlagsFile = xmlFlagsFile;
			
			String xmlScoreboardFile = configMap.get("xmlScoreboardFile");
			if (xmlScoreboardFile != null)
				Constants.xmlScoreboardFile = xmlScoreboardFile;
			
			String xmlTeamsFile = configMap.get("xmlTeamsFile");
			if (xmlTeamsFile != null)
				Constants.xmlTeamsFile = xmlTeamsFile;
			
			String xmlServicesFile = configMap.get("xmlServicesFile");
			if (xmlServicesFile != null)
				Constants.xmlServicesFile = xmlServicesFile;
			
			String log4jConfigFile = configMap.get("log4jConfigFile");
			if (log4jConfigFile != null)
				Constants.log4jConfigFile = log4jConfigFile;
						
			String dbConfigFile = configMap.get("dbConfigFile");
			if (dbConfigFile != null)
				Constants.dbConfigFile = dbConfigFile;
			
			String checkersDir = configMap.get("checkersDir");
			if (checkersDir != null)
				Constants.checkersDir = checkersDir;
			
			String secureFlagsInterval = configMap.get("secureFlagsInterval");
			if (secureFlagsInterval != null)
				Constants.secureFlagsInterval = Integer.parseInt(secureFlagsInterval);
			
			String getFlagsClientTimeout = configMap.get("getFlagsClientTimeout");
			if (getFlagsClientTimeout != null)
				Constants.getFlagsClientTimeout = Integer.parseInt(getFlagsClientTimeout);
			
			String getFlagsMinReconnectTime = configMap.get("getFlagsMinReconnectTime");
			if (getFlagsMinReconnectTime != null)
				Constants.getFlagsMinReconnectTime = Integer.parseInt(getFlagsMinReconnectTime);
			
/*			String getFlagsDisconnectThreshold = configMap.get("getFlagsDisconnectThreshold");
			if (getFlagsDisconnectThreshold != null)
				Constants.getFlagsDisconnectThreshold = Integer.parseInt(getFlagsDisconnectThreshold);*/
			
			String flagExpireInterval = configMap.get("flagExpireInterval");
			if (flagExpireInterval != null)
				Constants.flagExpireInterval = Integer.parseInt(flagExpireInterval);
			
			String checkerRunTimeout = configMap.get("checkerRunTimeout");
			if (checkerRunTimeout != null)
				Constants.checkerRunTimeout = Integer.parseInt(checkerRunTimeout);
			
			String roundLength = configMap.get("roundLength");
			if (roundLength != null)
				Constants.roundLength = Integer.parseInt(roundLength);

			String cacheUpdateInterval = configMap.get("cacheUpdateInterval");
			if (cacheUpdateInterval != null)
				Constants.cacheUpdateInterval = Integer.parseInt(cacheUpdateInterval);
			
			String flagLength = configMap.get("flagLength");
			if (flagLength != null)
				Constants.flagLength = Integer.parseInt(flagLength);
			
			String getFlagsPort = configMap.get("getFlagsPort");
			if (getFlagsPort != null)
				Constants.getFlagsPort = Integer.parseInt(getFlagsPort);
			
			String getFlagsIface = configMap.get("getFlagsIface");
			if (getFlagsIface != null)
				Constants.getFlagsIface = getFlagsIface;		
			
			String historyDumperDelay = configMap.get("historyDumperDelay");
			if (historyDumperDelay != null)
				Constants.historyDumperDelay = Integer.parseInt(historyDumperDelay);		
			
		} catch (FileNotFoundException e) {
			System.err.println("Can't find config file '" + configFilePath + "'. Using default settings.");
			return;
		}		
	}
}
