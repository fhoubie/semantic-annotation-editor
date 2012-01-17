package com.erdas.projects.smaad.annotation.model;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.erdas.projects.smaad.annotation.model.VoidDoc.Dataset;
import com.google.gson.annotations.Expose;

public class Thesaurus {
	
	// Fields
	
	@Expose
	String 	name;
	@Expose
	String 	URI;
	@Expose
	String	displayName;
	String 	matchString		= null;
	String	sparqlUrl		= null;
	String	openSearchUrl	= null;
	String	jsonSearchUrl	= null;
	String	rdfSearchUrl	= null;
	String	uriLookupUrl	= null;
	Pattern	matchPattern	= null;
	
	// Constructors
	
	public Thesaurus(String name, String uri) {
		this.URI			= uri;
		setName(name);
	}

	// Methods
	
	public Thesaurus(Dataset ds) {
		
		URI				= ds.getUri();
		setName(ds.getDescription());
		setDisplayName(ds.getTitle());
		sparqlUrl		= ds.getSparqlUrl();
		openSearchUrl	= ds.getOpenSearchUrl();
		uriLookupUrl	= ds.getUriLookupUrl();
		if (ds.getUriRegexpPattern() != null) {
			setMatchString(ds.getUriRegexpPattern());
		} else if (ds.getUriSpace() != null) {
			setMatchString("^"+ds.getUriSpace()+".*");
		}
		
	}

	public void setName(String name) {

		this.name = name;
		if (displayName == null) {
			displayName = name;
		}
		
	}

	public String getName() {
		return name;
	}

	public String getUri() {
		return URI;
	}

	public void setMatchString(String matchString) {
		this.matchString = matchString;
		matchPattern = Pattern.compile(matchString);
	}
	
	public boolean matches(String thesaurusName) {
		
		boolean ret = false;
		
		if (matchPattern != null) {
			Matcher matcher = matchPattern.matcher(thesaurusName);
			ret = matcher.matches();
		}
		
		return ret;
		
	}

	public String getDisplayName() {
		return displayName;
	}

	public void setDisplayName(String displayName) {
		this.displayName = displayName;
		if (name == null) {
			name = displayName;
		}
	}

	public String getJsonSearchUrl() {
		return jsonSearchUrl;
	}

	public String getRdfSearchUrl() {
		return rdfSearchUrl;
	}

	public void setJsonSearchUrl(String searchUrl) {
		this.jsonSearchUrl = searchUrl;
	}

	public void setRdfSearchUrl(String searchUrl) {
		this.rdfSearchUrl = searchUrl;
	}

	public String getSparqlUrl() {
		return sparqlUrl;
	}

	public String getOpenSearchUrl() {
		return openSearchUrl;
	}

	public String getUriLookupUrl() {
		return uriLookupUrl;
	}
	
}