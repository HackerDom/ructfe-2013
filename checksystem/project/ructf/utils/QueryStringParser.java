package ructf.utils;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class QueryStringParser {

	public static Map<String, List<String>> parse(String url) throws UnsupportedEncodingException{
		Map<String, List<String>> params = new HashMap<String, List<String>>(); 
		String[] urlParts = url.split("\\?"); 
		if (urlParts.length > 1) { 
		    String query = urlParts[1]; 
		    for (String param : query.split("&")) {
		    	//TODO добавить проверок на неправильно сформированный урл
		        String[] pair = param.split("=", 2); 
		        String key = URLDecoder.decode(pair[0], "UTF-8"); 
		        String value = URLDecoder.decode(pair[1], "UTF-8"); 
		        List<String> values = params.get(key); 
		        if (values == null) { 
		            values = new ArrayList<String>(); 
		            params.put(key, values); 
		        } 
		        values.add(value); 
		    } 
		}
		return params;		
	}
}
