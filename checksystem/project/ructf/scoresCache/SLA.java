package ructf.scoresCache;

import java.sql.Timestamp;

public class SLA {
	public int team;
	public int successed;
	public int failed;
	public Timestamp time;
	
	public SLA(int team, int successed, int failed, Timestamp time) {
		this.team = team;
		this.successed = successed;
		this.failed = failed;
		this.time = time;
	}
}
