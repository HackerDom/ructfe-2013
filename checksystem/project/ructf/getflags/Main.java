package ructf.getflags;

import java.net.*;

import ructf.main.*;

import org.apache.log4j.*;

public class Main
{
	private static ServerSocket s;
	private static String startupMessage = "RuCTF Get-Flags service";
	private static Logger logger;

	public static void main(String[] args)
	{
		if (args.length > 0)
			Constants.Initialize(args[0]);
		
		System.out.println(startupMessage);
		CreateLoggers();
		
		logger.info("Starting...");
		try {
			DatabaseManager.Initialize();
			s = new ServerSocket(Constants.getFlagsPort, 0, InetAddress.getByName(Constants.getFlagsIface));
			logger.info("Listening: " + s);
			while (true) {
				Socket clientSock = s.accept();
				ClientProcessor.CreateAndStart(clientSock);
			}
		} catch (Exception e) {
			logger.fatal("Cannot continue");
			logException(e);
		}
		logger.info("Terminated");
	}
	
	private static void CreateLoggers() {
		System.out.println("Using log4j config: " + Constants.log4jConfigFile);
		PropertyConfigurator.configure(Constants.log4jConfigFile);
		logger = Logger.getLogger("ructf.getflags");
		ClientProcessor.logger = logger;
		ClientProcessor.loggerDump = Logger.getLogger("ructf.getflagsdump");
	}

	public static void logException(Exception e) {
		logger.error(e.getMessage());
		for( StackTraceElement te : e.getStackTrace())
			logger.error("\t"+te.toString());
	}
	
	public static Logger getLogger() {
		return logger;
	}
}
