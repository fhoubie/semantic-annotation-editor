package com.erdas.projects.smaad.annotation.model;

public class Skos {

	// Constants
	
	public final static String SKOS_NS		= "http://www.w3.org/2004/02/skos/core#";
	
	public final static String RELATED_TAG		= "related";
	public final static String SKOS_RELATED		= buildSkosUrl(RELATED_TAG);
	
	public final static String PREF_LABEL_TAG	= "prefLabel";
	public final static String SKOS_PREF_LABEL	= buildSkosUrl(PREF_LABEL_TAG);
	
	public final static String DEFINITION_TAG	= "definition";
	public final static String SKOS_DEFINITION	= buildSkosUrl(DEFINITION_TAG);

	public final static String EXACT_MATCH_TAG	= "exactMatch";
	public final static String SKOS_EXACT_MATCH	= buildSkosUrl(EXACT_MATCH_TAG);
	
	public final static String BROADER_TAG		= "broader";
	public final static String SKOS_BROADER		= buildSkosUrl(BROADER_TAG);
	
	public final static String NARROWER_TAG		= "narrower";
	public final static String SKOS_NARROWER	= buildSkosUrl(NARROWER_TAG);
	
	public final static String CLOSE_MATCH_TAG	= "closeMatch";
	public final static String SKOS_CLOSE_MATCH	= buildSkosUrl(CLOSE_MATCH_TAG);
	
	// Methods
	
	private static String buildSkosUrl(String tag) {
		return SKOS_NS + tag;
	}
	
}
