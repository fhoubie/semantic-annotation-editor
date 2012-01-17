package com.erdas.projects.smaad.annotation.md;

import java.util.List;

import org.w3c.dom.Document;

import com.erdas.projects.smaad.annotation.model.Concept;


/**
 * Performs various treatment on metadata. Each implementation
 * will handle a specific metadata format.
 * 
 * @author Nicolas
 *
 */
public interface MetadataHandler {

	// Constants
	
	final static String ENGLISH_LANGUAGE_CODE	= "en";
	final static String FRENCH_LANGUAGE_CODE	= "fr";
	
	public interface ValidationResult {
		
		public boolean isSuccess();
		
		public List<ValidationErrorInfo> getErrors();
		
	}
	
	/**
	 * Add concepts to a meta data document.
	 * @param doc The input document (will be modified).
	 * @param conceptList The list of concepts to be added.
	 * @throws MetadataHandlerException 
	 */
	
	public void addConcept(Document doc, List<Concept> conceptList) throws MetadataHandlerException;

	/**
	 * Returns all the metadata types supported by this handler.
	 * 
	 * @return Supported metadata types.
	 */
	public String[] getSupportedTypes();

	/**
	 * Returns the types of the document if this handler can
	 * determine it.
	 * 
	 * @param doc The metadata document.
	 * 
	 * @return The metadata document type or <code>null</code>.
	 */
	public String getType(Document doc);

	/**
	 * Returns the language of the document if it can be retrieve.
	 * @param doc The metadata document.
	 * @return The language of the metadata document or <code>null</code>
	 *         if it cannot be determined.
	 */
	public String getLanguage(Document doc);

	/**
	 * Returns the MIME type for the given document type.
	 * 
	 * @param type The document type.
	 * @return The corresponding MIME type or <code>null</code> if unknown.
	 */
	public String getMimeType(String type);

	/**
	 * Validate a metadata document.
	 * @param xsdValidation indicates if the XSD validation should be performed 
	 * @param schematronValidation indicates if the schematron validation should be performed
	 * 
	 * @return A ValidationResult object indicating how the 
	 * validation performed.
	 */
	public ValidationResult validate(Document doc, boolean xsdValidation, boolean schematronValidation);
}
