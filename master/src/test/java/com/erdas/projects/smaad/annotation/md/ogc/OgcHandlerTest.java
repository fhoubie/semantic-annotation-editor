package com.erdas.projects.smaad.annotation.md.ogc;

import com.erdas.projects.smaad.annotation.md.HandlerTestHelper;
import com.erdas.projects.smaad.annotation.md.MetadataHandler;
import com.erdas.projects.smaad.annotation.md.MetadataHandlerException;
import com.erdas.projects.smaad.annotation.md.iso.Iso19115Handler;
import com.erdas.projects.smaad.annotation.model.Concept;
import org.junit.Ignore;
import org.junit.Test;
import org.w3c.dom.Document;
import org.xml.sax.SAXException;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.TransformerException;
import java.io.IOException;

/**
 * Test adding keywords in OGC Capabilities
 */
public class OgcHandlerTest {

    @Test
    public void testTagOgc1() throws ParserConfigurationException, IOException, SAXException, MetadataHandlerException, TransformerException {
        tagOGC("samples/ogc/wmc.xml");
    }

    @Test
    public void testTagOgc2() throws ParserConfigurationException, IOException, SAXException, MetadataHandlerException, TransformerException {
        tagOGC("samples/ogc/wcs-cap-1.1.1.xml");
    }

    @Test
    public void testTagOgc3() throws ParserConfigurationException, IOException, SAXException, MetadataHandlerException, TransformerException {
        tagOGC("samples/ogc/WCS-100-Capabilities4ERDAS.xml");
    }

    @Test
    public void testTagOgc4() throws ParserConfigurationException, IOException, SAXException, MetadataHandlerException, TransformerException {
        tagOGC("samples/ogc/WCS-200-Capabilities4ERDAS.xml");
    }

    @Test
    public void testTagOgc5() throws ParserConfigurationException, IOException, SAXException, MetadataHandlerException, TransformerException {
        tagOGC("samples/ogc/WMS-130Capabilities4ERDAS.xml");
    }

    @Test
    @Ignore
    public void testTagOgc6() throws ParserConfigurationException, IOException, SAXException, MetadataHandlerException, TransformerException {
        tagOGC("samples/ogc/wms-cap.xml");
    }

    private void tagOGC(String fileName) throws ParserConfigurationException, IOException, SAXException, MetadataHandlerException, TransformerException {
        System.out.println("Test tag file " + fileName);
        Concept concept = HandlerTestHelper.createGEMETInterventionOnLandConcept();
        MetadataHandler handler = new OgcHandler();
        Document document = HandlerTestHelper.tagDocument(handler,fileName, concept);
        //handler.validate(document,true,false);
        HandlerTestHelper.displayDocument(document);
        HandlerTestHelper.checkConceptInDocument(document,concept);
    }

}
