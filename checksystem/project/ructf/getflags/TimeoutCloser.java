package ructf.getflags;

import java.io.*;
import java.net.*;

import org.apache.log4j.NDC;

public class TimeoutCloser extends Thread
{
	private int milliseconds;
	private LoggingWriter writer;
	private Socket sock; 
	private boolean wantExit = false;

	public TimeoutCloser(Socket sock, LoggingWriter writer, int seconds)
	{
		this.milliseconds = seconds*1000;
		this.sock = sock;
		this.writer = writer;
		start();
	}
	
	public void run()
	{
		NDC.push(sock.getInetAddress().getHostAddress());
		while (true)
		{
			try {
				Thread.sleep(milliseconds);
				break;
			} catch (InterruptedException ignore) {
				if (wantExit) break;
				else continue;
			}
		}
		Main.getLogger().info("Timeout for " + sock.getInetAddress());
		writer.println("");
		writer.println("Timeout.");
		try {
			sock.shutdownInput();
			sock.shutdownOutput();
		} catch (IOException ignore) { }
	}
	
	public void resetTimer() {
		wantExit = false;
		interrupt();
	}
	
	public void exit() {
		wantExit = true;
		interrupt();
	}
}
