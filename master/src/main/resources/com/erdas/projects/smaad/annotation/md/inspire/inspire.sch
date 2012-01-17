<?xml version="1.0" encoding="UTF-8"?>
<!--
/*
* Copyright 2009 EUROPEAN CCOMMUNITIES
*
* Licensed under the EUPL, Version 1.1 or – as soon they will be approved by the European Commission - subsequent versions of the EUPL (the "Licence");
* You may not use this work except in compliance with the Licence.
* You may obtain a copy of the Licence at:
*
* http://ec.europa.eu/idabc/eupl
*
* Unless required by applicable law or agreed to in writing, software distributed under the Licence is distributed on an "AS IS" basis,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the Licence for the specific language governing permissions and limitations under the Licence.

*Authors: Kristian Senkler, con terra Gesellschaft für Informationstechnologie mbH <K.Senkler@conterra.de>, 
Gianluca Luraschi <gianluca.luraschi@jrc.ec.europa.eu>, European Commission, Joint Research Centre
Ioannis Kanellopoulos <ioannis.kanellopoulos@jrc.ec.europa.eu>, European Commission, Joint Research Centre
*/ 

-->       
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron">
	<sch:ns uri="http://www.isotc211.org/2005/gmd" prefix="gmd"/>
	<sch:ns uri="http://www.isotc211.org/2005/gco" prefix="gco"/>
	<sch:ns uri="http://www.isotc211.org/2005/srv" prefix="srv"/>
	<sch:ns uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
	<sch:ns uri="http://www.opengis.net/gml" prefix="gml"/>
	<!-- ############################################ -->
	<!-- General issues                               -->
	<!-- ############################################ -->
	<sch:pattern name="Test implementation">
		<sch:title>Testing implementation</sch:title>
		<sch:rule context="/*">
			<sch:assert test="namespace-uri(/*) = 'http://www.isotc211.org/2005/gmd'">XML document is defined in the wrong namespace:
                <sch:value-of select="namespace-uri(/*)"/>
			</sch:assert>
			<sch:report test="namespace-uri(/*) = 'http://www.isotc211.org/2005/gmd'">Document namespace is <sch:value-of select="namespace-uri(/*)"/>
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<!-- ############################################ -->
	<!-- Identification                               -->
	<!-- ############################################ -->
	<sch:pattern name="Identification">
		<sch:title>Testing 'Identification' elements</sch:title>
		<sch:rule context="//gmd:identificationInfo[1]/*/gmd:citation/*">
			<sch:let name="resourceTitle" value="gmd:title/*/text()"/>
			<!-- assertions and report -->
			<sch:assert test="$resourceTitle">(2.2.1) Resource title is missing</sch:assert>
			<sch:report test="$resourceTitle">(2.2.1) Resource title found: <sch:value-of select="$resourceTitle"/>
			</sch:report>
		</sch:rule>
		<sch:rule context="//gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*">
			<sch:let name="resourceLocator" value="gmd:linkage/*/text()"/>
			<!-- assertions and report -->
			<sch:report test="$resourceLocator">(2.2.4) Resource locator found:
                <sch:value-of select="$resourceLocator"/>
			</sch:report>
		</sch:rule>
		<sch:rule context="//gmd:MD_Metadata/gmd:hierarchyLevel[1]">
			<sch:let name="resourceType_present" value="*/@codeListValue='dataset'
                            or */@codeListValue='series'
                            or */@codeListValue='service'"/>
			<sch:let name="resourceType" value="*/@codeListValue"/>
			<!-- assertions and report -->
			<sch:assert test="$resourceType_present">(2.2.3) Resource type is missing or has a wrong value</sch:assert>
			<sch:report test="$resourceType_present">(2.2.3) Resource type found:
                <sch:value-of select="$resourceType"/>
			</sch:report>
		</sch:rule>
		<sch:rule context="//gmd:identificationInfo[1]/*">
			<sch:let name="resourceAbstract" value="gmd:abstract/*/text()"/>
			<!-- assertions and report -->
			<sch:assert test="$resourceAbstract">(2.2.2) Resource abstract is missing</sch:assert>
			<sch:report test="$resourceAbstract">(2.2.2) Resource abstract found:
                <sch:value-of select="$resourceAbstract"/>
			</sch:report>
		</sch:rule>
		<sch:rule context="//gmd:hierarchyLevel[1]/*[@codeListValue ='service']">
			<sch:let name="coupledResource" value="//srv:operatesOn/@xlink:href"/>
			<!-- assertions and report -->
			<sch:report test="$coupledResource">(2.2.6) Coupled Resource found: <sch:value-of select="$coupledResource"/>
			</sch:report>
		</sch:rule>
		<sch:rule context="//gmd:hierarchyLevel[1]/*[@codeListValue ='dataset'] | //gmd:hierarchyLevel[1]/*[@codeListValue ='series']">
			<sch:let name="resourceIdentifier_code" value="//gmd:identificationInfo[1]/*/gmd:citation/*/gmd:identifier/*/gmd:code/*/text()"/>
			<sch:let name="resourceIdentifier_codeSpace" value="//gmd:identificationInfo[1]/*/gmd:citation/*/gmd:identifier/*/gmd:codeSpace/*/text()"/>
			<sch:let name="resourceLanguage_present" value="//gmd:identificationInfo[1]/*/gmd:language/*/text()='bul' or
							//gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='ita' or
                            //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='cze' or
                            //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='lav' or
                            //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='dan' or
                            //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='lit' or
                            //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='dut' or
                            //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='mlt' or
                            //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='eng' or
                            //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='pol' or
                            //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='est' or
                            //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='por' or
                            //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='fin' or
                            //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='rum' or
                            //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='fre' or
                            //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='slo' or
                            //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='ger' or
                            //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='slv' or
                            //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='gre' or
                            //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='spa' or
                            //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='hun' or
                            //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='swe' or
                            //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='gle'"/>
			<sch:let name="resourceLanguage" value="//gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue"/>
			<!-- assertions and report -->
			<!-- resource language is only conditional for 'dataset' and 'series'. So no assert is defined -->
			<sch:assert test="$resourceIdentifier_code">(2.2.5) Unique resource identifier is missing</sch:assert>
			<sch:report test="$resourceIdentifier_code">(2.2.5) Unique resource identifier (code) found:
                <sch:value-of select="$resourceIdentifier_code"/>
			</sch:report>
			<sch:report test="$resourceIdentifier_codeSpace">(2.2.5) Unique resource identifier (codeSpace) found:
                <sch:value-of select="$resourceIdentifier_codeSpace"/>
			</sch:report>
			<sch:report test="$resourceLanguage_present">(2.2.7) Resource language found:
                <sch:value-of select="$resourceLanguage"/>
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<!-- ############################################ -->
	<!-- Classification of spatial data and services  -->
	<!-- ############################################ -->
	<sch:pattern name="Classification of spatial data and services">
		<sch:title>Testing 'Classification of spatial data and services' elements</sch:title>
		<sch:rule context="//gmd:hierarchyLevel[1]/*[@codeListValue ='dataset'] | //gmd:hierarchyLevel[1]/*[@codeListValue ='series']">
			<sch:let name="topicCategory" value="//gmd:topicCategory/*/text()"/>
			<!-- assertions and report -->
			<sch:assert test="$topicCategory">(2.3.1) Topic category is missing</sch:assert>
			<sch:report test="$topicCategory">(2.3.1) Topic category found:
                <sch:value-of select="$topicCategory"/>
			</sch:report>
		</sch:rule>
		<sch:rule context="//gmd:hierarchyLevel[1]/*[@codeListValue ='service']">
			<sch:let name="serviceType" value="//srv:serviceType/*/text()"/>
			<sch:let name="serviceType_present" value="//srv:serviceType/*/text() = 'view'
                            or //srv:serviceType/*/text() = 'discovery'
                            or //srv:serviceType/*/text() = 'download'
                            or //srv:serviceType/*/text() = 'transformation'
                            or //srv:serviceType/*/text() = 'invoke'
                            or //srv:serviceType/*/text() = 'other'"/>
			<!-- assertions and report -->
			<sch:assert test="$serviceType_present">(2.3.2) Spatial data service type is missing or has a wrong value</sch:assert>
			<sch:report test="$serviceType_present">(2.3.2) Spatial data service type found:
                <sch:value-of select="$serviceType"/>
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<!-- ############################################ -->
	<!-- Keyword                                      -->
	<!-- ############################################ -->
	<sch:pattern name="Keyword">
		<sch:title>Testing 'Keyword' elements</sch:title>
		<sch:rule context="//gmd:hierarchyLevel[1]/*[@codeListValue ='dataset'] | //gmd:hierarchyLevel[1]/*[@codeListValue ='series']">
			<sch:let name="keywordValue" value="//gmd:descriptiveKeywords/*/gmd:keyword/*/text()"/>
			<sch:let name="keywordValue_SDT" value="//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Addresses' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Administrative units' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Agricultural and aquaculture facilities' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Area management/restriction/regulation zones and reporting units' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Atmospheric conditions' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Bio-geographical regions' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Buildings' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Cadastral parcels' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Coordinate reference systems' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Elevation' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Energy resources' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Environmental monitoring facilities' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Geographical grid systems' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Geographical names' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Geology' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Habitats and biotopes' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Human health and safety' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Hydrography' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Land cover' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Land use' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Meteorological geographical features' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Mineral resources' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Natural risk zones' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Oceanographic geographical features' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Orthoimagery' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Population distribution — demography' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Production and industrial facilities' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Protected sites' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Sea regions' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Soil' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Species distribution' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Statistical units' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Transport networks' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Utility and governmental services'"/>
			<sch:let name="thesaurus_name" value="//gmd:descriptiveKeywords/*/gmd:thesaurusName/*/gmd:title/*/text()"/>
			<sch:let name="thesaurus_date" value="//gmd:descriptiveKeywords/*/gmd:thesaurusName/*/gmd:date/*/gmd:date/*/text()"/>
			<sch:let name="thesaurus_dateType" value="//gmd:descriptiveKeywords/*/gmd:thesaurusName/*/gmd:date/*/gmd:dateType/*/@codeListValue"/>
			<sch:assert test="$thesaurus_name = 'GemetInspireTheme'">(2.4.) A GEMET INSPIRE Spatial data theme thesaurus (GemetInspireTheme) shall be cited</sch:assert>
			<sch:assert test="$keywordValue_SDT">(2.4) For datasets and series at least one keyword of GEMET thesaurus shall be documented.</sch:assert>
			<sch:assert test="$keywordValue">(2.4.1) Keyword value is missing</sch:assert>
			<sch:report test="$keywordValue">(2.4.1) Keyword value found:
                <sch:value-of select="$keywordValue"/>
			</sch:report>
			<sch:report test="$thesaurus_name">(2.4.2) Thesaurus found:
                <sch:value-of select="$thesaurus_name"/>, <sch:value-of select="$thesaurus_date"/> (<sch:value-of select="$thesaurus_dateType"/>)
            </sch:report>
		</sch:rule>
		<sch:rule context="//gmd:hierarchyLevel[1]/*[@codeListValue ='service']">
			<sch:let name="keywordValue" value="//gmd:descriptiveKeywords/*/gmd:keyword/*/text()"/>
			<sch:let name="keywordValue_SDT" value="//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanInteractionService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanCatalogueViewer' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanGeographicViewer' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanGeographicSpreadsheetViewer' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanServiceEditor' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanChainDefinitionEditor' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanWorkflowEnactmentManager' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanGeographicFeatureEditor' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanGeographicSymbolEditor' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanFeatureGeneralizationEditor' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanGeographicDataStructureViewer' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoManagementService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoFeatureAccessService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoMapAccessService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoCoverageAccessService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoSensorDescriptionService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoProductAccessService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoFeatureTypeService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoCatalogueService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoRegistryService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoGazetteerService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoOrderHandlingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoStandingOrderService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='taskManagementService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='chainDefinitionService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='workflowEnactmentService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='subscriptionService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialProcessingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialCoordinateConversionService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialCoordinateTransformationService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialCoverageVectorConversionService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialImageCoordinateConversionService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialRectificationService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialOrthorectificationService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialSensorGeometryModelAdjustmentService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialImageGeometryModelConversionService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialSubsettingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialSamplingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialTilingChangeService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialDimensionMeasurementService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialFeatureManipulationService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialFeatureMatchingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialFeatureGeneralizationService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialRouteDeterminationService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialPositioningService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialProximityAnalysisService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicProcessingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicGoparameterCalculationService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicClassificationService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicFeatureGeneralizationService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicSubsettingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicSpatialCountingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicChangeDetectionService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicGeographicInformationExtractionService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicImageProcessingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicReducedResolutionGenerationService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicImageManipulationService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicImageUnderstandingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicImageSynthesisService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicMultibandImageManipulationService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicObjectDetectionService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicGeoparsingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicGeocodingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='temporalProcessingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='temporalReferenceSystemTransformationService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='temporalSubsettingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='temporalSamplingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='temporalProximityAnalysisService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='metadataProcessingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='metadataStatisticalCalculationService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='metadataGeographicAnnotationService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='comService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='comEncodingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='comTransferService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='comGeographicCompressionService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='comGeographicFormatConversionService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='comMessagingService' or
				//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='comRemoteFileAndExecutableManagement'"/>
			<!-- assertions and report -->
			<sch:assert test="$keywordValue_SDT">(2.4) For spatial data services, at least the category or subcategory of the service as defined in Part D 4 shall be documented.</sch:assert>
			<sch:assert test="$keywordValue">(2.4.1) Keyword value is missing</sch:assert>
			<sch:report test="$keywordValue">(2.4.1) Keyword value found:
                <sch:value-of select="$keywordValue"/>
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<!-- ############################################ -->
	<!-- Geographic location                          -->
	<!-- ############################################ -->
	<sch:pattern name="Geographic location">
		<sch:title>Testing 'Geographic location' elements</sch:title>
		<sch:rule context="//gmd:hierarchyLevel[1]/*[@codeListValue ='dataset'] | //gmd:hierarchyLevel[1]/*[@codeListValue ='series']">
			<sch:let name="west" value="number(//gmd:identificationInfo[1]/*/gmd:extent/*/gmd:geographicElement/*/gmd:westBoundLongitude/*)"/>
			<sch:let name="east" value="number(//gmd:identificationInfo[1]/*/gmd:extent/*/gmd:geographicElement/*/gmd:eastBoundLongitude/*)"/>
			<sch:let name="north" value="number(//gmd:identificationInfo[1]/*/gmd:extent/*/gmd:geographicElement/*/gmd:northBoundLatitude/*)"/>
			<sch:let name="south" value="number(//gmd:identificationInfo[1]/*/gmd:extent/*/gmd:geographicElement/*/gmd:southBoundLatitude/*)"/>
			<!-- assertions and report -->
			<sch:assert test="(-180.00 &lt;= $west) and ( $west &lt;= 180.00)">(2.5.1) WestBoundLongitude is missing or has wrong value</sch:assert>
			<sch:report test="(-180.00 &lt;= $west) and ( $west &lt;= 180.00)">(2.5.1) WestBoundLongitude found:
                <sch:value-of select="$west"/>
			</sch:report>
			<sch:assert test="(-180.00 &lt;= $east) and ($east &lt;= 180.00)">(2.5.1) EastBoundLongitude is missing or has wrong value</sch:assert>
			<sch:report test="(-180.00 &lt;= $east) and ($east &lt;= 180.00)">(2.5.1) EastBoundLongitude found:
                <sch:value-of select="$east"/>
			</sch:report>
			<sch:assert test="(-90.00 &lt;= $south) and ($south &lt;= $north)">(2.5.1) SouthBoundLatitude is missing or has wrong value</sch:assert>
			<sch:report test="(-90.00 &lt;= $south) and ($south &lt;= $north)">(2.5.1) SouthBoundLatitude found:
                <sch:value-of select="$south"/>
			</sch:report>
			<sch:assert test="($south &lt;= $north) and ($north &lt;= 90.00)">(2.5.1) NorthBoundLatitude is missing or has wrong value</sch:assert>
			<sch:report test="($south &lt;= $north) and ($north &lt;= 90.00)">(2.5.1) NorthBoundLatitude found:
                <sch:value-of select="$north"/>
			</sch:report>
		</sch:rule>
		<sch:rule context="//gmd:hierarchyLevel[1]/*[@codeListValue ='service']">
			<sch:let name="west" value="number(//gmd:identificationInfo[1]/*/srv:extent/*/gmd:geographicElement/*/gmd:westBoundLongitude/*)"/>
			<sch:let name="east" value="number(//gmd:identificationInfo[1]/*/srv:extent/*/gmd:geographicElement/*/gmd:eastBoundLongitude/*)"/>
			<sch:let name="north" value="number(//gmd:identificationInfo[1]/*/srv:extent/*/gmd:geographicElement/*/gmd:northBoundLatitude/*)"/>
			<sch:let name="south" value="number(//gmd:identificationInfo[1]/*/srv:extent/*/gmd:geographicElement/*/gmd:southBoundLatitude/*)"/>
			<!-- assertions and report -->
			<sch:report test="(-180.00 &lt;= $west) and ( $west &lt;= 180.00)">(2.5.1) WestBoundLongitude found:
                <sch:value-of select="$west"/>
			</sch:report>
			<sch:report test="(-180.00 &lt;= $east) and ($east &lt;= 180.00)">(2.5.1) EastBoundLongitude found:
                <sch:value-of select="$east"/>
			</sch:report>
			<sch:report test="(-90.00 &lt;= $south) and ($south &lt;= $north)">(2.5.1) SouthBoundLatitude found:
                <sch:value-of select="$south"/>
			</sch:report>
			<sch:report test="($south &lt;= $north) and ($north &lt;= 90.00)">(2.5.1) NorthBoundLatitude found:
                <sch:value-of select="$north"/>
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<!-- ############################################ -->
	<!-- Temporal reference                           -->
	<!-- ############################################ -->
	<sch:pattern name="Temporal reference">
		<sch:title>Testing 'Temporal reference' elements</sch:title>
		<sch:rule context="//gmd:identificationInfo[1]/*">
			<sch:let name="temporalExtentBegin" value="gmd:extent/*/gmd:temporalElement/*/gmd:extent/*/gml:beginPosition/text()"/>
			<sch:let name="temporalExtentEnd" value="gmd:extent/*/gmd:temporalElement/*/gmd:extent/*/gml:endPosition/text()"/>
			<sch:let name="publicationDate" value="gmd:citation/*/gmd:date[./*/gmd:dateType/*/@codeListValue='publication']/*/gmd:date/*"/>
			<sch:let name="creationDate" value="gmd:citation/*/gmd:date[./*/gmd:dateType/*/@codeListValue='creation']/*/gmd:date/*"/>
			<sch:let name="no_creationDate" value="count(gmd:citation/*/gmd:date[./*/gmd:dateType/*/@codeListValue='creation']/*/gmd:date/*)"/>
			<sch:let name="revisionDate" value="gmd:citation/*/gmd:date[./*/gmd:dateType/*/@codeListValue='revision']/*/gmd:date/*"/>
			<!-- assertions and report -->
			<sch:assert test="$no_creationDate &lt;= 1">SC7.  There shall not be more than one instance of MD_Metadata.identificationInfo[1].MD_Identification.citation.CI_Citation.date declared as a creation date (i.e. CI_Date.dateType having the creation value)</sch:assert>
			<sch:assert test="$publicationDate or $creationDate or $revisionDate or $temporalExtentBegin or $temporalExtentEnd">(2.6) No instance of Temporal reference has been found.</sch:assert>
			<sch:report test="$temporalExtentBegin">(2.6.1) Temporal extent (begin) found: <sch:value-of select="$temporalExtentBegin"/>
			</sch:report>
			<sch:report test="$temporalExtentEnd">(2.6.1) Temporal extent (end) found: <sch:value-of select="$temporalExtentEnd"/>
			</sch:report>
			<sch:report test="$publicationDate">(2.6.2) Date of publication of the resource found: <sch:value-of select="$publicationDate"/>
			</sch:report>
			<sch:report test="$revisionDate">(2.6.3) Date of revision of the resource found: : <sch:value-of select="$revisionDate"/>
			</sch:report>
			<sch:report test="$creationDate">(2.6.4) Date of creation of the resource found: : <sch:value-of select="$creationDate"/>
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<!-- ############################################ -->
	<!-- Quality and validity                         -->
	<!-- ############################################ -->
	<sch:pattern name="Quality and validity">
		<sch:title>Testing 'Quality and validity' elements</sch:title>
		<sch:rule context="//gmd:hierarchyLevel[1]/*[@codeListValue ='dataset'] | //gmd:hierarchyLevel[1]/*[@codeListValue ='series']">
			<sch:let name="lineage" value="//gmd:dataQualityInfo/*/gmd:lineage/*/gmd:statement/*/text()"/>
			<!-- assertions and report -->
			<sch:assert test="$lineage">(2.7.1) Lineage is missing</sch:assert>
			<sch:report test="$lineage">(2.7.1) Lineage found:
                <sch:value-of select="$lineage"/>
			</sch:report>
		</sch:rule>
		<sch:rule context="//gmd:identificationInfo[1]/*/gmd:spatialResolution/*">
			<sch:let name="spatialResolution_equivalentScale" value="gmd:equivalentScale/*/gmd:denominator"/>
			<sch:let name="spatialResolution_distance" value="gmd:distance/*/text()"/>
			<sch:let name="spatialResolution_distance_uom" value="gmd:distance/*/@uom"/>
			<!-- assertions and report -->
			<sch:report test="$spatialResolution_equivalentScale">(2.7.2) Spatial resolution (equivalentScale) found:
                <sch:value-of select="$spatialResolution_equivalentScale"/>
			</sch:report>
			<sch:report test="$spatialResolution_distance">(2.7.2) Spatial resolution (distance) found:
                <sch:value-of select="$spatialResolution_distance"/>
				<sch:value-of select="$spatialResolution_distance_uom"/>
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<!-- ############################################ -->
	<!-- Conformity                                   -->
	<!-- ############################################ -->
	<sch:pattern name="Conformity">
		<sch:title>Testing 'Conformity' elements</sch:title>
		<sch:rule context="/*">
			<sch:let name="degree" value="gmd:dataQualityInfo[1]/*/gmd:report[1]/*/gmd:result[1]/*/gmd:pass/*/text()"/>
			<sch:report test="not($degree)">(2.8.1) The degree of conformity of the resource has not yet been evaluated.</sch:report>
		</sch:rule>
		<sch:rule context="//gmd:dataQualityInfo[1]/*/gmd:report[1]/*/gmd:result[1]/*">
			<sch:let name="degree" value="gmd:pass/*/text()"/>
			<sch:let name="specification_title" value="gmd:specification/*/gmd:title/*/text()"/>
			<sch:let name="specification_date" value="gmd:specification/*/gmd:date/*/gmd:date/*/text()"/>
			<sch:let name="specification_dateType" value="gmd:specification/*/gmd:date/*/gmd:dateType/*/@codeListValue"/>
			<sch:let name="specification_SD" value="gmd:specification/*/gmd:title/*/text()='INSPIRE_D2.8.I.1' or
				//gmd:specification/*/gmd:title/*/text()='INSPIRE_D2.8.I.2'"/>
			<!-- assertions and report -->
			<sch:assert test="$specification_SD">(2.8.2.1) For INSPIRE Data Specification CODE shall be citated</sch:assert>
			<sch:report test="$degree">(2.8.1) Degree of conformity found:
            <sch:value-of select="$degree"/>
			</sch:report>
			<sch:report test="$specification_title">(2.8.2) Specification found:
            <sch:value-of select="$specification_title"/>, (<sch:value-of select="$specification_date"/>, <sch:value-of select="$specification_dateType"/>)
		</sch:report>
		</sch:rule>
	</sch:pattern>
	<!-- ############################################ -->
	<!-- Constraints related to access and use        -->
	<!-- ############################################ -->
	<sch:pattern name="Constraints related to access and use">
		<sch:title>Testing 'Constraints related to access and use' elements</sch:title>
		<sch:rule context="//gmd:identificationInfo[1]/*">
			<sch:assert test="count(gmd:resourceConstraints/*)">SC12. There shall be at least one instance of MD_Metadata.identificationInfo[1].MD_Identification.resourceConstraints</sch:assert>
		</sch:rule>
		<sch:rule context="//gmd:identificationInfo[1]/*/gmd:resourceConstraints/*">
			<sch:let name="accessConstraints" value="gmd:accessConstraints/*/@codeListValue"/>
			<sch:let name="accessConstraints_present" value="gmd:accessConstraints/*/@codeListValue = 'copyright' or gmd:accessConstraints/*/@codeListValue = 'patent' or gmd:accessConstraints/*/@codeListValue = 'patentPending' or gmd:accessConstraints/*/@codeListValue = 'trademark' or gmd:accessConstraints/*/@codeListValue = 'license' or gmd:accessConstraints/*/@codeListValue = 'intellectualPropertyRights' or gmd:accessConstraints/*/@codeListValue = 'restricted' or gmd:accessConstraints/*/@codeListValue = 'otherRestrictions'"/>
			<sch:let name="classification" value="gmd:classification/*/@codeListValue"/>
			<sch:let name="classification_present" value="gmd:classification/*/@codeListValue = 'unclassified' or gmd:classification/*/@codeListValue = 'restricted' or gmd:classification/*/@codeListValue = 'confidential' or gmd:classification/*/@codeListValue = 'secret' or gmd:classification/*/@codeListValue = 'topSecret'"/>
			<sch:let name="otherConstraints" value="gmd:otherConstraints/*/text()"/>
			<sch:report test="$accessConstraints_present">(2.9.1) Limitation on public access (accessConstraints) found:
                <sch:value-of select="$accessConstraints"/>
			</sch:report>
			<sch:report test="$classification_present">(2.9.1) Limitation on public access (classification) found:
                <sch:value-of select="$classification"/>
			</sch:report>
		</sch:rule>
		<sch:rule context="//gmd:identificationInfo[1]/*/gmd:resourceConstraints/*/gmd:otherConstraints/*">
			<sch:let name="accessConstraints_value" value="../../gmd:accessConstraints/*/@codeListValue"/>
			<sch:assert test="$accessConstraints_value = 'otherRestrictions'">(2.9.1) The value of 'accessConstraints' must be 'otherRestrictions', if there are instances of 'otherConstraints' expressing limitations on public access.</sch:assert>
			<sch:report test="$accessConstraints_value = 'otherRestrictions'">(2.9.1) Limitation on public access (otherConstraints) found:
                <sch:value-of select="."/>
			</sch:report>
		</sch:rule>
		<sch:rule context="//gmd:identificationInfo[1]/*">
			<sch:let name="useLimitation" value="gmd:resourceConstraints/*/gmd:useLimitation/*/text()"/>
			<sch:let name="useLimitation_count" value="count(gmd:resourceConstraints/*/gmd:useLimitation/*/text())"/>
			<sch:assert test="$useLimitation_count">(2.9.2) Conditions applying to access and use is missing</sch:assert>
			<sch:report test="$useLimitation_count">(2.9.2) Conditions applying to access and use found:
                <sch:value-of select="$useLimitation"/>
			</sch:report>
		</sch:rule>		
	</sch:pattern>
	<!-- ############################################ -->
	<!-- Responsible organisation                     -->
	<!-- ############################################ -->
	<sch:pattern name="Responsible organisation">
		<sch:title>Testing 'Responsible organisation' elements</sch:title>
		<sch:rule context="//gmd:identificationInfo[1]/*">
			<sch:let name="organisationName" value="gmd:pointOfContact/*/gmd:organisationName/*/text()"/>
			<sch:let name="role" value="gmd:pointOfContact/*/gmd:role/*/@codeListValue"/>
			<sch:let name="role_present" value="gmd:pointOfContact/*/gmd:role/*/@codeListValue = 'resourceProvider' or
												gmd:pointOfContact/*/gmd:role/*/@codeListValue = 'custodian' or
												gmd:pointOfContact/*/gmd:role/*/@codeListValue = 'owner' or
												gmd:pointOfContact/*/gmd:role/*/@codeListValue = 'user' or
												gmd:pointOfContact/*/gmd:role/*/@codeListValue = 'distributor' or
												gmd:pointOfContact/*/gmd:role/*/@codeListValue = 'originator' or
												gmd:pointOfContact/*/gmd:role/*/@codeListValue = 'pointOfContact' or
												gmd:pointOfContact/*/gmd:role/*/@codeListValue = 'principalInvestigator' or
												gmd:pointOfContact/*/gmd:role/*/@codeListValue = 'processor' or
												gmd:pointOfContact/*/gmd:role/*/@codeListValue = 'publisher' or
												gmd:pointOfContact/*/gmd:role/*/@codeListValue = 'author'"/>
			<sch:let name="emailAddress" value="gmd:pointOfContact/*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/*/text()"/>
			<!-- assertions and report -->
			<sch:assert test="$organisationName">(2.10.1) Organisation name (Resource) is missing</sch:assert>
			<sch:report test="$organisationName">(2.10.1) Organisation name (Resource) found:
                <sch:value-of select="$organisationName"/>
			</sch:report>
			<sch:assert test="$emailAddress">(2.10.1) Electronic mail address(resource) is missing </sch:assert>
			<sch:report test="$emailAddress">(2.10.1) Electronic mail address(resource) found:
                <sch:value-of select="$emailAddress"/>
			</sch:report>
			<sch:assert test="$role_present">(2.10.1) Role (resource) is missing or has a wrong value</sch:assert>
			<sch:report test="$role_present">(2.10.1) Role (resource) found:
                <sch:value-of select="$role"/>
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<!-- ############################################ -->
	<!-- Metadata on metadata                         -->
	<!-- ############################################ -->
	<sch:pattern name="Metadata on metadata">
		<sch:title>Testing 'Metadata on metadata' elements</sch:title>
		<sch:rule context="//gmd:MD_Metadata">
			<sch:let name="dateStamp" value="gmd:dateStamp/*/text()"/>
			<sch:let name="language" value="gmd:language/*/@codeListValue"/>
			<sch:let name="language_present" value="gmd:language/*/@codeListValue='bul' or
                            gmd:language/*/@codeListValue='ita' or
                            gmd:language/*/@codeListValue='cze' or
                            gmd:language/*/@codeListValue='lav' or
                            gmd:language/*/@codeListValue='dan' or
                            gmd:language/*/@codeListValue='lit' or
                            gmd:language/*/@codeListValue='dut' or
                            gmd:language/*/@codeListValue='mlt' or
                            gmd:language/*/@codeListValue='eng' or
                            gmd:language/*/@codeListValue='pol' or
                            gmd:language/*/@codeListValue='est' or
                            gmd:language/*/@codeListValue='por' or
                            gmd:language/*/@codeListValue='fin' or
                            gmd:language/*/@codeListValue='rum' or
                            gmd:language/*/@codeListValue='fre' or
                            gmd:language/*/@codeListValue='slo' or
                            gmd:language/*/@codeListValue='ger' or
                            gmd:language/*/@codeListValue='slv' or
                            gmd:language/*/@codeListValue='gre' or
                            gmd:language/*/@codeListValue='spa' or
                            gmd:language/*/@codeListValue='hun' or
                            gmd:language/*/@codeListValue='swe' or
                            gmd:language/*/@codeListValue='gle'"/>
			<!-- assertions and report -->
			<sch:assert test="$dateStamp">(2.11.2) Metadata date stamp is missing</sch:assert>
			<sch:report test="$dateStamp">(2.11.2) Metadata date stamp found:
                <sch:value-of select="$dateStamp"/>
			</sch:report>
			<sch:assert test="$language_present">(2.11.3) Metadata language is missing or has a wrong value</sch:assert>
			<sch:report test="$language_present">(2.11.3) Metadata language found:
                <sch:value-of select="$language"/>
			</sch:report>
		</sch:rule>
		<sch:rule context="gmd:MD_Metadata/gmd:contact/*">
			<sch:let name="organisationName" value="gmd:organisationName/*/text()"/>
			<sch:let name="role" value="gmd:role/*/@codeListValue"/>
			<sch:let name="role_present" value="gmd:role/*/@codeListValue = 'pointOfContact'"/>
			<sch:let name="emailAddress" value="gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/*/text()"/>
			<!-- assertions and report -->
			<sch:assert test="$organisationName">(2.11.1) Metadata responsible party (organisation name) is missing</sch:assert>
			<sch:report test="$organisationName">(2.11.1) Metadata responsible party (organisation name) found:
                <sch:value-of select="$organisationName"/>
			</sch:report>
			<sch:assert test="$emailAddress">(2.11.1) Metadata responsible party (electronic mail address) is missing</sch:assert>
			<sch:report test="$emailAddress">(2.11.1) Metadata responsible party (electronic mail address) found:
                <sch:value-of select="$emailAddress"/>
			</sch:report>
			<sch:assert test="$role_present">(SC16) The value of Metadata responsible party role shall be 'pointOfContact'.</sch:assert>
			<sch:report test="$role_present">(2.11.1) Metadata responsible party role found:
                <sch:value-of select="$role"/>
			</sch:report>
		</sch:rule>
	</sch:pattern>
</sch:schema>
