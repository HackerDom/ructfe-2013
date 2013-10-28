package ructf.daemon;

import org.apache.log4j.Logger;

import ructf.main.CheckerExitCode;
import ructf.main.CheckerFailureException;
import ructf.utils.StringUtils;

public class CheckerWrapper2 {	// Возможно, этот класс не нужен, все можно сделать методом в Worker-е
	
	ProcessWrapper processWrapper;
	
	public CheckerWrapper2(String fullPath, int timeout)
	{
		processWrapper = new ProcessWrapper(fullPath, timeout);		
	}
	
	public ProcessResult ExecuteOrFail(String[] args) throws Exception
	{
		long start = System.currentTimeMillis();
		ProcessResult result =  processWrapper.ExecuteOrFail(args);
		long finish = System.currentTimeMillis();
		
		logger.info(String.format("(%s %s) -> (exit: %d, timeout: %b, %d ms, stdout: %s, stderr: %s)", processWrapper.getFullPath(), StringUtils.join(args, 0, " "), result.getExitCode(), result.exceededTimeout(), finish - start, result.getStdout().trim(), result.getStderr().trim()));
		
		if (result.exceededTimeout())
			throw new CheckerFailureException("Timeout", CheckerExitCode.Down.toInt());
		else if (CheckerExitCode.isUnknown(result.getExitCode()))
			throw new CheckerFailureException("Unknown exitCode: " + result.getExitCode(), result.getExitCode());
		else if (result.getExitCode() != CheckerExitCode.OK.toInt())
			throw new CheckerFailureException(result.getStdout(), result.getExitCode());
		
		return result;
	}
	
	private static Logger logger = Logger.getLogger("ructf.daemon");
}
