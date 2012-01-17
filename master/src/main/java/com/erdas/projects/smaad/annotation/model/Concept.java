package com.erdas.projects.smaad.annotation.model;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.google.gson.annotations.Expose;

/**
 * Created by IntelliJ IDEA.
 * User: fskivee
 * Date: 30-déc.-2010
 * Time: 13:42:28
 * To change this template use File | Settings | File Templates.
 */
public class Concept {

	@Expose
	private String URI;
	@Expose
    private String label;
	@Expose
    private String description;
	@Expose
    private Thesaurus thesaurus;
	@Expose
    private List<Concept> groups			= new ArrayList<Concept>();
	@Expose
    private List<Concept> themes			= new ArrayList<Concept>();
	@Expose
    private List<Concept> closeConcepts		= new ArrayList<Concept>();
	@Expose
    private List<Concept> relatedConcepts	= new ArrayList<Concept>();
	@Expose
    private List<Concept> exactConcepts		= new ArrayList<Concept>(); 
	@Expose
    private List<Concept> broaderConcepts	= new ArrayList<Concept>(); 
	@Expose
    private List<Concept> narrowerConcepts	= new ArrayList<Concept>();
	
	// Multi-langual property maps
	
	private Map<String, String> labelMap_	= new HashMap<String, String>();

    public Concept() {
    }
    
    public Concept(String uri) {
		URI = uri;
	}

	public String getURI() {
        return URI;
    }

    public void setURI(String URI) {
        this.URI = URI;
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
    
    public void addRelatedConcept(Concept c) {
    	relatedConcepts.add(c);
    }
    
    public void addSynonym(Concept c) {
    	exactConcepts.add(c);
    }
    
    public void addCloseConcept(Concept c) {
    	closeConcepts.add(c);
    }
    
    public void addBroaderConcept(Concept c) {
    	broaderConcepts.add(c);
    }
    
    public void addNarrowerConcept(Concept c) {
    	narrowerConcepts.add(c);
    }
    
    public void addTheme(Concept c) {
    	themes.add(c);
    }
    
    public void addGroup(Concept c) {
    	groups.add(c);
    }

	public List<Concept> getRelatedConcepts() {
		return relatedConcepts;
	}

	public List<Concept> getSynonyms() {
		return exactConcepts;
	}

	public void setRelatedConcepts(List<Concept> relatedConcepts) {
		this.relatedConcepts = relatedConcepts;
	}

	public void setSynonyms(List<Concept> synonyms) {
		this.exactConcepts = synonyms;
	}

	public List<Concept> getGroups() {
		return groups;
	}

	public void setGroups(List<Concept> groups) {
		this.groups = groups;
	}

	public List<Concept> getThemes() {
		return themes;
	}

	public void setThemes(List<Concept> themes) {
		this.themes = themes;
	}

	public List<Concept> getCloseConcepts() {
		return closeConcepts;
	}

	public void setCloseConcepts(List<Concept> closeConcepts) {
		this.closeConcepts = closeConcepts;
	}

	public List<Concept> getBroaderConcepts() {
		return broaderConcepts;
	}

	public void setBroaderConcepts(List<Concept> broaderConcepts) {
		this.broaderConcepts = broaderConcepts;
	}

	public List<Concept> getNarrowerConcepts() {
		return narrowerConcepts;
	}

	public void setNarrowerConcepts(List<Concept> narrowerConcepts) {
		this.narrowerConcepts = narrowerConcepts;
	}
	
    public Thesaurus getThesaurus() {
		return thesaurus;
	}

	public void setThesaurus(Thesaurus thesaurus) {
		this.thesaurus = thesaurus;
	}

	public String getLabel(String lang) {
		String label;
		
		label = labelMap_.get(lang);
		
		if (label == null) {
			// Not found, return the default language value
			label = this.label;
		}
		
		return label;
	}
	
	public void addLabel(String label, String lang) {
		labelMap_.put(lang, label);
	}
	
	/**
	 * Check if two concepts match.
	 * 
	 * @param c1 The first concept
	 * @param c2 The second concept
	 * @return <code>true</code> if the concepts match.
	 */
	public static boolean match(Concept c1, Concept c2) {
		
		boolean match;
		
		if (c1.getThesaurus() == null) {
			
			if (c2.getThesaurus() == null && c2.getLabel() != null) {
				
				match = c2.getLabel().equalsIgnoreCase(c1.getLabel());
				
			} else {
				
				match = false;
			}
			
		} else {
			
			if (c2.getThesaurus() != null && c2.getURI() != null) {
				
				match = c2.getURI().equals(c1.getURI()) &&
						c2.getThesaurus().getUri().equals(c1.getURI());
				
			} else {
				
				match = false;
				
			}
			
		}
		
		return match;
	}
	
	
	@Override
	public String toString() {
		
		String ret = getLabel();

		if (thesaurus != null) {
			ret += " (" + getURI() + ")";
		}
		
		return ret;
	}
	
}

