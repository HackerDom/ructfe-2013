package ructf.executor;

public class TimeoutKiller extends Thread
{
	private Process process;
	private int timeout;
	private boolean wasKilled = false;

	public TimeoutKiller(Process process, int timeout)
	{
		this.process = process;
		this.timeout = timeout;
		start();
	}

	public void StopWatching()
	{
		interrupt();
	}

	public void run()
	{
		try
		{
			Thread.sleep(timeout);
			wasKilled = true;
			process.destroy();
		} catch (InterruptedException e) { }
	}

	public boolean WasKilled()
	{
		return wasKilled;
	}
}
