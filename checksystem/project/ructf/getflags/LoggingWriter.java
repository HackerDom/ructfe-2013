package ructf.getflags;

import java.io.*;
import java.net.Socket;

import org.apache.log4j.*;

public class LoggingWriter
{
	private PrintWriter writer;
	private Logger logger;
	private static String prefix = "--> ";
	
	public static LoggingWriter Create(Socket s, Logger logger) throws IOException
	{
		PrintWriter w = new PrintWriter(s.getOutputStream(), true);
		return new LoggingWriter(w, logger);
	}
	
	public LoggingWriter(PrintWriter writer, Logger logger)
	{
		this.writer = writer;
		this.logger = logger;
	}
	
	public void println(String s)
	{
		writer.println(s + "\r");
		logger.debug(prefix + s);
	}
	
	public void print(String s)
	{
		writer.print(s);
		writer.flush();
		logger.debug(prefix + s);
	}
	
	public void close()
	{
		writer.close();
	}
}
