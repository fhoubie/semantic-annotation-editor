package com.erdas.projects.smaad.annotation.service;

import org.w3c.dom.Document;

import com.erdas.projects.smaad.annotation.md.MetadataHandler.ValidationResult;
import com.google.gson.annotations.Expose;

class MetaDataInfo {
	
	// Constants
	
	public enum Status { WAITING, READY, ERROR };
	
	// Fields
	
	Document			document_;
	@Expose
	String				name;
	@Expose
	String				type;
	@Expose
	String				errorMessage;
	@Expose
	String				errorUrl;
	@Expose
	Status				status = Status.WAITING;
	@Expose
	String				documentLanguage;
	String				mimeType_;
	ValidationResult	validationResult_;

	// Constructors
	
	public MetaDataInfo(String name) {
		this.name	= name;
	}
	public MetaDataInfo(String name, Document document) {
		document_	= document;
		this.name	= name;
	}
	
	// Methods

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getErrorMessage() {
		return errorMessage;
	}

	public void setErrorMessage(String errorMessage) {
		this.errorMessage	= errorMessage;
		status				= Status.ERROR;
	}

	public Document getDocument() {
		return document_;
	}

	public String getName() {
		return name;
	}

	public void setStatus(Status status) {
		this.status = status;
	}

	public void setDocument(Document document) {
		document_ = document;
	}
	public String getDocumentLanguage() {
		return documentLanguage;
	}
	public void setDocumentLanguage(String documentLanguage) {
		this.documentLanguage = documentLanguage;
	}
	public String getMimeType() {
		return mimeType_;
	}
	public void setMimeType(String mimeType) {
		mimeType_ = mimeType;
	}
	public Status getStatus() {
		return status;
	}
	public void setValidationResult(ValidationResult validationResult) {
		validationResult_ = validationResult;		
	}
	public ValidationResult getValidationResult() {
		return validationResult_;
	}
	public void setErrorUrl(String errorUrl) {
		this.errorUrl = errorUrl;
	}
	
}