package com.erdas.projects.smaad.annotation.md.sensorml;

import com.erdas.projects.smaad.annotation.md.MetadataHandlerException;

public class BadSensorMLDocumentException extends MetadataHandlerException {

	/**
	 * Version id.
	 */
	private static final long serialVersionUID = 1L;

	public BadSensorMLDocumentException() {
		// Do nothing
	}

	public BadSensorMLDocumentException(String arg0) {
		super(arg0);
	}

	public BadSensorMLDocumentException(Throwable arg0) {
		super(arg0);
	}

	public BadSensorMLDocumentException(String arg0, Throwable arg1) {
		super(arg0, arg1);
	}

}
