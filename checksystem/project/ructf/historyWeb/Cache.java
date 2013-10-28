package ructf.historyWeb;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import ructf.utils.StringUtils;


public class Cache {

	ArrayList<Integer> rounds;
	ArrayList<Long> roundTimes;
	ArrayList<TeamHistory> teamHistories;
	
	private Logger logger = Logger.getLogger("ructf.historyWeb");
	
	public void Reset(ArrayList<Integer> rounds, ArrayList<Long> roundTimes, ArrayList<TeamHistory> teamHistories) {
		synchronized (this) {
			this.rounds = rounds;
			this.roundTimes = roundTimes;
			this.teamHistories = teamHistories;
		}	
		logger.info(String.format("Cache reset, round = %d, teams = %d", rounds.size(), teamHistories.size()));
	}
	
	public String GetCacheJSON(int fromRound, long seed){
		synchronized (this) {
			StringBuffer sb = new StringBuffer();
			sb.append("{\r\n");
			int startIndex=0;
			for (;startIndex < rounds.size(); startIndex++) {
				if (rounds.get(startIndex) >= fromRound)
					break;				
			}
			
			sb.append(String.format("\t\"seed\": %d,\r\n", seed));
			if (startIndex < rounds.size())
			{
				sb.append(String.format("\t\"rounds\": [%s],\r\n", StringUtils.join(rounds.toArray(), startIndex, ", ")));
				sb.append(String.format("\t\"round_times\": [%s],\r\n", StringUtils.join(roundTimes.toArray(), startIndex, ", ")));
								
				sb.append("\t\"teams\": {\r\n");
				for (int i=0; i < teamHistories.size() - 1; i++) {
					sb.append(teamHistories.get(i).SerializeToJSON(startIndex));
					sb.append(",\r\n");
				}
				sb.append(teamHistories.get(teamHistories.size() - 1).SerializeToJSON(startIndex));
				sb.append("\r\n");
				
				sb.append("\t}\r\n");
			}
				
			
			sb.append('}');
			return sb.toString();
		}	
	}
}
