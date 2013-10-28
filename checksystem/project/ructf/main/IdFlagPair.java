package ructf.main;

public class IdFlagPair
{
	private String flagId;
	private String flagData;
	
	public IdFlagPair(String flagId, String flagData)
	{
		this.flagId = flagId;
		this.flagData = flagData;
	}

	public String getFlagId()
	{
		return flagId;
	}

	public String getFlagData()
	{
		return flagData;
	}
	
	public String toString()
	{
		return flagId + " " + flagData;
	}
}
