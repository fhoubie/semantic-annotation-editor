<div id="smaad.main" class="smaad yui3-skin-sam">

	<table class="mainTable" width="100%" height="100%">
		<tr>
			<td>
				<div style="white-space: nowrap;">
					Concept:&nbsp;<input id="smaad.searchField" type="text" value="" class="" onkeydown="if (event.keyCode == 13) com.erdas.smaad.search(document.getElementById('smaad.searchField').value);"/>
					&nbsp;					
					<select id="smaad.languageSelect">
						<option value="en">English</option>
						<option value="fr">Français</option>
					</select>
				</div>
				<br>
				<div style="white-space: nowrap;">
					Thesaurus:
					<select id="smaad.thesaurusSelect">
						<option value="">&lt;thesaurus not found&gt;</option>
					</select>&nbsp;
					Max results:
					<select id="smaad.maxResults">
						<option value="10">10</option>
						<option value="25">25</option>
						<option value="50">50</option>
						<option value="100">100</option>
					</select>
					&nbsp;<a href="#" class="button" onclick="com.erdas.smaad.search(document.getElementById('smaad.searchField').value);">Search</a>
					<a href="#" class="button" onclick="com.erdas.smaad.reset();">Reset</a>
				</div>
				<br>
				<div class="section">
					<!-- <div class="sectionTitle">Metadata</div>  -->
					<!--  The container is needed by the flash component  -->
					<table>
						<tr><td>
						<div id="uploaderContainer" class=""> 
							<div id="uploaderOverlay" style="position:absolute; z-index:2"></div>
							 
							<div id="smaad.selectFilesLink" style="z-index:1">
								<a id="selectLink" href="#" class="button">Select&nbsp;Files</a>
							</div> 
						</div>
						</td><td>
						<div id="smaad.uploadFilesLink" class="">
							<a id="smaad.uploadLink" class="button" href="#">Tag&nbsp;metadata</a>
						</div>
						</td><td>
						<div id="smaad.downloadFilesLink" class=""><a id="smaad.downloadLink" class="button" href="#"  onclick="com.erdas.smaad.downloadAll();">Download&nbsp;all</a></div>
						</td><td>
					</table>
				</div>
				<br>
				<div class="section" style="height: 100%">
					<div class="sectionTitle" id="smaad.listTitle">Search results</div>
					<div class="sectionContent" id="smaad.searchResultDiv" style="overflow: auto;height: 250px">
					</div>
					<div class="sectionContent" id="smaad.fileDiv" style="visibility: hidden; display: none">
					  <table id="smaad.filenameTable" class="fileTable">
						<tr><th>Filename</th><th>File&nbsp;type</th><th>Size</th><th>Status</th><th></th><th></th></tr>
						<tr><td>&lt;no files selected&gt;</td><td></td><td></td><td></td><td></td></tr>
					  </table>
					  <div id="dataTableContainer"></div>					  
					</div>
				</div>
			</td>
			<td>
				<div class="section">
				<div class="sectionTitle">Focus On</div>
				<div class="sectionContent" id="smaad.focusConceptDiv"></div>
				</div>	
				
				<br>
				
				<div class="section">
				<div class="sectionTitle">Selected concepts</div>
				<div class="sectionContent" id="smaad.selectedConceptDiv"></div>
				</div>	
				<hr>
				<div style="white-space: nowrap;">
					Free keyword:
					<input id="smaad.freeConceptField" type="text" value="" class="" onkeydown="if (event.keyCode == 13) com.erdas.smaad.addFreeConcept(document.getElementById('smaad.freeConceptField').value)"/>&nbsp;
					<a class="button" href="#" onclick="com.erdas.smaad.addFreeConcept(document.getElementById('smaad.freeConceptField').value)">Add</a>
				</div>
			</td>
		</tr>
		
	</table>
	<!-- 
	<div id="smaad.progressOverlay" class="progressOverlay">
		<h1 style="text-align: center;">In progress</h1>
	</div>
	 -->
</div>
<!-- 
<script type="text/javascript" src="http://yui.yahooapis.com/2.9.0/build/yahoo-dom-event/yahoo-dom-event.js"></script>
<script type="text/javascript" src="http://yui.yahooapis.com/2.9.0/build/element/element-min.js"></script>
<script type="text/javascript" src="http://yui.yahooapis.com/2.9.0/build/uploader/uploader-min.js"></script>
<script type="text/javascript" src="http://yui.yahooapis.com/2.9.0/build/datasource/datasource-min.js"></script>
<script type="text/javascript" src="http://yui.yahooapis.com/2.9.0/build/event-delegate/event-delegate-min.js"></script>
<script type="text/javascript" src="http://yui.yahooapis.com/2.9.0/build/datatable/datatable-min.js"></script>
<script type="text/javascript" src="http://yui.yahooapis.com/3.2.0/build/yui/yui-min.js"></script>
-->
<script src="/smaad-annotation-core/js/Namespace.js"></script>
<script src="/smaad-annotation-core/js/editor.js"></script>
 