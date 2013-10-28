package ructf.historyWeb;

import java.io.FileWriter;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.sql.SQLException;
import java.util.List;

import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;

import ructf.dbObjects.Service;
import ructf.dbObjects.Team;
import ructf.main.Constants;
import ructf.main.DatabaseManager;

import com.sun.net.httpserver.HttpServer;

public class Main {
	
	private static Logger logger = Logger.getLogger("ructf.historyWeb");

	public static void main(String[] args) throws IOException, SQLException {
			
		PropertyConfigurator.configure(Constants.log4jConfigFile);
		logger.info("HistoryWeb process started");
		try
		{			
			if (args.length > 0)
				Constants.Initialize(args[0]);
	
			DatabaseManager.Initialize();
			System.out.println("Dumping teams and services.");
			DumpServices();
			DumpTeams();
			
			Cache cache = new Cache();
			CacheUpdater cacheUpdater = new CacheUpdater(cache);						
			cacheUpdater.start();
			logger.info("CacheUpdater started");			
			
			Log log = new Log();
		    LogUpdater logUpdater = new LogUpdater(log);
		    logUpdater.start();
		    logger.info("CacheUpdater started");
			
			InetSocketAddress addr = new InetSocketAddress(8080);
		    
			HttpServer server = HttpServer.create(addr, 0);	
		    server.createContext("/history", new HistoryHttpHandler(cache));
		    server.createContext("/log", new LogHttpHandler(log));
		    server.createContext("/clientaccesspolicy.xml", new ClientAccessPolicyHandler());
		    server.start();
		    logger.info(String.format("Http server started on port %d", addr.getPort()));		    		    
		} catch (Exception e) {
			logger.fatal("General error", e);
			e.printStackTrace();
		}
	}
	
	private static void DumpServices() throws IOException {
		FileWriter fileWriter = new FileWriter(Constants.xmlServicesFile);
		fileWriter.write("<?xml version=\"1.0\" encoding=\"utf-8\" ?>\r\n");
		fileWriter.write("<services>\r\n");
		List<Service> services = DatabaseManager.getServices();
		for (Service service : services)
			fileWriter.write(String.format("\t<service id=\"%d\" name=\"%s\"/>\r\n", service.getId(), service.getName()));
		
		fileWriter.write("</services>\r\n");
		fileWriter.close();
	}

	private static void DumpTeams() throws IOException {
		FileWriter fileWriter = new FileWriter(Constants.xmlTeamsFile);
		fileWriter.write("<?xml version=\"1.0\" encoding=\"utf-8\" ?>\r\n");
		fileWriter.write("<teams>\r\n");
		List<Team> teams = DatabaseManager.getTeams();
		for (Team team : teams)
			fileWriter.write(String.format("\t<team id=\"%d\" name=\"%s\"/>\r\n", team.getId(), team.getName()));
		
		fileWriter.write("</teams>\r\n");
		fileWriter.close();		
	}
}
