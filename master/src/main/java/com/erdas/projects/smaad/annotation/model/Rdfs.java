package com.erdas.projects.smaad.annotation.model;

public class Rdfs {

	// Constants
	
	public final static String RDFS_NS = "http://www.w3.org/2000/01/rdf-schema#";
	
	public final static String LABEL_TAG	= "label";
	public final static String RDFS_LABEL	= buildRdfsUrl(LABEL_TAG);
	
	// Methods
	
	private static String buildRdfsUrl(String tag) {
		return RDFS_NS + tag;
	}
	
}
