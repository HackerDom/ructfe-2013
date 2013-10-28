package ructf.taskManager;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.sql.SQLException;

import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;

import ructf.main.Constants;
import ructf.main.DatabaseManager;

import com.sun.net.httpserver.HttpServer;

public class Main {
	
	private static Logger logger = Logger.getLogger("ructf.taskManager");
	
	public static void main(String[] args) throws IOException, SQLException {		
		PropertyConfigurator.configure(Constants.log4jConfigFile);
		logger.info("TaskManager process started");
		try
		{			
			if (args.length > 0 && (args[0].equals("-h") || args[0].equals("/?")))
				printUsageAndExit();			
			if (args.length > 0)
				configFilePath = args[0];
			
			Constants.Initialize(configFilePath);
	
			DatabaseManager.Initialize();
			
			TaskManager taskManager = new TaskManager();
			taskManager.start();			
						
			InetSocketAddress addr = new InetSocketAddress(8080);		    
			HttpServer server = HttpServer.create(addr, 0);	
		    server.createContext("/getTasks", new GetTasksHttpHandler(taskManager));
		    server.createContext("/doneTask", new DoneTaskHandler(taskManager));
		    server.createContext("/mon", new MonitoringTaskHandler(taskManager));
		    server.start();
		    logger.info(String.format("Http server started on port %d", addr.getPort()));
		    
		    taskManager.join();		    
		} catch (Exception e) {
			logger.fatal("General error", e);
			e.printStackTrace();
			System.exit(-1);
		}
	}
	
	public static void printUsageAndExit() {
		System.out.println("Usage: TaskManager [<pathToSettingsFile>] [<pathToCheckersSettingsFile>]");	// pathToCheckersSettingsFile - это фейк
		System.exit(0);
	}

	private static String configFilePath = "checksystem.cfg";		
}

