package ructf.scoresCache;

import java.sql.Timestamp;

public class TeamScore {
	public int team;
	public double score;
	public Timestamp time;
	
	public TeamScore(int team, double score, Timestamp time) {
		this.team = team;
		this.score = score;
		this.time = time;
	}		
}