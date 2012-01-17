
	if (!Namespace.exist('com.erdas.smaad')) {
		
	// First define name space

	Namespace('com.erdas.smaad');

	// Define variables an functions inside the name space
	
	com.erdas.smaad = {
			
		servletName : "smaad-annotation-core",
			
		baseUrl : "",
			
		uploader : {},
			
		Y : {},
		
		searchRequest : undefined,
		
		progressCount : 0,
		
		searchResults : {},
		fileList : new Array(),
		resolvedConcepts : {},
		selectedConcepts : new Array(),
		
		reset : function () {
			com.erdas.smaad.searchResults = new Array();
			com.erdas.smaad.selectedConcepts = new Array();
			com.erdas.smaad.fileList = new Array();
			com.erdas.smaad.uploader.clearFileList();
			com.erdas.smaad.updateFilesFromSelection(new Array());
			com.erdas.smaad.updateSelectedConcepts();
			com.erdas.smaad.selectConcept(undefined);
			com.erdas.smaad.updateSearchResults({});
		},
		
		removeFile : function (id) {
			var fileData = com.erdas.smaad.uploader.removeFile(id);
			com.erdas.smaad.updateFilesFromSelection(fileData);
		},
		
		toNiceSize : function (size) {
			
			var s;
			
			if (size < 1024) {
				s = "&lt;&nbsp;1&nbsp;Ko";
			} else {
				s = Math.round(size / 1024) + "&nbsp;Ko";
			}
			
			return s;
			
		},
		
		size : function(obj) {
		    var size = 0, key;
		    for (key in obj) {
		        if (obj.hasOwnProperty(key)) {
		        	size++;
		        }
		    }
		    return size;
		},

	
		isEmpty : function (obj){
			
			   for(var prop in obj) {
				   if (obj.hasOwnProperty(prop)) {
					   return false;
				   }
			   }
			   
			   return true;
		},
		
		getSessionId : function () {
			
			var i,x,y;
			var cookies=document.cookie.split(";");
			for (i=0;i<cookies.length;i++)
			{
			  x=cookies[i].substr(0,cookies[i].indexOf("="));
			  y=cookies[i].substr(cookies[i].indexOf("=")+1);
			  x=x.replace(/^\s+|\s+$/g,"");
			  if (x=="JSESSIONID")
			    {
			    return unescape(y);
			    }
			  }
			
		},
		
		getBaseUrl : function () {

			var baseUrl = "/" + com.erdas.smaad.servletName + "/";
			
			return baseUrl;
			
		},
		
		createOverlay : function () {
			
			var main = com.erdas.smaad.Y.one("#smaad\\.main");
			
			var dialog;
			
			// Create the main overlay
			
			dialog = new com.erdas.smaad.Y.Overlay({
				
				id			: 'smaad.progressOverlay',
				width		: '300px',
				zIndex		: 100,
				centered	: true,
				constrain	: true,
				visible		: false,
				centered	: '#smaad\\.main'
//				align		: {node: "#smaad\\.main", points: [com.erdas.smaad.Y.WidgetPositionAlign.CC, com.erdas.smaad.Y.WidgetPositionAlign.CC]},
//				plugins		: [com.erdas.smaad.Y.Plugin.OverlayModal]
									
			});
			
			dialog.set("headerContent","<div class='progressTitle'>Work in progress</h1>");
			dialog.set("bodyContent","<div id='smaad.progressDialog.infoDiv'>Preparing upload...</div>");
			dialog.set("footerContent","<div id='smaad.progressDialog.progressDiv' style='height:20px'></div>");

			dialog.render('#smaad\\.main');
			
			var progressBar = new com.erdas.smaad.Y.ProgressBar({id:"smaad.progressDialog.progressBar", progress : 0, animation: {easing: com.erdas.smaad.Y.Easing.easeIn, duration: 0.1}, layout : '<div class="{labelClass}"></div><div class="{sliderClass}"></div>'});
			progressBar.set("progress", 0);
			progressBar.render("#smaad\\.progressDialog\\.progressDiv");


			com.erdas.smaad.progressDialog = dialog;
			com.erdas.smaad.progressBar = progressBar;
		},
		
		getFileEntryById : function (fileId) {
			
			var entry = null;
			for (var name in com.erdas.smaad.fileList) {
				if (com.erdas.smaad.fileList[name].id == fileId) {
					entry = com.erdas.smaad.fileList[name];
				}
			}
			return entry;
		},
		
		updateProgressDialog : function (fileId, progress) {
			
			var fileEntry = com.erdas.smaad.getFileEntryById(fileId);
			if (fileEntry != undefined) {
				fileEntry.progress = progress;
				
				// Calculate infos
				
				var total = com.erdas.smaad.size(com.erdas.smaad.fileList)
				com.erdas.smaad.progressCount++;
				var nb = com.erdas.smaad.progressCount;
				
				// Update progress bar
				
				com.erdas.smaad.progressBar.set("progress", 100*nb/total);
				
				// Update dialog
				
				com.erdas.smaad.Y.one("#smaad\\.progressDialog\\.infoDiv").setContent("Tagging file " + nb + " / " + total + "<br>"+ fileEntry.name + " (" + progress + "%)");
				var content = com.erdas.smaad.Y.Node.create("<span></span>");
				content.set("innerHTML", "Tagging file " + fileEntry.name + " " + progress + "%");
				
				if (nb  >= total) {
					
					// Hide dialog if finished
					
					com.erdas.smaad.progressDialog.hide();
					
				}
				
				
				
			}
			
			
		},
		
		showSearchResults : function () {
			
			var searchResultDiv = com.erdas.smaad.Y.one("#smaad\\.searchResultDiv");			
			var fileDiv = com.erdas.smaad.Y.one("#smaad\\.fileDiv");
			var title = com.erdas.smaad.Y.one("#smaad\\.listTitle");
			
			// Set div visibility
			
			searchResultDiv.setStyle('visibility','visible');
			searchResultDiv.setStyle('display','block');
			fileDiv.setStyle('visibility','hidden');
			fileDiv.setStyle('display','none');
			
			// Set title
			
			var titleContent = "<a onclick='com.erdas.smaad.showFileList()' style='color: inherit;' title='Click to show selected files'>Search results";
			var nb = com.erdas.smaad.size(com.erdas.smaad.searchResults);
			if (nb > 0) {
				titleContent += " (" + nb + ")";
			}
			title.setContent(titleContent);
			titleContent += "</a>"
			
		},
		
		showFileList : function () {
			
			var searchResultDiv = com.erdas.smaad.Y.one("#smaad\\.searchResultDiv");			
			var fileDiv = com.erdas.smaad.Y.one("#smaad\\.fileDiv");
			var title = com.erdas.smaad.Y.one("#smaad\\.listTitle");
			
			// Set div visibility
			
			searchResultDiv.setStyle('visibility','hidden');
			searchResultDiv.setStyle('display','none');
			fileDiv.setStyle('visibility','visible');
			fileDiv.setStyle('display','block');
			
			// Set title
			
			var titleContent = "<a onclick='com.erdas.smaad.showSearchResults()' style='color: inherit;' title='Click to show search results'>Files";
			var nb = com.erdas.smaad.size(com.erdas.smaad.fileList)
			if (nb > 0) {
				titleContent += " (" + nb + ")";
			}
			titleContent += "</a>"
			title.setContent(titleContent);
			
		},
		
		updateFilesFromTagging : function (fileData) {
			
			for (var i in fileData) {
				var fileEntry = com.erdas.smaad.fileList[fileData[i].name];
				if (fileEntry != undefined) {
					fileEntry.status	= fileData[i].status;
					fileEntry.type	 	= fileData[i].type;
					fileEntry.progress	= 100;
					var div = com.erdas.smaad.Y.one("#smaad\\.file\\.status_"+fileEntry.id);
					if (fileEntry.status == "READY") {
						div.setContent("<a target='_blank' href='" + com.erdas.smaad.baseUrl + "service?op=get&file=" + fileEntry.name + "' title='download'>" + fileEntry.status + "</a>")
					} else if (fileEntry.status = "ERROR") {
						if (fileData[i].errorUrl) {
							div.setContent("<a class='error' target='_blank' href='" + fileData[i].errorUrl +"' title='" + fileData[i].errorMessage + "'>" + fileEntry.status + "</a>")
						} else {
							div.setContent("<span title='" + fileData[i].errorMessage + "'>"+fileEntry.status+"</span>");
						}
						div.addClass("error");
					} else {
						div.setContent(fileEntry.status);
					}
					var div = com.erdas.smaad.Y.one("#smaad\\.file\\.type_"+fileEntry.id);
					if (fileEntry.type != undefined) {
						div.setContent(fileEntry.type);
					} else {
						div.setContent("?");
					}
				}
			}
			//com.erdas.smaad.updateFileList();
		},
		
		updateFilesFromSelection : function (fileData) {
			
			com.erdas.smaad.fileList = new Array();
			for (var i in fileData) {
				com.erdas.smaad.fileList[fileData[i].name] = {
					"name"		: fileData[i].name,
					"id"		: fileData[i].id,
					"size"		: fileData[i].size,
					"type"		: "?",
					"status"	: "waiting",
					"progress"	: 0
				};
			}
			
			com.erdas.smaad.updateFileList();
			
		},
	
		
		updateFileList : function () {
			
			var fileData = com.erdas.smaad.fileList;
			
			var content = "";
			content += "<tr><th>Filename</th><th>File&nbsp;type</th><th>Size</th><th>Status</th><th></th><th></th></tr>"
			
			if (com.erdas.smaad.isEmpty(fileData)) {
				content += "<tr><td>&lt;no files selected&gt;</td><td></td><td></td><td></td><td></td></tr>";
			} else {
				for (var key in fileData) {
	
					var progressBar = new com.erdas.smaad.Y.ProgressBar({id:"pb_" + fileData[key].id, progress : 0, animation : false, layout : '<div class="{labelClass}"></div><div class="{sliderClass}"></div>'});
					progressBar.set("progress", 0);
					progressBar.setLabelAt(0,"not uploaded");
					progressBar.setLabelAt(1,"uploading...");
					progressBar.setLabelAt(100,"ready");
					
					var id = fileData[key].id;
					var sid = '"' + id + '"';
					var output = "<tr><td>" + fileData[key].name + "</td><td id='smaad.file.type_"+id+"'>" + fileData[key].type+ "</td><td>" + com.erdas.smaad.toNiceSize(fileData[key].size) + "</td>";
					output += "<td><div class='fileStatus' id='smaad.file.status_" + id + "'>" + fileData[key].status + "</div></td>";
					output += "<td></td>";
					output += "<td style='padding: 0;'><a class='smallButton' href='#' title='remove' onclick='com.erdas.smaad.removeFile(" + sid + ")'>X</a></td></tr>\n"; 
					
					content += output;
					
				}
				
			}
			// Use standard dom method instead of YUI'one to workaround a bug in YUI 3.2 (corrected in 3.3)
			// in latest Chrome versions.
			document.getElementById("smaad.filenameTable").innerHTML = content;
			com.erdas.smaad.showFileList();
			
		},
		
		init : function () {

			com.erdas.smaad.baseUrl = com.erdas.smaad.getBaseUrl();
			
			var overlayRegion = this.one("#selectLink").get('region');
			this.log(overlayRegion);
			this.one("#uploaderOverlay").set("offsetWidth", overlayRegion.width);
			this.one("#uploaderOverlay").set("offsetHeight", overlayRegion.height);
	
			uploader = new this.Uploader({boundingBox:"#uploaderOverlay", swfURL : com.erdas.smaad.baseUrl + "js/yui_3.2.0/uploader/assets/uploader.swf"});
			uploader.set("simLimit", 1);
			
			uploader.on("uploaderReady", com.erdas.smaad.setupUploader);
			uploader.on("fileselect", com.erdas.smaad.fileSelect);
			uploader.on("uploadprogress", com.erdas.smaad.updateProgress);
			uploader.on("uploadcomplete", com.erdas.smaad.uploadComplete);
			uploader.on("uploadcompletedata", com.erdas.smaad.uploadCompleteData);
			
			this.one("#smaad\\.uploadFilesLink").on("click", com.erdas.smaad.uploadFile);
			
			com.erdas.smaad.uploader = uploader;
			
			com.erdas.smaad.updateSearchResults({});
			com.erdas.smaad.selectConcept(undefined);
			com.erdas.smaad.updateSelectedConcepts();
			
			
			// Prepare overlay

			com.erdas.smaad.createOverlay();
			
			// Get thesaurus list
			
			var requestUrl = com.erdas.smaad.baseUrl + "service?op=getThesaurus";

			com.erdas.smaad.searchRequest = com.erdas.smaad.Y.io(requestUrl, {
				on : {
					success: com.erdas.smaad.updateThesaurusList,
					failure: com.erdas.smaad.handleNoThesaurus
				},
		        timeout: 5000
		    });


		},

		updateThesaurusList : function(id, o, args) {
			
			var jsonString = o.responseText;
			
			try {
			    var data = com.erdas.smaad.Y.JSON.parse(jsonString);
			    com.erdas.smaad.setThesaurusList(data);
			} catch (e) {
			    // An error occurred parsing json data
				alert("An error occurred during retrieval of thesaurus list");
				com.erdas.smaad.Y.log("Could not parse get thesaurus response: " + e);
			}
		},
		
		conceptResolved : function(id ,response, args) {
			var jsonString = response.responseText;
			
			try {
			    var concept = com.erdas.smaad.Y.JSON.parse(jsonString);
			    com.erdas.smaad.resolvedConcepts[concept.URI]=concept;
			    com.erdas.smaad.selectConcept(concept);
			} catch (e) {
			    // An error occurred parsing json data
				com.erdas.smaad.Y.log("Could not parse resolved concept: " + e);
				com.erdas.smaad.displayResolveError();
			}
			
		},
		
		setThesaurusList : function (thesaurusList) {
			var thList = com.erdas.smaad.Y.one("#smaad\\.thesaurusSelect");
			var content = "";
			for (id in thesaurusList) {
				var name = thesaurusList[id].displayName;
				content += "<option value='" + name + "' title='" + thesaurusList[id].name + "'>" + name + "</option>";
			}
			thList.setContent(content);
		},
		
		handleNoThesaurus : function (id, response ,args) {
			alert("Could not get thesaurus list!");
			com.erdas.smaad.Y.log("Error getting thesaurus list: " + response.status + " " + response.statusText);
		},
		

		setupUploader : function (event) {
			com.erdas.smaad.uploader.set("multiFiles", true);
			com.erdas.smaad.uploader.set("simLimit", 3);
			com.erdas.smaad.uploader.set("log", true);
			
		},

		fileSelect : function (event) {
			var fileData = event.fileList;	

			com.erdas.smaad.updateFilesFromSelection(fileData);
			
		},
		
		updateProgress : function (event) {
			var pb = com.erdas.smaad.Y.Widget.getByNode("#pb_" + event.id);
			pb.set("progress", Math.round(100 * event.bytesLoaded / event.bytesTotal));
			com.erdas.smaad.updateProgressDialog(event.id, 100 * event.bytesLoaded / event.bytesTotal);
		},

		uploadComplete : function (event) {
			var stDiv = com.erdas.smaad.Y.one("#smaad\\.file\\.status_" + event.id);
			stDiv.setContent("uploaded");
			com.erdas.smaad.updateProgressDialog(event.id, 100);
		},

		uploadCompleteData : function (event) {
			//alert("Upload complete: " + event.data);
			
			var jsonString = event.data;
			
			try {
			    var data = com.erdas.smaad.Y.JSON.parse(jsonString);
				com.erdas.smaad.updateFilesFromTagging(data); 
			} catch (e) {
			    // An error occurred parsing json data
				alert("An error occurred when parsing response: " + e);
				com.erdas.smaad.Y.log("Could not parse search response: " + e);
				com.erdas.smaad.displayTaggingError();
			}
		},


		uploadFile : function (event) {
			
			// Check if at least one file and one concept have been selected
			
			if (com.erdas.smaad.isEmpty(com.erdas.smaad.selectedConcepts)) {
				
				alert("Select at least one concept before tagging");
				
			} else if (com.erdas.smaad.isEmpty(com.erdas.smaad.fileList)) {
					
				alert("Select at least one file before tagging");
				
			} else {
			
				// First clear file list on server
				
				var requestUrl = com.erdas.smaad.baseUrl + "service?op=reset";

				com.erdas.smaad.searchRequest = com.erdas.smaad.Y.io(requestUrl, {
			        timeout: 5000
			    });
				
				// TODO, do this in a callback method or use synchronize call for reset

				
				var selectedConcepts = new Array();
				
				for (var id in com.erdas.smaad.selectedConcepts) {
					var concept = com.erdas.smaad.selectedConcepts[id];
					selectedConcepts[id] = concept.URI;
				}
				
				// Reset progress on all files
				
				for (var name in com.erdas.smaad.fileList) {
					com.erdas.smaad.fileList[name].progress = 0;
					com.erdas.smaad.fileList[name].status = "uploading";
				}
				com.erdas.smaad.Y.one("#smaad\\.progressDialog\\.infoDiv").setContent("Preparing upload...");
				com.erdas.smaad.progressCount = 0;
				com.erdas.smaad.progressBar.set("progress",0);
				
				// Display modal dialog
				
				com.erdas.smaad.progressDialog.show();
				
				// Show the file list to display updated status
				
				com.erdas.smaad.showFileList();
				com.erdas.smaad.uploader.uploadAll(com.erdas.smaad.baseUrl + "service;jsessionid=" + com.erdas.smaad.getSessionId() + ";?op=tag",
												   "POST",
												   {"concepts" : JSON.stringify(selectedConcepts)});
			}
		},
		
		search : function (searchTerm) {

			com.erdas.smaad.Y.log("Searching for: " + searchTerm);
			
			com.erdas.smaad.showSearchResults();
			com.erdas.smaad.displaySearching();
			
			var requestUrl = com.erdas.smaad.baseUrl + "service?op=search&q="+searchTerm+"&lang="+com.erdas.smaad.Y.one("#smaad\\.languageSelect").get("value")+"&ont="+com.erdas.smaad.Y.one("#smaad\\.thesaurusSelect").get('value')+"&count="+com.erdas.smaad.Y.one("#smaad\\.maxResults").get('value');

			com.erdas.smaad.searchRequest = com.erdas.smaad.Y.io(requestUrl, {
				on : {
					success: com.erdas.smaad.displaySearchResult,
					failure: com.erdas.smaad.displaySearchError
				},
		        timeout: 20000
		    });

		},
		
		displaySearching : function() {
			var resultDiv = com.erdas.smaad.Y.one("#smaad\\.searchResultDiv");
			resultDiv.removeClass('error');
			resultDiv.setContent("<div class='searchingDiv'><img style='vertical-align: middle; padding-right:5px' src='" + com.erdas.smaad.baseUrl + "img/loading2.gif'/>Searching...</div>");
		},
		
		displayResolving : function() {
			var focusDiv = com.erdas.smaad.Y.one("#smaad\\.focusConceptDiv");
			focusDiv.removeClass('error');
			focusDiv.setContent("<div class='searchingDiv'><img style='vertical-align: middle; padding-right:5px' src='" + com.erdas.smaad.baseUrl + "img/loading2.gif'/>Resolving...</div>");
		},
		
		resolveAndSelectConcept : function (uri) {
			com.erdas.smaad.displayResolving();
			var requestUrl = com.erdas.smaad.baseUrl + "service?op=resolve&q="+encodeURIComponent(uri)+"&lang="+com.erdas.smaad.Y.one("#smaad\\.languageSelect").get("value")+"&ont="+com.erdas.smaad.Y.one("#smaad\\.thesaurusSelect").get('value');

			com.erdas.smaad.searchRequest = com.erdas.smaad.Y.io(requestUrl, {
				on : {
					success: com.erdas.smaad.conceptResolved,
					failure: com.erdas.smaad.displayResolveError
				},
		        timeout: 60000,
		    });
		},
		
		displayResolveError : function(id, response) {
			
			var focusDiv = com.erdas.smaad.Y.one("#smaad\\.focusConceptDiv");
			focusDiv.addClass('error');
			focusDiv.setContent("An error occurred during concept resolution!");
			
		},

		getResolvedConceptByUri : function (uri) {
			
			var concept;
			
			concept = com.erdas.smaad.resolvedConcepts[uri];
			
			return concept;
			
		},
		
		selectConceptByUri : function (uri) {
			var concept = com.erdas.smaad.getResolvedConceptByUri(uri);
			if (concept == undefined) {
				com.erdas.smaad.resolveAndSelectConcept(uri);
			} else {
				com.erdas.smaad.selectConcept(concept);
			}
		},
		
		selectConcept : function (concept) {
				
			var focusDiv = com.erdas.smaad.Y.one("#smaad\\.focusConceptDiv");
			focusDiv.removeClass('error');
			
			if (concept == undefined) {
				focusDiv.setContent("&lt;no concept selected&gt;");
			} else {
		    	var uris = '"' + concept.URI + '"';		    	
		    	var tmp = "";
		    	
		    	tmp += "<div class='sectionContent'><div class='conceptName' title='Concept URI: " + concept.URI +"'>";
		    	tmp +=concept.label;
		    	tmp += "&nbsp;<a class='smallButton' href='#' onclick='com.erdas.smaad.addConceptUri(" + uris + ")'>Add</a>"
		    	tmp +="</div>";
		    	tmp +="<div class='conceptDescription'>";
		    	if (concept.description != undefined) {
		    		tmp +=concept.description;
		    	} else {
		    		tmp += "&lt;description not available&gt;";
		    	} 
		    	tmp +="</div>";
		    	tmp +="<div class='conceptPropertyDiv'>";
		    	tmp +="<span class='conceptPropertyName'>Groups:</span>";
		    	tmp +="<span class='conceptPropertyValue'>";
		    	for (var id in concept.groups) {
		    		tmp += " " + concept.groups[id].label;
		    	}
		    	tmp +="</span>";
		    	tmp +="<br><span class='conceptPropertyName'>Themes:</span>";
		    	tmp +="<span class='conceptPropertyValue'>";
		    	for (var id in concept.themes) {
		    		tmp += " " + concept.themes[id].label;
		    	}
		    	tmp +="</span>";
		    	tmp +="<br><span class='conceptPropertyName'>Broader:</span>";
		    	tmp +="<span class='conceptPropertyValue'>";
		    	for (var id in concept.broaderConcepts) {
		    		var ruris = '"' + concept.broaderConcepts[id].URI + '"'; 
		    		var title = "Concept URI: " + concept.broaderConcepts[id].URI;
		    		var label = concept.broaderConcepts[id].label;
		    		if (label == undefined) {
		    			label = "[URI]";
		    		}
		    		tmp += " <a href='#' onclick='com.erdas.smaad.resolveAndSelectConcept(" + ruris + ")' title='"+ title +"'>" + label + "</a>";
		    	}
		    	tmp +="</span>";
		    	tmp +="<br><span class='conceptPropertyName'>Narrower:</span>";
		    	tmp +="<span class='conceptPropertyValue'>";
		    	for (var id in concept.narrowerConcepts) {
		    		var ruris = '"' + concept.narrowerConcepts[id].URI + '"'; 
		    		var title = "Concept URI: " + concept.narrowerConcepts[id].URI;
		    		var label = concept.narrowerConcepts[id].label;
		    		if (label == undefined) {
		    			label = "[URI]";
		    		}
		    		tmp += " <a href='#' onclick='com.erdas.smaad.resolveAndSelectConcept(" + ruris + ")' title='"+ title +"'>" + label + "</a>";
		    	}
		    	tmp +="</span>";
		    	tmp +="<br><span class='conceptPropertyName'>Related terms: </span>";
		    	tmp +="<span class='conceptPropertyValue'>";
		    	for (var id in concept.relatedConcepts) {
		    		var ruris = '"' + concept.relatedConcepts[id].URI + '"'; 
		    		var title = "Concept URI: " + concept.relatedConcepts[id].URI;
		    		var label = concept.relatedConcepts[id].label;
		    		if (label == undefined) {
		    			label = "[URI]";
		    		}
		    		tmp += " <a href='#' onclick='com.erdas.smaad.resolveAndSelectConcept(" + ruris + ")' title='"+ title +"'>" + label + "</a>";
		    	}
		    	tmp +="</span>";
		    	tmp +="<br><span class='conceptPropertyName'>Synonyms:</span>";
		    	tmp +="<span class='conceptPropertyValue'>";
		    	for (var id in concept.exactConcepts) {
		    		var ruris = '"' + concept.exactConcepts[id].URI + '"';
		    		var title = "Concept URI: " + concept.exactConcepts[id].URI;
		    		var label = concept.exactConcepts[id].label;
		    		if (label == undefined) {
		    			label = "[URI]";
		    		}
		    		tmp += " <a href='" + concept.exactConcepts[id].URI + "' target='_blank' title='" + title + "'>" + label + "</a>";
		    	}
		    	tmp +="</span>";
		    	tmp +="<br><span class='conceptPropertyName'>Close terms: </span>";
		    	tmp +="<span class='conceptPropertyValue'>";
		    	for (var id in concept.closeConcepts) {
		    		var ruris = '"' + concept.closeConcepts[id].URI + '"'; 
		    		var title = "Concept URI: " + concept.closeConcepts[id].URI;
		    		var label = concept.closeConcepts[id].label;
		    		if (label == undefined) {
		    			label = "[URI]";
		    		}
		    		tmp += " <a href='" + concept.closeConcepts[id].URI + "' target='_blank' title='" + title + "'>" + label + "</a>";
		    	}
		    	tmp +="</span>";
		    	tmp +="</div>";
		    	tmp +="</div>";
		    	focusDiv.setContent(tmp);
			}
		},
		
		conceptSelected : function (concept) {
			
			var ret = false;
			
			for ( var id in com.erdas.smaad.selectedConcepts) {
				var c = com.erdas.smaad.selectedConcepts[id];
				if (c.URI == concept.URI) {
					ret = true;
					break;
				}
			}
			
			return ret;
			
		},
		
		addConceptUri : function (uri){
			var concept;
			
			concept = com.erdas.smaad.getResolvedConceptByUri(uri);
			
			if (concept == undefined) {
				concept = com.erdas.smaad.searchResults[uri]
			}
			
			com.erdas.smaad.addConcept(concept);
		},

		addConcept : function (concept){
			if (!com.erdas.smaad.conceptSelected(concept)) {
				com.erdas.smaad.selectedConcepts.push(concept);
				com.erdas.smaad.updateSelectedConcepts();
			} else {
				alert("The concept '" + concept.label + "' was already selected");
			}
		},

		addFreeConcept : function (name){
			
			// Create a concept
			
			var concept = {
				label: name,
				URI: "custom#"+name,
				description: "&lt;free concept&gt;"
			};
			
			// Add newly created concept in resolved concept list
			com.erdas.smaad.resolvedConcepts[concept.URI] = concept;
			
			// Add the concept to the list of selected concepts
			com.erdas.smaad.addConcept(concept);
			
			// Clear field
			var field = com.erdas.smaad.Y.one("#smaad\\.freeConceptField");
			field.set('value','');
			
		},

		removeConcept : function (uri) {
			for ( var id in com.erdas.smaad.selectedConcepts) {
				var c = com.erdas.smaad.selectedConcepts[id];
				if (c.URI == uri) {
					// Found, remove the element
					com.erdas.smaad.selectedConcepts.splice(id,1);
					break;
				}
			}
			com.erdas.smaad.updateSelectedConcepts();
		},
		
		updateSelectedConcepts : function () {
			var selectedDiv = com.erdas.smaad.Y.one("#smaad\\.selectedConceptDiv");
			selectedDiv.setContent("");
		    if (com.erdas.smaad.isEmpty(com.erdas.smaad.selectedConcepts)) {
		    	selectedDiv.setContent("&lt;no concepts&gt;");
		    } else {
			    for ( var id in com.erdas.smaad.selectedConcepts) {
			    	var concept = com.erdas.smaad.selectedConcepts[id];
			    	var uris = '"' + concept.URI + '"';
			    	var tmp = "";
			    	
			    	tmp += "<div class='sectionContent selectedConcept'><div class='conceptName'><span title='Click to focus on' onclick='com.erdas.smaad.selectConceptByUri(" + uris + ")'>";
			    	tmp +=concept.label;
			    	tmp += "</span>&nbsp;<a class='smallButton' href='#' onclick='com.erdas.smaad.removeConcept(" + uris + ")'>Remove</a>"
			    	tmp +="</div>";
			    	tmp +="</div>";
			    	selectedDiv.append(tmp);
			    }
		    }
		},
		
		displaySearchResult : function(id, o, args) {
			com.erdas.smaad.Y.log("Search success!");
			
			var jsonString = o.responseText;
			
			try {
			    var data = com.erdas.smaad.Y.JSON.parse(jsonString);
				com.erdas.smaad.updateSearchResults(data);
			} catch (e) {
			    // An error occurred parsing json data
				alert("An error occurred when parsing response: " + e);
				com.erdas.smaad.Y.log("Could not parse search response.");
				com.erdas.smaad.displaySearchError(id, o, args);
			}
		},
		
		updateSearchResults : function (concepts) {
			var resultDiv = com.erdas.smaad.Y.one("#smaad\\.searchResultDiv");
			resultDiv.removeClass('error');

			com.erdas.smaad.searchResults = {};
			
		    resultDiv.setContent("");
		    if (concepts == undefined || com.erdas.smaad.isEmpty(concepts)) {
		    	resultDiv.setContent("&lt;no results&gt;");
		    } else {
			    for ( var id in concepts) {
			    	var concept = concepts[id];
			    	var uris = '"' + concept.URI + '"';
			    	var tmp = "";
			    	
			    	com.erdas.smaad.searchResults[concept.URI] = concept;
			    	
			    	tmp += "<div class='sectionContent searchResult'><div class='conceptName' onClick='com.erdas.smaad.selectConceptByUri(" + uris +")' title='Concept URI: " + concept.URI + "'>";
			    	tmp +=concept.label;
			    	tmp += "&nbsp;<a class='smallButton' href='#' onclick='com.erdas.smaad.addConceptUri(" + uris + ")'>Add</a>"
			    	tmp +="</div>";
			    	tmp +="<div class='conceptDescription' title='Click to focus on' onClick='com.erdas.smaad.selectConceptByUri(" + uris +")'>";
			    	if (concept.description != undefined) {
			    		tmp += com.erdas.smaad.truncateString(concept.description,100);
			    	} else {
			    		tmp += "&lt;description not available&gt;"
			    	}
			    	tmp +="</div>";
			    	tmp +="</div>";
			    	resultDiv.append(tmp);
			    }
		    }
			com.erdas.smaad.showSearchResults();
		},
		
		truncateString : function (string, maxLength) {
			
			var ret = string;
			if (string.length > maxLength) {
				ret = string.substr(0,maxLength-3) + "...";
			}
				
			return ret;
		},
		
		displaySearchError : function(id, o) {
			
			com.erdas.smaad.showSearchResults();
			
			if (o.status == 0) {
				com.erdas.smaad.displaySearchTimeout(id, o);
			} else {
			
				var resultDiv = com.erdas.smaad.Y.one("#smaad\\.searchResultDiv");
				resultDiv.addClass('error');
				
				resultDiv.setContent("An error occurred during the search!");
				
			}
			
		},

		displayTaggingError : function() {
			
			com.erdas.smaad.showFileList();
			
			var resultDiv = com.erdas.smaad.Y.one("#smaad\\.fileListDiv");
			resultDiv.addClass('error');
				
			resultDiv.setContent("Tagging error");
			
		},

		displaySearchTimeout : function() {
			
			var resultDiv = com.erdas.smaad.Y.one("#smaad\\.searchResultDiv");
			resultDiv.addClass('error');
			
			resultDiv.setContent("No responses from server!");
		},
		
		downloadAll : function() {
			
			var url = com.erdas.smaad.baseUrl + "service?op=getAll"; 
			window.open(url,"Download all");
			
		}

	};
	
	}

//	YUI({ filter: 'debug', root : '/html/js/', combine : false },{gallery: 'gallery-2011.02.09-21-32'}).use('uploader', 'gallery-progress-bar', function(Y, info) {

	YUI({ filter: 'raw', combine : false },{gallery: 'gallery-2011.02.09-21-32'}).use('io', 'json', 'uploader', 'gallery-progress-bar', 'overlay', 'gallery-overlay-extras', function(Y, info) {
		
//	YUI().use('uploader', function(Y, info) {
		
		if (info.success !== true) {
			
			alert ("An error occurred during initialization: " + info.msg);
			return;
		}
		
		com.erdas.smaad.Y = Y;
		
//		AUI({root:'oh ben ca', comboBase  : 'http://yeah/'} , {gallery: 'gallery-2011.02.09-21-32'}).use('gallery-progress-bar', function(Y, info) {
//			
//			if (info.success !== true) {
//				
//				alert ('Failed loading pbar');
//			} else {
//				alert ('Bingo?');
//			}
//		});

		
//	YUI({ filter: 'raw' },{gallery: 'gallery-2010.06.30-19-54'}).use('uploader', function(Y) {
		

		Y.on("domready", com.erdas.smaad.init);

	});
