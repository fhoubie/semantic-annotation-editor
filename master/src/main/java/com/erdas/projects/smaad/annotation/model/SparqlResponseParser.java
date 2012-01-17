package com.erdas.projects.smaad.annotation.model;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.Map;

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
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;


/**
 * Created by IntelliJ IDEA.
 * User: fskivee
 * Date: 30-déc.-2010
 * Time: 13:42:50
 * To change this template use File | Settings | File Templates.
 */
public class SparqlResponseParser {

	// Constants
	
	final static String DEFAULT_LANGUAGE	= "en";
	
	// Fields
	
	Logger logger_ = null;
	
	// Constructors
	
	public SparqlResponseParser() {
		logger_ = LoggerFactory.getLogger(this.getClass());
	}
	
	// Methods
	

     public Collection<Concept> parse(InputStream inputStream) throws XPathExpressionException, ParserConfigurationException, SAXException, IOException {
        return parse(inputStream,DEFAULT_LANGUAGE);
     }

    public Collection<Concept> parse(InputStream inputStream, String lang) throws XPathExpressionException, ParserConfigurationException, SAXException, IOException {
        String xpathQuery = "/*[name()='sparql']/*[name()='results']/*[name()='result'][*]"; // /*[name()='binding'][@name='conceptLabel']/*[name()='literal']/text()";

        Element element = parseXml(inputStream);
		
		if (logger_.isDebugEnabled()) {
			try {
				ByteArrayOutputStream bos = new ByteArrayOutputStream();
				Transformer transformer;
				
				transformer = TransformerFactory.newInstance().newTransformer();
				transformer.setOutputProperty(OutputKeys.INDENT, "yes");
				DOMSource domSrc = new DOMSource(element);
				transformer.transform(domSrc, new StreamResult(bos));
					
				System.out.println("SPARQL response:\n" + bos.toString());
			} catch (TransformerConfigurationException e) {
				logger_.debug("Could not print SPARQL response: " + e);
			} catch (TransformerFactoryConfigurationError e) {
				logger_.debug("Could not print SPARQL response: " + e);
			} catch (TransformerException e) {
				logger_.debug("Could not print SPARQL response: " + e);
			}
		}
		

        XPathFactory factory = XPathFactory.newInstance();
        XPath xpath = factory.newXPath();
        
        XPathExpression expression = xpath.compile(xpathQuery);

        Object result = expression.evaluate(element, XPathConstants.NODESET);
        NodeList nodes = (NodeList) result;

        Collection<Concept> results = parseNodes(nodes, lang);

        return results;
    }


    private Collection<Concept> parseNodes(NodeList resultNodeList, String lang) {

        Concept concept;
        String	uri;
        Element	value;
        String	predicate;
        Map<String, Concept> conceptMap = new LinkedHashMap<String, Concept>();
        
        // Parse all result nodes
        
        for(int index = 0; index < resultNodeList.getLength(); index ++){
        	
        	value		= null;
        	predicate	= null;

            Node resultNode = resultNodeList.item(index);
            
            if (resultNode.getNodeType() == Node.ELEMENT_NODE){
            	
                NodeList resultNodeChildren = resultNode.getChildNodes();

                // First get concept ID (URI)

                uri = getUri(resultNodeChildren);
                
                if (uri == null) {
                	
                	// Could not find the URI, log warning and go to next result
                	
                	logger_.warn("Could not find concept URI for result " + (index+1));
                	
                	continue;
                }

                
                // Check if concept already created, if not create it
                
                concept = conceptMap.get(uri);
                if (concept == null) {
                	concept = new Concept();
                	concept.setURI(uri);
                	conceptMap.put(uri,concept);
                }
                
                // Then get all other bindings

                for(int resultNodeChildrenIdx = 0; resultNodeChildrenIdx < resultNodeChildren.getLength(); resultNodeChildrenIdx ++) {
                    Node bindingNode = resultNodeChildren.item(resultNodeChildrenIdx);
                    if (bindingNode.getNodeName().equals("binding")) {
                    	
                        NamedNodeMap bindingNodeAttribute = bindingNode.getAttributes();
                        Node nameAttribute = bindingNodeAttribute.getNamedItem("name");
                        String nameValue = nameAttribute.getNodeValue();

                        if (nameValue.equals("label")) {
                            // add label
                            NodeList childNodes1 = bindingNode.getChildNodes();
                            for(int index1 = 0; index1 < childNodes1.getLength(); index1 ++){
                                Node childNode = childNodes1.item(index1);
                                if (childNode.getNodeName().equals("literal")) {
                                    String label = childNode.getFirstChild().getNodeValue();
                                    //System.out.println("Label " + label);
                                    concept.setLabel(label);
                                }
                            }
                        } else if (nameValue.equals("definition")) {
                            // add definition
                            NodeList childNodes1 = bindingNode.getChildNodes();
                            for(int index1 = 0; index1 < childNodes1.getLength(); index1 ++){
                                Node childNode = childNodes1.item(index1);
                                if (childNode.getNodeName().equals("literal")) {
                                    String description = childNode.getFirstChild().getNodeValue();
                                    //System.out.println("Description " + childNode.getFirstChild().getNodeValue());
                                    concept.setDescription(description);
                                }
                            }
                        } else if (nameValue.equals("predicate")) {
                        	predicate = getUri(bindingNode);
                        	setPredicate(concept, predicate, value, lang);
                        } else if (nameValue.equals("value") || nameValue.equals("object")) {
                        	value = getFirstElement(bindingNode);
                        	setPredicate(concept, predicate, value, lang);
                        }
                    }
                }

            }
        }
        
        return conceptMap.values();
    }

	private Element getFirstElement(Node bindingNode) {
		
		Element elt = null;
		
		NodeList childNodes = bindingNode.getChildNodes();
		for(int i = 0; i < childNodes.getLength(); i ++){
		    Node childNode = childNodes.item(i);
		    if (childNode instanceof Element) {
		    	elt = (Element)childNode;
		    	break;
		    }
		}
		return elt;
	}

	private void setPredicate(Concept concept, String predicate,
			Element valueElement, String requestLang) {

		if (predicate != null && valueElement != null) {
			
			String lang;
			
			// Get language
			
			lang = valueElement.getAttribute("xml:lang");
			
			if (Skos.SKOS_RELATED.equals(predicate)) {
				concept.addRelatedConcept(new Concept(valueElement.getTextContent()));
			} else if (Skos.SKOS_EXACT_MATCH.equals(predicate)) {
				concept.addSynonym(new Concept(valueElement.getTextContent()));
			} else if (Skos.SKOS_CLOSE_MATCH.equals(predicate)) {
				concept.addCloseConcept(new Concept(valueElement.getTextContent()));
			} else if (Skos.SKOS_NARROWER.equals(predicate)) {
				concept.addNarrowerConcept(new Concept(valueElement.getTextContent()));
			} else if (Skos.SKOS_BROADER.equals(predicate)) {
				concept.addBroaderConcept(new Concept(valueElement.getTextContent()));
			} else if (Gmet.GMET_THEME.equals(predicate)) {
				concept.addTheme(new Concept(valueElement.getTextContent()));
			} else if (Gmet.GMET_GROUP.equals(predicate)) {
				concept.addGroup(new Concept(valueElement.getTextContent()));
			} else if (Rdfs.RDFS_LABEL.equals(predicate)) {
				if (requestLang.equalsIgnoreCase(lang) ||
					((lang==null||lang.length()==0||DEFAULT_LANGUAGE.equalsIgnoreCase(lang)) && concept.getLabel() == null)) {
					concept.setLabel(valueElement.getTextContent());
				}
			} else if (Skos.SKOS_PREF_LABEL.equals(predicate)) {
				if (requestLang.equalsIgnoreCase(lang) ||
					((lang==null||lang.length()==0||DEFAULT_LANGUAGE.equalsIgnoreCase(lang)) && concept.getLabel() == null)) {
					concept.setLabel(valueElement.getTextContent());
				}
				// Keep also all other language versions
				concept.addLabel(valueElement.getTextContent(), lang);
			} else if (Skos.SKOS_DEFINITION.equals(predicate)) {
				if (requestLang.equalsIgnoreCase(lang) ||
					((lang==null||lang.length()==0||DEFAULT_LANGUAGE.equalsIgnoreCase(lang)) && concept.getDescription() == null)) {
					concept.setDescription(valueElement.getTextContent());
				}
			}
			
		}
		
		
	}

	private String getUri(NodeList childrenNodeList) {
		
		String uri = null;
		
		for(int resultNodeChildrenIdx = 0; resultNodeChildrenIdx < childrenNodeList.getLength(); resultNodeChildrenIdx ++) {
		    Node bindingNode = childrenNodeList.item(resultNodeChildrenIdx);
		    if (bindingNode.getNodeName().equals("binding")) {
		        NamedNodeMap bindingNodeAttribute = bindingNode.getAttributes();
		        Node nameAttribute = bindingNodeAttribute.getNamedItem("name");
		        String nameValue = nameAttribute.getNodeValue();
		        if (nameValue.equals("id") || nameValue.equals("subject")) {
		            uri = getUri(bindingNode);
		            // We have found the Id, break the loop
		            break;
		        }                    	
		    }
		}
		return uri;
	}

	private String getUri(Node bindingNode) {
		
		String uri = null;
		
		NodeList childNodes1 = bindingNode.getChildNodes();
		for(int index1 = 0; index1 < childNodes1.getLength(); index1 ++){
		    Node childNode = childNodes1.item(index1);
		    if (childNode.getNodeName().equals("uri")) {
		        uri = childNode.getFirstChild().getNodeValue();
		    }
		}
		return uri;
	}

    private Element parseXml(InputStream inputStream) throws ParserConfigurationException, SAXException, IOException {
    	
        // first of all we request out
        // DOM-implementation:
        DocumentBuilderFactory factory =
                DocumentBuilderFactory.newInstance();
        // then we have to create document-loader:
        DocumentBuilder loader = factory.newDocumentBuilder();

        // loading a DOM-tree...
        Document document = loader.parse(inputStream); //"smaad-annotation-core/src/test/resources/sparql-response.xml");
        // at last, we get a root element:
        Element tree = document.getDocumentElement();

        return tree;

    }

}
