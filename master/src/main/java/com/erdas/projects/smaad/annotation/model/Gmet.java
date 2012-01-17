package com.erdas.projects.smaad.annotation.model;

public class Gmet {

	// Constants
	
	public final static String GMET_NS			= "http://www.eionet.europa.eu/gemet/2004/06/gemet-schema.rdf#";	
	
	public final static String THEME_TAG		= "theme";
	public final static String GMET_THEME		= buildGmetUrl(THEME_TAG);
	
	public final static String GROUP_TAG		= "group";
	public final static String GMET_GROUP		= buildGmetUrl(GROUP_TAG);
	
	// Methods
	
	private static String buildGmetUrl(String tag) {
		return GMET_NS + tag;
	}
	

}
