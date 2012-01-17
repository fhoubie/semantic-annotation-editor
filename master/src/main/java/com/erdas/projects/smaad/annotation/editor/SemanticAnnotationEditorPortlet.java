package com.erdas.projects.smaad.annotation.editor;

import java.io.IOException;
import java.util.Enumeration;

import javax.portlet.GenericPortlet;
import javax.portlet.PortletException;
import javax.portlet.PortletPreferences;
import javax.portlet.PortletRequestDispatcher;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;
import javax.portlet.WindowState;

public class SemanticAnnotationEditorPortlet extends GenericPortlet {

	public void doView(
	        RenderRequest renderRequest, RenderResponse renderResponse)
	    throws IOException, PortletException {
	    
	    include("/html/portlets/editor-portlet.jsp", renderRequest, renderResponse);
	    
//	    StringBuilder sb = new StringBuilder();
//	    
//	    sb.append("<h1>Semantic Annotation Editor</h1>");
//	    
//	    WindowState wstate = renderRequest.getWindowState();
//	    
//	    if (wstate.equals(WindowState.MAXIMIZED)) {
//	    	sb.append("MAXIMIZED!<BR>");
//	    } else {
//	    	sb.append("NORMAL.<BR>");
//	    }
//	    
//	    sb.append("<HR>");
//	    
//	    PortletPreferences pprefs = renderRequest.getPreferences();
//	    
//	    sb.append("Parameters:<BR>");
//	    Enumeration<String> en = getInitParameterNames();
//	    if (en.hasMoreElements()) {
//	        while (en.hasMoreElements()) {
//	        	String name = en.nextElement();
//	        	String val	= getInitParameter(name);
//	        	sb.append("<LI>");
//	        	sb.append(name);
//	        	sb.append(": ");
//	        	sb.append(val);
//	        }
//	    } else {
//	    	sb.append("&lt;none&gt;");
//	    }
//	
//	    sb.append("<BR>Preferences:<BR>");
//	    en = pprefs.getNames();
//	    if (en.hasMoreElements()) {
//	        while (en.hasMoreElements()) {
//	        	String name = en.nextElement();
//	        	String val	= pprefs.getValue(name, "");
//	        	sb.append("<LI>");
//	        	sb.append(name);
//	        	sb.append(": ");
//	        	sb.append(val);
//	        }
//	    } else {
//	    	sb.append("&lt;none&gt;");
//	    }
//	    
//	
//	    
//	    renderResponse.getWriter().print(sb.toString());
	}

	protected void include(
	        String path, RenderRequest renderRequest,
	        RenderResponse renderResponse)
	    throws IOException, PortletException {
	
	    PortletRequestDispatcher portletRequestDispatcher =
	        getPortletContext().getRequestDispatcher(path);
	
	    if (portletRequestDispatcher == null) {
	        System.out.println(path + " is not a valid include");
	    }
	    else {
	        portletRequestDispatcher.include(renderRequest, renderResponse);
	    }
	}

	
}
