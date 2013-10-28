package ructf.utils;

public class StringUtils {
	
	public static String join(Object[] array, int startIndex, String separator){
		StringBuffer sb = new StringBuffer();
		for (int i=startIndex; i < array.length; i++){
			sb.append(array[i]);
			if (i != array.length - 1)
				sb.append(separator);
		}		
		return sb.toString();
	}
	
	public static String LuteHalfString(String s){
		if (s == null)
			return null;
		
		return s.substring(0, s.length()/2) + "..."; 
	}
}
