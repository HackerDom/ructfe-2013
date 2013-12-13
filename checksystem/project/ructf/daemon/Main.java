package ructf.daemon;

import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;

import ructf.main.Constants;

public class Main {
	public static void main(String[] args)
	{		
		PropertyConfigurator.configure(Constants.log4jConfigFile);
		try	{
			if (args.length != 2)
				printUsageAndExit();

			String daemonConfigFile = args[0];
			String checkersConfigFile= args[1];
			
			DaemonSettings.Initialize(daemonConfigFile);
			CheckersSettings.Initialize(checkersConfigFile);			
			
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
		System.out.println("Usage: Daemon <daemonConfig> <checkersConfig>");
		System.exit(0);
	}

	private static Logger logger = Logger.getLogger("ructf.daemon");
}
