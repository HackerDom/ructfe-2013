package ructf.daemon;

import java.util.UUID;

import ructf.utils.Base64Coder;

public class Task {
	public UUID id;
	
	public int serviceId;
	public String vulnBoxIp;
	
	public String newId;
	public String newFlag;
	public String randomId;
	public String randomFlag;
	
	public int round;	
		
	public Task(String str) throws IllegalArgumentException{
		String[] tokens = str.split(",", -1);
		if (tokens.length != 8)
			throw new IllegalArgumentException("Invalind task string. Must be CSV-like with 8 fields");
		
		try{
			id = UUID.fromString(tokens[0]);
			serviceId = Integer.parseInt(tokens[1]);
			vulnBoxIp = tokens[2];
			newId = tokens[3].equals("") ? null : Base64Coder.decodeString(tokens[3]);
			newFlag = tokens[4].equals("") ? null : tokens[4];
			randomId = tokens[5].equals("") ? null : Base64Coder.decodeString(tokens[5]);
			randomFlag = tokens[6].equals("") ? null : tokens[6];
			round = Integer.parseInt(tokens[7]); 
		}	
		catch (Exception e) {
			throw new IllegalArgumentException("Failed to parse string with task", e);
		}
	}



	@Override
	public String toString() {
		return "Task [round=" + round + ", id=" + id + ", serviceId="
				+ serviceId + ", vulnBoxIp=" + vulnBoxIp + ", newId=" + newId
				+ ", newFlag=" + newFlag + ", randomId=" + randomId
				+ ", randomFlag=" + randomFlag + "]";
	}

			
}
