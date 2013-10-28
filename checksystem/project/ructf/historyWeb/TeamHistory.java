package ructf.historyWeb;

import java.util.ArrayList;

import ructf.utils.StringUtils;

public class TeamHistory {
	public int teamId;	
	public String teamName;
	public ArrayList<Integer> defense = new ArrayList<Integer>();
	public ArrayList<Integer> attack = new ArrayList<Integer>();
	public ArrayList<Integer> advisories = new ArrayList<Integer>();
	public ArrayList<Integer> tasks = new ArrayList<Integer>();
	
	public String SerializeToJSON(int startIndex){
		StringBuffer sb = new StringBuffer();
		sb.append(String.format("\t\t\"team_%s\": {\r\n", teamId));
		sb.append(String.format("\t\t\t\"name\": \"%s\",\r\n", teamName));
		sb.append(String.format("\t\t\t\"defense\": [%s],\r\n", StringUtils.join(defense.toArray(), startIndex, ", ")));
		sb.append(String.format("\t\t\t\"attack\": [%s],\r\n", StringUtils.join(attack.toArray(), startIndex, ", ")));
		sb.append(String.format("\t\t\t\"advisories\": [%s],\r\n", StringUtils.join(advisories.toArray(), startIndex, ", ")));
		sb.append(String.format("\t\t\t\"tasks\": [%s]\r\n", StringUtils.join(tasks.toArray(), startIndex, ", ")));		
		sb.append("\t\t}");
		return sb.toString();
	}
}
