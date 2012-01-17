package com.erdas.projects.smaad.annotation.model;

import java.util.ArrayList;
import java.util.List;

import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import com.erdas.projects.smaad.annotation.tools.NamespaceResolver;

public class VoidDoc {

	// Constants
	
	final static String VOID_NS			= "http://rdfs.org/ns/void#";
	final static String RDF_NS			= "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
	final static String DC_TERMS_NS		= "http://purl.org/dc/terms/";
	
	final static String VOID_NS_PREFIX	= "void";
	final static String RDF_NS_PREFIX	= "rdf";
	final static String DC_TERMS_NS_PREFIX = "dcterms";
	
	final static String RDF_TAG			= "RDF";
	final static String DATASET_TAG		= "Dataset";
	final static String OPEN_SEARCH_DESCRIPTION_TAG	= "openSearchDescription";
	final static String SPARQL_ENDPOINT_TAG			= "sparqlEndpoint";
	final static String URI_SPACE_TAG				= "uriSpace";
	final static String URI_REG_EXP_TAG				= "uriRegexPattern";
	final static String URI_LOOK_UP_END_POINT_TAG	= "uriLookupEndpoint";
	final static String DESCRIPTION_TAG				= "description";
	final static String TITLE_TAG					= "title";
	final static String DATA_DUMP_TAG				= "dataDump";
	
	final static String ABOUT_PARAM					= "about";
	final static String RESOURCE_PARAM				= "resource";
	
	final static String DATA_SET_XPATH	= RDF_NS_PREFIX + ":" + RDF_TAG + "/" + 
										  VOID_NS_PREFIX + ":" + DATASET_TAG;
	
	// Fields
	
	static Logger logger_ = LoggerFactory.getLogger(VoidDoc.class);
	
	List<Dataset> dataSets = new ArrayList<VoidDoc.Dataset>();
	

	// Classes
	
	public static class Dataset {
		
		public void setUri(String uri) {
			this.uri = uri;
		}

		public void setTitle(String title) {
			this.title = title;
			if (this.description == null) {
				this.description = title;
			}
		}

		public void setDescription(String description) {
			this.description = description;
			if (this.title == null) {
				this.title = description;
			}
		}

		public void setSparqlUrl(String sparqlUrl) {
			this.sparqlUrl = sparqlUrl;
		}

		public void setOpenSearchUrl(String openSearchUrl) {
			this.openSearchUrl = openSearchUrl;
		}

		public void setUriLookupUrl(String uriLookupUrl) {
			this.uriLookupUrl = uriLookupUrl;
		}

		public void setUriSpace(String uriSpace) {
			this.uriSpace = uriSpace;
		}

		public void setUriRegexpPattern(String uriRegexpPattern) {
			this.uriRegexpPattern = uriRegexpPattern;
		}

		String uri;
		String title;
		String description;
		String sparqlUrl;
		String openSearchUrl;
		String uriLookupUrl;
		String uriSpace;
		String uriRegexpPattern;
		List<String> dataDumps = new ArrayList<String>();
		
		@Override
		public String toString() {

			StringBuilder sb = new StringBuilder();

			sb.append(uri);
			sb.append("\n - title: ");
			sb.append(title);
			sb.append("\n - description: ");
			sb.append(description);
			sb.append("\n - sparqlUrl: ");
			sb.append(sparqlUrl);
			sb.append("\n - openSearchUrl: ");
			sb.append(openSearchUrl);
			sb.append("\n - uriLookupUrl: ");
			sb.append(uriLookupUrl);
			sb.append("\n - uriSpace: ");
			sb.append(uriSpace);
			sb.append("\n - uriRegexpPattern: ");
			sb.append(uriRegexpPattern);
			sb.append("\n - dataDumps: ");
			sb.append(dataDumps);
			
			return sb.toString();
		}

		public String getUri() {
			return uri;
		}

		public String getTitle() {
			return title;
		}

		public String getDescription() {
			return description;
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

		public String getUriSpace() {
			return uriSpace;
		}

		public String getUriRegexpPattern() {
			return uriRegexpPattern;
		}

		public List<String> getDataDumps() {
			return dataDumps;
		}

		public void adddataDump(String uri) {
			
			dataDumps.add(uri);
			
		}
		
		
	}
	
	// Constructors
	
	// Methods
	
	public static VoidDoc parse(Document doc) throws Exception {
		
		VoidDoc v = new VoidDoc();
		
		NamespaceResolver resolver = new NamespaceResolver();
		resolver.addNamespace(VOID_NS_PREFIX, VOID_NS);
		resolver.addNamespace(RDF_NS_PREFIX, RDF_NS);
		resolver.addNamespace(DC_TERMS_NS_PREFIX, DC_TERMS_NS);
		
		// Get all Dataset
		
        XPathFactory factory = XPathFactory.newInstance();
        XPath xpath = factory.newXPath();
        xpath.setNamespaceContext(resolver);
        
        XPathExpression expression;
		try {
			expression = xpath.compile(DATA_SET_XPATH);

	        Object result = expression.evaluate(doc, XPathConstants.NODESET);
	        NodeList nodes = (NodeList) result;
	        
	        for (int i=0;i<nodes.getLength();i++) {
	        	Node n = nodes.item(i);
	        	if (n instanceof Element) {
	        		Dataset ds = parseDataset((Element)n);
	        		v.dataSets.add(ds);
	        	}
	        }
		} catch (XPathExpressionException ex) {
			throw new Exception("Could not parse VOID document",ex);
		}

		return v;
		
	}

	private static Dataset parseDataset(Element dataset) {
		
		Dataset d = new Dataset();
		
		// Get data set URI
		
		d.uri = dataset.getAttributeNS(RDF_NS, ABOUT_PARAM);
		
		// Get data set properties
		
		NodeList nl = dataset.getChildNodes();
		
		Node n;
		Element e;
		String name;
		String namespace;
		for (int i=0;i<nl.getLength();i++) {
			
			n  = nl.item(i);
			
			namespace = n.getNamespaceURI();
			name = n.getLocalName();
			
			if (n instanceof Element) {
				e = (Element)n;
				if (VOID_NS.equals(namespace)) {
					
					if (OPEN_SEARCH_DESCRIPTION_TAG.equals(name)) {					
						d.setOpenSearchUrl(e.getAttributeNS(RDF_NS, RESOURCE_PARAM));
					} else if (URI_LOOK_UP_END_POINT_TAG.equals(name)) {
						d.setUriLookupUrl(e.getAttributeNS(RDF_NS, RESOURCE_PARAM));
					} else if (SPARQL_ENDPOINT_TAG.equals(name)) {
						d.setSparqlUrl(e.getAttributeNS(RDF_NS, RESOURCE_PARAM));
					} else if (DATA_DUMP_TAG.equals(name)) {
						d.adddataDump(e.getAttributeNS(RDF_NS, RESOURCE_PARAM));
					} else if (URI_SPACE_TAG.equals(name)) {
						d.setUriSpace(n.getTextContent());
					} else if (URI_REG_EXP_TAG.equals(name)) {
						d.setUriRegexpPattern(n.getTextContent());
					}
					
				} else if (DC_TERMS_NS.equals(namespace)) {
					
					if (TITLE_TAG.equals(name)) {
						d.setTitle(n.getTextContent());
					} else if (DESCRIPTION_TAG.equals(name)) {
						d.setDescription(n.getTextContent());
					}
					
				}
			}
			
		}
		
		return d;
	}
	
	@Override
	public String toString() {
		
		StringBuilder sb = new StringBuilder();
		
		sb.append("Void content:\n");
		for (Dataset ds : dataSets) {
			sb.append(ds);
			sb.append("\n");
		}
		
		return sb.toString();
	}

	public List<Dataset> getDataSets() {
		return dataSets;
	}
	
}
