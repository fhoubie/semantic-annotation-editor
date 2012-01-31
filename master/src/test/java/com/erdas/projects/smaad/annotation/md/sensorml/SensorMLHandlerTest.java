package com.erdas.projects.smaad.annotation.md.sensorml;

import com.erdas.projects.smaad.annotation.md.HandlerTestHelper;
import com.erdas.projects.smaad.annotation.md.MetadataHandler;
import com.erdas.projects.smaad.annotation.md.MetadataHandlerException;
import com.erdas.projects.smaad.annotation.model.Concept;
import com.erdas.projects.smaad.annotation.model.Thesaurus;
import org.junit.Test;
import org.w3c.dom.Document;
import org.xml.sax.SAXException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.Collections;

/**
 * Test adding keywords in SensorML
 */
public class SensorMLHandlerTest {

    @Test
    public void testTagSensorML1() throws ParserConfigurationException, IOException, SAXException, MetadataHandlerException, TransformerException {
        tagSensorML("samples/sensorML/sml-existing_keywords.xml");
    }

    @Test
    public void testTagSensorML2() throws ParserConfigurationException, IOException, SAXException, MetadataHandlerException, TransformerException {
        tagSensorML("samples/sensorML/sml-gmet-intervention_on_land.xml");
    }

    @Test
    public void testTagSensorML3() throws ParserConfigurationException, IOException, SAXException, MetadataHandlerException, TransformerException {
        tagSensorML("samples/sensorML/sml-gmet-none.xml");
    }

    @Test
    public void testTagSensorML4() throws ParserConfigurationException, IOException, SAXException, MetadataHandlerException, TransformerException {
        tagSensorML("samples/sensorML/sml-no_keywords-boundedby.xml");
    }

    @Test
    public void testTagSensorML5() throws ParserConfigurationException, IOException, SAXException, MetadataHandlerException, TransformerException {
        tagSensorML("samples/sensorML/sml-no_keywords-description.xml");
    }

    @Test
    public void testTagSensorML6() throws ParserConfigurationException, IOException, SAXException, MetadataHandlerException, TransformerException {
        tagSensorML("samples/sensorML/sml-no_keywords-name.xml");
    }

    @Test
    public void testTagSensorMLSystemWithNoKeywords() throws ParserConfigurationException, IOException, SAXException, MetadataHandlerException, TransformerException {
        tagSensorML("samples/sensorML/sml-no_keywords-none.xml");
    }

    @Test
    public void testTagSensorMLComponentWithNoKeyword() throws ParserConfigurationException, IOException, SAXException, MetadataHandlerException, TransformerException {
        tagSensorML("samples/sensorML/sml-no_keywords-none2.xml");
    }

    @Test
    public void testTagSensorMLSpot1() throws ParserConfigurationException, IOException, SAXException, MetadataHandlerException, TransformerException {
        tagSensorML("samples/sensorML/SPOT-1-HRV1.xml");
    }

    @Test
    public void testTagSensorMLDiscoverySample() throws ParserConfigurationException, IOException, SAXException, MetadataHandlerException, TransformerException {
        tagSensorML("samples/sensorML/SensorML_Profile_for_Discovery_Example.xml");
    }

    @Test
    public void testTagSensorMLCalVal() throws ParserConfigurationException, IOException, SAXException, MetadataHandlerException, TransformerException {
        tagSensorML("samples/sensorML/CalVal_v01/CalVal_ALOS_AVNIR-2_v01.xml");
    }


    private void tagSensorML(String fileName) throws ParserConfigurationException, IOException, SAXException, MetadataHandlerException, TransformerException {
        System.out.println("Test tag file " + fileName);
        Concept concept = HandlerTestHelper.createGEMETInterventionOnLandConcept();
        Document document = HandlerTestHelper.tagDocument(new SensorMLHandler(),fileName, concept);
        HandlerTestHelper.checkConceptInDocument(document,concept);
    }

}
