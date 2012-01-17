<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:sch="http://www.ascc.net/xml/schematron" xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:gml="http://www.opengis.net/gml" version="1.0">
<!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->
<xsl:param name="archiveDirParameter"/>
<xsl:param name="archiveNameParameter"/>
<xsl:param name="fileNameParameter"/>
<xsl:param name="fileDirParameter"/>

<!--PHASES-->


<!--PROLOG-->
<xsl:output xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" method="xml" omit-xml-declaration="no" standalone="yes" indent="yes"/>

<!--KEYS-->


<!--DEFAULT RULES-->


<!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<xsl:template match="*" mode="schematron-select-full-path">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:template>

<!--MODE: SCHEMATRON-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<xsl:template match="*" mode="schematron-get-full-path">
<xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
<xsl:text>/</xsl:text>
<xsl:choose>
<xsl:when test="namespace-uri()=''">
<xsl:value-of select="name()"/>
<xsl:variable name="p_1" select="1+    count(preceding-sibling::*[name()=name(current())])"/>
<xsl:if test="$p_1&gt;1 or following-sibling::*[name()=name(current())]">[<xsl:value-of select="$p_1"/>]</xsl:if>
</xsl:when>
<xsl:otherwise>
<xsl:text>*[local-name()='</xsl:text>
<xsl:value-of select="local-name()"/>
<xsl:text>' and namespace-uri()='</xsl:text>
<xsl:value-of select="namespace-uri()"/>
<xsl:text>']</xsl:text>
<xsl:variable name="p_2" select="1+   count(preceding-sibling::*[local-name()=local-name(current())])"/>
<xsl:if test="$p_2&gt;1 or following-sibling::*[local-name()=local-name(current())]">[<xsl:value-of select="$p_2"/>]</xsl:if>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<xsl:template match="@*" mode="schematron-get-full-path">
<xsl:text>/</xsl:text>
<xsl:choose>
<xsl:when test="namespace-uri()=''">@<xsl:value-of select="name()"/>
</xsl:when>
<xsl:otherwise>
<xsl:text>@*[local-name()='</xsl:text>
<xsl:value-of select="local-name()"/>
<xsl:text>' and namespace-uri()='</xsl:text>
<xsl:value-of select="namespace-uri()"/>
<xsl:text>']</xsl:text>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!--MODE: SCHEMATRON-FULL-PATH-2-->
<!--This mode can be used to generate prefixed XPath for humans-->
<xsl:template match="node() | @*" mode="schematron-get-full-path-2">
<xsl:for-each select="ancestor-or-self::*">
<xsl:text>/</xsl:text>
<xsl:value-of select="name(.)"/>
<xsl:if test="preceding-sibling::*[name(.)=name(current())]">
<xsl:text>[</xsl:text>
<xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
<xsl:text>]</xsl:text>
</xsl:if>
</xsl:for-each>
<xsl:if test="not(self::*)">
<xsl:text/>/@<xsl:value-of select="name(.)"/>
</xsl:if>
</xsl:template>

<!--MODE: GENERATE-ID-FROM-PATH -->
<xsl:template match="/" mode="generate-id-from-path"/>
<xsl:template match="text()" mode="generate-id-from-path">
<xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
<xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
</xsl:template>
<xsl:template match="comment()" mode="generate-id-from-path">
<xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
<xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
</xsl:template>
<xsl:template match="processing-instruction()" mode="generate-id-from-path">
<xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
<xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
</xsl:template>
<xsl:template match="@*" mode="generate-id-from-path">
<xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
<xsl:value-of select="concat('.@', name())"/>
</xsl:template>
<xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
<xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
<xsl:text>.</xsl:text>
<xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
</xsl:template>
<!--MODE: SCHEMATRON-FULL-PATH-3-->
<!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->
<xsl:template match="node() | @*" mode="schematron-get-full-path-3">
<xsl:for-each select="ancestor-or-self::*">
<xsl:text>/</xsl:text>
<xsl:value-of select="name(.)"/>
<xsl:if test="parent::*">
<xsl:text>[</xsl:text>
<xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
<xsl:text>]</xsl:text>
</xsl:if>
</xsl:for-each>
<xsl:if test="not(self::*)">
<xsl:text/>/@<xsl:value-of select="name(.)"/>
</xsl:if>
</xsl:template>

<!--MODE: GENERATE-ID-2 -->
<xsl:template match="/" mode="generate-id-2">U</xsl:template>
<xsl:template match="*" mode="generate-id-2" priority="2">
<xsl:text>U</xsl:text>
<xsl:number level="multiple" count="*"/>
</xsl:template>
<xsl:template match="node()" mode="generate-id-2">
<xsl:text>U.</xsl:text>
<xsl:number level="multiple" count="*"/>
<xsl:text>n</xsl:text>
<xsl:number count="node()"/>
</xsl:template>
<xsl:template match="@*" mode="generate-id-2">
<xsl:text>U.</xsl:text>
<xsl:number level="multiple" count="*"/>
<xsl:text>_</xsl:text>
<xsl:value-of select="string-length(local-name(.))"/>
<xsl:text>_</xsl:text>
<xsl:value-of select="translate(name(),':','.')"/>
</xsl:template>
<!--Strip characters-->
<xsl:template match="text()" priority="-1"/>

<!--SCHEMA METADATA-->
<xsl:template match="/">
<svrl:schematron-output xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" title="" schemaVersion="">
<xsl:comment>
<xsl:value-of select="$archiveDirParameter"/>   
		 <xsl:value-of select="$archiveNameParameter"/>  
		 <xsl:value-of select="$fileNameParameter"/>  
		 <xsl:value-of select="$fileDirParameter"/>
</xsl:comment>
<svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/gmd" prefix="gmd"/>
<svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/gco" prefix="gco"/>
<svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/srv" prefix="srv"/>
<svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
<svrl:ns-prefix-in-attribute-values uri="http://www.opengis.net/gml" prefix="gml"/>
<svrl:active-pattern>
<xsl:attribute name="name">Testing implementation</xsl:attribute>
<xsl:apply-templates/>
</svrl:active-pattern>
<xsl:apply-templates select="/" mode="M5"/>
<svrl:active-pattern>
<xsl:attribute name="name">Testing 'Identification' elements</xsl:attribute>
<xsl:apply-templates/>
</svrl:active-pattern>
<xsl:apply-templates select="/" mode="M6"/>
<svrl:active-pattern>
<xsl:attribute name="name">Testing 'Classification of spatial data and services' elements</xsl:attribute>
<xsl:apply-templates/>
</svrl:active-pattern>
<xsl:apply-templates select="/" mode="M7"/>
<svrl:active-pattern>
<xsl:attribute name="name">Testing 'Keyword' elements</xsl:attribute>
<xsl:apply-templates/>
</svrl:active-pattern>
<xsl:apply-templates select="/" mode="M8"/>
<svrl:active-pattern>
<xsl:attribute name="name">Testing 'Geographic location' elements</xsl:attribute>
<xsl:apply-templates/>
</svrl:active-pattern>
<xsl:apply-templates select="/" mode="M9"/>
<svrl:active-pattern>
<xsl:attribute name="name">Testing 'Temporal reference' elements</xsl:attribute>
<xsl:apply-templates/>
</svrl:active-pattern>
<xsl:apply-templates select="/" mode="M10"/>
<svrl:active-pattern>
<xsl:attribute name="name">Testing 'Quality and validity' elements</xsl:attribute>
<xsl:apply-templates/>
</svrl:active-pattern>
<xsl:apply-templates select="/" mode="M11"/>
<svrl:active-pattern>
<xsl:attribute name="name">Testing 'Conformity' elements</xsl:attribute>
<xsl:apply-templates/>
</svrl:active-pattern>
<xsl:apply-templates select="/" mode="M12"/>
<svrl:active-pattern>
<xsl:attribute name="name">Testing 'Constraints related to access and use' elements</xsl:attribute>
<xsl:apply-templates/>
</svrl:active-pattern>
<xsl:apply-templates select="/" mode="M13"/>
<svrl:active-pattern>
<xsl:attribute name="name">Testing 'Responsible organisation' elements</xsl:attribute>
<xsl:apply-templates/>
</svrl:active-pattern>
<xsl:apply-templates select="/" mode="M14"/>
<svrl:active-pattern>
<xsl:attribute name="name">Testing 'Metadata on metadata' elements</xsl:attribute>
<xsl:apply-templates/>
</svrl:active-pattern>
<xsl:apply-templates select="/" mode="M15"/>
</svrl:schematron-output>
</xsl:template>

<!--SCHEMATRON PATTERNS-->


<!--PATTERN Testing implementation-->
<svrl:text xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Testing implementation</svrl:text>

	<!--RULE -->
<xsl:template match="/*" priority="1000" mode="M5">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="namespace-uri(/*) = 'http://www.isotc211.org/2005/gmd'"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="namespace-uri(/*) = 'http://www.isotc211.org/2005/gmd'">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>XML document is defined in the wrong namespace:
                <xsl:text/>
<xsl:value-of select="namespace-uri(/*)"/>
<xsl:text/>
			</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--REPORT -->
<xsl:if test="namespace-uri(/*) = 'http://www.isotc211.org/2005/gmd'">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="namespace-uri(/*) = 'http://www.isotc211.org/2005/gmd'">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Document namespace is <xsl:text/>
<xsl:value-of select="namespace-uri(/*)"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M5"/>
</xsl:template>
<xsl:template match="text()" priority="-1" mode="M5"/>
<xsl:template match="@*|node()" priority="-2" mode="M5">
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M5"/>
</xsl:template>

<!--PATTERN Testing 'Identification' elements-->
<svrl:text xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Testing 'Identification' elements</svrl:text>

	<!--RULE -->
<xsl:template match="//gmd:identificationInfo[1]/*/gmd:citation/*" priority="1005" mode="M6">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:identificationInfo[1]/*/gmd:citation/*"/>
<xsl:variable name="resourceTitle" select="gmd:title/*/text()"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="$resourceTitle"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$resourceTitle">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.2.1) Resource title is missing</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--REPORT -->
<xsl:if test="$resourceTitle">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$resourceTitle">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.2.1) Resource title found: <xsl:text/>
<xsl:value-of select="$resourceTitle"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M6"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*" priority="1004" mode="M6">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*"/>
<xsl:variable name="resourceLocator" select="gmd:linkage/*/text()"/>

		<!--REPORT -->
<xsl:if test="$resourceLocator">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$resourceLocator">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.2.4) Resource locator found:
                <xsl:text/>
<xsl:value-of select="$resourceLocator"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M6"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//gmd:MD_Metadata/gmd:hierarchyLevel[1]" priority="1003" mode="M6">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:MD_Metadata/gmd:hierarchyLevel[1]"/>
<xsl:variable name="resourceType_present" select="*/@codeListValue='dataset'                             or */@codeListValue='series'                             or */@codeListValue='service'"/>
<xsl:variable name="resourceType" select="*/@codeListValue"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="$resourceType_present"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$resourceType_present">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.2.3) Resource type is missing or has a wrong value</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--REPORT -->
<xsl:if test="$resourceType_present">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$resourceType_present">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.2.3) Resource type found:
                <xsl:text/>
<xsl:value-of select="$resourceType"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M6"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//gmd:identificationInfo[1]/*" priority="1002" mode="M6">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:identificationInfo[1]/*"/>
<xsl:variable name="resourceAbstract" select="gmd:abstract/*/text()"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="$resourceAbstract"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$resourceAbstract">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.2.2) Resource abstract is missing</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--REPORT -->
<xsl:if test="$resourceAbstract">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$resourceAbstract">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.2.2) Resource abstract found:
                <xsl:text/>
<xsl:value-of select="$resourceAbstract"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M6"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//gmd:hierarchyLevel[1]/*[@codeListValue ='service']" priority="1001" mode="M6">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:hierarchyLevel[1]/*[@codeListValue ='service']"/>
<xsl:variable name="coupledResource" select="//srv:operatesOn/@xlink:href"/>

		<!--REPORT -->
<xsl:if test="$coupledResource">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$coupledResource">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.2.6) Coupled Resource found: <xsl:text/>
<xsl:value-of select="$coupledResource"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M6"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//gmd:hierarchyLevel[1]/*[@codeListValue ='dataset'] | //gmd:hierarchyLevel[1]/*[@codeListValue ='series']" priority="1000" mode="M6">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:hierarchyLevel[1]/*[@codeListValue ='dataset'] | //gmd:hierarchyLevel[1]/*[@codeListValue ='series']"/>
<xsl:variable name="resourceIdentifier_code" select="//gmd:identificationInfo[1]/*/gmd:citation/*/gmd:identifier/*/gmd:code/*/text()"/>
<xsl:variable name="resourceIdentifier_codeSpace" select="//gmd:identificationInfo[1]/*/gmd:citation/*/gmd:identifier/*/gmd:codeSpace/*/text()"/>
<xsl:variable name="resourceLanguage_present" select="//gmd:identificationInfo[1]/*/gmd:language/*/text()='bul' or        //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='ita' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='cze' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='lav' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='dan' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='lit' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='dut' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='mlt' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='eng' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='pol' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='est' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='por' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='fin' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='rum' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='fre' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='slo' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='ger' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='slv' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='gre' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='spa' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='hun' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='swe' or                             //gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue='gle'"/>
<xsl:variable name="resourceLanguage" select="//gmd:identificationInfo[1]/*/gmd:language/*/@codeListValue"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="$resourceIdentifier_code"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$resourceIdentifier_code">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.2.5) Unique resource identifier is missing</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--REPORT -->
<xsl:if test="$resourceIdentifier_code">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$resourceIdentifier_code">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.2.5) Unique resource identifier (code) found:
                <xsl:text/>
<xsl:value-of select="$resourceIdentifier_code"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>

		<!--REPORT -->
<xsl:if test="$resourceIdentifier_codeSpace">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$resourceIdentifier_codeSpace">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.2.5) Unique resource identifier (codeSpace) found:
                <xsl:text/>
<xsl:value-of select="$resourceIdentifier_codeSpace"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>

		<!--REPORT -->
<xsl:if test="$resourceLanguage_present">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$resourceLanguage_present">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.2.7) Resource language found:
                <xsl:text/>
<xsl:value-of select="$resourceLanguage"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M6"/>
</xsl:template>
<xsl:template match="text()" priority="-1" mode="M6"/>
<xsl:template match="@*|node()" priority="-2" mode="M6">
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M6"/>
</xsl:template>

<!--PATTERN Testing 'Classification of spatial data and services' elements-->
<svrl:text xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Testing 'Classification of spatial data and services' elements</svrl:text>

	<!--RULE -->
<xsl:template match="//gmd:hierarchyLevel[1]/*[@codeListValue ='dataset'] | //gmd:hierarchyLevel[1]/*[@codeListValue ='series']" priority="1001" mode="M7">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:hierarchyLevel[1]/*[@codeListValue ='dataset'] | //gmd:hierarchyLevel[1]/*[@codeListValue ='series']"/>
<xsl:variable name="topicCategory" select="//gmd:topicCategory/*/text()"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="$topicCategory"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$topicCategory">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.3.1) Topic category is missing</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--REPORT -->
<xsl:if test="$topicCategory">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$topicCategory">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.3.1) Topic category found:
                <xsl:text/>
<xsl:value-of select="$topicCategory"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M7"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//gmd:hierarchyLevel[1]/*[@codeListValue ='service']" priority="1000" mode="M7">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:hierarchyLevel[1]/*[@codeListValue ='service']"/>
<xsl:variable name="serviceType" select="//srv:serviceType/*/text()"/>
<xsl:variable name="serviceType_present" select="//srv:serviceType/*/text() = 'view'                             or //srv:serviceType/*/text() = 'discovery'                             or //srv:serviceType/*/text() = 'download'                             or //srv:serviceType/*/text() = 'transformation'                             or //srv:serviceType/*/text() = 'invoke'                             or //srv:serviceType/*/text() = 'other'"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="$serviceType_present"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$serviceType_present">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.3.2) Spatial data service type is missing or has a wrong value</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--REPORT -->
<xsl:if test="$serviceType_present">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$serviceType_present">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.3.2) Spatial data service type found:
                <xsl:text/>
<xsl:value-of select="$serviceType"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M7"/>
</xsl:template>
<xsl:template match="text()" priority="-1" mode="M7"/>
<xsl:template match="@*|node()" priority="-2" mode="M7">
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M7"/>
</xsl:template>

<!--PATTERN Testing 'Keyword' elements-->
<svrl:text xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Testing 'Keyword' elements</svrl:text>

	<!--RULE -->
<xsl:template match="//gmd:hierarchyLevel[1]/*[@codeListValue ='dataset'] | //gmd:hierarchyLevel[1]/*[@codeListValue ='series']" priority="1001" mode="M8">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:hierarchyLevel[1]/*[@codeListValue ='dataset'] | //gmd:hierarchyLevel[1]/*[@codeListValue ='series']"/>
<xsl:variable name="keywordValue" select="//gmd:descriptiveKeywords/*/gmd:keyword/*/text()"/>
<xsl:variable name="keywordValue_SDT" select="//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Addresses' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Administrative units' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Agricultural and aquaculture facilities' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Area management/restriction/regulation zones and reporting units' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Atmospheric conditions' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Bio-geographical regions' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Buildings' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Cadastral parcels' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Coordinate reference systems' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Elevation' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Energy resources' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Environmental monitoring facilities' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Geographical grid systems' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Geographical names' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Geology' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Habitats and biotopes' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Human health and safety' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Hydrography' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Land cover' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Land use' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Meteorological geographical features' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Mineral resources' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Natural risk zones' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Oceanographic geographical features' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Orthoimagery' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Population distribution — demography' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Production and industrial facilities' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Protected sites' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Sea regions' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Soil' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Species distribution' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Statistical units' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Transport networks' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='Utility and governmental services'"/>
<xsl:variable name="thesaurus_name" select="//gmd:descriptiveKeywords/*/gmd:thesaurusName/*/gmd:title/*/text()"/>
<xsl:variable name="thesaurus_date" select="//gmd:descriptiveKeywords/*/gmd:thesaurusName/*/gmd:date/*/gmd:date/*/text()"/>
<xsl:variable name="thesaurus_dateType" select="//gmd:descriptiveKeywords/*/gmd:thesaurusName/*/gmd:date/*/gmd:dateType/*/@codeListValue"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="$thesaurus_name = 'GemetInspireTheme'"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$thesaurus_name = 'GemetInspireTheme'">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.4.) A GEMET INSPIRE Spatial data theme thesaurus (GemetInspireTheme) shall be cited</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="$keywordValue_SDT"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$keywordValue_SDT">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.4) For datasets and series at least one keyword of GEMET thesaurus shall be documented.</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="$keywordValue"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$keywordValue">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.4.1) Keyword value is missing</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--REPORT -->
<xsl:if test="$keywordValue">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$keywordValue">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.4.1) Keyword value found:
                <xsl:text/>
<xsl:value-of select="$keywordValue"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>

		<!--REPORT -->
<xsl:if test="$thesaurus_name">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$thesaurus_name">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.4.2) Thesaurus found:
                <xsl:text/>
<xsl:value-of select="$thesaurus_name"/>
<xsl:text/>, <xsl:text/>
<xsl:value-of select="$thesaurus_date"/>
<xsl:text/> (<xsl:text/>
<xsl:value-of select="$thesaurus_dateType"/>
<xsl:text/>)
            </svrl:text>
</svrl:successful-report>
</xsl:if>
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M8"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//gmd:hierarchyLevel[1]/*[@codeListValue ='service']" priority="1000" mode="M8">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:hierarchyLevel[1]/*[@codeListValue ='service']"/>
<xsl:variable name="keywordValue" select="//gmd:descriptiveKeywords/*/gmd:keyword/*/text()"/>
<xsl:variable name="keywordValue_SDT" select="//gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanInteractionService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanCatalogueViewer' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanGeographicViewer' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanGeographicSpreadsheetViewer' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanServiceEditor' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanChainDefinitionEditor' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanWorkflowEnactmentManager' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanGeographicFeatureEditor' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanGeographicSymbolEditor' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanFeatureGeneralizationEditor' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='humanGeographicDataStructureViewer' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoManagementService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoFeatureAccessService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoMapAccessService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoCoverageAccessService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoSensorDescriptionService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoProductAccessService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoFeatureTypeService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoCatalogueService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoRegistryService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoGazetteerService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoOrderHandlingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='infoStandingOrderService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='taskManagementService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='chainDefinitionService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='workflowEnactmentService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='subscriptionService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialProcessingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialCoordinateConversionService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialCoordinateTransformationService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialCoverageVectorConversionService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialImageCoordinateConversionService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialRectificationService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialOrthorectificationService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialSensorGeometryModelAdjustmentService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialImageGeometryModelConversionService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialSubsettingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialSamplingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialTilingChangeService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialDimensionMeasurementService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialFeatureManipulationService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialFeatureMatchingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialFeatureGeneralizationService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialRouteDeterminationService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialPositioningService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='spatialProximityAnalysisService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicProcessingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicGoparameterCalculationService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicClassificationService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicFeatureGeneralizationService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicSubsettingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicSpatialCountingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicChangeDetectionService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicGeographicInformationExtractionService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicImageProcessingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicReducedResolutionGenerationService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicImageManipulationService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicImageUnderstandingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicImageSynthesisService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicMultibandImageManipulationService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicObjectDetectionService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicGeoparsingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='thematicGeocodingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='temporalProcessingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='temporalReferenceSystemTransformationService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='temporalSubsettingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='temporalSamplingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='temporalProximityAnalysisService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='metadataProcessingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='metadataStatisticalCalculationService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='metadataGeographicAnnotationService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='comService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='comEncodingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='comTransferService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='comGeographicCompressionService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='comGeographicFormatConversionService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='comMessagingService' or     //gmd:descriptiveKeywords/*/gmd:keyword/*/text()='comRemoteFileAndExecutableManagement'"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="$keywordValue_SDT"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$keywordValue_SDT">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.4) For spatial data services, at least the category or subcategory of the service as defined in Part D 4 shall be documented.</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="$keywordValue"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$keywordValue">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.4.1) Keyword value is missing</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--REPORT -->
<xsl:if test="$keywordValue">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$keywordValue">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.4.1) Keyword value found:
                <xsl:text/>
<xsl:value-of select="$keywordValue"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M8"/>
</xsl:template>
<xsl:template match="text()" priority="-1" mode="M8"/>
<xsl:template match="@*|node()" priority="-2" mode="M8">
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M8"/>
</xsl:template>

<!--PATTERN Testing 'Geographic location' elements-->
<svrl:text xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Testing 'Geographic location' elements</svrl:text>

	<!--RULE -->
<xsl:template match="//gmd:hierarchyLevel[1]/*[@codeListValue ='dataset'] | //gmd:hierarchyLevel[1]/*[@codeListValue ='series']" priority="1001" mode="M9">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:hierarchyLevel[1]/*[@codeListValue ='dataset'] | //gmd:hierarchyLevel[1]/*[@codeListValue ='series']"/>
<xsl:variable name="west" select="number(//gmd:identificationInfo[1]/*/gmd:extent/*/gmd:geographicElement/*/gmd:westBoundLongitude/*)"/>
<xsl:variable name="east" select="number(//gmd:identificationInfo[1]/*/gmd:extent/*/gmd:geographicElement/*/gmd:eastBoundLongitude/*)"/>
<xsl:variable name="north" select="number(//gmd:identificationInfo[1]/*/gmd:extent/*/gmd:geographicElement/*/gmd:northBoundLatitude/*)"/>
<xsl:variable name="south" select="number(//gmd:identificationInfo[1]/*/gmd:extent/*/gmd:geographicElement/*/gmd:southBoundLatitude/*)"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="(-180.00 &lt;= $west) and ( $west &lt;= 180.00)"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(-180.00 &lt;= $west) and ( $west &lt;= 180.00)">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.5.1) WestBoundLongitude is missing or has wrong value</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--REPORT -->
<xsl:if test="(-180.00 &lt;= $west) and ( $west &lt;= 180.00)">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(-180.00 &lt;= $west) and ( $west &lt;= 180.00)">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.5.1) WestBoundLongitude found:
                <xsl:text/>
<xsl:value-of select="$west"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="(-180.00 &lt;= $east) and ($east &lt;= 180.00)"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(-180.00 &lt;= $east) and ($east &lt;= 180.00)">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.5.1) EastBoundLongitude is missing or has wrong value</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--REPORT -->
<xsl:if test="(-180.00 &lt;= $east) and ($east &lt;= 180.00)">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(-180.00 &lt;= $east) and ($east &lt;= 180.00)">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.5.1) EastBoundLongitude found:
                <xsl:text/>
<xsl:value-of select="$east"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="(-90.00 &lt;= $south) and ($south &lt;= $north)"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(-90.00 &lt;= $south) and ($south &lt;= $north)">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.5.1) SouthBoundLatitude is missing or has wrong value</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--REPORT -->
<xsl:if test="(-90.00 &lt;= $south) and ($south &lt;= $north)">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(-90.00 &lt;= $south) and ($south &lt;= $north)">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.5.1) SouthBoundLatitude found:
                <xsl:text/>
<xsl:value-of select="$south"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="($south &lt;= $north) and ($north &lt;= 90.00)"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="($south &lt;= $north) and ($north &lt;= 90.00)">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.5.1) NorthBoundLatitude is missing or has wrong value</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--REPORT -->
<xsl:if test="($south &lt;= $north) and ($north &lt;= 90.00)">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="($south &lt;= $north) and ($north &lt;= 90.00)">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.5.1) NorthBoundLatitude found:
                <xsl:text/>
<xsl:value-of select="$north"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M9"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//gmd:hierarchyLevel[1]/*[@codeListValue ='service']" priority="1000" mode="M9">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:hierarchyLevel[1]/*[@codeListValue ='service']"/>
<xsl:variable name="west" select="number(//gmd:identificationInfo[1]/*/srv:extent/*/gmd:geographicElement/*/gmd:westBoundLongitude/*)"/>
<xsl:variable name="east" select="number(//gmd:identificationInfo[1]/*/srv:extent/*/gmd:geographicElement/*/gmd:eastBoundLongitude/*)"/>
<xsl:variable name="north" select="number(//gmd:identificationInfo[1]/*/srv:extent/*/gmd:geographicElement/*/gmd:northBoundLatitude/*)"/>
<xsl:variable name="south" select="number(//gmd:identificationInfo[1]/*/srv:extent/*/gmd:geographicElement/*/gmd:southBoundLatitude/*)"/>

		<!--REPORT -->
<xsl:if test="(-180.00 &lt;= $west) and ( $west &lt;= 180.00)">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(-180.00 &lt;= $west) and ( $west &lt;= 180.00)">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.5.1) WestBoundLongitude found:
                <xsl:text/>
<xsl:value-of select="$west"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>

		<!--REPORT -->
<xsl:if test="(-180.00 &lt;= $east) and ($east &lt;= 180.00)">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(-180.00 &lt;= $east) and ($east &lt;= 180.00)">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.5.1) EastBoundLongitude found:
                <xsl:text/>
<xsl:value-of select="$east"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>

		<!--REPORT -->
<xsl:if test="(-90.00 &lt;= $south) and ($south &lt;= $north)">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(-90.00 &lt;= $south) and ($south &lt;= $north)">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.5.1) SouthBoundLatitude found:
                <xsl:text/>
<xsl:value-of select="$south"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>

		<!--REPORT -->
<xsl:if test="($south &lt;= $north) and ($north &lt;= 90.00)">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="($south &lt;= $north) and ($north &lt;= 90.00)">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.5.1) NorthBoundLatitude found:
                <xsl:text/>
<xsl:value-of select="$north"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M9"/>
</xsl:template>
<xsl:template match="text()" priority="-1" mode="M9"/>
<xsl:template match="@*|node()" priority="-2" mode="M9">
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M9"/>
</xsl:template>

<!--PATTERN Testing 'Temporal reference' elements-->
<svrl:text xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Testing 'Temporal reference' elements</svrl:text>

	<!--RULE -->
<xsl:template match="//gmd:identificationInfo[1]/*" priority="1000" mode="M10">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:identificationInfo[1]/*"/>
<xsl:variable name="temporalExtentBegin" select="gmd:extent/*/gmd:temporalElement/*/gmd:extent/*/gml:beginPosition/text()"/>
<xsl:variable name="temporalExtentEnd" select="gmd:extent/*/gmd:temporalElement/*/gmd:extent/*/gml:endPosition/text()"/>
<xsl:variable name="publicationDate" select="gmd:citation/*/gmd:date[./*/gmd:dateType/*/@codeListValue='publication']/*/gmd:date/*"/>
<xsl:variable name="creationDate" select="gmd:citation/*/gmd:date[./*/gmd:dateType/*/@codeListValue='creation']/*/gmd:date/*"/>
<xsl:variable name="no_creationDate" select="count(gmd:citation/*/gmd:date[./*/gmd:dateType/*/@codeListValue='creation']/*/gmd:date/*)"/>
<xsl:variable name="revisionDate" select="gmd:citation/*/gmd:date[./*/gmd:dateType/*/@codeListValue='revision']/*/gmd:date/*"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="$no_creationDate &lt;= 1"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$no_creationDate &lt;= 1">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>SC7.  There shall not be more than one instance of MD_Metadata.identificationInfo[1].MD_Identification.citation.CI_Citation.date declared as a creation date (i.e. CI_Date.dateType having the creation value)</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="$publicationDate or $creationDate or $revisionDate or $temporalExtentBegin or $temporalExtentEnd"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$publicationDate or $creationDate or $revisionDate or $temporalExtentBegin or $temporalExtentEnd">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.6) No instance of Temporal reference has been found.</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--REPORT -->
<xsl:if test="$temporalExtentBegin">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$temporalExtentBegin">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.6.1) Temporal extent (begin) found: <xsl:text/>
<xsl:value-of select="$temporalExtentBegin"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>

		<!--REPORT -->
<xsl:if test="$temporalExtentEnd">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$temporalExtentEnd">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.6.1) Temporal extent (end) found: <xsl:text/>
<xsl:value-of select="$temporalExtentEnd"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>

		<!--REPORT -->
<xsl:if test="$publicationDate">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$publicationDate">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.6.2) Date of publication of the resource found: <xsl:text/>
<xsl:value-of select="$publicationDate"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>

		<!--REPORT -->
<xsl:if test="$revisionDate">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$revisionDate">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.6.3) Date of revision of the resource found: : <xsl:text/>
<xsl:value-of select="$revisionDate"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>

		<!--REPORT -->
<xsl:if test="$creationDate">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$creationDate">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.6.4) Date of creation of the resource found: : <xsl:text/>
<xsl:value-of select="$creationDate"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M10"/>
</xsl:template>
<xsl:template match="text()" priority="-1" mode="M10"/>
<xsl:template match="@*|node()" priority="-2" mode="M10">
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M10"/>
</xsl:template>

<!--PATTERN Testing 'Quality and validity' elements-->
<svrl:text xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Testing 'Quality and validity' elements</svrl:text>

	<!--RULE -->
<xsl:template match="//gmd:hierarchyLevel[1]/*[@codeListValue ='dataset'] | //gmd:hierarchyLevel[1]/*[@codeListValue ='series']" priority="1001" mode="M11">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:hierarchyLevel[1]/*[@codeListValue ='dataset'] | //gmd:hierarchyLevel[1]/*[@codeListValue ='series']"/>
<xsl:variable name="lineage" select="//gmd:dataQualityInfo/*/gmd:lineage/*/gmd:statement/*/text()"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="$lineage"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$lineage">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.7.1) Lineage is missing</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--REPORT -->
<xsl:if test="$lineage">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$lineage">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.7.1) Lineage found:
                <xsl:text/>
<xsl:value-of select="$lineage"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M11"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//gmd:identificationInfo[1]/*/gmd:spatialResolution/*" priority="1000" mode="M11">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:identificationInfo[1]/*/gmd:spatialResolution/*"/>
<xsl:variable name="spatialResolution_equivalentScale" select="gmd:equivalentScale/*/gmd:denominator"/>
<xsl:variable name="spatialResolution_distance" select="gmd:distance/*/text()"/>
<xsl:variable name="spatialResolution_distance_uom" select="gmd:distance/*/@uom"/>

		<!--REPORT -->
<xsl:if test="$spatialResolution_equivalentScale">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$spatialResolution_equivalentScale">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.7.2) Spatial resolution (equivalentScale) found:
                <xsl:text/>
<xsl:value-of select="$spatialResolution_equivalentScale"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>

		<!--REPORT -->
<xsl:if test="$spatialResolution_distance">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$spatialResolution_distance">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.7.2) Spatial resolution (distance) found:
                <xsl:text/>
<xsl:value-of select="$spatialResolution_distance"/>
<xsl:text/>
				<xsl:text/>
<xsl:value-of select="$spatialResolution_distance_uom"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M11"/>
</xsl:template>
<xsl:template match="text()" priority="-1" mode="M11"/>
<xsl:template match="@*|node()" priority="-2" mode="M11">
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M11"/>
</xsl:template>

<!--PATTERN Testing 'Conformity' elements-->
<svrl:text xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Testing 'Conformity' elements</svrl:text>

	<!--RULE -->
<xsl:template match="/*" priority="1001" mode="M12">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*"/>
<xsl:variable name="degree" select="gmd:dataQualityInfo[1]/*/gmd:report[1]/*/gmd:result[1]/*/gmd:pass/*/text()"/>

		<!--REPORT -->
<xsl:if test="not($degree)">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($degree)">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.8.1) The degree of conformity of the resource has not yet been evaluated.</svrl:text>
</svrl:successful-report>
</xsl:if>
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M12"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//gmd:dataQualityInfo[1]/*/gmd:report[1]/*/gmd:result[1]/*" priority="1000" mode="M12">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:dataQualityInfo[1]/*/gmd:report[1]/*/gmd:result[1]/*"/>
<xsl:variable name="degree" select="gmd:pass/*/text()"/>
<xsl:variable name="specification_title" select="gmd:specification/*/gmd:title/*/text()"/>
<xsl:variable name="specification_date" select="gmd:specification/*/gmd:date/*/gmd:date/*/text()"/>
<xsl:variable name="specification_dateType" select="gmd:specification/*/gmd:date/*/gmd:dateType/*/@codeListValue"/>
<xsl:variable name="specification_SD" select="gmd:specification/*/gmd:title/*/text()='INSPIRE_D2.8.I.1' or     //gmd:specification/*/gmd:title/*/text()='INSPIRE_D2.8.I.2'"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="$specification_SD"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$specification_SD">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.8.2.1) For INSPIRE Data Specification CODE shall be citated</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--REPORT -->
<xsl:if test="$degree">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$degree">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.8.1) Degree of conformity found:
            <xsl:text/>
<xsl:value-of select="$degree"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>

		<!--REPORT -->
<xsl:if test="$specification_title">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$specification_title">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.8.2) Specification found:
            <xsl:text/>
<xsl:value-of select="$specification_title"/>
<xsl:text/>, (<xsl:text/>
<xsl:value-of select="$specification_date"/>
<xsl:text/>, <xsl:text/>
<xsl:value-of select="$specification_dateType"/>
<xsl:text/>)
		</svrl:text>
</svrl:successful-report>
</xsl:if>
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M12"/>
</xsl:template>
<xsl:template match="text()" priority="-1" mode="M12"/>
<xsl:template match="@*|node()" priority="-2" mode="M12">
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M12"/>
</xsl:template>

<!--PATTERN Testing 'Constraints related to access and use' elements-->
<svrl:text xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Testing 'Constraints related to access and use' elements</svrl:text>

	<!--RULE -->
<xsl:template match="//gmd:identificationInfo[1]/*" priority="1003" mode="M13">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:identificationInfo[1]/*"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="count(gmd:resourceConstraints/*)"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(gmd:resourceConstraints/*)">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>SC12. There shall be at least one instance of MD_Metadata.identificationInfo[1].MD_Identification.resourceConstraints</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M13"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//gmd:identificationInfo[1]/*/gmd:resourceConstraints/*" priority="1002" mode="M13">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:identificationInfo[1]/*/gmd:resourceConstraints/*"/>
<xsl:variable name="accessConstraints" select="gmd:accessConstraints/*/@codeListValue"/>
<xsl:variable name="accessConstraints_present" select="gmd:accessConstraints/*/@codeListValue = 'copyright' or gmd:accessConstraints/*/@codeListValue = 'patent' or gmd:accessConstraints/*/@codeListValue = 'patentPending' or gmd:accessConstraints/*/@codeListValue = 'trademark' or gmd:accessConstraints/*/@codeListValue = 'license' or gmd:accessConstraints/*/@codeListValue = 'intellectualPropertyRights' or gmd:accessConstraints/*/@codeListValue = 'restricted' or gmd:accessConstraints/*/@codeListValue = 'otherRestrictions'"/>
<xsl:variable name="classification" select="gmd:classification/*/@codeListValue"/>
<xsl:variable name="classification_present" select="gmd:classification/*/@codeListValue = 'unclassified' or gmd:classification/*/@codeListValue = 'restricted' or gmd:classification/*/@codeListValue = 'confidential' or gmd:classification/*/@codeListValue = 'secret' or gmd:classification/*/@codeListValue = 'topSecret'"/>
<xsl:variable name="otherConstraints" select="gmd:otherConstraints/*/text()"/>

		<!--REPORT -->
<xsl:if test="$accessConstraints_present">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$accessConstraints_present">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.9.1) Limitation on public access (accessConstraints) found:
                <xsl:text/>
<xsl:value-of select="$accessConstraints"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>

		<!--REPORT -->
<xsl:if test="$classification_present">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$classification_present">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.9.1) Limitation on public access (classification) found:
                <xsl:text/>
<xsl:value-of select="$classification"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M13"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//gmd:identificationInfo[1]/*/gmd:resourceConstraints/*/gmd:otherConstraints/*" priority="1001" mode="M13">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:identificationInfo[1]/*/gmd:resourceConstraints/*/gmd:otherConstraints/*"/>
<xsl:variable name="accessConstraints_value" select="../../gmd:accessConstraints/*/@codeListValue"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="$accessConstraints_value = 'otherRestrictions'"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$accessConstraints_value = 'otherRestrictions'">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.9.1) The value of 'accessConstraints' must be 'otherRestrictions', if there are instances of 'otherConstraints' expressing limitations on public access.</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--REPORT -->
<xsl:if test="$accessConstraints_value = 'otherRestrictions'">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$accessConstraints_value = 'otherRestrictions'">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.9.1) Limitation on public access (otherConstraints) found:
                <xsl:text/>
<xsl:value-of select="."/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M13"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//gmd:identificationInfo[1]/*" priority="1000" mode="M13">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:identificationInfo[1]/*"/>
<xsl:variable name="useLimitation" select="gmd:resourceConstraints/*/gmd:useLimitation/*/text()"/>
<xsl:variable name="useLimitation_count" select="count(gmd:resourceConstraints/*/gmd:useLimitation/*/text())"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="$useLimitation_count"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$useLimitation_count">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.9.2) Conditions applying to access and use is missing</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--REPORT -->
<xsl:if test="$useLimitation_count">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$useLimitation_count">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.9.2) Conditions applying to access and use found:
                <xsl:text/>
<xsl:value-of select="$useLimitation"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M13"/>
</xsl:template>
<xsl:template match="text()" priority="-1" mode="M13"/>
<xsl:template match="@*|node()" priority="-2" mode="M13">
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M13"/>
</xsl:template>

<!--PATTERN Testing 'Responsible organisation' elements-->
<svrl:text xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Testing 'Responsible organisation' elements</svrl:text>

	<!--RULE -->
<xsl:template match="//gmd:identificationInfo[1]/*" priority="1000" mode="M14">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:identificationInfo[1]/*"/>
<xsl:variable name="organisationName" select="gmd:pointOfContact/*/gmd:organisationName/*/text()"/>
<xsl:variable name="role" select="gmd:pointOfContact/*/gmd:role/*/@codeListValue"/>
<xsl:variable name="role_present" select="gmd:pointOfContact/*/gmd:role/*/@codeListValue = 'resourceProvider' or             gmd:pointOfContact/*/gmd:role/*/@codeListValue = 'custodian' or             gmd:pointOfContact/*/gmd:role/*/@codeListValue = 'owner' or             gmd:pointOfContact/*/gmd:role/*/@codeListValue = 'user' or             gmd:pointOfContact/*/gmd:role/*/@codeListValue = 'distributor' or             gmd:pointOfContact/*/gmd:role/*/@codeListValue = 'originator' or             gmd:pointOfContact/*/gmd:role/*/@codeListValue = 'pointOfContact' or             gmd:pointOfContact/*/gmd:role/*/@codeListValue = 'principalInvestigator' or             gmd:pointOfContact/*/gmd:role/*/@codeListValue = 'processor' or             gmd:pointOfContact/*/gmd:role/*/@codeListValue = 'publisher' or             gmd:pointOfContact/*/gmd:role/*/@codeListValue = 'author'"/>
<xsl:variable name="emailAddress" select="gmd:pointOfContact/*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/*/text()"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="$organisationName"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$organisationName">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.10.1) Organisation name (Resource) is missing</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--REPORT -->
<xsl:if test="$organisationName">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$organisationName">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.10.1) Organisation name (Resource) found:
                <xsl:text/>
<xsl:value-of select="$organisationName"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="$emailAddress"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$emailAddress">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.10.1) Electronic mail address(resource) is missing </svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--REPORT -->
<xsl:if test="$emailAddress">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$emailAddress">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.10.1) Electronic mail address(resource) found:
                <xsl:text/>
<xsl:value-of select="$emailAddress"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="$role_present"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$role_present">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.10.1) Role (resource) is missing or has a wrong value</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--REPORT -->
<xsl:if test="$role_present">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$role_present">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.10.1) Role (resource) found:
                <xsl:text/>
<xsl:value-of select="$role"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M14"/>
</xsl:template>
<xsl:template match="text()" priority="-1" mode="M14"/>
<xsl:template match="@*|node()" priority="-2" mode="M14">
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M14"/>
</xsl:template>

<!--PATTERN Testing 'Metadata on metadata' elements-->
<svrl:text xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Testing 'Metadata on metadata' elements</svrl:text>

	<!--RULE -->
<xsl:template match="//gmd:MD_Metadata" priority="1001" mode="M15">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:MD_Metadata"/>
<xsl:variable name="dateStamp" select="gmd:dateStamp/*/text()"/>
<xsl:variable name="language" select="gmd:language/*/@codeListValue"/>
<xsl:variable name="language_present" select="gmd:language/*/@codeListValue='bul' or                             gmd:language/*/@codeListValue='ita' or                             gmd:language/*/@codeListValue='cze' or                             gmd:language/*/@codeListValue='lav' or                             gmd:language/*/@codeListValue='dan' or                             gmd:language/*/@codeListValue='lit' or                             gmd:language/*/@codeListValue='dut' or                             gmd:language/*/@codeListValue='mlt' or                             gmd:language/*/@codeListValue='eng' or                             gmd:language/*/@codeListValue='pol' or                             gmd:language/*/@codeListValue='est' or                             gmd:language/*/@codeListValue='por' or                             gmd:language/*/@codeListValue='fin' or                             gmd:language/*/@codeListValue='rum' or                             gmd:language/*/@codeListValue='fre' or                             gmd:language/*/@codeListValue='slo' or                             gmd:language/*/@codeListValue='ger' or                             gmd:language/*/@codeListValue='slv' or                             gmd:language/*/@codeListValue='gre' or                             gmd:language/*/@codeListValue='spa' or                             gmd:language/*/@codeListValue='hun' or                             gmd:language/*/@codeListValue='swe' or                             gmd:language/*/@codeListValue='gle'"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="$dateStamp"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$dateStamp">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.11.2) Metadata date stamp is missing</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--REPORT -->
<xsl:if test="$dateStamp">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$dateStamp">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.11.2) Metadata date stamp found:
                <xsl:text/>
<xsl:value-of select="$dateStamp"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="$language_present"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$language_present">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.11.3) Metadata language is missing or has a wrong value</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--REPORT -->
<xsl:if test="$language_present">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$language_present">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.11.3) Metadata language found:
                <xsl:text/>
<xsl:value-of select="$language"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M15"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="gmd:MD_Metadata/gmd:contact/*" priority="1000" mode="M15">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:MD_Metadata/gmd:contact/*"/>
<xsl:variable name="organisationName" select="gmd:organisationName/*/text()"/>
<xsl:variable name="role" select="gmd:role/*/@codeListValue"/>
<xsl:variable name="role_present" select="gmd:role/*/@codeListValue = 'pointOfContact'"/>
<xsl:variable name="emailAddress" select="gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/*/text()"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="$organisationName"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$organisationName">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.11.1) Metadata responsible party (organisation name) is missing</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--REPORT -->
<xsl:if test="$organisationName">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$organisationName">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.11.1) Metadata responsible party (organisation name) found:
                <xsl:text/>
<xsl:value-of select="$organisationName"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="$emailAddress"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$emailAddress">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.11.1) Metadata responsible party (electronic mail address) is missing</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--REPORT -->
<xsl:if test="$emailAddress">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$emailAddress">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.11.1) Metadata responsible party (electronic mail address) found:
                <xsl:text/>
<xsl:value-of select="$emailAddress"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="$role_present"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$role_present">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(SC16) The value of Metadata responsible party role shall be 'pointOfContact'.</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--REPORT -->
<xsl:if test="$role_present">
<svrl:successful-report xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$role_present">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>(2.11.1) Metadata responsible party role found:
                <xsl:text/>
<xsl:value-of select="$role"/>
<xsl:text/>
			</svrl:text>
</svrl:successful-report>
</xsl:if>
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M15"/>
</xsl:template>
<xsl:template match="text()" priority="-1" mode="M15"/>
<xsl:template match="@*|node()" priority="-2" mode="M15">
<xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M15"/>
</xsl:template>
</xsl:stylesheet>
