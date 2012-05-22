package com.erdas.projects.smaad.annotation.md.iso;

import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

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

import com.erdas.projects.smaad.annotation.md.BaseMetadataHandler;
import com.erdas.projects.smaad.annotation.md.MetadataHandlerException;
import com.erdas.projects.smaad.annotation.model.Concept;
import com.erdas.projects.smaad.annotation.model.Thesaurus;
import com.erdas.projects.smaad.annotation.tools.NamespaceResolver;

/**
 * ISO 19115/19119 metadata handler.
 *
 * @author Nicolas
 */
public class Iso19115Handler extends BaseMetadataHandler {


    // Constants

    public final static String ISO_19115 = "ISO_19115";
    public final static String ISO_19119 = "ISO_19119";

    public final static String ISO_19115_MIME_TYPE = "text/xml";
    public final static String ISO_19119_MIME_TYPE = "text/xml";

    final static String[] SUPPORTED_TYPES = {ISO_19115, ISO_19119};

    final static String ISO_SCHEMATRON_PATH = "/org/opengis/schemas/resources/inspire/inspire-svrl.xsl";
    final static String ISO_19115_XSD = "/org/opengis/schemas/resources/iso/iso19139/20060504/gmd/gmd.xsd";

    //  language

    final static String ENGLISH_ISO_LANGUAGE_CODE_3 = "eng";
    final static String FRENCH_ISO_LANGUAGE_CODE_3_1 = "fra";
    final static String FRENCH_ISO_LANGUAGE_CODE_3_2 = "fre";

    final static Map<String, String> LANGUAGE_MAP = new HashMap<String, String>();

    static {
        LANGUAGE_MAP.put(ENGLISH_ISO_LANGUAGE_CODE_3, ENGLISH_LANGUAGE_CODE);
        LANGUAGE_MAP.put(FRENCH_ISO_LANGUAGE_CODE_3_1, FRENCH_LANGUAGE_CODE);
        LANGUAGE_MAP.put(FRENCH_ISO_LANGUAGE_CODE_3_2, FRENCH_LANGUAGE_CODE);
    }

    // Namespaces

    final static String GMD_NS = "http://www.isotc211.org/2005/gmd";
    final static String GCO_NS = "http://www.isotc211.org/2005/gco";
    final static String GMX_NS = "http://www.isotc211.org/2005/gmx";
    final static String XLINK_NS = "http://www.w3.org/1999/xlink";
    final static String SRV_NS = "http://www.isotc211.org/2005/srv";

    final static String GMD_NS_PREFIX = "gmd";
    final static String GCO_NS_PREFIX = "gco";
    final static String GMX_NS_PREFIX = "gmx";
    final static String XLINK_NS_PREFIX = "xlink";
    final static String SRV_NS_PREFIX = "srv";

    // GMD

    final static String MD_METADATA_TAG = "MD_Metadata";
    final static String DESCRIPTIVE_KEYWORDS_TAG = "descriptiveKeywords";
    final static String MD_KEYWORDS_TAG = "MD_Keywords";
    final static String THESAURUS_NAME_TAG = "thesaurusName";
    final static String KEYWORD_TAG = "keyword";
    final static String CI_CITATION_TAG = "CI_Citation";
    final static String TITLE_TAG = "title";
    final static String RESOURCE_FORMAT_TAG = "resourceFormat";
    final static String GRAPHIC_OVERVIEW_TAG = "graphicOverview";
    final static String RESOURCE_MAINTENANCE_TAG = "resourceMaintenance";
    final static String POINT_OF_CONTACT_TAG = "pointOfContact";
    final static String STATUS_TAG = "status";
    final static String CREDIT_TAG = "credit";
    final static String PURPOSE_TAG = "purpose";
    final static String ABSTRACT_TAG = "abstract";
    final static String DATE_TAG = "date";

    final static String[] DESCRIPTIVE_KEYWORDS_PREDECESSORS = {
            RESOURCE_FORMAT_TAG,
            GRAPHIC_OVERVIEW_TAG,
            RESOURCE_MAINTENANCE_TAG,
            POINT_OF_CONTACT_TAG,
            STATUS_TAG,
            CREDIT_TAG,
            PURPOSE_TAG,
            ABSTRACT_TAG
    };

    // GCO

    final static String CHARACTER_STRING_TAG = "CharacterString";

    // GMX

    final static String ANCHOR_TAG = "Anchor";

    // XLINK

    final static String HREF_ATTR = "href";

    final static String MD_DATA_IDENTIFICATION_XPATH = "gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification";
    final static String SV_SERVICE_IDENTIFICATION_XPATH = "gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification";
    final static String DESCRIPTIVE_KEYWORDS_XPATH = "gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords";
    final static String LANGUAGE_XPATH = "gmd:MD_Metadata/gmd:language/gmd:LanguageCode";


    // Fields

    Logger logger_;
    NamespaceResolver resolver_;

    // Constructors

    public Iso19115Handler() {
        // Init namespace resolver
        resolver_ = new NamespaceResolver();
        resolver_.addNamespace(GMD_NS_PREFIX, GMD_NS);
        resolver_.addNamespace(GCO_NS_PREFIX, GCO_NS);
        resolver_.addNamespace(GMX_NS_PREFIX, GMX_NS);
        resolver_.addNamespace(XLINK_NS_PREFIX, XLINK_NS);
        resolver_.addNamespace(SRV_NS_PREFIX, SRV_NS);

        // Get a logger

        logger_ = LoggerFactory.getLogger(this.getClass());

    }

    // Class

    private class ProcessingState {

        // Fields

        Document doc_;
        String lang_ = null;
        Node insertBefore_ = null;
        Element insertParent_ = null;
        Map<String, MD_Keywords> mdKeywordsMap_;
        List<MD_Keywords> freeMdKeywordsList_;

        // Constructors

        public ProcessingState(Document doc) {
            doc_ = doc;
        }

        // Methods

        public String getLang() {
            return lang_;
        }

        public void setLang(String lang) {
            if (lang == null) {
                lang_ = "";
            } else {
                lang_ = lang;
            }
        }

        public Node getInsertBefore() {
            return insertBefore_;
        }

        public void setInsertBefore(Node insertBefore) {
            insertBefore_ = insertBefore;
        }

        public Map<String, MD_Keywords> getMdKeywordsMap() {
            return mdKeywordsMap_;
        }

        public void setMdKeywordsMap(Map<String, MD_Keywords> mdKeywordsMap) {
            mdKeywordsMap_ = mdKeywordsMap;
        }

        public Document getDoc() {
            return doc_;
        }

        public void setDoc(Document doc) {
            doc_ = doc;
        }

        public Element getInsertParent() {
            return insertParent_;
        }

        public void setInsertParent(Element insertParent) {
            insertParent_ = insertParent;
        }

        public void setFreeMdKeywordsList(List<MD_Keywords> freeMdKeywordsList) {
            freeMdKeywordsList_ = freeMdKeywordsList;
        }

        public List<MD_Keywords> getFreeMdKeywordsList() {
            return freeMdKeywordsList_;
        }

    }

    private class MD_Keywords {

        // Fields

        Element elt_;
        Document doc_;
        String thesaurusName_;
        String thesaurusUri_ = null;
        boolean freeKeywords_ = false;

        List<Concept> keywords_ = new ArrayList<Concept>();

        // Constructors

        public MD_Keywords(Element mdKeywordsElement, Document doc) throws MetadataHandlerException {

            elt_ = mdKeywordsElement;
            doc_ = doc;

        }

        public void parse() throws MetadataHandlerException {

            Element elt;
            List<Element> eltList;
            Concept concept;
            Thesaurus thesaurus = null;

            // Check thesaurus (thesaurusName/CI_CITATION/title)

            elt = getUniqueElement(elt_, GMD_NS, TITLE_TAG);

            if (elt != null) {

                concept = getValue(elt);
                thesaurusName_ = concept.getLabel();
                thesaurusUri_ = concept.getURI();
                thesaurus = new Thesaurus(thesaurusName_, thesaurusUri_);

            } else {

                // Not thesaurus found in this MD_Keywords, this is valid

                thesaurusName_ = null;
                thesaurusUri_ = null;

                // Check if there is at least a thesaurus name, if not
                // => free keywords

                freeKeywords_ = elt_.getElementsByTagNameNS(GMD_NS, THESAURUS_NAME_TAG).getLength() <= 0;

            }


            // Get all keywords

            eltList = getAllElements(elt_, GMD_NS, KEYWORD_TAG);
            for (Element e : eltList) {
                concept = getValue(e);
                concept.setThesaurus(thesaurus);
                keywords_.add(concept);
            }


        }

        private Concept getValue(Element elt) throws MetadataHandlerException {

            Element child;
            Concept c = null;

            // Try first to get an anchor

            child = getUniqueElement(elt, GMX_NS, ANCHOR_TAG);

            if (child != null) {

                c = new Concept(child.getAttribute(XLINK_NS_PREFIX + ":" + HREF_ATTR));
                c.setLabel(child.getTextContent());

            } else {

                // Not found, try to find a CharacterString

                child = getUniqueElement(elt, GCO_NS, CHARACTER_STRING_TAG);

                if (child != null) {

                    c = new Concept();
                    c.setLabel(child.getTextContent());

                } else {

                    // Don't know how to handle

                }

            }

            return c;
        }

        private Element getUniqueElement(Element parent, String ns, String eltName) {

            NodeList nl;
            Element elt = null;
            nl = parent.getElementsByTagNameNS(ns, eltName);

            if (nl.getLength() == 1 && nl.item(0).getNodeType() == Node.ELEMENT_NODE) {
                elt = (Element) nl.item(0);
            }

            return elt;

        }

        private List<Element> getAllElements(Element parent, String ns, String eltName)
                throws MetadataHandlerException {

            List<Element> ret = new ArrayList<Element>();

            NodeList nl;
            Node n;

            nl = parent.getElementsByTagNameNS(ns, eltName);

            for (int i = 0; i < nl.getLength(); i++) {
                n = nl.item(i);
                if (n.getNodeType() == Node.ELEMENT_NODE) {
                    ret.add((Element) n);
                }
            }

            return ret;

        }

        @Override
        public String toString() {
            StringBuilder sb = new StringBuilder();
            sb.append((thesaurusName_ != null ? (thesaurusName_ + " (" + (thesaurusUri_ != null ? thesaurusUri_ : "<no uri>") + ")") : "Free keywords") + ":");
            for (Concept c : keywords_) {
                sb.append(" '");
                sb.append(c.getLabel());
                sb.append("'");
                if (c.getURI() != null) {
                    sb.append("(");
                    sb.append(c.getURI());
                    sb.append(")");
                }
            }
            return sb.toString();
        }

        public String getThesaurusName() {
            return thesaurusName_;
        }

        public String getThesaurusUri() {
            return thesaurusUri_;
        }

        public List<Concept> getKeywords() {
            return keywords_;
        }

        public void addConcept(Concept concept, String lang) {

            boolean found = false;

            // Check if concept already present

            for (Concept keyword : keywords_) {

                if (Concept.match(keyword, concept)) {
                    found = true;
                }

            }

            // If not found, add the concept

            if (!found) {

                // Add it to the list

                keywords_.add(concept);

                if (concept.getThesaurus() != null) {

                    // Add a gmd:keywords/gmx:Anchor element to the
                    // MD_Keywords element
                    // Will be inserted first

                    Element e, parent;

                    parent = elt_;
                    e = doc_.createElementNS(GMD_NS, getTag(GMD_NS, KEYWORD_TAG, parent));
                    parent.insertBefore(e, parent.getFirstChild());

                    parent = e;
                    e = doc_.createElementNS(GMX_NS, getTag(GMX_NS, ANCHOR_TAG, parent));
                    e.setAttributeNS(XLINK_NS, getTag(XLINK_NS, HREF_ATTR, parent, true), concept.getURI());
                    e.setTextContent(concept.getLabel(lang));
                    parent.appendChild(e);

                } else {

                    // Free keyword

                    // Add a gmd:keywords/gco:CharacterString element to the
                    // MD_Keywords element
                    // Will be inserted first

                    Element e, parent;

                    parent = elt_;
                    e = doc_.createElementNS(GMD_NS, getTag(GMD_NS, KEYWORD_TAG, parent));
                    parent.insertBefore(e, parent.getFirstChild());

                    parent = e;
                    e = doc_.createElementNS(GCO_NS, getTag(GCO_NS, CHARACTER_STRING_TAG, parent));
                    e.setTextContent(concept.getLabel(lang));
                    parent.appendChild(e);

                }


            }

        }

        public Element getElt() {
            return elt_;
        }

        public boolean isFreeKeywords() {
            return freeKeywords_;
        }

    }

    // Constructors

    // Methods

    public void addConcept(Document doc, List<Concept> conceptList) throws MetadataHandlerException {

        Element insertionPoint;
        MD_Keywords mdKeywords;
        ProcessingState processingState;

        // Get all <gmd:descriptiveKeywords>

        XPathFactory factory = XPathFactory.newInstance();
        XPath xpath = factory.newXPath();
        xpath.setNamespaceContext(resolver_);

        XPathExpression expression;

        // Get file type

        String type = getType(doc);

        if (type == null) {
            throw new BadIso19115DocumentException("Unrecognized file type");
        }

        try {

            processingState = new ProcessingState(doc);

            // Get document language

            processingState.setLang(getLanguage(doc));

            // Get the insertion point (gmd:MD_DataIdentification or srv:SV_ServiceIdentification)

            if (type == ISO_19115) {
                // 19115
                expression = xpath.compile(MD_DATA_IDENTIFICATION_XPATH);
                insertionPoint = (Element) expression.evaluate(doc, XPathConstants.NODE);
                if (insertionPoint == null) {
                    logger_.warn("Could not find element: " + MD_DATA_IDENTIFICATION_XPATH);
                    throw new BadIso19115DocumentException(MD_DATA_IDENTIFICATION_XPATH + " not found");
                }
            } else {
                // 19119
                expression = xpath.compile(SV_SERVICE_IDENTIFICATION_XPATH);
                insertionPoint = (Element) expression.evaluate(doc, XPathConstants.NODE);
                if (insertionPoint == null) {
                    logger_.warn("Could not find element: " + SV_SERVICE_IDENTIFICATION_XPATH);
                    throw new BadIso19115DocumentException(SV_SERVICE_IDENTIFICATION_XPATH + " not found");
                }
            }

            processingState.setInsertParent(insertionPoint);

            // Get all gmd:descriptiveKeywords/gmd:MD_Keywords

            getAllMdKeywords(processingState, xpath);

            // Add all concept

            for (Concept concept : conceptList) {

                mdKeywords = getMdKeywords(concept, processingState);

                // Add the concept to the mdKeywords element

                mdKeywords.addConcept(concept, processingState.getLang());

            }


        } catch (XPathExpressionException ex) {

            logger_.warn("Cannot add concept, xpath exception: " + ex);
            throw new MetadataHandlerException("Internal error");

        }


    }

    private MD_Keywords getMdKeywords(Concept concept, ProcessingState pstate)
            throws MetadataHandlerException {


        MD_Keywords mdKeywords;
        Thesaurus thesaurus;
        String thesaurusUri = null;
        String thesaurusName = null;
        String dateThesaurus = null;

        Map<String, MD_Keywords> mdKeywordsMap;
        List<MD_Keywords> freeMdKeywordsList;
        Document doc;
        Element insertionPoint;
        Element ciCitation;

        mdKeywordsMap = pstate.getMdKeywordsMap();
        freeMdKeywordsList = pstate.getFreeMdKeywordsList();
        doc = pstate.getDoc();
        insertionPoint = pstate.getInsertParent();
        thesaurus = concept.getThesaurus();

        // Check if there is a MD_Keywords referencing the concept
        // thesaurus


        thesaurusUri = null;
        if (thesaurus != null) {
            thesaurusUri = thesaurus.getUri();
            mdKeywords = mdKeywordsMap.get(thesaurusUri);
            if (mdKeywords == null) {

                thesaurusName = concept.getThesaurus().getName();
                if (thesaurusName.equals("GEMET")) {
                    thesaurusName = "GEMET - INSPIRE themes, version 1.0";
                    dateThesaurus = "2008-06-01";
                } else if (thesaurusName.equals("GCMD")) {
                    thesaurusName = "NASA/Global Change Master Directory (GCMD) Earth Science Keywords. Version  6.0.0.0.0 ";
                    dateThesaurus = "2008-02-05";
                }

                // Not found, we have to create a new one
                // The new mdKeywords should reference the correct thesaurus in
                // gmd:thesaurusName/gmd:CI_Citation/gmd:title/gmxAnchor

                Element e, parent;

                parent = insertionPoint;
                e = doc.createElementNS(GMD_NS, getTag(GMD_NS, DESCRIPTIVE_KEYWORDS_TAG, parent));
                parent.insertBefore(e, pstate.getInsertBefore());

                parent = e;
                e = doc.createElementNS(GMD_NS, getTag(GMD_NS, MD_KEYWORDS_TAG, parent));
                parent.appendChild(e);
                mdKeywords = new MD_Keywords(e, doc);
                parent = e;

                // gmd:MD_Keywords/gmd:type is not mandatory

                // gmd:MD_Keywords/gmd:thesaurusName is not mandatory

                e = doc.createElementNS(GMD_NS, getTag(GMD_NS, THESAURUS_NAME_TAG, parent));
                parent.appendChild(e);
                parent = e;
                ciCitation = doc.createElementNS(GMD_NS, getTag(GMD_NS, CI_CITATION_TAG, parent));
                parent.appendChild(ciCitation);
                parent = ciCitation;

                // gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title is mandatory

                e = doc.createElementNS(GMD_NS, getTag(GMD_NS, TITLE_TAG, parent));
                parent.appendChild(e);
                parent = e;
                e = doc.createElementNS(GMX_NS, getTag(GMX_NS, ANCHOR_TAG, parent));
                e.setAttributeNS(XLINK_NS, getTag(XLINK_NS, HREF_ATTR, parent, true), thesaurusUri);
                e.setTextContent(thesaurusName);
                parent.appendChild(e);

                // gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:date is mandatory

                parent = ciCitation;
                e = doc.createElementNS(GMD_NS, getTag(GMD_NS, DATE_TAG, parent));
                e.setTextContent(dateThesaurus);
                parent.appendChild(e);

                // gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:identifier is not mandatory

                // Add the mdKeywords to the map

                mdKeywordsMap.put(thesaurusUri, mdKeywords);
            }

        } else {

            // Free keyword, try to find a mdKeywords that contains the
            // keyword and if not found, take the first one or create a
            // new one

            mdKeywords = null;
            for (MD_Keywords mdk : freeMdKeywordsList) {

                List<Concept> clist = mdk.getKeywords();

                for (Concept c : clist) {

                    if (Concept.match(concept, c)) {

                        mdKeywords = mdk;
                        break;

                    }

                }

                if (mdKeywords != null) {
                    break;
                }

            }

            if (mdKeywords == null) {

                // Not found, take last one or create a new one

                if (freeMdKeywordsList.size() > 0) {
                    mdKeywords = freeMdKeywordsList.get(freeMdKeywordsList.size() - 1);
                } else {
                    Element e, parent;

                    parent = insertionPoint;
                    e = doc.createElementNS(GMD_NS, getTag(GMD_NS, DESCRIPTIVE_KEYWORDS_TAG, parent));
                    parent.insertBefore(e, pstate.getInsertBefore());

                    parent = e;
                    e = doc.createElementNS(GMD_NS, getTag(GMD_NS, MD_KEYWORDS_TAG, parent));
                    parent.appendChild(e);
                    mdKeywords = new MD_Keywords(e, doc);
                    freeMdKeywordsList.add(mdKeywords);
                }

            }


        }


        return mdKeywords;
    }


    private void getAllMdKeywords(ProcessingState pstate, XPath xpath)
            throws XPathExpressionException, MetadataHandlerException {

        Document doc;
        NodeList descriptiveKeywordsNodes;
        NodeList mdKeywordsNodes;
        Node n = null;
        Element elt;
        MD_Keywords mdKeywords;
        Map<String, MD_Keywords> mdKeywordsMap;
        List<MD_Keywords> freeMdKeywordsList;
        XPathExpression expression;

        doc = pstate.getDoc();

        expression = xpath.compile(DESCRIPTIVE_KEYWORDS_XPATH);
        descriptiveKeywordsNodes = (NodeList) expression.evaluate(doc, XPathConstants.NODESET);

        String thesaurusUri;
        mdKeywordsMap = new LinkedHashMap<String, Iso19115Handler.MD_Keywords>();
        freeMdKeywordsList = new ArrayList<Iso19115Handler.MD_Keywords>();
        for (int i = 0; i < descriptiveKeywordsNodes.getLength(); i++) {

            n = descriptiveKeywordsNodes.item(i);

            if (n.getNodeType() == Node.ELEMENT_NODE) {

                elt = (Element) n;

                mdKeywordsNodes = elt.getElementsByTagNameNS(GMD_NS, MD_KEYWORDS_TAG);

                for (int j = 0; j < mdKeywordsNodes.getLength(); j++) {

                    if (mdKeywordsNodes.item(j).getNodeType() == Node.ELEMENT_NODE) {
                        mdKeywords = new MD_Keywords((Element) mdKeywordsNodes.item(j), doc);
                        mdKeywords.parse();

                        thesaurusUri = mdKeywords.getThesaurusUri();
                        // Keep mdKeywords that identify a thesaurus by URI in a map
                        // and all other that have no thesaurus in a list
                        // (useful for free keywords only)
                        if (thesaurusUri != null) {
                            mdKeywordsMap.put(thesaurusUri, mdKeywords);
                        } else {
                            if (mdKeywords.isFreeKeywords()) {
                                freeMdKeywordsList.add(mdKeywords);
                            }
                        }
                    }

                }

            }

        }

        pstate.setMdKeywordsMap(mdKeywordsMap);
        pstate.setFreeMdKeywordsList(freeMdKeywordsList);

        // Store where to insert new descriptiveKeywords (i.e. the element
        // that will come just after the last descriptiveKeywords or after
        // its predefined predecessor in order to use the insertBefore
        // method).

        if (n != null) {
            n = n.getNextSibling();
        } else {
            n = findInsertionPoint(pstate.insertParent_, GMD_NS, DESCRIPTIVE_KEYWORDS_PREDECESSORS);
        }

        pstate.setInsertBefore(n);

    }


    public String getLanguage(Document doc) {

        Node languageNode;
        String lang = null;

        XPathFactory factory = XPathFactory.newInstance();
        XPath xpath = factory.newXPath();

        XPathExpression expression;
        try {
            xpath.setNamespaceContext(resolver_);
            expression = xpath.compile(LANGUAGE_XPATH);
            languageNode = (Node) expression.evaluate(doc, XPathConstants.NODE);

            if (languageNode != null) {
                lang = languageNode.getTextContent();

                // Convert ISO language code to Semantic DB code

                if (LANGUAGE_MAP.containsKey(lang)) {
                    lang = LANGUAGE_MAP.get(lang);
                }

            }

        } catch (XPathExpressionException ex) {

            logger_.warn("Cannot get language, xpath exception: " + ex);

        }

        return lang;
    }

    public String[] getSupportedTypes() {
        return SUPPORTED_TYPES;
    }

    public String getType(Document doc) {

        String type = null;

        Element root = doc.getDocumentElement();

        if (GMD_NS.equals(root.getNamespaceURI()) &&
                MD_METADATA_TAG.equals(root.getLocalName())) {

            // Document starts with MD_Metadata, should be a ISO 19115 or 19119 file
            // Check identificationInfo

            XPathFactory factory = XPathFactory.newInstance();
            XPath xpath = factory.newXPath();

            XPathExpression expression;
            Node n;
            try {
                xpath.setNamespaceContext(resolver_);
                expression = xpath.compile(MD_DATA_IDENTIFICATION_XPATH);
                n = (Node) expression.evaluate(doc, XPathConstants.NODE);
                if (n != null) {
                    // Found a MD_DataIdentification, type is ISO 19115
                    type = ISO_19115;
                } else {
                    expression = xpath.compile(SV_SERVICE_IDENTIFICATION_XPATH);
                    n = (Node) expression.evaluate(doc, XPathConstants.NODE);
                    if (n != null) {
                        // Found a SV_ServiceIdentification, type is ISO 19119
                        type = ISO_19119;
                    } else {
                        // File not recognized
                    }
                }
            } catch (XPathExpressionException ex) {
                logger_.warn("Iso19115Handler: Cannot get document type, xpath exception: " + ex);
            }

        }

        return type;
    }

    public String getMimeType(String type) {

        String mimeType = null;

        if (ISO_19115.equals(type)) {

            mimeType = ISO_19115_MIME_TYPE;

        } else if (ISO_19119.equals(type)) {

            mimeType = ISO_19119_MIME_TYPE;

        }

        return mimeType;

    }

    @Override
    public URL getSchematronValidationUrl(Document doc) {
        return getClass().getResource(ISO_SCHEMATRON_PATH);
    }

    @Override
    protected URL getXsdValidationUrl(Document doc) {

        URL url = null;

        String type = getType(doc);

        if (ISO_19115.equals(type)) {
            url = getClass().getResource(ISO_19115_XSD);
        }

        return url;

    }

}
