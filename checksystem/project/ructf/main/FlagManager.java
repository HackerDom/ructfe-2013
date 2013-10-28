package ructf.main;

import java.sql.*;
import java.util.*;

import ructf.getflags.StolenFlag;

public class FlagManager
{
	/*	 ласс дл€ работы с флагами.
	 *	”меет:
	 *		- генерировать флаги + идентификаторы,
	 *		- добавл€ть флаг в базу,
	 *		- получать случайный непротухший флаг.
	 */
	
	private PreparedStatement	stInsertFlag;
	private PreparedStatement	stInsertDelayedFlag;
	private PreparedStatement	stGetDelayedFlag;
	private PreparedStatement	stDeleteDelayedFlag;
	private PreparedStatement	stInsertStolenFlag;
	private PreparedStatement	stGetNotExpiredFlags;
	private Random				random;
	private StringBuilder		stringBuilder;
	
	private static String sqlInsertFlag = "INSERT INTO flags (team_id, service_id, flag_id, flag_data) VALUES (?,?,?,?)";
	private static String sqlInsertDelayedFlag = "INSERT INTO delayed_flags (team_id, service_id, flag_id, flag_data) VALUES (?,?,?,?)";
	private static String sqlGetDelayedFlag    = "SELECT flag_id, flag_data FROM delayed_flags WHERE team_id=? AND service_id=?";
	private static String sqlDeleteDelayedFlag = "DELETE FROM delayed_flags WHERE team_id=? AND service_id=?";
	private static String sqlInsertStolenFlag = "INSERT INTO stolen_flags (team_id, flag_data, victim_team_id, victim_service_id) VALUES (?,?,?,?)";
	private static String sqlGetNotExpiredFlags = "SELECT flag_id, flag_data FROM flags WHERE " +
		"team_id=? AND service_id=? AND EXTRACT(EPOCH FROM NOW()-time) < ?";
	
	public FlagManager(Connection dbConnection) throws SQLException
	{
		stInsertFlag = dbConnection.prepareStatement(sqlInsertFlag);
		stInsertStolenFlag = dbConnection.prepareStatement(sqlInsertStolenFlag);
		stInsertDelayedFlag = dbConnection.prepareStatement(sqlInsertDelayedFlag);
		stDeleteDelayedFlag = dbConnection.prepareStatement(sqlDeleteDelayedFlag);
		stGetDelayedFlag = dbConnection.prepareStatement(sqlGetDelayedFlag);
		stGetNotExpiredFlags = dbConnection.prepareStatement(sqlGetNotExpiredFlags);
		random = new Random();
		stringBuilder = new StringBuilder();
	}
	
	public String CreateId()
	{
		return String.format("%s-%s-%s",
			CreateRandomString(Constants.idSymbols, 4),
			CreateRandomString(Constants.idSymbols, 4),
			CreateRandomString(Constants.idSymbols, 4)
		);
	}
	
	public String CreateFlag()
	{
		// ’отим, чтобы у флагов был '=' на конце
		return CreateRandomString(Constants.flagSymbols, Constants.flagLength-1) + "=";
	}
	
	public void InsertFlag(int teamId, int serviceId, String flagId, String flagData)
	{
		try	{
			stInsertFlag.setInt(1, teamId);
			stInsertFlag.setInt(2, serviceId);
			stInsertFlag.setString(3, flagId);
			stInsertFlag.setString(4, flagData);
			stInsertFlag.executeUpdate();
		}
		catch (SQLException e) {
			DatabaseManager.ShowDbException(stInsertFlag, e);
		}
	}
	
	public void InsertDelayedFlag(int teamId, int serviceId, String flagId, String flagData)
	{
		try	{
			stInsertDelayedFlag.setInt(1, teamId);
			stInsertDelayedFlag.setInt(2, serviceId);
			stInsertDelayedFlag.setString(3, flagId);
			stInsertDelayedFlag.setString(4, flagData);
			stInsertDelayedFlag.executeUpdate();
		}
		catch (SQLException e) {
			DatabaseManager.ShowDbException(stInsertDelayedFlag, e);
		}
	}
	
	/*
	 * 	GetDelayedFlag() - возвращает "отложенный" флаг, одновременно удал€€ его
	 * 				из таблицы "отложенных" флагов.
	 */
	
	public IdFlagPair GetDelayedFlag(int teamId, int serviceId)
	{
		IdFlagPair result = null;
		try {
			stGetDelayedFlag.setInt(1, teamId);
			stGetDelayedFlag.setInt(2, serviceId);
			ResultSet rs = stGetDelayedFlag.executeQuery();
			if (rs.next()) {
				result = new IdFlagPair(rs.getString(1), rs.getString(2));
				rs.close();
			}
			stDeleteDelayedFlag.setInt(1, teamId);
			stDeleteDelayedFlag.setInt(2, serviceId);
			stDeleteDelayedFlag.executeUpdate();
		}
		catch (SQLException e) {
			DatabaseManager.ShowDbException(stGetDelayedFlag, e);
		}
		return result;
	}
	
	public boolean InsertStolenFlag(int teamId, StolenFlag stolenFlag) {
		try {
			stInsertStolenFlag.setInt(1, teamId);
			stInsertStolenFlag.setString(2, stolenFlag.getFlagData());
			stInsertStolenFlag.setInt(3, stolenFlag.getOwnerTeamId());
			stInsertStolenFlag.setInt(4, stolenFlag.getServiceId());
			stInsertStolenFlag.executeUpdate();
			return true;
		}
		catch (SQLException e) {
			DatabaseManager.ShowDbException(stInsertStolenFlag, e);
			return false;
		}
	}
	
	public IdFlagPair GetRandomAliveFlag(int teamId, int serviceId)
	{
		try {
			stGetNotExpiredFlags.setInt(1, teamId);
			stGetNotExpiredFlags.setInt(2, serviceId);
			stGetNotExpiredFlags.setInt(3, Constants.flagExpireInterval);
			
			List<IdFlagPair> flags = new LinkedList<IdFlagPair>(); 
			
			ResultSet rs = stGetNotExpiredFlags.executeQuery();
			while (rs.next())
				flags.add(new IdFlagPair(rs.getString(1), rs.getString(2)));
			rs.close();
			
			//System.out.println("GetRandomAliveFlag: " + flags.size() + " flags.");
			
			if (flags.size() == 0)
				return null;
			
			return flags.get(random.nextInt(flags.size()));
		}
		catch (SQLException e) {
			DatabaseManager.ShowDbException(stGetNotExpiredFlags, e);
			return null;
		}
	}
	
	private String CreateRandomString(String charSet, int length)
	{
		stringBuilder.setLength(0);
		for (int i=0; i<length; ++i)
			stringBuilder.append(charSet.charAt(random.nextInt(charSet.length())));
		return stringBuilder.toString();
	}
}
