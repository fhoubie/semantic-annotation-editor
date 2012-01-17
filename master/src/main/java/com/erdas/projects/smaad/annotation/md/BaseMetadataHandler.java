package com.erdas.projects.smaad.annotation.md;

import java.io.IOException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

import javax.xml.XMLConstants;
import javax.xml.transform.dom.DOMSource;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;
import javax.xml.validation.Validator;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.w3c.dom.ls.LSInput;
import org.w3c.dom.ls.LSResourceResolver;
import org.xml.sax.SAXException;

public abstract class BaseMetadataHandler implements MetadataHandler {

	protected class MdValidationResult implements ValidationResult {

		// Fields
		
		boolean success = false;
		List<ValidationErrorInfo> errorList;
		
		// Methods
		
		public boolean isSuccess() {
			return success;
		}

		public List<ValidationErrorInfo> getErrors() {
			return errorList;
		}
		
		public void setSuccess(boolean success) {
			this.success = success;
		}
		
		public void setErrorList(List<ValidationErrorInfo> errorList) {
			this.errorList = errorList;
		}
		
		
	}
	
	protected Element getNextElement(Element parent, String ns, String elementName) {

		Element e = null;
		Node n;
		NodeList nl;
		
		nl = parent.getElementsByTagNameNS(ns, elementName);
		
		if (nl.getLength() > 0) {
			
			// Get last
			
			e = (Element)nl.item(nl.getLength()-1);
			
			n = e.getNextSibling();
			e = null;
			
			// Find first sibling which is an element
			
			while (e == null && n != null) {
				if (n instanceof Element) {
					e = (Element)n;
				}
				n = n.getNextSibling();
			}
			
		}

		return e;
	}
	
	protected Node findInsertionPoint(Element parent, String ns, String[] predecessors) {
		
		Node next = null;
		
		// Find the element the element following one of the given predecessors 
		
		Element pred = null;
		Node n;
		NodeList nl;
		
		// First find a matching element (in the given order)
		
		for (String pname : predecessors) {
			nl = parent.getElementsByTagNameNS(ns, pname);
			if (nl.getLength() > 0) {
				
				// Found, now get last and break the loop
				
				pred = (Element)nl.item(nl.getLength()-1);
				break;
			}
		}
		
		if (pred != null) {

			// Predecessor found, find first sibling which is an element
			
			n = pred.getNextSibling();
			while (next == null && n != null) {
				if (n instanceof Element) {
					next = (Element)n;
				}
				n = n.getNextSibling();
			}
			
		} else {
			
			// Predecessor not found, find first element
			
			nl = parent.getChildNodes();
			for (int i=0;i<nl.getLength();i++) {
				if (nl.item(i) instanceof Element) {
					next = nl.item(i);
					break;
				}
			}
			
		}
		
		return next;
	}


	protected String getTag(String namespace, String tagName, Element parentElement) {
		return getTag(namespace, tagName, parentElement, false);
	}
	
	protected String getTag(String namespace, String tagName, Element parentElement, boolean noPrefixIfSameAsParent) {
		String prefix;
		String tag;
		// Check first if parent element namespace is not requested namespace
		// (only for attributes)
		if (noPrefixIfSameAsParent && namespace.equals(parentElement.getNamespaceURI())) {
			tag = tagName;
		} else {
			prefix = parentElement.lookupPrefix(namespace);
			if (prefix != null) {
				tag = prefix+":"+tagName;
			} else {
				tag = tagName;
			}
		}
		
		return tag;
	}

	/**
	 * Returns the URL of a schematron file that can be used to
	 * validate a Metadata file.
	 * @param doc The document to validate
	 * 
	 * @return The URL of schematron file or <code>null</code>.
	 */
	public URL getSchematronValidationUrl(Document doc) {
		
		// Default implementation, no validation available.
		
		return null;
	}

	public ValidationResult validate(Document doc, boolean xsdValidation, boolean schematronValidation) {
		
		MdValidationResult result = new MdValidationResult();

		// Until now, validation is successful
		
		result.setSuccess(true);
		
		// XML Schema validation
		
		URL xsdUrl = getXsdValidationUrl(doc);
		
		if (xsdValidation && xsdUrl != null) {
			
			SchemaFactory factory = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
			
			try {
				factory.setResourceResolver(new LSResourceResolver() {
					public LSInput resolveResource(String type, String namespaceURI, String publicId,
							String systemId, String baseURI) {
						System.out.println(">> Trying to resolve: " + namespaceURI);
						return null;
					}
				});
				
				Schema schema;
				schema = factory.newSchema(xsdUrl);
				Validator validator = schema.newValidator();
				validator.validate(new DOMSource(doc));
				
			} catch (SAXException ex) {
				// Validation failed
				ex.printStackTrace();
				result.setSuccess(false);
				ValidationErrorInfo info = new ValidationErrorInfo("XML document", "Schema validation error: " + ex.getMessage());
				List<ValidationErrorInfo> errList = new ArrayList<ValidationErrorInfo>();
				errList.add(info);
				result.setErrorList(errList);
			} catch (IOException ex) {
				// Error during validation
				ex.printStackTrace();
				result.setSuccess(false);
				ValidationErrorInfo info = new ValidationErrorInfo("XSD Validation", "Error during schema validation: " + ex.getMessage());
				List<ValidationErrorInfo> errList = new ArrayList<ValidationErrorInfo>();
				errList.add(info);
				result.setErrorList(errList);
			}
		}
		
		// Schematron validation
		
		URL schematronUrl = getSchematronValidationUrl(doc);
		
		if (schematronValidation && schematronUrl != null && result.isSuccess()) {
			
			List<ValidationErrorInfo> errors;
			
			errors = SchematronValidator.validateWithSVRL(new DOMSource(doc), schematronUrl);
			
			if (errors != null && errors.size() != 0) {
				result.setSuccess(false);
				result.setErrorList(errors);
			}
			
		}
		
		return result;
	}

	/**
	 * Get the URL of a XSD document allowing to validate the given
	 * document schema.
	 * 
	 * @param doc The document to validate.
	 * @return The URL of the XSD or <code>null</code> if no schemas
	 *         could be found for the given document.
	 */
	protected URL getXsdValidationUrl(Document doc) {
		
		// Default implementation, no XSD validation
		
		return null;
	}

}
