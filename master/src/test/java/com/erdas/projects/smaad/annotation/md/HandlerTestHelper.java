package com.erdas.projects.smaad.annotation.md;

import com.erdas.projects.smaad.annotation.md.sensorml.SensorMLHandler;
import com.erdas.projects.smaad.annotation.model.Concept;
import com.erdas.projects.smaad.annotation.model.Thesaurus;
import org.junit.Assert;
import org.w3c.dom.Document;
import org.xml.sax.SAXException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.net.URL;
import java.util.Collections;

/**
 * Created by IntelliJ IDEA.
 * User: fskivee
 * Date: 23-janv.-2012
 * Time: 16:11:25
 * To change this template use File | Settings | File Templates.
 */
public class HandlerTestHelper {

    public static Concept createGEMETInterventionOnLandConcept() {
        return createConcept("intervention on land",
                "http://www.eionet.europa.eu/gemet/concept/78",
                "GEMET","http://www.eionet.europa.eu/gemet/");
    }

    public static Concept createConcept(String conceptName,String conceptURI, String thesaurusName, String thesaurusURI) {
        Concept c = new Concept(conceptURI);
        Thesaurus t = new Thesaurus(thesaurusName,thesaurusURI);
        c.setThesaurus(t);
        c.setLabel(conceptName);

        return c;
    }

    public static Document tagDocument(MetadataHandler handler, String fileName, Concept c) throws ParserConfigurationException, IOException, SAXException, MetadataHandlerException, TransformerException {

        ClassLoader loader = HandlerTestHelper.class.getClassLoader();
        URL resource =loader.getResource(fileName);
        InputStream stream = resource.openConnection().getInputStream();

        Document doc;
        DocumentBuilderFactory docBuilderFactory = DocumentBuilderFactory.newInstance();
        docBuilderFactory.setNamespaceAware(true);
        DocumentBuilder docBuilder = docBuilderFactory.newDocumentBuilder();
        doc = docBuilder.parse(stream);

        handler.addConcept(doc, Collections.singletonList(c));
        //handler.validate(doc,true,false);

        return doc;
    }

    public static void checkConceptInDocument(Document doc, Concept c) throws TransformerException, UnsupportedEncodingException {
        // Use a Transformer for output
        TransformerFactory tFactory =
                TransformerFactory.newInstance();
        Transformer transformer = tFactory.newTransformer();

        DOMSource source = new DOMSource(doc);

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        StreamResult result = new StreamResult(baos);
        transformer.transform(source, result);

        String documentAsString = baos.toString("UTF-8");

        int i = documentAsString.indexOf(c.getURI());

        Assert.assertTrue("The concept "+ c.getURI() + " is not found in the following document: \n" + documentAsString,i > 0);
    }

    public static void displayDocument(Document doc) throws TransformerException {
        // Use a Transformer for output
        TransformerFactory tFactory =
                TransformerFactory.newInstance();
        Transformer transformer = tFactory.newTransformer();

        DOMSource source = new DOMSource(doc);
        StreamResult result = new StreamResult(System.out);
        transformer.transform(source, result);
    }

}
