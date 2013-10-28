package ructf.getflags;

import java.io.*;
import java.net.Socket;
import org.apache.log4j.Logger;

public class LoggingReader
{
	private BufferedReader	reader;
	private Logger			logger;
	private static String	prefix = "<-- ";
	
	public static LoggingReader Create(Socket s, Logger logger) throws IOException
	{
		BufferedReader r = new BufferedReader(new InputStreamReader(s.getInputStream()));
		return new LoggingReader(r, logger);
	}
	
	public LoggingReader(BufferedReader reader, Logger logger)
	{
		this.reader = reader;
		this.logger = logger;
	}
	
	public String readLine() throws IOException
	{
		String s = reader.readLine();
		logger.debug(prefix + s);
		return s;
	}
	
	public void close() throws IOException
	{
		reader.close();
	}
}
