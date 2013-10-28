package ructf.executor;

import java.io.*;
import java.util.*;

public class ReaderThread extends Thread
{
	private List<String> linesList;
	private BufferedReader reader;

	public ReaderThread(List<String> linesList, BufferedReader reader)
	{
		this.linesList = linesList;
		this.reader = reader;
		this.setDaemon(true);
	}

	public void run()
	{
		String line;
		try	{
			while (null != (line = reader.readLine()))
				linesList.add(line);
		} catch (IOException e)	{
			System.err.println("Error: ReaderThread: " + e.getMessage());
		}
	}
}
