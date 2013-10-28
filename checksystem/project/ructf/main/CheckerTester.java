package ructf.main;

import java.io.IOException;
import java.util.List;

import ructf.dbObjects.Service;
import ructf.executor.Executor;

public class CheckerTester
{
	public static void CheckAllOrDie(List<Service> services) throws IOException, InterruptedException 
	{
		for (Service s : services)
		{
			Executor executor = new Executor(s.getChecker(), 500);
			try {
				executor.Execute("");
			}
			catch (Exception ex) {
				System.err.println("Problem with: " + s);
				System.err.println("  failed pre-run test: " + ex.getMessage());
				System.exit(1);
			}
		}
	}
}
