package com.erdas.projects.smaad.annotation.model;

public class SearchResults {

	// Fields
	
	int totalResults;
	
	//Query query;
	
	//Concept[] searchResults;
	
	// Classes
	
	public static class Query {
		
		String searchTerm;
		String language;
		int maxResults;
		int startIndex;
		
	}
	
	// Methods
	
	public int getTotalResults() {
		return totalResults;
	}
	
//	public Query getQuery() {
//		return query;
//	}
//	
//	public Concept[] getSearchResults() {
//		return searchResults;
//	}
	
}
