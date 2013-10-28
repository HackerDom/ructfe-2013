package ructf.getflags;

import java.net.InetAddress;

public class UnknownAddressException extends Exception
{
	private static final long serialVersionUID = 8818398228389666224L;
	private InetAddress addr;

	public UnknownAddressException(InetAddress addr)
	{
		this.addr = addr;
	}
	
	public String getAddress()
	{
		return addr.getHostAddress();
	}
}
