package ructf.executor;
import java.io.*;
import java.util.*;

import ructf.main.*;

public class Executor
{
	private int timeout;
	private String program;
	
	private Thread stdoutThread;
	private Thread stderrThread;
	
	private List<String> stdout = new LinkedList<String>();
	private List<String> stderr = new LinkedList<String>();
	
	private int exitCode;
	private boolean wasKilled;
	private boolean wasExecuted;
	private File checkersDir;
	
	public Executor(String program, int timeout)
	{
		this.program = program;
		this.timeout = timeout;
		checkersDir = new File(Constants.checkersDir);
	}
	
	public void Execute(String args) throws IOException, InterruptedException
	{		
		Cleanup();
		wasExecuted = true;
				
		File checker = new File(checkersDir, program);		
		Process proc = Runtime.getRuntime().exec(checker.getCanonicalPath() + " " + args, new String[]{}, checker.getParentFile() );
		TimeoutKiller killer = new TimeoutKiller(proc, timeout);
		
		CreateReaderThreads(proc);
		JoinReaderThreads();
		proc.waitFor();
		killer.StopWatching();		
		
		exitCode = proc.exitValue();
		wasKilled = killer.WasKilled();
	}

	private void Cleanup()
	{
		stdout.clear();
		stderr.clear();
		exitCode = 0;
		wasKilled = false;
	}

	private void JoinReaderThreads() throws InterruptedException
	{
		if (stdoutThread != null && stdoutThread.isAlive()) stdoutThread.join();
		if (stderrThread != null && stderrThread.isAlive()) stderrThread.join();
	}

	private void CreateReaderThreads(Process proc)
	{
		if (stdoutThread != null)
			stdoutThread.interrupt();
		stdoutThread = CreateReaderThread(stdout, proc.getInputStream());	// not a bug!
		stdoutThread.start();
		
		if (stderrThread != null)
			stderrThread.interrupt();
		stderrThread = CreateReaderThread(stderr, proc.getErrorStream());		
		stderrThread.start();
	}

	private static Thread CreateReaderThread(List<String> list, InputStream stream)
	{
		BufferedReader stdout = new BufferedReader(new InputStreamReader( stream ));
		return new ReaderThread(list, stdout);
	}

	public int GetExitCode()
	{
		return exitCode;
	}

	public boolean WasKilled()
	{
		return wasKilled;
	}
	
	public boolean WasExecuted()
	{
		return wasExecuted;
	}
	
	public String GetStdout()
	{
		return JoinList(stdout, newLine);
	}

	public String GetStderr()
	{
		return JoinList(stderr, newLine);
	}

	public String GetProgram()
	{
		return program;
	}
	
	public static String JoinList(List<String> list, String delimiter)
	{
		StringBuilder builder = new StringBuilder();
		Iterator<String> iter = list.iterator();
		while (iter.hasNext())
		{
			builder.append(iter.next());
			if (iter.hasNext())
				builder.append(delimiter);
		}
		return builder.toString();
	}

	public static String newLine = System.getProperty("line.separator");
}
