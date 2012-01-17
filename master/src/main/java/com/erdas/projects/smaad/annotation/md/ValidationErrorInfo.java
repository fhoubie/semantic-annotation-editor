package com.erdas.projects.smaad.annotation.md;

public class ValidationErrorInfo {
	
	// Fields
	
	String error;
	String location;
	
	// Constructors
	
	public ValidationErrorInfo(String location, String error) {
		this.error		= error;
		this.location	= location;
	}
	
	// Methods
	
	public String getError() {
		return error;
	}
	
	public String getLocation() {
		return location;
	}
	
}