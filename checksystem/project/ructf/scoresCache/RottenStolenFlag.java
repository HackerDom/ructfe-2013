package ructf.scoresCache;

import java.sql.Timestamp;

public class RottenStolenFlag {
	public String flagData;
	public Timestamp time;
	public int owner;
	public int attacker;
	
	public RottenStolenFlag(String flagData, Timestamp time, int owner,	int attacker) {
		this.flagData = flagData;
		this.time = time;
		this.owner = owner;
		this.attacker = attacker;
	}
}
