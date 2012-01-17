package com.erdas.projects.smaad.annotation.md;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.io.StringReader;
import java.io.StringWriter;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import com.erdas.projects.smaad.annotation.tools.NamespaceResolver;
import com.erdas.projects.smaad.annotation.tools.XmlTools;

public class SchematronValidator {

	// Constants
	
	final static String SVRL_NS					= "http://purl.oclc.org/dsdl/svrl";
	final static String SVRL_PREFIX				= "svrl";
	final static String ASSERTION_FAILURE_XPATH	= "/svrl:schematron-output/svrl:failed-assert";
	final static String LOCATION_ATTR			= "location";
	final static String TEXT_TAG				= "text";
	
	// Classes
	
	public static List<ValidationErrorInfo> validateWithSVRL(Source xmlSource, URL schematronUrl) {
    	
        List<ValidationErrorInfo> result = new ArrayList<ValidationErrorInfo>();

        try {
        	
	    	// Create a source from the given shematron
	    	
	        Source xslSource = new StreamSource(schematronUrl.openStream());
	
	        // Prepate XLST transformation
	        
	        TransformerFactory transFact = TransformerFactory.newInstance();
	        Transformer trans = transFact.newTransformer(xslSource);
	        trans.setOutputProperty(OutputKeys.INDENT, "yes");
	        trans.setOutputProperty(OutputKeys.METHOD, "xml");
	
	        // Prepate XLST transform result container (String)
	        
	        StringWriter myWriter = new StringWriter();
	        StreamResult target = new StreamResult(myWriter);
	
	        // Apply the schematron xlst to input document
	        
	        trans.transform(xmlSource, target);
	
	        // Parse the result file
	        
	        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
	        dbf.setNamespaceAware(true);
	        DocumentBuilder builder = dbf.newDocumentBuilder();
	        
	        Document doc = builder.parse(new InputSource(new StringReader(myWriter.getBuffer().toString())));
	        
	        // Retrieve all failed asset message
	        
	        String query = ASSERTION_FAILURE_XPATH;
	
	        XPathFactory factory = XPathFactory.newInstance();
	        XPath xpath = factory.newXPath();
	        NamespaceResolver resolver = new NamespaceResolver();
	        resolver.addNamespace(SVRL_PREFIX, SVRL_NS);
	        xpath.setNamespaceContext(resolver);
	
	        XPathExpression expr = xpath.compile(query);
	        NodeList nodes = (NodeList) expr.evaluate(doc, XPathConstants.NODESET);
	
	        // and put them in a result list
	        
	        String xmlLocation;
	        ValidationErrorInfo ei;
	        String text;
	        Element elt;
	        for (int i = 0; i < nodes.getLength(); i++) {
	        	if (nodes.item(i) instanceof Element) {
	        		elt = (Element)nodes.item(i);
		        	xmlLocation = buildLocation(elt.getAttribute(LOCATION_ATTR));
		        	text = XmlTools.getNodeValue(elt,SVRL_NS, TEXT_TAG);
		        	ei = new ValidationErrorInfo(xmlLocation,text);
		            result.add(ei);
	        	}
	        }
	        
        } catch (TransformerException ex) {
        	result.add(new ValidationErrorInfo("/","Validation error: " +ex.toString()));
		} catch (IOException ex) {
        	result.add(new ValidationErrorInfo("/","Validation error: " +ex.toString()));
		} catch (XPathExpressionException ex) {
        	result.add(new ValidationErrorInfo("/","Validation error: " +ex.toString()));
		} catch (ParserConfigurationException ex) {
        	result.add(new ValidationErrorInfo("/","Validation error: " +ex.toString()));
		} catch (SAXException ex) {
        	result.add(new ValidationErrorInfo("/","Validation error: " +ex.toString()));
		}

        return result;
    }

    /**
     * Write some text into a file.
     * 
     * @param outText
     * @param f
     */
    public static void writeFile(String outText, File f) {
        try {
            //BufferedWriter out = new BufferedWriter(new FileWriter(f));
            PrintWriter out = new java.io.PrintWriter(f, "UTF-8");
            out.print(outText);
            out.flush();
            out.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }




    
    protected static String buildLocation(String xpathLocation) {
    	
    	StringBuilder sb = new StringBuilder("");
    	
    	Pattern pattern = Pattern.compile("(?:local-name\\(\\)='([^']+)')");
    	Matcher matcher = pattern.matcher(xpathLocation);
    	
    	while (matcher.find()) {
    		sb.append("/");
    		sb.append(matcher.group(1));
    	}
    	
    	if (sb.length() == 0) {
    		sb.append("/");
    	}
    	
    	return sb.toString();
    }

}
