package ructf.daemon;

import java.io.File;
import java.io.IOException;

import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;

import ructf.main.Constants;

public class Main {
	public static void main(String[] args)
	{		
		PropertyConfigurator.configure(Constants.log4jConfigFile);
		try	{
			if (args.length > 0 && (args[0].equals("-h") || args[0].equals("/?")))
				printUsageAndExit();

			if (args.length >= 1)
				settingsFilePath = args[0];
			
			if (args.length >= 2)
				checkersFilePath= args[1];
			
			DaemonSettings.Initialize(settingsFilePath);
			
			ServiceIds.LoadFromUrl(DaemonSettings.xmlServicesUrl);
			CheckersSettings.Initialize(checkersFilePath, ServiceIds.serviceIds);			
			
			WorkerManager workerManager = new WorkerManager();
			workerManager.start();
			logger.info("WorkerManager started.");
			
			workerManager.join();
		}
		catch (Exception ex) {
			logger.fatal("Daemon fatal error", ex);
			System.exit(-1);
		}		
	}

	public static void printUsageAndExit() {
		System.out.println("Usage: Daemon [<pathToSettingsFile>] [<pathToCheckersSettingsFile>]");
		System.exit(0);
	}

	private static String checkersFilePath = "checkers.cfg";
	private static String settingsFilePath = "daemon.cfg";
	
	private static Logger logger = Logger.getLogger("ructf.daemon");
}
