package ructf.executor;

import java.io.*;
import org.junit.*;
import static org.junit.Assert.*; 

public class TimeoutKiller_Test		// Windows only!
{
	@Test
	public void KillTest() throws Exception
	{
		assertFalse(IsRunning("notepad.exe"));
		Process p = Runtime.getRuntime().exec("notepad.exe");
		Thread.sleep(100);
		assertTrue(IsRunning("notepad.exe"));
		
		TimeoutKiller killer = new TimeoutKiller(p, 500);
		Thread.sleep(300);
		assertTrue(IsRunning("notepad.exe"));
		assertFalse(killer.WasKilled());

		Thread.sleep(600);
		assertFalse(IsRunning("notepad.exe"));
		assertTrue(killer.WasKilled());
	}

	@Test
	public void StopWatching() throws Exception
	{
		assertFalse(IsRunning("notepad.exe"));
		Process p = Runtime.getRuntime().exec("notepad.exe");
		Thread.sleep(100);
		assertTrue(IsRunning("notepad.exe"));
		
		TimeoutKiller killer = new TimeoutKiller(p, 500);
		Thread.sleep(300);
		assertTrue(IsRunning("notepad.exe"));
		assertFalse(killer.WasKilled());
		
		killer.StopWatching();
		Thread.sleep(600);
		assertTrue(IsRunning("notepad.exe"));
		assertFalse(killer.WasKilled());
		
		p.destroy();
	}
	
	@Test
	public void KillAlreadyTerminated() throws Exception
	{
		assertFalse(IsRunning("notepad.exe"));
		Process p = Runtime.getRuntime().exec("notepad");
		p.destroy();
		assertFalse(IsRunning("notepad.exe"));
		TimeoutKiller killer = new TimeoutKiller(p, 100);
		Thread.sleep(300);
		assertTrue(killer.WasKilled());
	}
	
	private static boolean IsRunning(String processName)
	{
		try {
	        String line;
	        Process p = Runtime.getRuntime().exec("tasklist");
	        BufferedReader input = new BufferedReader(new InputStreamReader(p.getInputStream()));
	        while ((line = input.readLine()) != null) {
	        	if (line.contains(processName))
	        		return true;
	        }
	        input.close();
	    } catch (Exception err) {
	        err.printStackTrace();
	    }
	    return false;
	}
}
