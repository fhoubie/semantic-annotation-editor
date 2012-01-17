package com.erdas.projects.smaad.annotation.md;

import java.util.LinkedHashMap;
import java.util.Map;

import org.w3c.dom.Document;

import com.erdas.projects.smaad.annotation.md.iso.Iso19115Handler;
import com.erdas.projects.smaad.annotation.md.ogc.OgcHandler;
import com.erdas.projects.smaad.annotation.md.sensorml.SensorMLHandler;

public class MetadataHandlerRespository {

	// Fields
	
	static MetadataHandlerRespository instance_ = null;
	
	Map<String, MetadataHandler> handlerMap_	= new LinkedHashMap<String, MetadataHandler>();
	
	// Constructors
	
	public MetadataHandlerRespository() {
		registerHandler(new Iso19115Handler());
		registerHandler(new OgcHandler());
		registerHandler(new SensorMLHandler());
	}
	
	// Methods
	
	public static MetadataHandlerRespository getInstance() {
		
		if (instance_ == null) {
			instance_ = new MetadataHandlerRespository();
		}
		
		return instance_;
		
	}
	
	public String getType(Document doc) {
		
		String type = null;
		
		for (MetadataHandler handler : handlerMap_.values()) {
			type = handler.getType(doc);
			if (type != null) {
				break;
			}
		}
		
		return type;
		
	}
	public MetadataHandler getHandler(String type) {
		return handlerMap_.get(type);
	}
	
	public void registerHandler(MetadataHandler handler) {
		
		for (String type : handler.getSupportedTypes()) {
			handlerMap_.put(type, handler);
		}
		
	}

	
}
