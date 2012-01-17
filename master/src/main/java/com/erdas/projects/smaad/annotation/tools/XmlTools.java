package com.erdas.projects.smaad.annotation.tools;

import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

/**
Static class to get NodeValue

*/

public class XmlTools {

	public static String getNodeValue(Element parent, String ns, String tag) {
		
		String ret = null;
		
		NodeList nl;
		nl = parent.getElementsByTagNameNS(ns, tag);

		if(nl.getLength() > 0) {
			ret = nl.item(0).getTextContent();
		}
		
		return ret;
	}
	
}
