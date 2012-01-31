package com.erdas.projects.smaad.annotation.md.ogc;

import java.util.ArrayList;
import java.util.List;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import com.erdas.projects.smaad.annotation.md.BaseMetadataHandler;
import com.erdas.projects.smaad.annotation.md.MetadataHandlerException;
import com.erdas.projects.smaad.annotation.model.Concept;

public class OgcHandler extends BaseMetadataHandler {

    // Constants

    public final static String WMS_CAPABILITIES	= "WMS_CAP";
    public final static String WCS_1_0_CAPABILITIES	= "WCS_CAP_1.0";
    public final static String WCS_1_1_1_CAPABILITIES	= "WCS_CAP_1.1.1";
    public final static String WCS_2_0_CAPABILITIES	= "WCS_CAP_2.0";

    public final static String WMC			= "WMC";

    public final static String CAPABILITIES_MIME_TYPE	= "text/xml";
    public final static String WMC_MIME_TYPE			= "text/xml";

    final static String[] SUPPORTED_TYPES	= { WMS_CAPABILITIES, WCS_1_0_CAPABILITIES, WCS_1_1_1_CAPABILITIES, WCS_2_0_CAPABILITIES, WMC };


    // Namespaces

    final static String OGC_CONTEXT_NS			= "http://www.opengeospatial.net/context";
    final static String OGC_WCS_1_0_NS		    = "http://www.opengis.net/wcs";
    final static String OGC_WCS_1_1_1_NS		= "http://www.opengis.net/wcs/1.1.1";
    final static String OGC_WCS_2_0_NS		    = "http://www.opengis.net/wcs/2.0";
    final static String OGC_WMS_NS				= "http://www.opengis.net/wms";
    final static String OGC_OWS_1_1_NS			= "http://www.opengis.net/ows/1.1";
    final static String OGC_OWS_2_0_NS          = "http://www.opengis.net/ows/2.0";

    final static String OGC_CONTEXT_NS_PREFIX	= "ogc";
    final static String OGC_WCS_NS_PREFIX		= "wcs";
    final static String OGC_WMS_NS_PREFIX		= "wms";
    final static String OGC_OWS_NS_PREFIX		= "ows";

    // Common

    final static String KEYWORD_LIST_TAG		= "KeywordList";
    final static String KEYWORD_TAG				= "Keyword";
    final static String TITLE_TAG				= "Title";
    final static String ABSTRACT_TAG			= "Abstract";

    // CONTEXT

    final static String VIEW_CONTEXT_TAG		= "ViewContext";
    final static String GENERAL_TAG				= "General";

    // WMS Cap

    final static String WMS_CAPABILITIES_TAG	= "WMS_Capabilities";
    final static String SERVICE_TAG				= "Service";
    final static String VOCABULARY_ATTR			= "vocabulary";
    final static String[] WMS_KEYWORDS_PREDECESSORS = {
            ABSTRACT_TAG,
            TITLE_TAG
    };

    // WCS (OWS) Cap
    final static String WCS_2_0_CAPABILITIES_TAG	= "Capabilities";
    final static String WCS_1_1_1_CAPABILITIES_TAG	= "Capabilities";
    final static String WCS_1_1_1_SERVICE_IDENTIFICATION_TAG	= "ServiceIdentification";
    final static String WCS_2_0_SERVICE_IDENTIFICATION_TAG	= "ServiceIdentification";

    final static String WCS_KEYWORDS_TAG				= "Keywords";
    final static String[] WCS_KEYWORDS_PREDECESSORS = {
            ABSTRACT_TAG,
            TITLE_TAG
    };

    final static String WCS_1_0_CAPABILITIES_TAG    = "WCS_Capabilities";
    final static String WCS_1_0_SERVICE_IDENTIFICATION_TAG	= "Service";
    final static String WCS_1_0_KEYWORDS_TAG				= "keywords";
    final static String WCS_1_0_KEYWORD_TAG				= "keyword";
    final static String[] WCS_1_0_KEYWORDS_PREDECESSORS = {
            "name",
            "label",
    };

    // Classes

    protected class Keyword {

        // Fields

        String label_;
        String vocabulary_;

        // Constructors

        public Keyword(String label, String vocabulary) {
            label_		= label;
            vocabulary_	= vocabulary;
        }

        public boolean matches(Concept c) {

            boolean ret = false;

            if (c.getThesaurus() == null ||
                    c.getThesaurus().getUri().equals(vocabulary_)) {

                String val = c.getURI();
                if (val == null) {
                    // For free keywords
                    val = c.getLabel();
                }

                ret = label_.equals(val);

            }

            return ret;
        }

    }

    // Methods

    public void addConcept(Document doc, List<Concept> conceptList)
            throws MetadataHandlerException {

        // First get document type

        String type = getType(doc);

        if (type == null) {
            throw new BadOgcDocumentException("Unrecognized document type");
        }

        if (WMC.equals(type)) {
            addConceptToWmc(doc,conceptList);
        } else if (WCS_1_0_CAPABILITIES.equals(type)) {
            addConceptToWcs10(doc,conceptList);
        } else if (WCS_1_1_1_CAPABILITIES.equals(type)) {
            addConceptToWcs111(doc,conceptList);
        } else if (WCS_2_0_CAPABILITIES.equals(type)) {
            addConceptToWcs20(doc,conceptList);
        } else if (WMS_CAPABILITIES.equals(type)) {
            addConceptToWms(doc,conceptList);
        }



    }

    protected void addConceptToWmc(Document doc, List<Concept> conceptList) throws BadOgcDocumentException {

        NodeList nl;
        Element elt, keywordList, keyword;
        List<String> existingKeywords = new ArrayList<String>();

        // Get (or create) Keyword list node

        nl = doc.getElementsByTagNameNS(OGC_CONTEXT_NS, GENERAL_TAG);

        if (nl.getLength() <= 0) {
            throw new BadOgcDocumentException("Could not find " + GENERAL_TAG + " element");
        }

        elt = (Element)nl.item(0);

        nl = elt.getElementsByTagNameNS(OGC_CONTEXT_NS, KEYWORD_LIST_TAG);

        if (nl.getLength() <= 0) {

            // KeywordList not found, create it just after the Title element if any

            keywordList = doc.createElementNS(OGC_CONTEXT_NS, getTag(OGC_CONTEXT_NS,KEYWORD_LIST_TAG,elt));
            elt.insertBefore(keywordList,getNextElement(elt,OGC_CONTEXT_NS,TITLE_TAG));

        } else {

            keywordList = (Element)nl.item(0);

        }

        // Get all existing keywords

        nl = keywordList.getElementsByTagNameNS(OGC_CONTEXT_NS, KEYWORD_TAG);

        for (int i=0;i<nl.getLength();i++) {
            existingKeywords.add(nl.item(i).getTextContent());
        }

        // Add each concept as a keyword at the end of the list if not found

        for (Concept c : conceptList) {
            String val = c.getURI();
            if (val == null) {
                // For free keyword, URI does not exist, we have to
                // take the label
                val = c.getLabel();
            }
            if (!existingKeywords.contains(val)) {
                keyword = doc.createElementNS(OGC_CONTEXT_NS, getTag(OGC_CONTEXT_NS,KEYWORD_TAG,keywordList));
                keyword.setTextContent(val);
                keywordList.appendChild(keyword);
            }
        }

    }


    protected void addConceptToWms(Document doc, List<Concept> conceptList) throws BadOgcDocumentException {

        // Base on WMS 1.3

        NodeList nl;
        Element elt, keywordList, keyword;
        List<Keyword> existingKeywords = new ArrayList<Keyword>();

        // Get (or create) Keyword list node

        nl = doc.getElementsByTagNameNS(OGC_WMS_NS, SERVICE_TAG);

        if (nl.getLength() <= 0) {
            throw new BadOgcDocumentException("Could not find " + SERVICE_TAG + " element");
        }

        elt = (Element)nl.item(0);

        nl = elt.getElementsByTagNameNS(OGC_WMS_NS, KEYWORD_LIST_TAG);

        if (nl.getLength() <= 0) {

            // KeywordList not found, create it just after Abstract or Title
            // (if Abstract is not present) element

            Node nextNode = findInsertionPoint(elt, OGC_WMS_NS, WMS_KEYWORDS_PREDECESSORS);

            keywordList = doc.createElementNS(OGC_WMS_NS, getTag(OGC_WMS_NS,KEYWORD_LIST_TAG,elt));
            elt.insertBefore(keywordList,nextNode);

        } else {

            keywordList = (Element)nl.item(0);

        }

        // Get all existing keywords

        Keyword k;
        Element keywordElement;
        nl = keywordList.getElementsByTagNameNS(OGC_WMS_NS, KEYWORD_TAG);

        for (int i=0;i<nl.getLength();i++) {

            if (nl.item(i) instanceof Element) {
                keywordElement = (Element)nl.item(i);
                k = new Keyword(keywordElement.getTextContent(),keywordElement.getAttribute(VOCABULARY_ATTR));
                existingKeywords.add(k);
            }

        }

        // Add each concept as a keyword at the end of the list if not found

        for (Concept c : conceptList) {
            if (!contains(existingKeywords,c)) {
                keyword = doc.createElementNS(OGC_WMS_NS, getTag(OGC_WMS_NS,KEYWORD_TAG,keywordList));
                if (c.getURI() != null) {
                    keyword.setTextContent(c.getURI());
                    keyword.setAttribute(VOCABULARY_ATTR, c.getThesaurus().getUri());
                } else {
                    // Free keyword
                    keyword.setTextContent(c.getLabel());
                }
                keywordList.appendChild(keyword);
            }
        }

    }

    protected boolean contains(List<Keyword> keywordList, Concept c) {

        boolean ret = false;

        for (Keyword k : keywordList) {

            if (k.matches(c)) {
                ret = true;
                break;
            }

        }

        return ret;
    }


    protected void addConceptToWcs10(Document doc, List<Concept> conceptList) throws BadOgcDocumentException {
        addConceptToWcs(doc,conceptList,
                OGC_WCS_1_0_NS,
                WCS_1_0_SERVICE_IDENTIFICATION_TAG,
                WCS_1_0_KEYWORDS_TAG,
                WCS_1_0_KEYWORD_TAG,
                WCS_1_0_KEYWORDS_PREDECESSORS);
    }

    protected void addConceptToWcs111(Document doc, List<Concept> conceptList) throws BadOgcDocumentException {
        addConceptToWcs(doc,conceptList,
                OGC_OWS_1_1_NS,
                WCS_1_1_1_SERVICE_IDENTIFICATION_TAG,
                WCS_KEYWORDS_TAG,
                KEYWORD_TAG,
                WCS_KEYWORDS_PREDECESSORS);
    }

    protected void addConceptToWcs20(Document doc, List<Concept> conceptList) throws BadOgcDocumentException {
        addConceptToWcs(doc,conceptList,
                OGC_OWS_2_0_NS,
                WCS_2_0_SERVICE_IDENTIFICATION_TAG,
                WCS_KEYWORDS_TAG,
                KEYWORD_TAG,
                WCS_KEYWORDS_PREDECESSORS);
    }

    private void addConceptToWcs(Document doc, List<Concept> conceptList,
                                   String OGC_OWS_NS,
                                   String SERVICE_IDENTIFICATION_TAG,
                                   String KEYWORDS_TAG,
                                   String KEYWORD_TAG,
                                   String[] WCS_KEYWORDS_PREDECESSORS) throws BadOgcDocumentException {

        NodeList nl;
        Element elt, keywordList, keyword;
        List<String> existingKeywords = new ArrayList<String>();


        // Capabilities => CapabilitiesBaseType
        // wcs:Capabilities/ows:ServiceIdentification[0,1]=>DescriptionType
        // - ows:Title [0:n]
        // - ows:Abstract [0:n]
        // - ows:Keywords [0:n]
        // - ServiceType [1:1]
        // - ServiceTypeVersion [1:n]
        // - Profile [0:n]
        // ...

        // Get (or create) Keyword list node

        nl = doc.getElementsByTagNameNS(OGC_OWS_NS, SERVICE_IDENTIFICATION_TAG);

        if (nl.getLength() <= 0) {
            throw new BadOgcDocumentException("Could not find " + SERVICE_IDENTIFICATION_TAG + " element");
        }

        elt = (Element)nl.item(0);

        nl = elt.getElementsByTagNameNS(OGC_OWS_NS, KEYWORDS_TAG);

        if (nl.getLength() <= 0) {

            // KeywordList not found, create it just after Abstract or Title
            // (if Abstract is not present) element

            Node nextNode = findInsertionPoint(elt, OGC_OWS_NS, WCS_KEYWORDS_PREDECESSORS);

            keywordList = doc.createElementNS(OGC_OWS_NS, getTag(OGC_OWS_NS,KEYWORDS_TAG,elt));
            elt.insertBefore(keywordList,nextNode);

        } else {

            keywordList = (Element)nl.item(0);

        }

        // Get all existing keywords

        nl = keywordList.getElementsByTagNameNS(OGC_OWS_NS, KEYWORD_TAG);

        for (int i=0;i<nl.getLength();i++) {
            existingKeywords.add(nl.item(i).getTextContent());
        }

        // Add each concept as a keyword at the end of the list if not found

        for (Concept c : conceptList) {
            String val = c.getURI();
            if (val == null) {
                // For free keyword, URI does not exist, we have to
                // take the label
                val = c.getLabel();
            }
            if (!existingKeywords.contains(val)) {
                keyword = doc.createElementNS(OGC_OWS_NS, getTag(OGC_OWS_NS,KEYWORD_TAG,keywordList));
                keyword.setTextContent(val);
                keywordList.appendChild(keyword);
            }
        }

    }



    public String[] getSupportedTypes() {
        return SUPPORTED_TYPES;
    }

    public String getType(Document doc) {

        String type = null;

        Element root = doc.getDocumentElement();

        if (OGC_WCS_1_1_1_NS.equals(root.getNamespaceURI()) &&
                WCS_1_1_1_CAPABILITIES_TAG.equals(root.getLocalName())) {
            type = WCS_1_1_1_CAPABILITIES;
        } else if (OGC_WCS_1_0_NS.equals(root.getNamespaceURI()) &&
                WCS_1_0_CAPABILITIES_TAG.equals(root.getLocalName())) {
            type = WCS_1_0_CAPABILITIES;
        } else if (OGC_WCS_2_0_NS.equals(root.getNamespaceURI()) &&
                WCS_2_0_CAPABILITIES_TAG.equals(root.getLocalName())) {
            type = WCS_2_0_CAPABILITIES;
        } else if (OGC_WMS_NS.equals(root.getNamespaceURI()) &&
                WMS_CAPABILITIES_TAG.equals(root.getLocalName())) {
            type = WMS_CAPABILITIES;
        } else if (OGC_CONTEXT_NS.equals(root.getNamespaceURI()) &&
                VIEW_CONTEXT_TAG.equals(root.getLocalName())) {
            type = WMC;
        }

        return type;
    }

    public String getLanguage(Document doc) {
        // Not supported
        return null;
    }

    public String getMimeType(String type) {

        String mimeType = null;

        if (WMS_CAPABILITIES.equals(type)
                || WCS_1_0_CAPABILITIES.equals(type)
                || WCS_1_1_1_CAPABILITIES.equals(type)
                || WCS_2_0_CAPABILITIES.equals(type)) {

            mimeType = CAPABILITIES_MIME_TYPE;

        } else if (WMC.equals(type)) {

            mimeType = WMC;

        }

        return mimeType;
    }

}
