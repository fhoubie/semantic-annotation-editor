package com.erdas.projects.smaad.annotation.md.ogc;

import com.erdas.projects.smaad.annotation.md.MetadataHandlerException;

public class BadOgcDocumentException extends MetadataHandlerException {

	/**
	 * Version id.
	 */
	private static final long serialVersionUID = 1L;

	public BadOgcDocumentException() {
		// Do nothing
	}

	public BadOgcDocumentException(String arg0) {
		super(arg0);
	}

	public BadOgcDocumentException(Throwable arg0) {
		super(arg0);
	}

	public BadOgcDocumentException(String arg0, Throwable arg1) {
		super(arg0, arg1);
	}

}
