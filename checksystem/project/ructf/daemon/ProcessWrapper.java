package ructf.daemon;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import ructf.executor.ReaderThread;
import ructf.executor.TimeoutKiller;

public class ProcessWrapper {	// Вроде прикольнее чем Executor
	
	private int timeout;
	private String fullPath;
	
	public String getFullPath() {
		return fullPath;
	}

	private Thread stdoutThread;
	private Thread stderrThread;
		
	public ProcessWrapper(String fullPath, int timeout)
	{
		this.fullPath = fullPath;
		this.timeout = timeout;		
	}
	
	public ProcessResult ExecuteOrFail(String[] args) throws IOException, InterruptedException
	{		
		File execFile = new File(fullPath);
		String fullPath = execFile.getCanonicalPath();
		File dir = execFile.getParentFile();
		
		String[] cmdArray = new String[args.length+1];
		cmdArray[0] = fullPath;
		System.arraycopy(args, 0, cmdArray, 1, args.length);
		
		Process proc = Runtime.getRuntime().exec(cmdArray, null, dir);
		try{
			TimeoutKiller killer = new TimeoutKiller(proc, timeout);
			
			List<String> stdout = new LinkedList<String>();
			List<String> stderr = new LinkedList<String>();
			
			stdoutThread = CreateReaderThread(stdout, proc.getInputStream());	// not a bug!
			stdoutThread.start();
			stderrThread = CreateReaderThread(stderr, proc.getErrorStream());		
			stderrThread.start();
			
			stdoutThread.join();
			stderrThread.join();
					
			proc.waitFor();
			killer.StopWatching();		
			
			//TODO надо ли?
			stdoutThread.interrupt();
			stderrThread.interrupt();
			
			return new ProcessResult(proc.exitValue(), killer.WasKilled(), JoinList(stdout), JoinList(stderr));	
		}
		finally{
			proc.destroy();
		}
	}

	private static Thread CreateReaderThread(List<String> list, InputStream stream)
	{
		BufferedReader stdout = new BufferedReader(new InputStreamReader( stream ));
		return new ReaderThread(list, stdout);
	}
	
	private static String JoinList(List<String> list)
	{
		StringBuilder builder = new StringBuilder();
		Iterator<String> iter = list.iterator();
		while (iter.hasNext())
		{
			builder.append(iter.next());
			if (iter.hasNext())
				builder.append(newLine);
		}
		return builder.toString();
	}

	private static String newLine = System.getProperty("line.separator");
}
