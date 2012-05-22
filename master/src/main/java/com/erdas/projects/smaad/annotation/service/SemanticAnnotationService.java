package com.erdas.projects.smaad.annotation.service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.net.URISyntaxException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
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

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.disk.DiskFileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.xml.sax.SAXException;

import com.erdas.projects.smaad.annotation.md.MetadataHandler;
import com.erdas.projects.smaad.annotation.md.MetadataHandler.ValidationResult;
import com.erdas.projects.smaad.annotation.md.MetadataHandlerException;
import com.erdas.projects.smaad.annotation.md.MetadataHandlerRespository;
import com.erdas.projects.smaad.annotation.md.ValidationErrorInfo;
import com.erdas.projects.smaad.annotation.model.Concept;
import com.erdas.projects.smaad.annotation.model.RdfDocParser;
import com.erdas.projects.smaad.annotation.model.SparqlResponseParser;
import com.erdas.projects.smaad.annotation.model.Thesaurus;
import com.erdas.projects.smaad.annotation.model.VoidDoc;
import com.erdas.projects.smaad.annotation.model.VoidDoc.Dataset;
import com.erdas.projects.smaad.annotation.service.MetaDataInfo.Status;
import com.erdas.projects.smaad.annotation.tools.NamespaceResolver;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonParseException;

/**
 * Servlet implementation class SemanticAnnotationEditorService
 */
public class SemanticAnnotationService extends HttpServlet {

	// Constants
	
	final static String VOID_URL_INIT_PARAM			= "VOID_URL";
	final static String XSD_VALIDATION_PARAM		= "XSD_VALIDATION";
	final static String SCHEMATRON_VALIDATION_PARAM	= "SCHEMATRON_VALIDATION";
	
	final static String OPERATION_PARAM 	= "op";
	
	final static String SEARCH_OP			= "search";
	final static String RESOLVE_OP			= "resolve";
	final static String GET_THESAURUS_OP	= "getThesaurus";
	final static String GET_BASE_URL_OP		= "getBaseUrl";
	final static String TAG_OP				= "tag";
	final static String GET_FILE_OP			= "get";
	final static String GET_ALL_FILE_OP		= "getAll";
	final static String GET_FILE_LIST_OP	= "getFileList";
	final static String GET_ERROR_OP		= "getError";
	final static String CLEAR_FILES_OP		= "reset";
	
	final static String QUERY_PARAM			= "q";
	final static String THESAURUS_PARAM		= "ont";
	final static String LANGUAGE_PARAM		= "lang";
	final static String CONCEPTS_PARAM		= "concepts";
	final static String FILE_PARAM			= "file";
	final static String MAX_RESULTS_PARAM	= "count";
	
	final static String MD_SESSION_OBJECT		= "MetaData";
	final static String CONCEPTS_SESSION_OBJECT	= "Concepts";
	
	final static String DEFAULT_MIME_TYPE	= "text/xml";
	
	final static String DEFAULT_LANGUAGE	= "en";
	
	final static int DEFAULT_MAX_RESULTS	= 20;
	
	private static final long serialVersionUID = 1L;
	
	final static String CONTENT_DISPOSITION_HEADER 	= "Content-Disposition";
	final static String CD_ATTACHMENT_TEMPLATE		= "attachment; filename=%s";
	final static String CD_INLINE_TEMPLATE			= "inline; filename=%s";
	
	final static String DEFAULT_ZIP_FILENAME		= "MetaData.zip";
	
	final static String ERROR_URL_TEMPLATE			= "?op=getError&file=%s";
	
	final static String CUSTOM_URI_PREFIX			= "custom#";
	
	// Opensearch constants
	
	final static String OPENSEARCH_NS	= "http://a9.com/-/spec/opensearch/1.1/";
	final static String URL_XPATH_TEMPLATE	= "/:OpenSearchDescription/:Url[@type=\"%s\"]";
	final static String TEMPLATE_ATTR	= "template";
	
	final static String SEARCH_TERMS_PARAM_TAG	= "{searchTerms}";
	final static String LANGUAGE_PARAM_TAG		= "{language}";
	final static String MAX_RESULTS_PARAM_TAG	= "{count}";
	final static String OPEN_SEARCH_PARAM_TAG	= "\\{[^\\{]*\\}";
	
	final static String JSON_MIME_TYPE			= "application/json";
	final static String RDF_MIME_TYPE			= "application/rdf+xml";

	
	// Fields
	
	Logger logger_;
	
	private boolean xsdValidation			= true;
	private boolean schematronValidation 	= true;
	
	private int maxResults_	= DEFAULT_MAX_RESULTS;
    
	private Map<String, Thesaurus> thesaurusMapByName_	= new HashMap<String, Thesaurus>();
	private Map<String, Thesaurus> thesaurusMapByUri_	= new HashMap<String, Thesaurus>();
	
	/**
     * @see HttpServlet#HttpServlet()
     */
    public SemanticAnnotationService() {
        super();
        logger_ = LoggerFactory.getLogger(this.getClass());
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
		String method = request.getParameter(OPERATION_PARAM);
		
		if (method == null || method.length() == 0) {
			// No method provided => error
			handleError(request, response, HttpServletResponse.SC_BAD_REQUEST, "No \"" + OPERATION_PARAM + "\" provided");
		} else {
			doGet(method, request, response);
		}
		
	}

	private void doGet(String operation, HttpServletRequest request,
			HttpServletResponse response) {
		
		if (SEARCH_OP.equals(operation)) {
			
			doSearch(request, response);

		} else if (RESOLVE_OP.equals(operation)) {

			doResolve(request, response);
			
		} else if (GET_THESAURUS_OP.equals(operation)) {
			
			doGetThesaurus(request, response);

		} else if (GET_BASE_URL_OP.equals(operation)) {
			
			doGetBaseUrl(request, response);
			
		} else if (GET_FILE_LIST_OP.equals(operation)) {
			
			doGetFileList(request, response);

		} else if (GET_FILE_OP.equals(operation)) {
			
			doGetFile(request, response);

		} else if (GET_ALL_FILE_OP.equals(operation)) {
			
			doGetAllFiles(request, response);
			
		} else if (GET_ERROR_OP.equals(operation)) {
			
			doGetError(request, response);
			
		} else if (CLEAR_FILES_OP.equals(operation)) {
			
			doClearAllFiles(request, response);
			
		} else {
			
			handleError(request, response, HttpServletResponse.SC_BAD_REQUEST, "GET operation \'" + operation + "' not supported.");
			
		}
		
	}
	
	private void doClearAllFiles(HttpServletRequest request,
			HttpServletResponse response) {
		
		HttpSession session;
		List<MetaDataInfo> mdDocuments;
		
		logger_.debug("Clear all files, cookie: " + request.getHeader("cookie"));

		
		// Check if there is a session
		
		session = request.getSession(false);
		
		if (session != null) {
		
			logger_.debug("Clear all files, session: " + session.getId());
			
			// Check if there is a document list in session
			
			mdDocuments = (List<MetaDataInfo>)session.getAttribute(MD_SESSION_OBJECT);
			
			if (mdDocuments != null && mdDocuments.size() > 0) {

				mdDocuments.clear();
				session.setAttribute(MD_SESSION_OBJECT, mdDocuments);
				
			} else {
				
				// No documents in session
				
				// Do nothing
				
			}
			
		} else {
			
			// No session
			
			handleError(request, response, HttpServletResponse.SC_NOT_FOUND, "Session cannot be found");
			
		}
		
	}

	private void doGetBaseUrl(HttpServletRequest request,
			HttpServletResponse response) {
		
		String baseUrl;
		
		baseUrl = request.getRequestURI();
		
		sendResult(baseUrl, request, response);
		
	}

	private void doGetFile(HttpServletRequest request,
			HttpServletResponse response) {
		
		List<MetaDataInfo>	mdDocuments;
		MetaDataInfo		doc;
		HttpSession			session;
		String				fileName;
		
		logger_.debug("GET file, cookie: " + request.getHeader("cookie"));

		
		// Get file parameter
		
		fileName = request.getParameter(FILE_PARAM);

		if (fileName == null) {
			handleError(request, response, HttpServletResponse.SC_BAD_REQUEST, "Get file request without '" + FILE_PARAM + "' parameter.");
		}
		
		// Check if there is a session
		
		session = request.getSession(false);
		
		if (session != null) {
		
			logger_.debug("GET file, session: " + session.getId());
			
			// Check if there is a document list in session
			
			mdDocuments = (List<MetaDataInfo>)session.getAttribute(MD_SESSION_OBJECT);
			
			if (mdDocuments != null) {
				
				doc = null;
				for (MetaDataInfo mdInfo : mdDocuments) {
					if (fileName.equals(mdInfo.getName())) {
						doc = mdInfo;
						break;
					}
				}
				
				if (doc != null) {
					
					// Document found, send it back
					
					sendXmlResult(doc.getDocument(), doc.getName(), doc.getMimeType(), request, response);
					
				} else {
					
					// No document with matching name
					
					handleError(request, response, HttpServletResponse.SC_NOT_FOUND, "Document not found in session: '" + fileName + "'");
					
				}
				
				
			} else {
				
				// No documents in session
				
				handleError(request, response, HttpServletResponse.SC_NOT_FOUND, "No documents in session");
				
			}
			
		} else {
			
			// No session
			
			handleError(request, response, HttpServletResponse.SC_NOT_FOUND, "Session cannot be found");
			
		}

	}
	
	
	private void doGetError(HttpServletRequest request,
			HttpServletResponse response) {
		
		List<MetaDataInfo>	mdDocuments;
		MetaDataInfo		doc;
		HttpSession			session;
		String				fileName;
		
		logger_.debug("GET error, cookie: " + request.getHeader("cookie"));

		
		// Get file parameter
		
		fileName = request.getParameter(FILE_PARAM);

		if (fileName == null) {
			handleError(request, response, HttpServletResponse.SC_BAD_REQUEST, "Get error request without '" + FILE_PARAM + "' parameter.");
		}
		
		// Check if there is a session
		
		session = request.getSession(false);
		
		if (session != null) {
		
			logger_.debug("GET error, session: " + session.getId());
			
			// Check if there is a document list in session
			
			mdDocuments = (List<MetaDataInfo>)session.getAttribute(MD_SESSION_OBJECT);
			
			if (mdDocuments != null) {
				
				doc = null;
				for (MetaDataInfo mdInfo : mdDocuments) {
					if (fileName.equals(mdInfo.getName())) {
						doc = mdInfo;
						break;
					}
				}
				
				if (doc != null) {
					
					// Document found, create error page
					
					ValidationResult result;
					List<ValidationErrorInfo> errors;
					result = doc.getValidationResult();
					StringBuilder resultPage = new StringBuilder();
					resultPage.append("<html><head><title>Validation result</title>");
					resultPage.append("<link href='css/validation.css' rel='stylesheet' type='text/css'/>");
					resultPage.append("</head><body>");
					if (result == null || result.isSuccess()) {
						
						// Validation was successful
						
						resultPage.append("<div class='errorTitle'>Validation successful</div>");
						
					} else {
						
						resultPage.append("<div class='errorTitle'>Validation errors:</div>");
						resultPage.append("<div>");
						errors = result.getErrors();
						if (errors == null || errors.size() == 0) {
							resultPage.append("<div class='errorInfo'>No more information available</div>");
						} else {
							resultPage.append("<div class='errorDiv'");
							for (ValidationErrorInfo ei : errors) {
								resultPage.append("<div>");
								resultPage.append("<div class='errorInfoDiv'><spand class='errorInfo'>");
								resultPage.append(ei.getError());
								resultPage.append("</span></div>");
								resultPage.append("<div class='errorLocation'><span class='errorLocationTitle'>Location:</span>");
								resultPage.append(ei.getLocation());
								resultPage.append("</div>");								
								resultPage.append("</div>");
							}
							resultPage.append("</div>");
						}
						resultPage.append("</div>");
					}
					resultPage.append("</body></html>");
					sendHtmlResult(resultPage.toString(), request, response);
					
				} else {
					
					// No document with matching name
					
					handleError(request, response, HttpServletResponse.SC_NOT_FOUND, "Document not found in session: '" + fileName + "'");
					
				}
				
				
			} else {
				
				// No documents in session
				
				handleError(request, response, HttpServletResponse.SC_NOT_FOUND, "No documents in session");
				
			}
			
		} else {
			
			// No session
			
			handleError(request, response, HttpServletResponse.SC_NOT_FOUND, "Session cannot be found");
			
		}

	}
	
	private void doGetAllFiles(HttpServletRequest request,
			HttpServletResponse response) {
		
		List<MetaDataInfo>	mdDocuments;
		MetaDataInfo		doc;
		HttpSession			session;
		String				fileName;
		
		logger_.debug("GET all files, cookie: " + request.getHeader("cookie"));

		
		// Check if there is a session
		
		session = request.getSession(false);
		
		if (session != null) {
		
			logger_.debug("GET all files, session: " + session.getId());
			
			// Check if there is a document list in session
			
			mdDocuments = (List<MetaDataInfo>)session.getAttribute(MD_SESSION_OBJECT);
			
			if (mdDocuments != null && mdDocuments.size() > 0) {

				// Set MIME type
				
				response.setContentType("application/zip");
				
				// Set Content-Disposition
				
				response.addHeader(CONTENT_DISPOSITION_HEADER, String.format(CD_ATTACHMENT_TEMPLATE, DEFAULT_ZIP_FILENAME));
				
				// Prepare a zip file with all documents and write it to output stream
				
				try {
					ZipOutputStream zos = new ZipOutputStream(response.getOutputStream());
					doc = null;
					for (MetaDataInfo mdInfo : mdDocuments) {
						zos.putNextEntry(new ZipEntry(mdInfo.getName()));
						writeDocument(mdInfo.getDocument(), zos);
						zos.closeEntry();
					}
					zos.close();
				} catch (IOException ex) {
					handleError(request, response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "IO exception during ZIP creation: " + ex);
				}
				
			} else {
				
				// No documents in session
				
				handleError(request, response, HttpServletResponse.SC_NOT_FOUND, "No documents in session");
				
			}
			
		} else {
			
			// No session
			
			handleError(request, response, HttpServletResponse.SC_NOT_FOUND, "Session cannot be found");
			
		}

		
		
	}

	private void sendXmlResult(Document doc, String filename, String mimeType, HttpServletRequest request,
			HttpServletResponse response) {
		
		// Request succeeded
		
		response.setStatus(HttpServletResponse.SC_OK);
		
		// Content type
		
		response.setContentType(mimeType);
		
		// Content disposition with filename
		
		response.addHeader(CONTENT_DISPOSITION_HEADER, String.format(CD_INLINE_TEMPLATE, filename));
		
		// Put result object in the response
		
		Transformer transformer;
		
		try {
			transformer = TransformerFactory.newInstance().newTransformer();
			transformer.setOutputProperty(OutputKeys.INDENT, "yes");
			DOMSource domSrc = new DOMSource(doc);
			transformer.transform(domSrc, new StreamResult(response.getOutputStream()));
				
		} catch (TransformerConfigurationException ex) {
			handleError(request, response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Could not write XML: " + ex);
		} catch (TransformerFactoryConfigurationError ex) {
			handleError(request, response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Could not write XML: " + ex);
		} catch (TransformerException ex) {
			handleError(request, response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Could not write XML: " + ex);
		} catch (IOException ex) {
			handleError(request, response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "IO exception while sending XML: " + ex);
		}
		
	}
	
	private void sendHtmlResult(String html, HttpServletRequest request,
			HttpServletResponse response) {
		
		// Request succeeded
		
		response.setStatus(HttpServletResponse.SC_OK);
		
		// Content type
		
		response.setContentType("text/html");
		
		// Write html response
		
		try {
			PrintWriter writer = response.getWriter();
			writer.write(html);
		} catch (IOException ex) {
			handleError(request, response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "IO exception while preparing response: " + ex);
		}

		
	}

	private void doGetFileList(HttpServletRequest request,
			HttpServletResponse response) {
		// TODO Implement doGetFileList
		
	}

	private void doPost(String operation, HttpServletRequest request,
			HttpServletResponse response) {
		
		if (TAG_OP.equals(operation)) {
			
			doTag(request, response);

		} else {
			
			handleError(request, response, HttpServletResponse.SC_BAD_REQUEST, "POST operation \'" + operation + "' not supported.");
			
		}
		
	}

	private void doTag(HttpServletRequest request, HttpServletResponse response) {
		
		logger_.debug("Do Tag, cookie: " + request.getHeader("cookie"));
		
		ServletFileUpload servletFileUpload = new ServletFileUpload();
		servletFileUpload.setFileItemFactory(new DiskFileItemFactory());

		List<MetaDataInfo>	mdDocuments = null;
		List<MetaDataInfo>	mdDocumentsToProcess = new ArrayList<MetaDataInfo>();
		String[]			concepts	= new String[0];
		List<Concept>		conceptList;
		
		// Get the session
		
		HttpSession session = request.getSession();
		
		synchronized (session) {
		
			logger_.debug("Do Tag, session: " + session.getId() + (session.isNew()?" (new)":" (existing)"));
			
			// Check if there is a document list in session
			
			mdDocuments = (List<MetaDataInfo>)session.getAttribute(MD_SESSION_OBJECT);
			
			// Create a new document list if needed
			
			if (mdDocuments == null) {
				mdDocuments = new ArrayList<MetaDataInfo>();
			}
			
			try {
				List<FileItem> items = servletFileUpload.parseRequest(request);
				if (items.isEmpty()) {
					// Do nothing
				} else {
					
					// Get request parameters and parse documents
					
					for (FileItem item : items) {
						if (item.isFormField()) {
							if (CONCEPTS_PARAM.equals(item.getFieldName())) {
								Gson gson = new Gson();
								concepts = gson.fromJson(item.getString(),String[].class);
							}
						}
						
						if (!item.isFormField() && item.getSize() > 0) {
							mdDocumentsToProcess.add(parseDocument(item, mdDocuments));
						}
					}
					
					// Store MD documents in session
					
					session.setAttribute(MD_SESSION_OBJECT, mdDocuments);
					
					// Resolve requested concepts
					
					conceptList = resolveConcepts(concepts);
					
					// Tag each meta data document
	
					tagMdDocuments(mdDocumentsToProcess, conceptList, request);
					
				}
				
				
			} catch (FileUploadException e) {
				logger_.warn("Do Tag, problem during upload: " +e);
			}
			
			sendResult(mdDocuments, request, response);
			
		} // synchronized
		
	}

	private void tagMdDocuments(List<MetaDataInfo> mdDocuments,
			List<Concept> conceptList, HttpServletRequest request) {
		
		String type;
		ValidationResult validationResult;
		MetadataHandlerRespository repo = MetadataHandlerRespository.getInstance();
		for (MetaDataInfo md : mdDocuments) {
			
			if (logger_.isInfoEnabled()) {
				StringBuilder sb = new StringBuilder();
				sb.append("Tagging file '");
				sb.append(md.getName());
				sb.append("' with concepts");
				for (Concept c : conceptList) {
					sb.append(" '");
					sb.append(c.getLabel());
					sb.append("'");
				}
				logger_.info(sb.toString());
			}
			
			Document doc = md.getDocument();
			
			if (doc != null) {
				
				// Identify document type
				
				type = repo.getType(md.getDocument());
				if (type != null) {
					md.setType(type);
				} else {
					md.setErrorMessage("Unknown file type");
					// No handlers have recognized the file,
					// we cannot continue processing it, go to
					// the next one.
					continue;
				}
				
				// Get handler
				
				MetadataHandler handler = repo.getHandler(type);
				
				// Identify document language
				
				md.setDocumentLanguage(handler.getLanguage(doc));
				
				// Identify MIME type
				
				String mtype = handler.getMimeType(type);
				if (mtype == null) {
					mtype = DEFAULT_MIME_TYPE;
				}
				md.setMimeType(mtype);
				
				// Tag metadata

				try {
					
					// Add concept to the document
					
					handler.addConcept(md.getDocument(), conceptList);
					
					// Validate document
					
					validationResult = handler.validate(md.getDocument(), xsdValidation, schematronValidation);
					md.setValidationResult(validationResult);

					if (validationResult.isSuccess()) {
						md.setStatus(Status.READY);
					} else {
						md.setStatus(Status.ERROR);
						md.setErrorMessage("Validation error");
						setErrorUrl(md, request);
					}
					
				} catch (MetadataHandlerException ex) {
					logger_.warn("Bad metadata: " + ex);
					md.setErrorMessage(ex.getMessage());
				}
				
			}
			
			// Print result document (test code)
			
//			System.out.println(" ===== Result document =====");
//			printDocument(doc);

		}
		
	}

	private void setErrorUrl(MetaDataInfo md, HttpServletRequest request) {

		md.setErrorUrl(request.getRequestURI()+String.format(ERROR_URL_TEMPLATE,md.getName()));
		
	}

	/**
	 * Parse document contained in a given FileItem. The parsed document will be added
	 * to the given List of MetaDataInfo if it was not yet present. 
	 * 
	 * @param fileItem The document to parse.
	 * @param mdDocuments The list to add the parsed document to.
	 * @return The parsed document.
	 */
	private MetaDataInfo parseDocument(FileItem fileItem, List<MetaDataInfo> mdDocuments) {
		
		MetaDataInfo mdInfo;
		DiskFileItem dfi = (DiskFileItem)fileItem;
		mdInfo = new MetaDataInfo(fileItem.getName());
		
		try {
			Document doc;
			DocumentBuilderFactory docBuilderFactory = DocumentBuilderFactory.newInstance();
			docBuilderFactory.setNamespaceAware(true);
			DocumentBuilder docBuilder = docBuilderFactory.newDocumentBuilder();
			doc = docBuilder.parse(dfi.getInputStream());
			//printDocument(doc);
			
			mdInfo.setDocument(doc);
			
		} catch (SAXException ex) {
			logger_.warn("Problem during parsing: " +ex);
			mdInfo.setErrorMessage("Bad XML document");
		} catch (ParserConfigurationException ex) {
			logger_.warn("Problem during parsing: " +ex);
			mdInfo.setErrorMessage("Bad XML document");
		} catch (IOException ex) {
			logger_.warn("Problem during parsing: " +ex);
			mdInfo.setErrorMessage("Bad XML document");
		}
		
		addDocument(mdInfo,mdDocuments);
		
		//System.out.println("Content:\n" + dfi.getString("ASCII"));
		
		return mdInfo;
	}

	private List<Concept> resolveConcepts(String[] concepts) {
		List<Concept> conceptList;

		conceptList = new ArrayList<Concept>();
		for (String conceptUri : concepts) {
			
			// Resolve concept (without requested language as the
			// document can be in multiple languages).
			
			Concept concept;
			concept = resolveConcept(conceptUri, "", false);
			
			// Add concept to list

			if (concept != null) {
				conceptList.add(concept);
			}
		}
		return conceptList;
	}

	private Thesaurus getThesaurusByUri(String uri) {
		
		Thesaurus t = null;
		
		t = thesaurusMapByUri_.get(uri);
		
		return t;
	}

	private void addDocument(MetaDataInfo mdInfo, List<MetaDataInfo> mdDocuments) {
		
		boolean found = false;

		// Check if document exists
		
		for (MetaDataInfo current: mdDocuments) {
			
			if (current.getName().equals(mdInfo.getName())) {
				found = true;
			}
			
		}
		
		
		// If document does not exist yet, add it
		
		if (!found) {
			mdDocuments.add(mdInfo);
		}
		
		logger_.debug("Add document, session has " + mdDocuments.size() + " documents");
		
	}

	private void doGetThesaurus(HttpServletRequest request,
			HttpServletResponse response) {
		
		logger_.debug("Get Thesaurus, cookie: " + request.getHeader("cookie"));
		logger_.info("Getting thesaurus: session = " + (request.getSession()!=null?request.getSession().getId():""));

		Collection<Thesaurus> list = thesaurusMapByName_.values();
		
		sendResult(list, request, response);
		
	}

	private void doResolve(HttpServletRequest request,
			HttpServletResponse response) {
		
		String conceptUri 	= request.getParameter(QUERY_PARAM);
		String lang			= request.getParameter(LANGUAGE_PARAM); 
		
		if (conceptUri == null) {

			handleError(request, response, HttpServletResponse.SC_BAD_REQUEST, "Resolve request without '" + QUERY_PARAM + "' parameter.");
			
		} else  if (lang == null) {
			
			handleError(request, response, HttpServletResponse.SC_BAD_REQUEST, "Resolve request without '" + LANGUAGE_PARAM + "' parameter.");
			
		} else {
		
			logger_.info("Resolving concept '" + conceptUri + "' in " + (lang==null?"<default_language>":lang));
			
			Concept concept;
			
			concept = resolveConcept(conceptUri, lang, true);
			
			sendResult(concept, request, response);
				
		}
		
	}
	
	private Concept resolveConcept(String conceptUri, String lang, boolean b) {
		
		Concept concept = null;
		Thesaurus th;
		
		// Find a thesaurus that handles this kind of conceptUri
		
		for (String thUri : thesaurusMapByUri_.keySet()) {
			
			th = thesaurusMapByUri_.get(thUri);
			
			if (th.matches(conceptUri)) {
				concept = resolveConcept(conceptUri, lang, th, b);
			}
			
			if (concept != null) {
				break;
			}
			
		}
		
		if (concept == null) {
			String label = conceptUri;
			if (conceptUri.startsWith(CUSTOM_URI_PREFIX)) {
				label = conceptUri.substring(CUSTOM_URI_PREFIX.length());
				conceptUri = null;
			} else {
				logger_.warn("No thesaurii could resolve concept '" + conceptUri + "'");
			}
			concept = new Concept(conceptUri);
			concept.setLabel(label);
		}
		
		return concept;
	}



	private void doSearch(HttpServletRequest request,
			HttpServletResponse response) {
		
		int maxResults = DEFAULT_MAX_RESULTS;
		
		String query = request.getParameter(QUERY_PARAM);
		String thesaurusName = request.getParameter(THESAURUS_PARAM);
		String lang = request.getParameter(LANGUAGE_PARAM);
		
		String max = request.getParameter(MAX_RESULTS_PARAM);
		if (max != null) {
			try {
				int tmp = Integer.parseInt(max);
				if (tmp <= 0) {
					throw new NumberFormatException();
				}
				maxResults = tmp;
			} catch (NumberFormatException ex) {
				logger_.warn("Invalid max results '" + max + "', using default: " + DEFAULT_MAX_RESULTS);
			}
		}
		
		if (query == null) {
			handleError(request, response, HttpServletResponse.SC_BAD_REQUEST, "Search request without '" + QUERY_PARAM + "' parameter.");
		} else if (thesaurusName == null) {
			handleError(request, response, HttpServletResponse.SC_BAD_REQUEST, "Search request without '" + THESAURUS_PARAM + "' parameter.");
			
		} else if (!checkThesaurus(thesaurusName)) {
			
			handleError(request, response, HttpServletResponse.SC_BAD_REQUEST, "Bad thesaurus name");
			
		} else {
			
			logger_.info("Searching for '" + query + "' in '" + (lang==null?"<default_language>":lang) + "' on '" + thesaurusName + "'");
			
			if (lang == null) {
				lang = DEFAULT_LANGUAGE;
			}
			
			Thesaurus thesaurus = thesaurusMapByName_.get(thesaurusName);
			
			try {
				
				Collection<Concept> results;
				
				results = searchConcept(query, thesaurus, lang, maxResults);
				
				sendResult(results, request, response);
				
			} catch (XPathExpressionException e) {
				handleError(request, response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "XPath error: " + e);
			} catch (IOException e) {
				handleError(request, response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "IO error: " + e);
			} catch (URISyntaxException e) {
				handleError(request, response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "URI error: " + e);
			} catch (ParserConfigurationException e) {
				handleError(request, response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Parse error: " + e);
			} catch (SAXException e) {
				handleError(request, response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Parse error: " + e);
			}
			
		}
		
		
	}

	private boolean checkThesaurus(String thesaurusName) {
		return thesaurusMapByName_.containsKey(thesaurusName);
	}

	private void sendResult(Object resultToJson, HttpServletRequest request,
			HttpServletResponse response) {
		
		Gson gson = new GsonBuilder().excludeFieldsWithoutExposeAnnotation().create();
		
		// Request succeeded
		
		response.setStatus(HttpServletResponse.SC_OK);
		
		// Put result object in the response
		
		try {
			response.setContentType("application/json;charset=UTF-8");
			PrintWriter writer = response.getWriter();
			writer.write(gson.toJson(resultToJson));
		} catch (IOException ex) {
			handleError(request, response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "IO exception while preparing response: " + ex);
		}
		
	}

	private void handleError(HttpServletRequest request,
			HttpServletResponse response, int errorCode, String errorMessage) {
		
		logger_.error("A problem occurred, sending " + errorCode + " " + errorMessage);
		
		try {
			response.sendError(errorCode, errorMessage);
		} catch (IOException e) {
			response.setStatus(errorCode);
		}
		
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
		String method = request.getParameter(OPERATION_PARAM);
		
		if (method == null || method.length() == 0) {
			// No method provided => error
			handleError(request, response, HttpServletResponse.SC_BAD_REQUEST, "No \"" + OPERATION_PARAM + "\" provided");
		} else {
			doPost(method, request, response);
		}
		
	}

	private void retrieveRelatedConcepts(Concept concept, String lang) {
		
		List<Concept> resolvedConcepts;;
		
		// Try to resolve related concepts
		
		resolvedConcepts = resolveConcepts(concept.getRelatedConcepts(), lang);
		
		concept.setRelatedConcepts(resolvedConcepts);
		
		// Try to resolve synonym concepts
		
		resolvedConcepts = resolveConcepts(concept.getSynonyms(), lang);
		
		concept.setSynonyms(resolvedConcepts);
		
		// Try to resolve close match concepts
		
		resolvedConcepts = resolveConcepts(concept.getCloseConcepts(), lang);
		
		concept.setCloseConcepts(resolvedConcepts);
		
		// Try to resolve broader concepts
		
		resolvedConcepts = resolveConcepts(concept.getBroaderConcepts(), lang);
		
		concept.setBroaderConcepts(resolvedConcepts);
		
		// Try to resolve narrower concepts
		
		resolvedConcepts = resolveConcepts(concept.getNarrowerConcepts(), lang);
		
		concept.setNarrowerConcepts(resolvedConcepts);
		
		// Try to resolve themes
		
		resolvedConcepts = resolveConcepts(concept.getThemes(), lang);
		
		concept.setThemes(resolvedConcepts);
		
		// Try to resolve groups
		
		resolvedConcepts = resolveConcepts(concept.getGroups(), lang);
		
		concept.setGroups(resolvedConcepts);
			
	}

	private List<Concept> resolveConcepts(List<Concept> conceptToResolve, String lang) {
		
		List<Concept> resolvedConcepts = new ArrayList<Concept>();
		
		Concept c;
		
		for (Concept relatedConcept : conceptToResolve) {
			
			c = resolveConcept(relatedConcept.getURI(), lang, false);
			
			if (c != null) {
				resolvedConcepts.add(c);
			} else {
				resolvedConcepts.add(relatedConcept);
			}
			
		}
			
		return resolvedConcepts;
		
	}

	private Concept resolveConceptWithSparql(String uri, String lang, Thesaurus thesaurus, boolean resolveRelated) {
		
		Concept resolvedConcept = null;
		
		// Create SPARQL query
		
		String query;

		query = "PREFIX skos: <http://www.w3.org/2004/02/skos/core#> " +
		"SELECT DISTINCT ?id ?predicate ?value" +
		" WHERE {" +
		" ?id ?predicate ?value ." +
		" FILTER (?id = <" + uri +">) ." +
	    "}";

		try {
			
			String url;
			
			url = thesaurus.getSparqlUrl();
			
			if (url != null) {
		
				// Create HTTP POST request
		
				List<NameValuePair> qparams = new ArrayList<NameValuePair>();
		
				qparams.add(new BasicNameValuePair("queryLn", "SPARQL"));        
				qparams.add(new BasicNameValuePair("query", query));
		
				
				HttpPost request = new HttpPost(url);
				request.addHeader("content-type","application/x-www-form-urlencoded");
				request.addHeader("accept","application/sparql-results+xml");
				UrlEncodedFormEntity  requestBody = new UrlEncodedFormEntity(qparams, "UTF-8");
				request.setEntity(requestBody);
				
				HttpClient httpclient = new DefaultHttpClient();
		
				// Execute request
				
				logger_.info("Resolving concept (using SPARQL) " + uri + " in '" + lang + "' from " + thesaurus.getName() + " (" + url + ")");
				
				HttpResponse response = httpclient.execute(request);
				
				// Check response
				
				if (response.getStatusLine().getStatusCode()/100 == 2) {
				
					// Parse result found in response body
			
					Collection<Concept>	retrievedConcepts	= null;
					
					HttpEntity entity = response.getEntity();
					
					if (entity != null) {
						
						InputStream instream = entity.getContent();
						SparqlResponseParser parser = new SparqlResponseParser();
						retrievedConcepts = parser.parse(instream, lang);
						
						instream.close();
			
						// Get the concept
						
						resolvedConcept = getConcept(retrievedConcepts,uri);
						
						// Check if we found the concept in the returned list
						
						if (resolvedConcept == null) {
							
							// No concept retrieve => concept could not be resolved
							
							logger_.warn("retrieveConcept: could not resolve concept " + uri + " (no results)");
							
						} else {
							resolvedConcept.setThesaurus(thesaurus);
							if (resolveRelated) {
								retrieveRelatedConcepts(resolvedConcept, lang);
							}
							
						}
						
					} // if (entity != null)
					
				} else {
					
					// An error has been returned
					
					logger_.error("An error has been returned during resolution of concept '" + 
							uri + "': " + response.getStatusLine().getStatusCode() + " " + 
							response.getStatusLine().getReasonPhrase());
					
				}
				
			} else {
				
				// SPARQL URL not found
				
				logger_.error("Could not find SPARQL URL for thesaurus: " + thesaurus.getName() + " (" + thesaurus.getUri() + ")");
				
			}
			
		} catch (IOException ex) {
			logger_.error("A problem occurred during resolution of concept '" + uri + "': " + ex);
		} catch (XPathExpressionException ex) {
			logger_.error("A problem occurred during resolution of concept '" + uri + "': " + ex);
		} catch (ParserConfigurationException ex) {
			logger_.error("A problem occurred during resolution of concept '" + uri + "': " + ex);
		} catch (SAXException ex) {
			logger_.error("A problem occurred during resolution of concept '" + uri + "': " + ex);
		}
		
		return resolvedConcept;
		
	}
	

	private Concept resolveConcept(String uri, String lang, Thesaurus thesaurus, boolean resolveRelated) {
		
		Concept concept = null;
		
		// Check if we have a lookup URL
		
		if (thesaurus.getUriLookupUrl() != null) {
            logger_.info("URILookupURL found in VoID file" );
			concept = resolveConceptByUri(uri, lang, thesaurus, resolveRelated);
		}
		
		// If not yet found, try using SPARQL
		
		if (concept == null && thesaurus.getSparqlUrl() != null) {
            logger_.info("No concept found, downgrading to SPARQL" );
			concept = resolveConceptWithSparql(uri, lang, thesaurus, resolveRelated);
		}
		
		return concept;
	}

	private Concept resolveConceptByUri(String uri, String lang, Thesaurus thesaurus, boolean resolveRelated) {
		
		Concept resolvedConcept = null;
		
		try {
			
			String url;
			
			// Create query
			
			url = thesaurus.getUriLookupUrl();
			
			if (url != null) {

				// Add concept URI to request URL
				
				url += URLEncoder.encode("<"+uri+">", "UTF8");
				
				// Create HTTP GET request
		
				HttpGet request = new HttpGet(url);
				
				HttpClient httpclient = new DefaultHttpClient();
		
				// Execute request
				
				logger_.info("Resolving concept (by URI) " + uri + " in '" + lang + "' from " + thesaurus.getName() + " (" + url + ")");
				
				HttpResponse response = httpclient.execute(request);
				
				// Check response
				
				if (response.getStatusLine().getStatusCode()/100 == 2) {
				
					// Parse result found in response body
			
					Collection<Concept>	retrievedConcepts	= null;
					
					HttpEntity entity = response.getEntity();
					
					if (entity != null) {
						
						InputStream instream = entity.getContent();
						SparqlResponseParser parser = new SparqlResponseParser();
						retrievedConcepts = parser.parse(instream, lang);
						
						instream.close();
			
						// Get the concept
						
						resolvedConcept = getConcept(retrievedConcepts,uri);
						
						// Check if we found the concept in the returned list
						
						if (resolvedConcept == null) {
							
							// No concept retrieve => concept could not be resolved
							
							logger_.warn("retrieveConcept: could not resolve concept " + uri + " (no results)");
							
						} else {
							resolvedConcept.setThesaurus(thesaurus);
							
							if (resolveRelated) {
								retrieveRelatedConcepts(resolvedConcept, lang);
							}
							
						}
						
						//System.out.println(convertStreamToString(instream));
						
					} // if (entity != null)
					
				} else {
					
					// An error has been returned
					
					logger_.error("An error has been returned during resolution of concept '" + 
							uri + "': " + response.getStatusLine().getStatusCode() + " " + 
							response.getStatusLine().getReasonPhrase());
					
				}
				
			} else {
				
				// SPARQL URL not found
				
				logger_.error("Could not find URI lookup URL for thesaurus: " + thesaurus.getName() + " (" + thesaurus.getUri() + ")");
				
			}
			
		} catch (IOException ex) {
			logger_.error("A problem occurred during resolution of concept '" + uri + "': " + ex);
		} catch (XPathExpressionException ex) {
			logger_.error("A problem occurred during resolution of concept '" + uri + "': " + ex);
		} catch (ParserConfigurationException ex) {
			logger_.error("A problem occurred during resolution of concept '" + uri + "': " + ex);
		} catch (SAXException ex) {
			logger_.error("A problem occurred during resolution of concept '" + uri + "': " + ex);
		}
		
		return resolvedConcept;
		
	}

	private Concept getConcept(Collection<Concept> conceptList, String uri) {

		Concept concept = null;

		for (Concept c : conceptList) {
			
			if (c.getURI().equals(uri)) {
				concept = c;
				break;
			}
			
		}
		
		return concept;
	}

	@Override
	public void init() throws ServletException {
		
		VoidDoc v;
		
		// Get the void description
		
		Document voidDoc;
		
		voidDoc = getVoidDocument();
		
		// Parse void
		
		try {
			v = VoidDoc.parse(voidDoc);
			
			//System.out.println(v);
			
		} catch (Exception ex) {
			logger_.error("Could retrieve VOID document: " + ex);
			throw new ServletException("Could retrieve VOID document",ex);
		}
		
		// Fill thesaurus list from VOID description
		
		Thesaurus t;
		for (Dataset ds : v.getDataSets()) {
			
			t = new Thesaurus(ds);
			addThesaurus(t);
			
		}
		
		// Check validation configuration
		
		String xsdValidationStr = getInitParameter(XSD_VALIDATION_PARAM);
		
		if (xsdValidationStr != null && xsdValidationStr.trim().length() != 0) {
			xsdValidation = Boolean.parseBoolean(xsdValidationStr);
		}
		
		String schematronValidationStr = getInitParameter(SCHEMATRON_VALIDATION_PARAM);
		
		if (schematronValidationStr != null && schematronValidationStr.trim().length() != 0) {
			schematronValidation = Boolean.parseBoolean(schematronValidationStr);
		}
		
	}

	private String getJsonOpensearchTemplateUrl(Thesaurus t) {
		
		String url;
		
		url	= t.getJsonSearchUrl(); 
		if (url == null && t.getOpenSearchUrl() != null) {
			url = resolveSearchUrl(t.getOpenSearchUrl(), JSON_MIME_TYPE);
			t.setJsonSearchUrl(url);
		}
		
		return url;
		
	}
	
	private String getRdfOpensearchTemplateUrl(Thesaurus t) {
		
		String url;
		
		url	= t.getRdfSearchUrl(); 
		if (url == null && t.getOpenSearchUrl() != null) {
			url = resolveSearchUrl(t.getOpenSearchUrl(), RDF_MIME_TYPE);
			t.setRdfSearchUrl(url);
		}
		
		return url;
		
	}

	private String resolveSearchUrl(String openSearchUrl, String format) {
		
		String searchUrl = null;
		
		Document doc;
		
		// Get open search document
		
		HttpGet request = new HttpGet(openSearchUrl);

		logger_.debug("Getting open search document from: " + openSearchUrl);
		
		HttpClient httpclient = new DefaultHttpClient();

		// Execute request
		
		try {
			HttpResponse response = httpclient.execute(request);
			
			if (response.getStatusLine().getStatusCode()/100 == 2) {
				
				HttpEntity entity = response.getEntity();
				
				if (entity != null) {
					
					// Create document from response
					
					DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
					dbFactory.setNamespaceAware(true);
					DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
					doc = dBuilder.parse(entity.getContent());

					// Find URL for result type 'application/json'
					
			        XPathFactory factory = XPathFactory.newInstance();
			        XPath xpath = factory.newXPath();
			        NamespaceResolver resolver = new NamespaceResolver();
			        resolver.addNamespace("", OPENSEARCH_NS);
			        xpath.setNamespaceContext(resolver);
			        
			        XPathExpression expression;
			        
			        String urlXpath = String.format(URL_XPATH_TEMPLATE,format);
					expression = xpath.compile(urlXpath);

			        Object result = expression.evaluate(doc, XPathConstants.NODE);
			        Node node = (Node) result;
			        
			        if (node != null && node instanceof Element) {
			        	
			        	searchUrl = ((Element)node).getAttribute(TEMPLATE_ATTR);
			        	
			        	logger_.debug("Found open search url template: " + searchUrl);
			        	
			        } else {
			        	
			        	if (logger_.isDebugEnabled()) {
				        	logger_.debug("Could not find \"" + urlXpath + "\" in opensearch document" );				        	
			        		logger_.debug("XML document:\n"+documentToString(doc));
			        	}
			        	
			        }

					
				} else {
					
					logger_.error("Could not parse open searh document, no response body");
					
				}
				
			} else {
				
				logger_.error("An error has been returned during opensearch retrieval: " + 
						response.getStatusLine().getStatusCode() + " " + 
						response.getStatusLine().getReasonPhrase());
				
			}
			
		} catch (ClientProtocolException ex) {
			logger_.error("Error during opensearch retrieval: " + ex);
		} catch (IOException ex) {
			logger_.error("Error during opensearch retrieval: " + ex);
		} catch (ParserConfigurationException ex) {
			logger_.error("Error during opensearch retrieval: " + ex);
		} catch (IllegalStateException ex) {
			logger_.error("Error during opensearch retrieval: " + ex);
		} catch (SAXException ex) {
			logger_.error("Error during opensearch retrieval: " + ex);
		} catch (XPathExpressionException ex) {
			logger_.error("Error during opensearch parsing, bad xpath: " + URL_XPATH_TEMPLATE);
		}

		
		
		return searchUrl;
	}

	private Document getVoidDocument() throws ServletException {

		Document doc = null;
		
		String voidUrl = getInitParameter(VOID_URL_INIT_PARAM);
		
		if (voidUrl == null) {
			throw new ServletException("Missing " + VOID_URL_INIT_PARAM + " init parameter");
		}
		
		HttpGet request = new HttpGet(voidUrl);

		logger_.info("Getting void from: " + voidUrl);
		
		HttpClient httpclient = new DefaultHttpClient();

		// Execute request
		
		try {
			HttpResponse response = httpclient.execute(request);
			
			if (response.getStatusLine().getStatusCode()/100 == 2) {
				
				HttpEntity entity = response.getEntity();
				
				if (entity != null) {
					
					// Create document from response
					
					DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
					dbFactory.setNamespaceAware(true);
					DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
					doc = dBuilder.parse(entity.getContent());
					
				} else {
					
					logger_.error("Could not parse void description");
					
					throw new ServletException("Initialization failed: Could not parse void description");
					
				}
				
			} else {
				
				logger_.error("An error has been returned during void retrieval: " + 
						response.getStatusLine().getStatusCode() + " " + 
						response.getStatusLine().getReasonPhrase());
				
				throw new ServletException("Initialization failed: Could not get void description: " + 
						response.getStatusLine().getStatusCode() + " " + 
						response.getStatusLine().getReasonPhrase());

			}
			
		} catch (ClientProtocolException ex) {
			logger_.error("Error during void retrieval: " + ex);
			throw new ServletException("Initialization failed: Could not get void description: " + ex);
		} catch (IOException ex) {
			logger_.error("Error during void retrieval: " + ex);
			throw new ServletException("Initialization failed: Could not get void description: " + ex);
		} catch (ParserConfigurationException ex) {
			logger_.error("Error during void parsing: " + ex);
			throw new ServletException("Initialization failed: Could not parse void description: " + ex);
		} catch (IllegalStateException ex) {
			logger_.error("Error during void parsing: " + ex);
			throw new ServletException("Initialization failed: Could not parse void description: " + ex);
		} catch (SAXException ex) {
			logger_.error("Error during void parsing: " + ex);
			throw new ServletException("Initialization failed: Could not parse void description: " + ex);
		}

		
		return doc;
	}

	private void addThesaurus(Thesaurus t) {
		thesaurusMapByName_.put(t.getDisplayName(), t);
		thesaurusMapByUri_.put(t.getUri(),t);
	}

	private String documentToString(Document doc) {
		return elementToString(doc.getDocumentElement());
	}
	
	private String elementToString(Element element) {
		
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		Transformer transformer;
		
		try {
			transformer = TransformerFactory.newInstance().newTransformer();
			transformer.setOutputProperty(OutputKeys.INDENT, "yes");
			DOMSource domSrc = new DOMSource(element);
				transformer.transform(domSrc, new StreamResult(bos));
				
		} catch (TransformerConfigurationException e) {
			// Do nothing
		} catch (TransformerFactoryConfigurationError e) {
			// Do nothing
		} catch (TransformerException e) {
			// Do nothing
		}
		
		return bos.toString();

	}
	
	private void writeDocument(Document doc, OutputStream os) {
		
		Transformer transformer;
		
		try {
			transformer = TransformerFactory.newInstance().newTransformer();
			transformer.setOutputProperty(OutputKeys.INDENT, "yes");
			DOMSource domSrc = new DOMSource(doc);
			transformer.transform(domSrc, new StreamResult(os));
				
		} catch (TransformerConfigurationException e) {
			// Do nothing
		} catch (TransformerFactoryConfigurationError e) {
			// Do nothing
		} catch (TransformerException e) {
			// Do nothing
		}
		
	}

	public Collection<Concept> searchConcept(String searchTerm, Thesaurus thesaurus, String lang, int maxResults) throws IOException, URISyntaxException, XPathExpressionException, ParserConfigurationException, SAXException {
	
		Collection<Concept> concepts;

		String urlTemplate;
		
//		// Try first to find with an open search URL returning JSON
//		
//		urlTemplate = getJsonOpensearchTemplateUrl(thesaurus);
//		
//		if (urlTemplate != null) {
//		
//			concepts = searchConceptWithJsonOpenSearch(searchTerm, lang,maxResults, urlTemplate);
//			    
//		} else {
//		
//			// Json output not found
		
			// Try to find an open search URL returning RDF
			
			urlTemplate = getRdfOpensearchTemplateUrl(thesaurus);
			
			if (urlTemplate != null) {
				
                logger_.info("Searching for '"+searchTerm+"' using Opensearch for thesaurus " + thesaurus.getName());
				concepts = searchConceptWithRdfOpenSearch(searchTerm, lang,maxResults, urlTemplate);

			} else {
			
				// If not possible fall back to SPARQL search

                logger_.info("No Opensearch endpoint advertised for Searching for '"+searchTerm+"'. Fallback on Sparql ");


				String sparqlEndpoint = thesaurus.getSparqlUrl();
				
				if (sparqlEndpoint != null) {
					
					concepts = searchConceptWithSparql(searchTerm, lang,maxResults, sparqlEndpoint);
				
				} else {
					
					// Could not find an opensearch url template
					
					logger_.warn("Could not find an opensearch URL template nor a SparQL endpoint for thesaurus: " + thesaurus.getName() + " (" + thesaurus.getUri() + ")");
					concepts = new ArrayList<Concept>(0);
					
				}
				
			}
			
//		}
	    return concepts;
	}

	private Collection<Concept> searchConceptWithSparql(String searchTerm,
			String lang, int maxResults, String sparqlUrl) throws ClientProtocolException, IOException, XPathExpressionException, ParserConfigurationException, SAXException {
		
		logger_.info("SparQL search: '" + searchTerm + "' (lang=" + lang + ", max="+maxResults+", url=" + sparqlUrl +")");
		
		String query = "PREFIX skos: <http://www.w3.org/2004/02/skos/core#> " +
		"SELECT DISTINCT ?id ?label ?definition " +
		"WHERE {" +
		"?id skos:prefLabel ?label ; " +
		"FILTER langMatches( lang(?label), '" + lang + "' ) . " +
		"OPTIONAL {?id skos:definition ?definition ; " +
		"FILTER langMatches( lang(?definition), '" + lang + "' )} . " +
		"FILTER (regex(str(?label), '" + searchTerm + "','i')) " +
		"} LIMIT " + maxResults_;


		List<NameValuePair> qparams = new ArrayList<NameValuePair>();

		qparams.add(new BasicNameValuePair("queryLn", "SPARQL"));        
		qparams.add(new BasicNameValuePair("query", query));

		HttpPost request = new HttpPost(sparqlUrl);
		request.addHeader("content-type","application/x-www-form-urlencoded");
		request.addHeader("accept","application/sparql-results+xml");

		UrlEncodedFormEntity  requestBody = new UrlEncodedFormEntity(qparams, "UTF-8");
		request.setEntity(requestBody);
		
		HttpClient httpclient = new DefaultHttpClient();

		HttpResponse response = httpclient.execute(request);
		HttpEntity entity = response.getEntity();
		Collection<Concept> concepts = null;
		if (entity != null) {
			InputStream instream = entity.getContent();
			SparqlResponseParser parser = new SparqlResponseParser();
			concepts = parser.parse(instream, lang);
			instream.close();
		} else {
			concepts = new ArrayList<Concept>(0);
		}
		return concepts;
	}

	private Collection<Concept> searchConceptWithJsonOpenSearch(String searchTerm,
			String lang, int maxResults, String urlTemplate)
			throws IOException, ClientProtocolException {
		
		Collection<Concept> concepts;
		String url;
		
		logger_.info("Json OpenSearch search: '" + searchTerm + "' (lang=" + lang + ", max="+maxResults+", url="+ urlTemplate + ")");
		
		// Change known parameters
		
		url = urlTemplate.replace(SEARCH_TERMS_PARAM_TAG, searchTerm)
				.replace(LANGUAGE_PARAM_TAG, lang)
				.replace(MAX_RESULTS_PARAM_TAG, Integer.toString(maxResults));
		
		// Clear all other parameters
		
		url = url.replaceAll(OPEN_SEARCH_PARAM_TAG, "");
		
		logger_.debug("Search url: " + url);
		
		HttpGet httpget = new HttpGet(url);
		httpget.addHeader("content-type","application/x-www-form-urlencoded");
		httpget.addHeader("accept",JSON_MIME_TYPE);

		HttpClient httpclient = new DefaultHttpClient();

		HttpResponse response = httpclient.execute(httpget);
		
		if (response.getStatusLine().getStatusCode()/100 == 2) {
		
		    HttpEntity entity = response.getEntity();
		    if (entity != null) {
		        InputStream instream = entity.getContent();
		        // Parse json results
		        Gson gson = new Gson();
		        try {
//		        	ByteArrayOutputStream baos = new ByteArrayOutputStream();
//		        	entity.writeTo(baos);
//		        	System.out.println("Response:\n" + new String(baos.toByteArray()));
//		        	SearchResults results = gson.fromJson(new InputStreamReader(instream),SearchResults.class);
//		        	Concept[] carray=null;// = results.getSearchResults();
		        	Concept[] carray= gson.fromJson(new InputStreamReader(instream),Concept[].class);
		        	if (carray != null) {
		        		concepts = Arrays.asList(carray);
		        	} else {
		        		concepts = new ArrayList<Concept>(0);
		        		logger_.error("Search reponse contains no data!");
		        	}
		        } catch (JsonParseException ex) {
		        	logger_.error("Could not parse search result: " + ex);
		        	concepts = new ArrayList<Concept>(0);
		        }
		        instream.close();
		    } else {
		    	concepts = new ArrayList<Concept>(0);
		    }
		    
		} else {
			
			// Error response received
			
			logger_.warn("An error has been returned by opensearch: " + 
					response.getStatusLine().getStatusCode() + " " + 
					response.getStatusLine().getReasonPhrase());

			concepts = new ArrayList<Concept>(0);
			
		}
		return concepts;
	}
	
	private Collection<Concept> searchConceptWithRdfOpenSearch(String searchTerm,
			String lang, int maxResults, String urlTemplate)
			throws IOException, ClientProtocolException {
		
		Collection<Concept> concepts;
		String url;
		
		searchTerm = URLEncoder.encode(searchTerm, "UTF-8");
		
		logger_.info("RDF OpenSearch search: '" + searchTerm + "' (lang=" + lang + ", max="+maxResults+", urlTemplate="+ urlTemplate + ")");
		
		// Change known parameters
		
		url = urlTemplate.replace(SEARCH_TERMS_PARAM_TAG, searchTerm)
				.replace(LANGUAGE_PARAM_TAG, lang)
				.replace(MAX_RESULTS_PARAM_TAG, Integer.toString(maxResults));



		// Clear all other parameters
		
		url = url.replaceAll(OPEN_SEARCH_PARAM_TAG, "");
				
		logger_.info("Search url: " + url);
		
		HttpGet httpget = new HttpGet(url);
		httpget.addHeader("content-type","application/x-www-form-urlencoded");
		httpget.addHeader("accept",RDF_MIME_TYPE);

		HttpClient httpclient = new DefaultHttpClient();

		HttpResponse response = httpclient.execute(httpget);
		
		if (response.getStatusLine().getStatusCode()/100 == 2) {
		
		    HttpEntity entity = response.getEntity();
		    if (entity != null) {
		        InputStream instream = entity.getContent();
		        // Parse RDF results
		        RdfDocParser rdfParser = new RdfDocParser();
		        try {
		        	concepts = rdfParser.parse(instream, lang);
		        } catch (XPathExpressionException ex) {
		        	logger_.error("Could not parse search result: " + ex);
		        	concepts = new ArrayList<Concept>(0);
				} catch (ParserConfigurationException ex) {
		        	logger_.error("Could not parse search result: " + ex);
		        	concepts = new ArrayList<Concept>(0);
				} catch (SAXException ex) {
		        	logger_.error("Could not parse search result: " + ex);
		        	concepts = new ArrayList<Concept>(0);
				}
		        instream.close();
		    } else {
		    	concepts = new ArrayList<Concept>(0);
		    }
		    
		} else {
			
			// Error response received
			
			logger_.warn("An error has been returned by opensearch: " + 
					response.getStatusLine().getStatusCode() + " " + 
					response.getStatusLine().getReasonPhrase());

			concepts = new ArrayList<Concept>(0);
			
		}
		return concepts;
	}
	
}
