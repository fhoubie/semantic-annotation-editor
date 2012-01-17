package com.erdas.projects.smaad.annotation.model;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collection;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.TransformerFactoryConfigurationError;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.xpath.XPathExpressionException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

public class RdfDocParser {

	// Constants
	
	public final static String RDF_NS	= "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
	
	public final static String RELEVANCE_NS	= "http://a9.com/-/opensearch/extensions/relevance/1.0/";
	public final static String XML_NS		= "http://www.w3.org/XML/1998/namespace";
	
	public final static String RDF_TAG			= "RDF";
	public final static String DESCRIPTION_TAG	= "Description";
	public final static String ABOUT_PARAM		= "about";
	public final static String RESOURCE_PARAM	= "resource";
	public final static String LANG_PARAM		= "lang";

	final static String DEFAULT_LANGUAGE		= "en";
	
	// Fields
	
	Logger logger_;
	
	// Constructors
	
	public RdfDocParser() {
		logger_ = LoggerFactory.getLogger(this.getClass());
	}

	// Methods
	
	
	 public Collection<Concept> parse(InputStream inputStream) throws XPathExpressionException, ParserConfigurationException, SAXException, IOException {
	    return parse(inputStream,DEFAULT_LANGUAGE);
	 }

	public Collection<Concept> parse(InputStream inputStream, String requestLang) throws XPathExpressionException, ParserConfigurationException, SAXException, IOException {
	
		Collection<Concept> results = new ArrayList<Concept>();
		
	    Element root = parseXml(inputStream);
		
		if (logger_.isDebugEnabled()) {
			try {
				ByteArrayOutputStream bos = new ByteArrayOutputStream();
				Transformer transformer;
				
				transformer = TransformerFactory.newInstance().newTransformer();
				transformer.setOutputProperty(OutputKeys.INDENT, "yes");
				DOMSource domSrc = new DOMSource(root);
				transformer.transform(domSrc, new StreamResult(bos));
					
				System.out.println("RDF document:\n" + bos.toString());
			} catch (TransformerConfigurationException e) {
				logger_.debug("Could not print SPARQL response: " + e);
			} catch (TransformerFactoryConfigurationError e) {
				logger_.debug("Could not print SPARQL response: " + e);
			} catch (TransformerException e) {
				logger_.debug("Could not print SPARQL response: " + e);
			}
		}
		
		// Get all rdf:Description and create concepts from them 
	
		NodeList descriptions;
		Element desc, predicateElement;
		String uri;
		String lang;
		String predicate;
		descriptions = root.getElementsByTagNameNS(RDF_NS, DESCRIPTION_TAG);
		
		for (int i=0;i<descriptions.getLength();i++) {
			
			Concept concept;
			String	val;
			
			if (descriptions.item(i) instanceof Element) {
			
				desc = (Element)descriptions.item(i);
				
				// Get URI
				
				uri = desc.getAttributeNS(RDF_NS, ABOUT_PARAM);
				
				if (uri != null) {

					concept = new Concept(uri);
					
					// Get all concept properties
					
					NodeList nl = desc.getChildNodes();
					
					for (int j=0;j<nl.getLength();j++) {
						
						if (nl.item(j) instanceof Element) {
							
							predicateElement	= (Element)nl.item(j);
							predicate			= predicateElement.getLocalName();
							lang				= predicateElement.getAttributeNS(XML_NS, LANG_PARAM);
							
							if (Skos.SKOS_NS.equals(predicateElement.getNamespaceURI())) {
								
								// Skos predicates
								
								if (Skos.RELATED_TAG.equals(predicate)) {
									val = predicateElement.getAttributeNS(RDF_NS, RESOURCE_PARAM);
									if (val != null) {
										concept.addRelatedConcept(new Concept(val));
									} else {
										logger_.warn("Found a " + Skos.RELATED_TAG + " without " + RESOURCE_PARAM + " parameter");
									}
								} else if (Skos.EXACT_MATCH_TAG.equals(predicate)) {
									val = predicateElement.getAttributeNS(RDF_NS, RESOURCE_PARAM);
									if (val != null) {
										concept.addSynonym(new Concept(val));
									} else {
										logger_.warn("Found a " + Skos.EXACT_MATCH_TAG + " without " + RESOURCE_PARAM + " parameter");
									}
								} else if (Skos.CLOSE_MATCH_TAG.equals(predicate)) {
									val = predicateElement.getAttributeNS(RDF_NS, RESOURCE_PARAM);
									if (val != null) {
										concept.addCloseConcept(new Concept(val));
									} else {
										logger_.warn("Found a " + Skos.CLOSE_MATCH_TAG + " without " + RESOURCE_PARAM + " parameter");
									}
								} else if (Skos.NARROWER_TAG.equals(predicate)) {
									val = predicateElement.getAttributeNS(RDF_NS, RESOURCE_PARAM);
									if (val != null) {
										concept.addNarrowerConcept(new Concept(val));
									} else {
										logger_.warn("Found a " + Skos.NARROWER_TAG + " without " + RESOURCE_PARAM + " parameter");
									}
								} else if (Skos.BROADER_TAG.equals(predicate)) {
									val = predicateElement.getAttributeNS(RDF_NS, RESOURCE_PARAM);
									if (val != null) {
										concept.addBroaderConcept(new Concept(val));
									} else {
										logger_.warn("Found a " + Skos.BROADER_TAG + " without " + RESOURCE_PARAM + " parameter");
									}
								} else if (Skos.PREF_LABEL_TAG.equals(predicate)) {
									if (requestLang.equalsIgnoreCase(lang) ||
										((lang==null||lang.length()==0||DEFAULT_LANGUAGE.equalsIgnoreCase(lang)) && concept.getLabel() == null)) {
										concept.setLabel(predicateElement.getTextContent());
									}
									// Keep also all other language versions
									concept.addLabel(predicateElement.getTextContent(), lang);
								} else if (Skos.DEFINITION_TAG.equals(predicate)) {
									if (requestLang.equalsIgnoreCase(lang) ||
										((lang==null||lang.length()==0||DEFAULT_LANGUAGE.equalsIgnoreCase(lang)) && concept.getDescription() == null)) {
										concept.setDescription(predicateElement.getTextContent());
									}
								}
							} else if (Gmet.GMET_NS.equals(predicateElement.getNamespaceURI())) {
							
								// GMET predicates
								
								if (Gmet.THEME_TAG.equals(predicate)) {
									concept.addTheme(new Concept(predicateElement.getTextContent()));
								} else if (Gmet.GROUP_TAG.equals(predicate)) {
									concept.addGroup(new Concept(predicateElement.getTextContent()));
								}
								
							} else  if (Rdfs.RDFS_NS.equals(predicateElement.getNamespaceURI())) {
								
								// RDFS predicates
								
								if (Rdfs.LABEL_TAG.equals(predicate)) {
									if (requestLang.equalsIgnoreCase(lang) ||
										((lang==null||lang.length()==0||DEFAULT_LANGUAGE.equalsIgnoreCase(lang)) && concept.getLabel() == null)) {
										concept.setLabel(predicateElement.getTextContent());
									}
								}
							}
								
						}

					}
					
					
					results.add(concept);
					
				} else {
					
					logger_.warn("Found concept (" + DESCRIPTION_TAG + " element) without URI (" + ABOUT_PARAM + " parameter)");
					
				}
			
			}
			
		}
	
	    return results;
	}

	private Element parseXml(InputStream inputStream) throws ParserConfigurationException, SAXException, IOException {
		
	    // first of all we request out
	    // DOM-implementation:
	    DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
	    factory.setNamespaceAware(true);
	    // then we have to create document-loader:
	    DocumentBuilder loader = factory.newDocumentBuilder();
	
	    // loading a DOM-tree...
	    Document document = loader.parse(inputStream); //"smaad-annotation-core/src/test/resources/sparql-response.xml");
	    // at last, we get a root element:
	    Element tree = document.getDocumentElement();
	
	    return tree;
	
	}

	
}
