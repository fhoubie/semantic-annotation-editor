<?xml version="1.0" encoding="utf-8" standalone="yes"?>
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

<axsl:stylesheet xmlns:axsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sch="http://www.ascc.net/xml/schematron" xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:gml="http://www.opengis.net/gml" version="1.0"><!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->

   <axsl:param name="archiveDirParameter"/>
   <axsl:param name="archiveNameParameter"/>
   <axsl:param name="fileNameParameter"/>
   <axsl:param name="fileDirParameter"/>

<!--PHASES-->


<!--PROLOG-->


<!--KEYS-->


<!--DEFAULT RULES-->


<!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->

   <axsl:template match="*" mode="schematron-select-full-path">
      <axsl:apply-templates select="." mode="schematron-get-full-path"/>
   </axsl:template>

<!--MODE: SCHEMATRON-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->

   <axsl:template match="*" mode="schematron-get-full-path">
      <axsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <axsl:text>/</axsl:text>
      <axsl:choose>
         <axsl:when test="namespace-uri()=''">
            <axsl:value-of select="name()"/>
            <axsl:variable name="p_1" select="1+    count(preceding-sibling::*[name()=name(current())])"/>
            <axsl:if test="$p_1&gt;1 or following-sibling::*[name()=name(current())]">[<axsl:value-of select="$p_1"/>]</axsl:if>
         </axsl:when>
         <axsl:otherwise>
            <axsl:text>*[local-name()='</axsl:text>
            <axsl:value-of select="local-name()"/>
            <axsl:text>' and namespace-uri()='</axsl:text>
            <axsl:value-of select="namespace-uri()"/>
            <axsl:text>']</axsl:text>
            <axsl:variable name="p_2" select="1+   count(preceding-sibling::*[local-name()=local-name(current())])"/>
            <axsl:if test="$p_2&gt;1 or following-sibling::*[local-name()=local-name(current())]">[<axsl:value-of select="$p_2"/>]</axsl:if>
         </axsl:otherwise>
      </axsl:choose>
   </axsl:template>
   <axsl:template match="@*" mode="schematron-get-full-path">
      <axsl:text>/</axsl:text>
      <axsl:choose>
         <axsl:when test="namespace-uri()=''">@<axsl:value-of select="name()"/>
         </axsl:when>
         <axsl:otherwise>
            <axsl:text>@*[local-name()='</axsl:text>
            <axsl:value-of select="local-name()"/>
            <axsl:text>' and namespace-uri()='</axsl:text>
            <axsl:value-of select="namespace-uri()"/>
            <axsl:text>']</axsl:text>
         </axsl:otherwise>
      </axsl:choose>
   </axsl:template>

<!--MODE: SCHEMATRON-FULL-PATH-2-->
<!--This mode can be used to generate prefixed XPath for humans-->

   <axsl:template match="node() | @*" mode="schematron-get-full-path-2">
      <axsl:for-each select="ancestor-or-self::*">
         <axsl:text>/</axsl:text>
         <axsl:value-of select="name(.)"/>
         <axsl:if test="preceding-sibling::*[name(.)=name(current())]">
            <axsl:text>[</axsl:text>
            <axsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <axsl:text>]</axsl:text>
         </axsl:if>
      </axsl:for-each>
      <axsl:if test="not(self::*)">
         <axsl:text/>/@<axsl:value-of select="name(.)"/>
      </axsl:if>
   </axsl:template>

<!--MODE: GENERATE-ID-FROM-PATH -->

   <axsl:template match="/" mode="generate-id-from-path"/>
   <axsl:template match="text()" mode="generate-id-from-path">
      <axsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <axsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
   </axsl:template>
   <axsl:template match="comment()" mode="generate-id-from-path">
      <axsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <axsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
   </axsl:template>
   <axsl:template match="processing-instruction()" mode="generate-id-from-path">
      <axsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <axsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
   </axsl:template>
   <axsl:template match="@*" mode="generate-id-from-path">
      <axsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <axsl:value-of select="concat('.@', name())"/>
   </axsl:template>
   <axsl:template match="*" mode="generate-id-from-path" priority="-0.5">
      <axsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <axsl:text>.</axsl:text>
      <axsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
   </axsl:template><!--MODE: SCHEMATRON-FULL-PATH-3-->
<!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->

   <axsl:template match="node() | @*" mode="schematron-get-full-path-3">
      <axsl:for-each select="ancestor-or-self::*">
         <axsl:text>/</axsl:text>
         <axsl:value-of select="name(.)"/>
         <axsl:if test="parent::*">
            <axsl:text>[</axsl:text>
            <axsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <axsl:text>]</axsl:text>
         </axsl:if>
      </axsl:for-each>
      <axsl:if test="not(self::*)">
         <axsl:text/>/@<axsl:value-of select="name(.)"/>
      </axsl:if>
   </axsl:template>

<!--MODE: GENERATE-ID-2 -->

   <axsl:template match="/" mode="generate-id-2">U</axsl:template>
   <axsl:template match="*" mode="generate-id-2" priority="2">
      <axsl:text>U</axsl:text>
      <axsl:number level="multiple" count="*"/>
   </axsl:template>
   <axsl:template match="node()" mode="generate-id-2">
      <axsl:text>U.</axsl:text>
      <axsl:number level="multiple" count="*"/>
      <axsl:text>n</axsl:text>
      <axsl:number count="node()"/>
   </axsl:template>
   <axsl:template match="@*" mode="generate-id-2">
      <axsl:text>U.</axsl:text>
      <axsl:number level="multiple" count="*"/>
      <axsl:text>_</axsl:text>
      <axsl:value-of select="string-length(local-name(.))"/>
      <axsl:text>_</axsl:text>
      <axsl:value-of select="translate(name(),':','.')"/>
   </axsl:template><!--Strip characters-->
   <axsl:template match="text()" priority="-1"/>

<!--SCHEMA METADATA-->

   <axsl:template match="/">
      <axsl:apply-templates select="/" mode="M5"/>
      <axsl:apply-templates select="/" mode="M6"/>
      <axsl:apply-templates select="/" mode="M7"/>
      <axsl:apply-templates select="/" mode="M8"/>
      <axsl:apply-templates select="/" mode="M9"/>
      <axsl:apply-templates select="/" mode="M10"/>
      <axsl:apply-templates select="/" mode="M11"/>
      <axsl:apply-templates select="/" mode="M12"/>
      <axsl:apply-templates select="/" mode="M13"/>
      <axsl:apply-templates select="/" mode="M14"/>
      <axsl:apply-templates select="/" mode="M15"/>
   </axsl:template>

<!--SCHEMATRON PATTERNS-->


<!--PATTERN Testing implementation-->


	<!--RULE -->

   <axsl:template match="/*" priority="1000" mode="M5">

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="namespace-uri(/*) = 'http://www.isotc211.org/2005/gmd'"/>
         <axsl:otherwise>XML document is defined in the wrong namespace:
                <axsl:text/>
            <axsl:value-of select="namespace-uri(/*)"/>
            <axsl:text/>
			
            <axsl:value-of select="string(' ')"/>
         </axsl:otherwise>
      </axsl:choose>

		<!--REPORT -->

      <axsl:if test="namespace-uri(/*) = 'http://www.isotc211.org/2005/gmd'">Document namespace is <axsl:text/>
         <axsl:value-of select="namespace-uri(/*)"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M5"/>
   </axsl:template>
   <axsl:template match="text()" priority="-1" mode="M5"/>
   <axsl:template match="@*|node()" priority="-2" mode="M5">
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M5"/>
   </axsl:template>

<!--PATTERN Testing 'Identification' elements-->


	<!--RULE -->

   <axsl:template match="//gmd:identificationInfo[1]/*/gmd:citation/*" priority="1005" mode="M6">
      <axsl:variable name="resourceTitle" select="gmd:title/*/text()"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="$resourceTitle"/>
         <axsl:otherwise>(2.2.1) Resource title is missing<axsl:value-of select="string(' ')"/>
         </axsl:otherwise>
      </axsl:choose>

		<!--REPORT -->

      <axsl:if test="$resourceTitle">(2.2.1) Resource title found: <axsl:text/>
         <axsl:value-of select="$resourceTitle"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M6"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="//gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*" priority="1004" mode="M6">
      <axsl:variable name="resourceLocator" select="gmd:linkage/*/text()"/>

		<!--REPORT -->

      <axsl:if test="$resourceLocator">(2.2.4) Resource locator found:
                <axsl:text/>
         <axsl:value-of select="$resourceLocator"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M6"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="//gmd:MD_Metadata/gmd:hierarchyLevel[1]" priority="1003" mode="M6">
      <axsl:variable name="resourceType_present" select="*/@codeListValue='dataset'                             or */@codeListValue='series'                             or */@codeListValue='service'"/>
      <axsl:variable name="resourceType" select="*/@codeListValue"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="$resourceType_present"/>
         <axsl:otherwise>(2.2.3) Resource type is missing or has a wrong value<axsl:value-of select="string(' ')"/>
         </axsl:otherwise>
      </axsl:choose>

		<!--REPORT -->

      <axsl:if test="$resourceType_present">(2.2.3) Resource type found:
                <axsl:text/>
         <axsl:value-of select="$resourceType"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M6"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="//gmd:identificationInfo[1]/*" priority="1002" mode="M6">
      <axsl:variable name="resourceAbstract" select="gmd:abstract/*/text()"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="$resourceAbstract"/>
         <axsl:otherwise>(2.2.2) Resource abstract is missing<axsl:value-of select="string(' ')"/>
         </axsl:otherwise>
      </axsl:choose>

		<!--REPORT -->

      <axsl:if test="$resourceAbstract">(2.2.2) Resource abstract found:
                <axsl:text/>
         <axsl:value-of select="$resourceAbstract"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M6"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="//gmd:hierarchyLevel[1]/*[@codeListValue ='service']" priority="1001" mode="M6">
      <axsl:variable name="coupledResource" select="//srv:operatesOn/@xlink:href"/>

		<!--REPORT -->

      <axsl:if test="$coupledResource">(2.2.6) Coupled Resource found: <axsl:text/>
         <axsl:value-of select="$coupledResource"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M6"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="//gmd:hierarchyLevel[1]/*[@codeListValue ='dataset'] | //gmd:hierarchyLevel[1]/*[@codeListValue ='series']" priority="1000" mode="M6">
      <axsl:variable name="resourceIdentifier_code" select="//gmd:identificationInfo[1]/*/gmd:citation/*/gmd:identifier/*/gmd:code/*/text()"/>
      <axsl:variable name="resourceIdentifier_codeSpace" select="//gmd:identificationInfo[1]/*/gmd:citation/*/gmd:identifier/*/gmd:codeSpace/*/text()"/>
      <axsl:variable name="resourceLanguage_present" select="//gmd:identificationInfo[1]/*/gmd:language/*/text()='bul' or        //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='ita' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='cze' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='lav' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='dan' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='lit' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='dut' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='mlt' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='eng' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='pol' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='est' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='por' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='fin' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='rum' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='fre' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='slo' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='ger' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='slv' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='gre' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='spa' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='hun' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='swe' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='gle'"/>
      <axsl:variable name="resourceLanguage" select="//gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="$resourceIdentifier_code"/>
         <axsl:otherwise>(2.2.5) Unique resource identifier is missing<axsl:value-of select="string(' ')"/>
         </axsl:otherwise>
      </axsl:choose>

		<!--REPORT -->

      <axsl:if test="$resourceIdentifier_code">(2.2.5) Unique resource identifier (code) found:
                <axsl:text/>
         <axsl:value-of select="$resourceIdentifier_code"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>

		<!--REPORT -->

      <axsl:if test="$resourceIdentifier_codeSpace">(2.2.5) Unique resource identifier (codeSpace) found:
                <axsl:text/>
         <axsl:value-of select="$resourceIdentifier_codeSpace"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>

		<!--REPORT -->

      <axsl:if test="$resourceLanguage_present">(2.2.7) Resource language found:
                <axsl:text/>
         <axsl:value-of select="$resourceLanguage"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M6"/>
   </axsl:template>
   <axsl:template match="text()" priority="-1" mode="M6"/>
   <axsl:template match="@*|node()" priority="-2" mode="M6">
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M6"/>
   </axsl:template>

<!--PATTERN Testing 'Classification of spatial data and services' elements-->


	<!--RULE -->

   <axsl:template match="//gmd:hierarchyLevel[1]/*[@codeListValue ='dataset'] | //gmd:hierarchyLevel[1]/*[@codeListValue ='series']" priority="1001" mode="M7">
      <axsl:variable name="topicCategory" select="//gmd:topicCategory/*/text()"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="$topicCategory"/>
         <axsl:otherwise>(2.3.1) Topic category is missing<axsl:value-of select="string(' ')"/>
         </axsl:otherwise>
      </axsl:choose>

		<!--REPORT -->

      <axsl:if test="$topicCategory">(2.3.1) Topic category found:
                <axsl:text/>
         <axsl:value-of select="$topicCategory"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M7"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="//gmd:hierarchyLevel[1]/*[@codeListValue ='service']" priority="1000" mode="M7">
      <axsl:variable name="serviceType" select="//srv:serviceType/*/text()"/>
      <axsl:variable name="serviceType_present" select="//srv:serviceType/*/text() = 'view'                             or //srv:serviceType/*/text() = 'discovery'                             or //srv:serviceType/*/text() = 'download'                             or //srv:serviceType/*/text() = 'transformation'                             or //srv:serviceType/*/text() = 'invoke'                             or //srv:serviceType/*/text() = 'other'"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="$serviceType_present"/>
         <axsl:otherwise>(2.3.2) Spatial data service type is missing or has a wrong value<axsl:value-of select="string(' ')"/>
         </axsl:otherwise>
      </axsl:choose>

		<!--REPORT -->

      <axsl:if test="$serviceType_present">(2.3.2) Spatial data service type found:
                <axsl:text/>
         <axsl:value-of select="$serviceType"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M7"/>
   </axsl:template>
   <axsl:template match="text()" priority="-1" mode="M7"/>
   <axsl:template match="@*|node()" priority="-2" mode="M7">
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M7"/>
   </axsl:template>

<!--PATTERN Testing 'Keyword' elements-->


	<!--RULE -->

   <axsl:template match="//gmd:hierarchyLevel[1]/*[@codeListValue ='dataset'] | //gmd:hierarchyLevel[1]/*[@codeListValue ='series']" priority="1001" mode="M8">
      <axsl:variable name="keywordValue" select="//gmd:descriptiveKeywords/*/gmd:keyword/*/text()"/>
      <axsl:variable name="keywordValue_SDT" select="//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Addresses' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Administrative units' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Agricultural and aquaculture facilities' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Area management/restriction/regulation zones and reporting units' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Atmospheric conditions' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Bio-geographical regions' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Buildings' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Cadastral parcels' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Coordinate reference systems' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Elevation' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Energy resources' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Environmental monitoring facilities' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Geographical grid systems' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Geographical names' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Geology' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Habitats and biotopes' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Human health and safety' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Hydrography' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Land cover' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Land use' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Meteorological geographical features' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Mineral resources' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Natural risk zones' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Oceanographic geographical features' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Orthoimagery' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Population distribution — demography' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Production and industrial facilities' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Protected sites' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Sea regions' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Soil' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Species distribution' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Statistical units' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Transport networks' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Utility and governmental services'"/>
      <axsl:variable name="thesaurus_name" select="//gmd:descriptiveKeywords/*/gmd:thesaurusName/*/gmd:title/*/text()"/>
      <axsl:variable name="thesaurus_date" select="//gmd:descriptiveKeywords/*/gmd:thesaurusName/*/gmd:date/*/gmd:date/*/text()"/>
      <axsl:variable name="thesaurus_dateType" select="//gmd:descriptiveKeywords/*/gmd:thesaurusName/*/gmd:date/*/gmd:dateType/*/@codeListValue"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="$thesaurus_name = 'GemetInspireTheme'"/>
         <axsl:otherwise>(2.4.) A GEMET INSPIRE Spatial data theme thesaurus (GemetInspireTheme) shall be cited<axsl:value-of select="string(' ')"/>
         </axsl:otherwise>
      </axsl:choose>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="$keywordValue_SDT"/>
         <axsl:otherwise>(2.4) For datasets and series at least one keyword of GEMET thesaurus shall be documented.<axsl:value-of select="string(' ')"/>
         </axsl:otherwise>
      </axsl:choose>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="$keywordValue"/>
         <axsl:otherwise>(2.4.1) Keyword value is missing<axsl:value-of select="string(' ')"/>
         </axsl:otherwise>
      </axsl:choose>

		<!--REPORT -->

      <axsl:if test="$keywordValue">(2.4.1) Keyword value found:
                <axsl:text/>
         <axsl:value-of select="$keywordValue"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>

		<!--REPORT -->

      <axsl:if test="$thesaurus_name">(2.4.2) Thesaurus found:
                <axsl:text/>
         <axsl:value-of select="$thesaurus_name"/>
         <axsl:text/>, <axsl:text/>
         <axsl:value-of select="$thesaurus_date"/>
         <axsl:text/> (<axsl:text/>
         <axsl:value-of select="$thesaurus_dateType"/>
         <axsl:text/>)
            <axsl:value-of select="string(' ')"/>
      </axsl:if>
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M8"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="//gmd:hierarchyLevel[1]/*[@codeListValue ='service']" priority="1000" mode="M8">
      <axsl:variable name="keywordValue" select="//gmd:descriptiveKeywords/*/gmd:keyword/*/text()"/>
      <axsl:variable name="keywordValue_SDT" select="//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanInteractionService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanCatalogueViewer' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanGeographicViewer' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanGeographicSpreadsheetViewer' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanServiceEditor' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanChainDefinitionEditor' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanWorkflowEnactmentManager' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanGeographicFeatureEditor' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanGeographicSymbolEditor' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanFeatureGeneralizationEditor' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanGeographicDataStructureViewer' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoManagementService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoFeatureAccessService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoMapAccessService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoCoverageAccessService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoSensorDescriptionService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoProductAccessService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoFeatureTypeService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoCatalogueService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoRegistryService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoGazetteerService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoOrderHandlingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoStandingOrderService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='taskManagementService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='chainDefinitionService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='workflowEnactmentService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='subscriptionService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialProcessingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialCoordinateConversionService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialCoordinateTransformationService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialCoverageVectorConversionService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialImageCoordinateConversionService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialRectificationService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialOrthorectificationService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialSensorGeometryModelAdjustmentService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialImageGeometryModelConversionService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialSubsettingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialSamplingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialTilingChangeService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialDimensionMeasurementService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialFeatureManipulationService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialFeatureMatchingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialFeatureGeneralizationService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialRouteDeterminationService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialPositioningService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialProximityAnalysisService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicProcessingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicGoparameterCalculationService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicClassificationService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicFeatureGeneralizationService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicSubsettingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicSpatialCountingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicChangeDetectionService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicGeographicInformationExtractionService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicImageProcessingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicReducedResolutionGenerationService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicImageManipulationService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicImageUnderstandingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicImageSynthesisService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicMultibandImageManipulationService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicObjectDetectionService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicGeoparsingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicGeocodingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='temporalProcessingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='temporalReferenceSystemTransformationService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='temporalSubsettingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='temporalSamplingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='temporalProximityAnalysisService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='metadataProcessingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='metadataStatisticalCalculationService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='metadataGeographicAnnotationService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='comService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='comEncodingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='comTransferService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='comGeographicCompressionService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='comGeographicFormatConversionService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='comMessagingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='comRemoteFileAndExecutableManagement'"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="$keywordValue_SDT"/>
         <axsl:otherwise>(2.4) For spatial data services, at least the category or subcategory of the service as defined in Part D 4 shall be documented.<axsl:value-of select="string(' ')"/>
         </axsl:otherwise>
      </axsl:choose>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="$keywordValue"/>
         <axsl:otherwise>(2.4.1) Keyword value is missing<axsl:value-of select="string(' ')"/>
         </axsl:otherwise>
      </axsl:choose>

		<!--REPORT -->

      <axsl:if test="$keywordValue">(2.4.1) Keyword value found:
                <axsl:text/>
         <axsl:value-of select="$keywordValue"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M8"/>
   </axsl:template>
   <axsl:template match="text()" priority="-1" mode="M8"/>
   <axsl:template match="@*|node()" priority="-2" mode="M8">
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M8"/>
   </axsl:template>

<!--PATTERN Testing 'Geographic location' elements-->


	<!--RULE -->

   <axsl:template match="//gmd:hierarchyLevel[1]/*[@codeListValue ='dataset'] | //gmd:hierarchyLevel[1]/*[@codeListValue ='series']" priority="1001" mode="M9">
      <axsl:variable name="west" select="number(//gmd:identificationInfo[1]/*/gmd:extent/*/gmd:geographicElement/*/gmd:westBoundLongitude/*)"/>
      <axsl:variable name="east" select="number(//gmd:identificationInfo[1]/*/gmd:extent/*/gmd:geographicElement/*/gmd:eastBoundLongitude/*)"/>
      <axsl:variable name="north" select="number(//gmd:identificationInfo[1]/*/gmd:extent/*/gmd:geographicElement/*/gmd:northBoundLatitude/*)"/>
      <axsl:variable name="south" select="number(//gmd:identificationInfo[1]/*/gmd:extent/*/gmd:geographicElement/*/gmd:southBoundLatitude/*)"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="(-180.00 &lt;= $west) and ( $west &lt;= 180.00)"/>
         <axsl:otherwise>(2.5.1) WestBoundLongitude is missing or has wrong value<axsl:value-of select="string(' ')"/>
         </axsl:otherwise>
      </axsl:choose>

		<!--REPORT -->

      <axsl:if test="(-180.00 &lt;= $west) and ( $west &lt;= 180.00)">(2.5.1) WestBoundLongitude found:
                <axsl:text/>
         <axsl:value-of select="$west"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="(-180.00 &lt;= $east) and ($east &lt;= 180.00)"/>
         <axsl:otherwise>(2.5.1) EastBoundLongitude is missing or has wrong value<axsl:value-of select="string(' ')"/>
         </axsl:otherwise>
      </axsl:choose>

		<!--REPORT -->

      <axsl:if test="(-180.00 &lt;= $east) and ($east &lt;= 180.00)">(2.5.1) EastBoundLongitude found:
                <axsl:text/>
         <axsl:value-of select="$east"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="(-90.00 &lt;= $south) and ($south &lt;= $north)"/>
         <axsl:otherwise>(2.5.1) SouthBoundLatitude is missing or has wrong value<axsl:value-of select="string(' ')"/>
         </axsl:otherwise>
      </axsl:choose>

		<!--REPORT -->

      <axsl:if test="(-90.00 &lt;= $south) and ($south &lt;= $north)">(2.5.1) SouthBoundLatitude found:
                <axsl:text/>
         <axsl:value-of select="$south"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="($south &lt;= $north) and ($north &lt;= 90.00)"/>
         <axsl:otherwise>(2.5.1) NorthBoundLatitude is missing or has wrong value<axsl:value-of select="string(' ')"/>
         </axsl:otherwise>
      </axsl:choose>

		<!--REPORT -->

      <axsl:if test="($south &lt;= $north) and ($north &lt;= 90.00)">(2.5.1) NorthBoundLatitude found:
                <axsl:text/>
         <axsl:value-of select="$north"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M9"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="//gmd:hierarchyLevel[1]/*[@codeListValue ='service']" priority="1000" mode="M9">
      <axsl:variable name="west" select="number(//gmd:identificationInfo[1]/*/srv:extent/*/gmd:geographicElement/*/gmd:westBoundLongitude/*)"/>
      <axsl:variable name="east" select="number(//gmd:identificationInfo[1]/*/srv:extent/*/gmd:geographicElement/*/gmd:eastBoundLongitude/*)"/>
      <axsl:variable name="north" select="number(//gmd:identificationInfo[1]/*/srv:extent/*/gmd:geographicElement/*/gmd:northBoundLatitude/*)"/>
      <axsl:variable name="south" select="number(//gmd:identificationInfo[1]/*/srv:extent/*/gmd:geographicElement/*/gmd:southBoundLatitude/*)"/>

		<!--REPORT -->

      <axsl:if test="(-180.00 &lt;= $west) and ( $west &lt;= 180.00)">(2.5.1) WestBoundLongitude found:
                <axsl:text/>
         <axsl:value-of select="$west"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>

		<!--REPORT -->

      <axsl:if test="(-180.00 &lt;= $east) and ($east &lt;= 180.00)">(2.5.1) EastBoundLongitude found:
                <axsl:text/>
         <axsl:value-of select="$east"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>

		<!--REPORT -->

      <axsl:if test="(-90.00 &lt;= $south) and ($south &lt;= $north)">(2.5.1) SouthBoundLatitude found:
                <axsl:text/>
         <axsl:value-of select="$south"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>

		<!--REPORT -->

      <axsl:if test="($south &lt;= $north) and ($north &lt;= 90.00)">(2.5.1) NorthBoundLatitude found:
                <axsl:text/>
         <axsl:value-of select="$north"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M9"/>
   </axsl:template>
   <axsl:template match="text()" priority="-1" mode="M9"/>
   <axsl:template match="@*|node()" priority="-2" mode="M9">
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M9"/>
   </axsl:template>

<!--PATTERN Testing 'Temporal reference' elements-->


	<!--RULE -->

   <axsl:template match="//gmd:identificationInfo[1]/*" priority="1000" mode="M10">
      <axsl:variable name="temporalExtentBegin" select="gmd:extent/*/gmd:temporalElement/*/gmd:extent/*/gml:beginPosition/text()"/>
      <axsl:variable name="temporalExtentEnd" select="gmd:extent/*/gmd:temporalElement/*/gmd:extent/*/gml:endPosition/text()"/>
      <axsl:variable name="publicationDate" select="gmd:citation/*/gmd:date[./*/gmd:dateType/*/@codeListValue='publication']/*/gmd:date/*"/>
      <axsl:variable name="creationDate" select="gmd:citation/*/gmd:date[./*/gmd:dateType/*/@codeListValue='creation']/*/gmd:date/*"/>
      <axsl:variable name="no_creationDate" select="count(gmd:citation/*/gmd:date[./*/gmd:dateType/*/@codeListValue='creation']/*/gmd:date/*)"/>
      <axsl:variable name="revisionDate" select="gmd:citation/*/gmd:date[./*/gmd:dateType/*/@codeListValue='revision']/*/gmd:date/*"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="$no_creationDate &lt;= 1"/>
         <axsl:otherwise>SC7.  There shall not be more than one instance of MD_Metadata.identificationInfo[1].MD_Identification.citation.CI_Citation.date declared as a creation date (i.e. CI_Date.dateType having the creation value)<axsl:value-of select="string(' ')"/>
         </axsl:otherwise>
      </axsl:choose>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="$publicationDate or $creationDate or $revisionDate or $temporalExtentBegin or $temporalExtentEnd"/>
         <axsl:otherwise>(2.6) No instance of Temporal reference has been found.<axsl:value-of select="string(' ')"/>
         </axsl:otherwise>
      </axsl:choose>

		<!--REPORT -->

      <axsl:if test="$temporalExtentBegin">(2.6.1) Temporal extent (begin) found: <axsl:text/>
         <axsl:value-of select="$temporalExtentBegin"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>

		<!--REPORT -->

      <axsl:if test="$temporalExtentEnd">(2.6.1) Temporal extent (end) found: <axsl:text/>
         <axsl:value-of select="$temporalExtentEnd"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>

		<!--REPORT -->

      <axsl:if test="$publicationDate">(2.6.2) Date of publication of the resource found: <axsl:text/>
         <axsl:value-of select="$publicationDate"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>

		<!--REPORT -->

      <axsl:if test="$revisionDate">(2.6.3) Date of revision of the resource found: : <axsl:text/>
         <axsl:value-of select="$revisionDate"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>

		<!--REPORT -->

      <axsl:if test="$creationDate">(2.6.4) Date of creation of the resource found: : <axsl:text/>
         <axsl:value-of select="$creationDate"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M10"/>
   </axsl:template>
   <axsl:template match="text()" priority="-1" mode="M10"/>
   <axsl:template match="@*|node()" priority="-2" mode="M10">
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M10"/>
   </axsl:template>

<!--PATTERN Testing 'Quality and validity' elements-->


	<!--RULE -->

   <axsl:template match="//gmd:hierarchyLevel[1]/*[@codeListValue ='dataset'] | //gmd:hierarchyLevel[1]/*[@codeListValue ='series']" priority="1001" mode="M11">
      <axsl:variable name="lineage" select="//gmd:dataQualityInfo/*/gmd:lineage/*/gmd:statement/*/text()"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="$lineage"/>
         <axsl:otherwise>(2.7.1) Lineage is missing<axsl:value-of select="string(' ')"/>
         </axsl:otherwise>
      </axsl:choose>

		<!--REPORT -->

      <axsl:if test="$lineage">(2.7.1) Lineage found:
                <axsl:text/>
         <axsl:value-of select="$lineage"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M11"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="//gmd:identificationInfo[1]/*/gmd:spatialResolution/*" priority="1000" mode="M11">
      <axsl:variable name="spatialResolution_equivalentScale" select="gmd:equivalentScale/*/gmd:denominator"/>
      <axsl:variable name="spatialResolution_distance" select="gmd:distance/*/text()"/>
      <axsl:variable name="spatialResolution_distance_uom" select="gmd:distance/*/@uom"/>

		<!--REPORT -->

      <axsl:if test="$spatialResolution_equivalentScale">(2.7.2) Spatial resolution (equivalentScale) found:
                <axsl:text/>
         <axsl:value-of select="$spatialResolution_equivalentScale"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>

		<!--REPORT -->

      <axsl:if test="$spatialResolution_distance">(2.7.2) Spatial resolution (distance) found:
                <axsl:text/>
         <axsl:value-of select="$spatialResolution_distance"/>
         <axsl:text/>
				
         <axsl:text/>
         <axsl:value-of select="$spatialResolution_distance_uom"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M11"/>
   </axsl:template>
   <axsl:template match="text()" priority="-1" mode="M11"/>
   <axsl:template match="@*|node()" priority="-2" mode="M11">
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M11"/>
   </axsl:template>

<!--PATTERN Testing 'Conformity' elements-->


	<!--RULE -->

   <axsl:template match="/*" priority="1001" mode="M12">
      <axsl:variable name="degree" select="gmd:dataQualityInfo[1]/*/gmd:report[1]/*/gmd:result[1]/*/gmd:pass/*/text()"/>

		<!--REPORT -->

      <axsl:if test="not($degree)">(2.8.1) The degree of conformity of the resource has not yet been evaluated.<axsl:value-of select="string(' ')"/>
      </axsl:if>
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M12"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="//gmd:dataQualityInfo[1]/*/gmd:report[1]/*/gmd:result[1]/*" priority="1000" mode="M12">
      <axsl:variable name="degree" select="gmd:pass/*/text()"/>
      <axsl:variable name="specification_title" select="gmd:specification/*/gmd:title/*/text()"/>
      <axsl:variable name="specification_date" select="gmd:specification/*/gmd:date/*/gmd:date/*/text()"/>
      <axsl:variable name="specification_dateType" select="gmd:specification/*/gmd:date/*/gmd:dateType/*/@codeListValue"/>
      <axsl:variable name="specification_SD" select="gmd:specification/*/gmd:title/*/text()='INSPIRE_D2.8.I.1' or     //gmd:specification/*/gmd:title/*/text()='INSPIRE_D2.8.I.2'"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="$specification_SD"/>
         <axsl:otherwise>(2.8.2.1) For INSPIRE Data Specification CODE shall be citated<axsl:value-of select="string(' ')"/>
         </axsl:otherwise>
      </axsl:choose>

		<!--REPORT -->

      <axsl:if test="$degree">(2.8.1) Degree of conformity found:
            <axsl:text/>
         <axsl:value-of select="$degree"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>

		<!--REPORT -->

      <axsl:if test="$specification_title">(2.8.2) Specification found:
            <axsl:text/>
         <axsl:value-of select="$specification_title"/>
         <axsl:text/>, (<axsl:text/>
         <axsl:value-of select="$specification_date"/>
         <axsl:text/>, <axsl:text/>
         <axsl:value-of select="$specification_dateType"/>
         <axsl:text/>)
		<axsl:value-of select="string(' ')"/>
      </axsl:if>
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M12"/>
   </axsl:template>
   <axsl:template match="text()" priority="-1" mode="M12"/>
   <axsl:template match="@*|node()" priority="-2" mode="M12">
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M12"/>
   </axsl:template>

<!--PATTERN Testing 'Constraints related to access and use' elements-->


	<!--RULE -->

   <axsl:template match="//gmd:identificationInfo[1]/*" priority="1003" mode="M13">

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="count(gmd:resourceConstraints/*)"/>
         <axsl:otherwise>SC12. There shall be at least one instance of MD_Metadata.identificationInfo[1].MD_Identification.resourceConstraints<axsl:value-of select="string(' ')"/>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M13"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="//gmd:identificationInfo[1]/*/gmd:resourceConstraints/*" priority="1002" mode="M13">
      <axsl:variable name="accessConstraints" select="gmd:accessConstraints/*/@codeListValue"/>
      <axsl:variable name="accessConstraints_present" select="gmd:accessConstraints/*/@codeListValue = 'copyright' or gmd:accessConstraints/*/@codeListValue = 'patent' or gmd:accessConstraints/*/@codeListValue = 'patentPending' or gmd:accessConstraints/*/@codeListValue = 'trademark' or gmd:accessConstraints/*/@codeListValue = 'license' or gmd:accessConstraints/*/@codeListValue = 'intellectualPropertyRights' or gmd:accessConstraints/*/@codeListValue = 'restricted' or gmd:accessConstraints/*/@codeListValue = 'otherRestrictions'"/>
      <axsl:variable name="classification" select="gmd:classification/*/@codeListValue"/>
      <axsl:variable name="classification_present" select="gmd:classification/*/@codeListValue = 'unclassified' or gmd:classification/*/@codeListValue = 'restricted' or gmd:classification/*/@codeListValue = 'confidential' or gmd:classification/*/@codeListValue = 'secret' or gmd:classification/*/@codeListValue = 'topSecret'"/>
      <axsl:variable name="otherConstraints" select="gmd:otherConstraints/*/text()"/>

		<!--REPORT -->

      <axsl:if test="$accessConstraints_present">(2.9.1) Limitation on public access (accessConstraints) found:
                <axsl:text/>
         <axsl:value-of select="$accessConstraints"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>

		<!--REPORT -->

      <axsl:if test="$classification_present">(2.9.1) Limitation on public access (classification) found:
                <axsl:text/>
         <axsl:value-of select="$classification"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M13"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="//gmd:identificationInfo[1]/*/gmd:resourceConstraints/*/gmd:otherConstraints/*" priority="1001" mode="M13">
      <axsl:variable name="accessConstraints_value" select="../../gmd:accessConstraints/*/@codeListValue"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="$accessConstraints_value = 'otherRestrictions'"/>
         <axsl:otherwise>(2.9.1) The value of 'accessConstraints' must be 'otherRestrictions', if there are instances of 'otherConstraints' expressing limitations on public access.<axsl:value-of select="string(' ')"/>
         </axsl:otherwise>
      </axsl:choose>

		<!--REPORT -->

      <axsl:if test="$accessConstraints_value = 'otherRestrictions'">(2.9.1) Limitation on public access (otherConstraints) found:
                <axsl:text/>
         <axsl:value-of select="."/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M13"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="//gmd:identificationInfo[1]/*" priority="1000" mode="M13">
      <axsl:variable name="useLimitation" select="gmd:resourceConstraints/*/gmd:useLimitation/*/text()"/>
      <axsl:variable name="useLimitation_count" select="count(gmd:resourceConstraints/*/gmd:useLimitation/*/text())"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="$useLimitation_count"/>
         <axsl:otherwise>(2.9.2) Conditions applying to access and use is missing<axsl:value-of select="string(' ')"/>
         </axsl:otherwise>
      </axsl:choose>

		<!--REPORT -->

      <axsl:if test="$useLimitation_count">(2.9.2) Conditions applying to access and use found:
                <axsl:text/>
         <axsl:value-of select="$useLimitation"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M13"/>
   </axsl:template>
   <axsl:template match="text()" priority="-1" mode="M13"/>
   <axsl:template match="@*|node()" priority="-2" mode="M13">
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M13"/>
   </axsl:template>

<!--PATTERN Testing 'Responsible organisation' elements-->


	<!--RULE -->

   <axsl:template match="//gmd:identificationInfo[1]/*" priority="1000" mode="M14">
      <axsl:variable name="organisationName" select="gmd:pointOfContact/*/gmd:organisationName/*/text()"/>
      <axsl:variable name="role" select="gmd:pointOfContact/*/gmd:role/*/@codeListValue"/>
      <axsl:variable name="role_present" select="gmd:pointOfContact/*/gmd:role/*/@codeListValue = 'resourceProvider' or             gmd:pointOfContact/*/gmd:role/*/@codeListValue = 'custodian' or             gmd:pointOfContact/*/gmd:role/*/@codeListValue = 'owner' or             gmd:pointOfContact/*/gmd:role/*/@codeListValue = 'user' or             gmd:pointOfContact/*/gmd:role/*/@codeListValue = 'distributor' or             gmd:pointOfContact/*/gmd:role/*/@codeListValue = 'originator' or             gmd:pointOfContact/*/gmd:role/*/@codeListValue = 'pointOfContact' or             gmd:pointOfContact/*/gmd:role/*/@codeListValue = 'principalInvestigator' or             gmd:pointOfContact/*/gmd:role/*/@codeListValue = 'processor' or             gmd:pointOfContact/*/gmd:role/*/@codeListValue = 'publisher' or             gmd:pointOfContact/*/gmd:role/*/@codeListValue = 'author'"/>
      <axsl:variable name="emailAddress" select="gmd:pointOfContact/*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/*/text()"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="$organisationName"/>
         <axsl:otherwise>(2.10.1) Organisation name (Resource) is missing<axsl:value-of select="string(' ')"/>
         </axsl:otherwise>
      </axsl:choose>

		<!--REPORT -->

      <axsl:if test="$organisationName">(2.10.1) Organisation name (Resource) found:
                <axsl:text/>
         <axsl:value-of select="$organisationName"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="$emailAddress"/>
         <axsl:otherwise>(2.10.1) Electronic mail address(resource) is missing <axsl:value-of select="string(' ')"/>
         </axsl:otherwise>
      </axsl:choose>

		<!--REPORT -->

      <axsl:if test="$emailAddress">(2.10.1) Electronic mail address(resource) found:
                <axsl:text/>
         <axsl:value-of select="$emailAddress"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="$role_present"/>
         <axsl:otherwise>(2.10.1) Role (resource) is missing or has a wrong value<axsl:value-of select="string(' ')"/>
         </axsl:otherwise>
      </axsl:choose>

		<!--REPORT -->

      <axsl:if test="$role_present">(2.10.1) Role (resource) found:
                <axsl:text/>
         <axsl:value-of select="$role"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M14"/>
   </axsl:template>
   <axsl:template match="text()" priority="-1" mode="M14"/>
   <axsl:template match="@*|node()" priority="-2" mode="M14">
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M14"/>
   </axsl:template>

<!--PATTERN Testing 'Metadata on metadata' elements-->


	<!--RULE -->

   <axsl:template match="//gmd:MD_Metadata" priority="1001" mode="M15">
      <axsl:variable name="dateStamp" select="gmd:dateStamp/*/text()"/>
      <axsl:variable name="language" select="gmd:language/*/@codeListValue"/>
      <axsl:variable name="language_present" select="gmd:language/*/@codeListValue='bul' or                             gmd:language/*/@codeListValue='ita' or                             gmd:language/*/@codeListValue='cze' or                             gmd:language/*/@codeListValue='lav' or                             gmd:language/*/@codeListValue='dan' or                             gmd:language/*/@codeListValue='lit' or                             gmd:language/*/@codeListValue='dut' or                             gmd:language/*/@codeListValue='mlt' or                             gmd:language/*/@codeListValue='eng' or                             gmd:language/*/@codeListValue='pol' or                             gmd:language/*/@codeListValue='est' or                             gmd:language/*/@codeListValue='por' or                             gmd:language/*/@codeListValue='fin' or                             gmd:language/*/@codeListValue='rum' or                             gmd:language/*/@codeListValue='fre' or                             gmd:language/*/@codeListValue='slo' or                             gmd:language/*/@codeListValue='ger' or                             gmd:language/*/@codeListValue='slv' or                             gmd:language/*/@codeListValue='gre' or                             gmd:language/*/@codeListValue='spa' or                             gmd:language/*/@codeListValue='hun' or                             gmd:language/*/@codeListValue='swe' or                             gmd:language/*/@codeListValue='gle'"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="$dateStamp"/>
         <axsl:otherwise>(2.11.2) Metadata date stamp is missing<axsl:value-of select="string(' ')"/>
         </axsl:otherwise>
      </axsl:choose>

		<!--REPORT -->

      <axsl:if test="$dateStamp">(2.11.2) Metadata date stamp found:
                <axsl:text/>
         <axsl:value-of select="$dateStamp"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="$language_present"/>
         <axsl:otherwise>(2.11.3) Metadata language is missing or has a wrong value<axsl:value-of select="string(' ')"/>
         </axsl:otherwise>
      </axsl:choose>

		<!--REPORT -->

      <axsl:if test="$language_present">(2.11.3) Metadata language found:
                <axsl:text/>
         <axsl:value-of select="$language"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M15"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="gmd:MD_Metadata/gmd:contact/*" priority="1000" mode="M15">
      <axsl:variable name="organisationName" select="gmd:organisationName/*/text()"/>
      <axsl:variable name="role" select="gmd:role/*/@codeListValue"/>
      <axsl:variable name="role_present" select="gmd:role/*/@codeListValue = 'pointOfContact'"/>
      <axsl:variable name="emailAddress" select="gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/*/text()"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="$organisationName"/>
         <axsl:otherwise>(2.11.1) Metadata responsible party (organisation name) is missing<axsl:value-of select="string(' ')"/>
         </axsl:otherwise>
      </axsl:choose>

		<!--REPORT -->

      <axsl:if test="$organisationName">(2.11.1) Metadata responsible party (organisation name) found:
                <axsl:text/>
         <axsl:value-of select="$organisationName"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="$emailAddress"/>
         <axsl:otherwise>(2.11.1) Metadata responsible party (electronic mail address) is missing<axsl:value-of select="string(' ')"/>
         </axsl:otherwise>
      </axsl:choose>

		<!--REPORT -->

      <axsl:if test="$emailAddress">(2.11.1) Metadata responsible party (electronic mail address) found:
                <axsl:text/>
         <axsl:value-of select="$emailAddress"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="$role_present"/>
         <axsl:otherwise>(SC16) The value of Metadata responsible party role shall be 'pointOfContact'.<axsl:value-of select="string(' ')"/>
         </axsl:otherwise>
      </axsl:choose>

		<!--REPORT -->

      <axsl:if test="$role_present">(2.11.1) Metadata responsible party role found:
                <axsl:text/>
         <axsl:value-of select="$role"/>
         <axsl:text/>
			
         <axsl:value-of select="string(' ')"/>
      </axsl:if>
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M15"/>
   </axsl:template>
   <axsl:template match="text()" priority="-1" mode="M15"/>
   <axsl:template match="@*|node()" priority="-2" mode="M15">
      <axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M15"/>
   </axsl:template>
</axsl:stylesheet>