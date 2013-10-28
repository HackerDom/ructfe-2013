package ructf.taskManager;

import java.util.UUID;

import ructf.dbObjects.Team;
import ructf.main.IdFlagPair;
import ructf.utils.Base64Coder;
import ructf.utils.StringUtils;

public class Task {	
	
	public UUID id;	// TODO: сделать приватные сеттеры
	
	public int serviceId;
	public Team team;
	
	public IdFlagPair newIdFlag;
	public IdFlagPair randomIdFlag;
	
	public int round;
	
	//TODO костыль
	public int status;
	
	public Task(int serviceId, int round, Team team, IdFlagPair newIdFlag, IdFlagPair randomIdFlag) {		
		this.id = UUID.randomUUID();
		this.round = round;
		this.serviceId = serviceId;
		this.team = team;
		this.newIdFlag = newIdFlag;
		this.randomIdFlag = randomIdFlag;		
	}

	//TODO Использовать один способ сериализации (например, JSON)
	//TODO Использовать готовый класс для JSON
	
	public String toString() {
		return String.format("%s,%d,%s,%s,%s,%s,%s,%s", id, serviceId, team.getVulnBox(),
				newIdFlag != null ? Base64Coder.encodeString(newIdFlag.getFlagId()) : "",
				newIdFlag != null ? newIdFlag.getFlagData() : "",
				randomIdFlag != null ? Base64Coder.encodeString(randomIdFlag.getFlagId()) : "",
				randomIdFlag != null ? randomIdFlag.getFlagData() : "",
				round);
	}
	
	public String SerializeToJSON(String state){
		StringBuffer sb = new StringBuffer();
		sb.append("\t\t{\r\n");
		sb.append(String.format("\t\t\t\"state\": \"%s\"\r\n", state));
		sb.append(String.format("\t\t\t,\"status\": \"%s\"\r\n", status));
		sb.append(String.format("\t\t\t,\"id\": \"%s\"\r\n", StringUtils.LuteHalfString(id.toString())));
		if (team != null){
			sb.append(String.format("\t\t\t,\"team_id\": \"%s\"\r\n", team.getId()));
			sb.append(String.format("\t\t\t,\"team_name\": \"%s\"\r\n", team.getName()));
			sb.append(String.format("\t\t\t,\"team_vulnbox\": \"%s\"\r\n", team.getVulnBox()));
		}		
		if (newIdFlag != null){
			sb.append(String.format("\t\t\t,\"new_f_id\": \"%s\"\r\n", StringUtils.LuteHalfString(newIdFlag.getFlagId())));
			sb.append(String.format("\t\t\t,\"new_f\": \"%s\"\r\n", StringUtils.LuteHalfString(StringUtils.LuteHalfString(newIdFlag.getFlagData()))));
		}
		if (randomIdFlag != null){
			sb.append(String.format("\t\t\t,\"random_f_id\": \"%s\"\r\n", StringUtils.LuteHalfString(randomIdFlag.getFlagId())));
			sb.append(String.format("\t\t\t,\"random_f\": \"%s\"\r\n", StringUtils.LuteHalfString(StringUtils.LuteHalfString(randomIdFlag.getFlagId()))));	
		}		
		sb.append("\t\t}");
		return sb.toString();
	}
	
	
}
