package ructf.historyWeb;

import java.util.ArrayList;

public class Log {

	ArrayList<LogEntry> flagLog = new ArrayList<LogEntry>();
	ArrayList<LogEntry> statusLog = new ArrayList<LogEntry>();
	
	ArrayList<LogEntry> scoresAttackLog = new ArrayList<LogEntry>();
	ArrayList<LogEntry> scoresSecretLog = new ArrayList<LogEntry>();
	ArrayList<LogEntry> scoresAccessLog = new ArrayList<LogEntry>();
	ArrayList<LogEntry> scoresAdvisoriesLog = new ArrayList<LogEntry>();
	ArrayList<LogEntry> scoresTasksLog = new ArrayList<LogEntry>();	
	
	public void insertFlag(long timestamp, String str){
		synchronized (flagLog) {
			flagLog.add(new LogEntry(timestamp, str));	
		}
	}
	
	public void insertStatus(long timestamp, String str){
		synchronized (statusLog) {
			statusLog.add(new LogEntry(timestamp, str));
		}
	}
	
	public void insertScores(long timestamp, String str, String prefix){
		LogEntry le = new LogEntry(timestamp, str);
		synchronized (scoresAttackLog) {
			if (prefix.equals("at"))
				scoresAttackLog.add(le);		
			else if (prefix.equals("se"))
				scoresSecretLog.add(le);		
			else if (prefix.equals("ac"))
				scoresAccessLog.add(le);		
			else if (prefix.equals("ad"))
				scoresAdvisoriesLog.add(le);		
			else if (prefix.equals("ta"))
				scoresTasksLog.add(le);
			else
				throw new IllegalArgumentException(String.format("Unknown argument exception: prefix='%s'", prefix));	
		}		
	}
	
	public String GetStateText(long fromTimestamp){
		synchronized (flagLog){
			synchronized (statusLog){
				int iFl = findOffsetForTimestamp(flagLog, fromTimestamp);
				int iSt = findOffsetForTimestamp(statusLog, fromTimestamp);
				
				ArrayList<LogEntry> result = MergeLists(new ArrayList[]{flagLog, statusLog}, new int[]{iFl, iSt});
						
				StringBuffer sb = new StringBuffer();
				for (LogEntry logEntry : result) {
					sb.append("\r\n");
					sb.append(logEntry.str);				
				}
				return sb.toString();
			}
		}	
	}
	
	public String GetScoresText(long fromTimestamp){
		synchronized (scoresAttackLog) {
			int iAt = findOffsetForTimestamp(scoresAttackLog, fromTimestamp);
			int iSe = findOffsetForTimestamp(scoresSecretLog, fromTimestamp);
			int iAc = findOffsetForTimestamp(scoresAccessLog, fromTimestamp);
			int iAd = findOffsetForTimestamp(scoresAdvisoriesLog, fromTimestamp);
			int iTa = findOffsetForTimestamp(scoresTasksLog, fromTimestamp);
			
			ArrayList<LogEntry> result = MergeLists(new ArrayList[]{scoresAttackLog, scoresSecretLog, scoresAccessLog, scoresAdvisoriesLog, scoresTasksLog},
													new int[]{iAt, iSe, iAc, iAd, iTa});
			
			StringBuffer sb = new StringBuffer();
			for (LogEntry logEntry : result) {
				sb.append("\r\n");
				sb.append(logEntry.str);				
			}
			return sb.toString();
		}
	}
	
	private int findOffsetForTimestamp(ArrayList<LogEntry> list, long timestamp){
		int first = 0;
		int last = list.size() - 1;
		if (list.size() == 0 || timestamp < list.get(first).timestamp)
			return 0;
		if (timestamp > list.get(last).timestamp)
			return list.size();
		
		while(first < last){
			int mid = (first + last)/2;
			if (timestamp <= list.get(mid).timestamp)
				last = mid;
			else
				first = mid + 1;
		}
		return last;
	}
	
	private ArrayList<LogEntry> MergeLists(ArrayList<LogEntry>[] lists, int[] offsets){
		ArrayList<LogEntry> result = new ArrayList<LogEntry>();
		if (lists.length != offsets.length)
			throw new IllegalArgumentException(String.format("ArrayList array size '%i' is not equal to startOffsets array size '%i'", lists.length, offsets.length));

		if (lists.length == 0)
			throw new IllegalArgumentException(String.format("ArrayList array size must be greater than 0", lists.length, offsets.length));
		
		while (true){
			int candidateNum = -1;
			for (int i=0; i < lists.length; i++){
				if (offsets[i] >= lists[i].size())
					continue;
				
				if (candidateNum == -1 || lists[i].get(offsets[i]).timestamp < lists[candidateNum].get(offsets[candidateNum]).timestamp)
					candidateNum = i;
			}
			
			if (candidateNum == -1)
				break;
			
			result.add(lists[candidateNum].get(offsets[candidateNum]));
			offsets[candidateNum]++;			
		}
		return result;
	}
}




