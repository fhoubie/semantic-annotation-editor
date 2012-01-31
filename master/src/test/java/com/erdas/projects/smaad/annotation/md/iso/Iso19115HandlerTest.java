package com.erdas.projects.smaad.annotation.md.iso;

import com.erdas.projects.smaad.annotation.md.HandlerTestHelper;
import com.erdas.projects.smaad.annotation.md.MetadataHandler;
import com.erdas.projects.smaad.annotation.md.MetadataHandlerException;
import com.erdas.projects.smaad.annotation.model.Concept;
import org.junit.Test;
import org.w3c.dom.Document;
import org.xml.sax.SAXException;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.TransformerException;
import java.io.IOException;

/**
 * Test adding keywords in ISO19115
 */
public class Iso19115HandlerTest {

    @Test
    public void testTagIso1() throws ParserConfigurationException, IOException, SAXException, MetadataHandlerException, TransformerException {
        tagISO("samples/iso/ISO-Coll_ESA-ERS_ORB_PRC_xS-I-en-formatted.xml");
    }

    @Test
    public void testTagIso2() throws ParserConfigurationException, IOException, SAXException, MetadataHandlerException, TransformerException {
        tagISO("samples/iso/AreasOfOutstandingNaturalBeauty.xml");
    }

    @Test
    public void testTagIso3() throws ParserConfigurationException, IOException, SAXException, MetadataHandlerException, TransformerException {
        tagISO("samples/iso/csw202apIso10_service_WMS_Wasser.xml");
    }

    @Test
    public void testTagIso4() throws ParserConfigurationException, IOException, SAXException, MetadataHandlerException, TransformerException {
        tagISO("samples/iso/IGNF_BDCARTOr_2-5.xml");
    }

    @Test
    public void testTagIso5() throws ParserConfigurationException, IOException, SAXException, MetadataHandlerException, TransformerException {
        tagISO("samples/iso/IGNF_BDORTHOr_2-0.xml");
    }

    @Test
    public void testTagIso6() throws ParserConfigurationException, IOException, SAXException, MetadataHandlerException, TransformerException {
        tagISO("samples/iso/IKO_OSA_GEO_1P.xml");
    }

    @Test
    public void testTagIso7() throws ParserConfigurationException, IOException, SAXException, MetadataHandlerException, TransformerException {
        tagISO("samples/iso/inspire-data-example.xml");
    }


    @Test
    public void testTagIso8() throws ParserConfigurationException, IOException, SAXException, MetadataHandlerException, TransformerException {
        tagISO("samples/iso/ISO-Coll_ESA-ERS_ORB_PRC_xS-I-en-formatted.xml");
    }

    @Test
    public void testTagIso9() throws ParserConfigurationException, IOException, SAXException, MetadataHandlerException, TransformerException {
        tagISO("samples/iso/metadata-9.xml");
    }   

    private void tagISO(String fileName) throws ParserConfigurationException, IOException, SAXException, MetadataHandlerException, TransformerException {
        System.out.println("Test tag file " + fileName);
        Concept concept = HandlerTestHelper.createGEMETInterventionOnLandConcept();
        MetadataHandler handler = new Iso19115Handler();
        Document document = HandlerTestHelper.tagDocument(handler,fileName, concept);
        //handler.validate(document,true,false);
        //HandlerTestHelper.displayDocument(document);
        HandlerTestHelper.checkConceptInDocument(document,concept);
    }

}
