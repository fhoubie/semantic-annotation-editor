package com.erdas.projects.smaad.annotation.tools;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import javax.xml.namespace.NamespaceContext;

public class NamespaceResolver implements NamespaceContext {

	/** prefix => namespace uri */
	Map<String, String>			namespaceMap_	= new HashMap<String, String>();
	/** namespace uri => prefix */
	Map<String, Set<String>>	prefixMap_		= new HashMap<String, Set<String>>();
	
	public String getNamespaceURI(String prefix) {
		return namespaceMap_.get(prefix);
	}

	public String getPrefix(String namespaceURI) {
		String ret = null;
		
		Set<String> s = prefixMap_.get(namespaceURI);
		
		if (s != null && s.size() > 0) {
			ret = s.iterator().next();
		}
		
		return ret;
	}

	public Iterator<String> getPrefixes(String namespaceURI) {
		
		Iterator<String> it = null;
		
		Set<String> s = prefixMap_.get(namespaceURI);
		
		if (s != null) {
			it = s.iterator();
		}
		
		return it;
	}
	
	public void addNamespace(String prefix, String namespaceURI) {
		namespaceMap_.put(prefix,namespaceURI);
		Set<String> s = prefixMap_.get(namespaceURI);
		
		if (s == null) {
			s = new HashSet<String>();
			prefixMap_.put(namespaceURI,s);
		}
		
		s.add(prefix);
		
	}

}
