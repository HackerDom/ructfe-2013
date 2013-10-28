package ructf.main;

public class CheckerFailureException extends Exception
{
	private static final long serialVersionUID = 3215534577222843266L;

	public String details;
	public int serviceStatus;

	public CheckerFailureException(String details, int serviceStatus)
	{
		this.details = details;
		this.serviceStatus = serviceStatus;
	}
}
