package ructf.daemon;

public class Checker {	
	public String checkerFilePath;
	public int timeout;
	
	public Checker(String checkerFilePath, int timeout){
		this.checkerFilePath = checkerFilePath;
		this.timeout = timeout;
	}	
}
