package ructf.daemon;

public class ProcessResult {
	
	private int exitCode;
	private boolean exceededTimeout;
	private String stdout;
	private String stderr;
	
	public ProcessResult(int exitCode, boolean exceededTimeout, String stdout, String stderr){
		 this.exitCode = exitCode;
		 this.exceededTimeout = exceededTimeout;
		 this.stdout = stdout;
		 this.stderr = stderr;
	}

	public int getExitCode() {
		return exitCode;
	}
	
	public boolean exceededTimeout() {
		return exceededTimeout;
	}	

	public String getStdout() {
		return stdout;
	}

	public String getStderr() {
		return stderr;
	}	
}
