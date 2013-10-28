package ructf.main;

public enum CheckerExitCode
{
	OK, UpNoFlag, Corrupted, Down, CheckerError;

	public static boolean isUnknown(int code)
	{
		return code<101 || code>104 && code != 110;  
	}

	public static CheckerExitCode fromInt(int code)
	{
		switch (code) {
			case 101: return OK;
			case 102: return UpNoFlag;
			case 103: return Corrupted;
			case 104: return Down;
			case 110: return CheckerError;
		default:
			throw new IndexOutOfBoundsException();
		}
	}
	
	public int toInt()
	{
		switch (this) {
			case OK: return 101;
			case UpNoFlag: return 102;
			case Corrupted: return 103;
			case Down: return 104;
			case CheckerError: return 110;
			default:
				throw new IndexOutOfBoundsException();
		}
	}	
}
