package com.erdas.projects.smaad.annotation.md.sensorml;

import java.util.ArrayList;
import java.util.List;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import com.erdas.projects.smaad.annotation.md.BaseMetadataHandler;
import com.erdas.projects.smaad.annotation.md.MetadataHandlerException;
import com.erdas.projects.smaad.annotation.model.Concept;

public class SensorMLHandler extends BaseMetadataHandler {

	// Constants
	
	final static String SENSOR_ML_1_0	= "SENSOR_ML_1.0";
	
	final static String[] SUPPORTED_TYPES	= { SENSOR_ML_1_0 }; 
	
	public final static String SENSOR_ML_MIME_TYPE	= "text/xml";

	// Namespaces
	
	final static String SENSOR_ML_NS	= "http://www.opengis.net/sensorML/1.0.1";
	final static String GML_NS			= "http://www.opengis.net/gml";
	
	final static String SENSOR_ML_NS_PREFIX	= "";
	
	final static String SENSOR_ML_TAG = "SensorML";
	
	final static String MEMBER_TAG			= "member";
	
	// sdm:_Process can be
	
	final static String COMPONENT_TAG		= "Component";
	final static String SYSTEM_TAG			= "System";
	final static String COMPONENT_ARRAY_TAG	= "ComponentArray";
	final static String DATA_SOURCE_TAG		= "DataSource";
	
	// GML (AbstractRestrictedProcessType)
	
	final static String DESCRIPTION_TAG		= "description";
	final static String NAME_TAG			= "name";
	final static String BOUNDED_BY_TAG		= "boundedBy";
	
	//    metadataGroup/generalInfo
	final static String KEYWORDS_TAG		= "keywords";		// [0,n]
	final static String KEYWORD_LIST_TAG	= "KeywordList";	// [0,1]
	final static String KEYWORD_TAG			= "keyword";		// [1,n]
	
	final static String CODESPACE_ATTR		= "codeSpace";

	final static String[] KEYWORDS_PREDECESSORS = {
		BOUNDED_BY_TAG,
		NAME_TAG,
		DESCRIPTION_TAG
	};
	// Classes
	
	class Process {

		// Fields
		
		Document document;
		Element processElement;
		List<Keywords> keywordsElements = new ArrayList<Keywords>();

		// Constructors
		
		public Process(Document document, Element processElement) throws BadSensorMLDocumentException {

			this.document = document;
			this.processElement = processElement;
			
			// Get all "keywords" elements 
			
			NodeList keywordsNl;
			keywordsNl = processElement.getElementsByTagNameNS(SENSOR_ML_NS, KEYWORDS_TAG);
			
			for (int k=0;k<keywordsNl.getLength();k++) {
				
				if (keywordsNl.item(k) instanceof Element) {
					addKeywords((Element)keywordsNl.item(k));
				}
				
			}


		}
		
		// Methods
		
		private void addKeywords(Element keywordsElement) throws BadSensorMLDocumentException {
			
			keywordsElements.add(new Keywords(keywordsElement,document));
			
		}

		public void addConcept(Concept concept) throws BadSensorMLDocumentException {
			
			List<Keywords> matchingKeywords = new ArrayList<Keywords>();
			
			// Get list of all keywords elements that match the concept thesaurus URI (in codeSpace)
			
			for (Keywords kws : keywordsElements) {
				
				if ((concept.getURI() == null && (kws.codeSpace == null || kws.codeSpace.length() == 0)) || // Free keyword 
					(concept.getURI() != null && kws.codeSpace != null && kws.codeSpace.equals(concept.getThesaurus().getUri()))) {
					matchingKeywords.add(kws);
				}
				
			}
			
			// Check if concept is already present
			
			boolean existing = false;
			for (Keywords kws : matchingKeywords) {
				
				if (kws.contains(concept)) {
					existing = true;
					break;
				}
				
			}
			
			if (!existing) {
				
				// Not already present
				
				Keywords container;
				
				// Check if we have a "keywords" element to add it
				
				if (matchingKeywords.size() != 0) {
					
					// Yes, take the first one
					
					container = matchingKeywords.get(0);
					
				} else {
					
					// No, we have to create one
					
					Element keywordsElement, keywordListElement;
					keywordsElement = document.createElementNS(SENSOR_ML_NS, getTag(SENSOR_ML_NS,KEYWORDS_TAG,processElement));
					
					container = new Keywords(keywordsElement,document);
					if (concept.getURI() != null) {
						container.codeSpace = concept.getThesaurus().getUri();
					}
					keywordsElements.add(container);

					// Check where to insert the element
					
					Node pred = findInsertionPoint(processElement, GML_NS, KEYWORDS_PREDECESSORS);
					processElement.insertBefore(keywordsElement, pred);
					
				}
				
				container.addConcept(concept);
				
			}
			
		}
		
	}
	
	class Keywords {
		
		// Fields
		
		Document	doc;
		Element 	element;
		Element 	keywordListElement;
		String		codeSpace;

		// Constructors
		
		public Keywords(Element keywordsElement, Document document) throws BadSensorMLDocumentException {
			
			doc		= document;
			element = keywordsElement;
			
			// Check if the keywordList element already exist
			
			NodeList nl;
			nl = element.getElementsByTagNameNS(SENSOR_ML_NS, KEYWORD_LIST_TAG);
			
			switch (nl.getLength()) {
				
			case 0:
				// KeywordList does not exist yet
				keywordListElement	= null;
				codeSpace			= null;
				break;
			case 1:
				keywordListElement = (Element)nl.item(0);
				
				// Check code space
				
				codeSpace = keywordListElement.getAttribute(CODESPACE_ATTR);
				
				break;
			default:
				// Multiple KeywordList element => this is not authorized
				throw new BadSensorMLDocumentException("A keywords element can only have one keywordList element");
			}
			
		}

		public void addConcept(Concept concept) {
			
			// Check if keywordList already present, if not
			// create it.
			
			if (keywordListElement == null) {
				
				keywordListElement = doc.createElementNS(SENSOR_ML_NS, getTag(SENSOR_ML_NS,KEYWORD_LIST_TAG,element));
				if (concept.getURI() != null) {
					// Non free keyword
					keywordListElement.setAttribute(CODESPACE_ATTR, concept.getThesaurus().getUri());
				}
				element.appendChild(keywordListElement);
				
			}
			
			// Create a new keyword with the concept URI
			
			Element e = doc.createElementNS(SENSOR_ML_NS, getTag(SENSOR_ML_NS,KEYWORD_TAG,keywordListElement));
			if (concept.getURI() == null) {
				// Free keyword
				e.setTextContent(concept.getLabel());
			} else {
				e.setTextContent(concept.getURI());
			}
			keywordListElement.appendChild(e);
			
		}

		public boolean contains(Concept concept) {
			
			boolean contains = false;
			
			if (keywordListElement != null) {
				
				NodeList nl;
				
				nl = keywordListElement.getElementsByTagNameNS(SENSOR_ML_NS, KEYWORD_TAG);
				
				for (int i=0;i<nl.getLength();i++) {
					
					if (nl.item(i) instanceof Element) {
						
						if (concept.getURI() == null) {
							// free keyword
							if (concept.getLabel().equals(nl.item(i).getTextContent())) {
								contains = true;
								break;
							}
						} else {
							if (concept.getURI().equals(nl.item(i).getTextContent())) {
								contains = true;
								break;
							}
						}
						
					}
					
				}
				
			}
			
			return contains;
		}
		
	}
	
	// Methods
	
	public void addConcept(Document doc, List<Concept> conceptList)
			throws MetadataHandlerException {

		// keywords can be in
		// 1. SensorML/(metadaGroup/generalInfo)keywords[0,n]
		// 2. SensorML/member[1,n]/(_Process>AbstractProcessType(>AbstractSMLType)/metadataGroup[0,1]/generalInfo[0,1])keywords[0,n]
		// Only 2. is supported
		
		// Member contains one of
		// _Process can be
		//		ProcessModel
		//		ProcessChain
		//		DataSource
		//		Component
		//		System
		//		ComponentArray
		// DocumentList
		// ContactList
		
		// _Process
		//      (> AbstractSMLType>gml:AbstractFeatureType)
		//      gml:description[0,1]
		//		gml:name[0,1]
		//		gml:boundedBy[0,1]
		//		-------------------
		//		keywords[0,n]

		// keywords/KeywordList[0,1]/keyword[1,n]
		
		NodeList memberNl, processNl;
		Node n;
		Element member, processElement;
		
		// Get all "member" elements (minimum 1)
		
		memberNl = doc.getElementsByTagNameNS(SENSOR_ML_NS, MEMBER_TAG);
		
		if (memberNl.getLength() <= 0) {
			throw new BadSensorMLDocumentException("Could not find any " + MEMBER_TAG + " elements");
		}
		
		// For each member element, get all keywords elements in the process element
		
		Process process;
		List<Process> processList = new ArrayList<Process>();
		for (int i=0;i<memberNl.getLength();i++) {
			
			if (memberNl.item(i) instanceof Element) {
				
				member = (Element)memberNl.item(i);
				
				processNl = member.getChildNodes();
				
				for (int j=0;j<processNl.getLength();j++) {
					
					n = processNl.item(j);
					
					if (n instanceof Element && SENSOR_ML_NS.equals(n.getNamespaceURI()) &&
						(COMPONENT_TAG.equals(n.getLocalName()) || SYSTEM_TAG.equals(n.getLocalName()))) {
					
						processElement = (Element)n;
						
						// Create a Process "element"
						
						process = new Process(doc,processElement);
						
						// Add process to list
						
						processList.add(process);
							
					}
					
				}
				
			}
			
		}
		
		// Now add all keywords to all processes
		
		for (Concept concept: conceptList) {
			for (Process p : processList) {
				
				p.addConcept(concept);
				
			}
		}

	}

	public String[] getSupportedTypes() {
		return SUPPORTED_TYPES;
	}

	public String getType(Document doc) {
		
		String type = null;
		
		Element root = doc.getDocumentElement();
		
		if (SENSOR_ML_NS.equals(root.getNamespaceURI()) &&
				SENSOR_ML_TAG.equals(root.getLocalName())) {
			type = SENSOR_ML_1_0;
		}
		
		return type;
	}

	public String getLanguage(Document doc) {
		// Not supported
		return null;
	}

	public String getMimeType(String type) {
		return SENSOR_ML_MIME_TYPE;
	}

}
