package ructf.daemon;

import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.HashMap;
import java.util.Scanner;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.apache.log4j.Logger;
import org.w3c.dom.Document;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import sun.misc.IOUtils;

public class ServiceIds {
	
	public static HashMap<String, Integer> serviceIds = new HashMap<String, Integer>();
	
	public static void LoadFromUrl(String xmlServicesUrl) throws Exception{
		URL url = new URL(xmlServicesUrl);
		HttpURLConnection connection = (HttpURLConnection) url.openConnection();
		connection.connect();
		
		InputStream inputStream = connection.getInputStream();		
		try{
			DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
		    DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
		    Document doc = dBuilder.parse(inputStream);//new File("E:\\Documents\\диплом\\svn\\trunk\\project\\history-out\\services.xml"));
		    
		    NodeList serviceNodes = doc.getElementsByTagName("service");
		    for (int i=0; i < serviceNodes.getLength(); i++) {
				Node serviceNode = serviceNodes.item(i);
				NamedNodeMap attributes = serviceNode.getAttributes();
				if (attributes == null || attributes.getLength() == 0){
					logger.warn("Malformed XML. Found 'service' element with no attributes");
					continue;
				}
				
				Node namedItem = attributes.getNamedItem("id");
				int id = Integer.parseInt(namedItem.getTextContent());				
				
				namedItem = attributes.getNamedItem("name");
				String name = namedItem.getTextContent();

				serviceIds.put(name, id);				
			}
		    
		}
		finally{
			inputStream.close();
		}		
	}
	
	private static Logger logger = Logger.getLogger("ructf.daemon");
}
