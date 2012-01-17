<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:sch="http://www.ascc.net/xml/schematron" xmlns:sml="http://www.opengis.net/sensorML/1.0.1" xmlns:gml="http://www.opengis.net/gml" xmlns:swe="http://www.opengis.net/swe/1.0.1" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.0">
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
<svrl:schematron-output xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" title="" schemaVersion="ISO19757-3">
<xsl:comment>
<xsl:value-of select="$archiveDirParameter"/>   
		 <xsl:value-of select="$archiveNameParameter"/>  
		 <xsl:value-of select="$fileNameParameter"/>  
		 <xsl:value-of select="$fileDirParameter"/>
</xsl:comment>
<svrl:ns-prefix-in-attribute-values uri="http://www.opengis.net/sensorML/1.0.1" prefix="sml"/>
<svrl:ns-prefix-in-attribute-values uri="http://www.opengis.net/gml" prefix="gml"/>
<svrl:ns-prefix-in-attribute-values uri="http://www.opengis.net/swe/1.0.1" prefix="swe"/>
<svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
<svrl:active-pattern>
<xsl:attribute name="id">SystemValidation</xsl:attribute>
<xsl:attribute name="name">SystemValidation</xsl:attribute>
<xsl:apply-templates/>
</svrl:active-pattern>
<xsl:apply-templates select="/" mode="M4"/>
<svrl:active-pattern>
<xsl:attribute name="id">ComponentValidation</xsl:attribute>
<xsl:attribute name="name">ComponentValidation</xsl:attribute>
<xsl:apply-templates/>
</svrl:active-pattern>
<xsl:apply-templates select="/" mode="M5"/>
<svrl:active-pattern>
<xsl:attribute name="id">GeneralValidation</xsl:attribute>
<xsl:attribute name="name">GeneralValidation</xsl:attribute>
<xsl:apply-templates/>
</svrl:active-pattern>
<xsl:apply-templates select="/" mode="M6"/>
</svrl:schematron-output>
</xsl:template>

<!--SCHEMATRON PATTERNS-->


<!--PATTERN SystemValidation-->


	<!--RULE -->
<xsl:template match="/" priority="1008" mode="M4">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="count(sml:SensorML/sml:member) = 1"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(sml:SensorML/sml:member) = 1">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: station description must have exactly one 'member'.</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="count(sml:SensorML/sml:member/sml:System) = 1"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(sml:SensorML/sml:member/sml:System) = 1">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: 'member' element must contain one 'System' element.</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//sml:System" priority="1007" mode="M4">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//sml:System"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="sml:validTime"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="sml:validTime">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: 'validTime' element has to be present</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//sml:System/sml:capabilities" priority="1006" mode="M4">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//sml:System/sml:capabilities"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="count(swe:DataRecord/swe:field/swe:Envelope[@definition = 'urn:ogc:def:property:OGC:1.0:observedBBOX']) = 1"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(swe:DataRecord/swe:field/swe:Envelope[@definition = 'urn:ogc:def:property:OGC:1.0:observedBBOX']) = 1">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: one "swe:field" of the "DataRecord" has to contain a "swe:Envelope" element with the definition "urn:ogc:def:property:OGC:1.0:observedBBOX".</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//sml:System" priority="1005" mode="M4">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//sml:System"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="sml:position/swe:Position"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="sml:position/swe:Position">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: 'sml:System/sml:position/swe:Position' has to be present.</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//sml:position/swe:Position" priority="1004" mode="M4">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//sml:position/swe:Position"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="@referenceFrame"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@referenceFrame">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: 'referenceFrame' attribute has to be present.</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//sml:position/swe:Position/swe:location" priority="1003" mode="M4">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//sml:position/swe:Position/swe:location"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="count(swe:Vector/swe:coordinate/swe:Quantity) &gt; 1"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(swe:Vector/swe:coordinate/swe:Quantity) &gt; 1">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: 'swe:location' has to specify at least 2 'swe:Vector/swe:coordinate/swe:Quantity' elements.</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//sml:position/swe:Position/swe:location/swe:Vector/swe:coordinate/swe:Quantity" priority="1002" mode="M4">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//sml:position/swe:Position/swe:location/swe:Vector/swe:coordinate/swe:Quantity"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="string-length(@axisID) &gt; 0"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="string-length(@axisID) &gt; 0">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: 'axisID' attribute has to be present and its value has to be &gt; 0.</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="swe:value"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="swe:value">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: 'swe:value' element has to be present.</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="swe:uom[@code]"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="swe:uom[@code]">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: 'swe:uom' element and its "code" attribute have to be present.</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//sml:position" priority="1001" mode="M4">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//sml:position"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="count(swe:Position/swe:location/swe:Vector/swe:coordinate/swe:Quantity[@axisID = 'x']) = 1"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(swe:Position/swe:location/swe:Vector/swe:coordinate/swe:Quantity[@axisID = 'x']) = 1">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: one x-axis coordinate has to be specified.</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="count(swe:Position/swe:location/swe:Vector/swe:coordinate/swe:Quantity[@axisID = 'y']) = 1"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(swe:Position/swe:location/swe:Vector/swe:coordinate/swe:Quantity[@axisID = 'y']) = 1">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: one y-axis coordinate has to be specified.</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="count(swe:Position/swe:location/swe:Vector/swe:coordinate/swe:Quantity[@axisID = 'z']) = 0                 or count(swe:Position/swe:location/swe:Vector/swe:coordinate/swe:Quantity[@axisID = 'z']) = 1"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(swe:Position/swe:location/swe:Vector/swe:coordinate/swe:Quantity[@axisID = 'z']) = 0 or count(swe:Position/swe:location/swe:Vector/swe:coordinate/swe:Quantity[@axisID = 'z']) = 1">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: one z-axis coordinate may be specified.</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//sml:System/sml:components/sml:ComponentList/sml:component" priority="1000" mode="M4">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//sml:System/sml:components/sml:ComponentList/sml:component"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="(@xlink:href and not(sml:Component)) or (not (@xlink:href) and sml:Component)"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@xlink:href and not(sml:Component)) or (not (@xlink:href) and sml:Component)">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: 'sml:component' must contain EITHER attribute 'xlink:href' OR child 'sml:Component'</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
</xsl:template>
<xsl:template match="text()" priority="-1" mode="M4"/>
<xsl:template match="@*|node()" priority="-2" mode="M4">
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
</xsl:template>

<!--PATTERN ComponentValidation-->


	<!--RULE -->
<xsl:template match="//sml:Component/sml:classification" priority="1000" mode="M5">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//sml:Component/sml:classification"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="count(sml:ClassifierList/sml:classifier/sml:Term[@definition = 'urn:ogc:def:classifier:OGC:1.0:sensorType']) &gt;= 1"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(sml:ClassifierList/sml:classifier/sml:Term[@definition = 'urn:ogc:def:classifier:OGC:1.0:sensorType']) &gt;= 1">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: At least one classifier has to be of the type 'urn:ogc:def:classifier:OGC:1.0:sensorType'.</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M5"/>
</xsl:template>
<xsl:template match="text()" priority="-1" mode="M5"/>
<xsl:template match="@*|node()" priority="-2" mode="M5">
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M5"/>
</xsl:template>

<!--PATTERN GeneralValidation-->


	<!--RULE -->
<xsl:template match="//sml:System" priority="1021" mode="M6">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//sml:System"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="gml:description"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gml:description">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: 'gml:description' element has to be present</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//sml:Component" priority="1020" mode="M6">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//sml:Component"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="gml:description"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="gml:description">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: 'gml:description' element has to be present</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//sml:System" priority="1019" mode="M6">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//sml:System"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="sml:keywords/sml:KeywordList"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="sml:keywords/sml:KeywordList">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: 'KeywordList' element has to be present</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//sml:Component" priority="1018" mode="M6">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//sml:Component"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="sml:keywords/sml:KeywordList"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="sml:keywords/sml:KeywordList">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: 'KeywordList' element has to be present</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//sml:identification/sml:IdentifierList/sml:identifier/sml:Term" priority="1017" mode="M6">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//sml:identification/sml:IdentifierList/sml:identifier/sml:Term"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="string-length(@definition) &gt; 0"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="string-length(@definition) &gt; 0">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: 'definition' attribute has to be present and its value has to be &gt; 0.</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//sml:identification" priority="1016" mode="M6">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//sml:identification"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="count(sml:IdentifierList/sml:identifier/sml:Term[@definition = 'urn:ogc:def:identifier:OGC:1.0:uniqueID']) = 1"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(sml:IdentifierList/sml:identifier/sml:Term[@definition = 'urn:ogc:def:identifier:OGC:1.0:uniqueID']) = 1">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: one identifier has to be of the type 'urn:ogc:def:identifier:OGC:1.0:uniqueID'.</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//sml:identification" priority="1015" mode="M6">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//sml:identification"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="count(sml:IdentifierList/sml:identifier/sml:Term[@definition = 'urn:ogc:def:identifier:OGC:1.0:longName']) = 1"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(sml:IdentifierList/sml:identifier/sml:Term[@definition = 'urn:ogc:def:identifier:OGC:1.0:longName']) = 1">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: one identifier has to be of the type 'urn:ogc:def:identifier:OGC:1.0:longName'.</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//sml:identification" priority="1014" mode="M6">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//sml:identification"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="count(sml:IdentifierList/sml:identifier/sml:Term[@definition = 'urn:ogc:def:identifier:OGC:1.0:shortName']) = 1"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(sml:IdentifierList/sml:identifier/sml:Term[@definition = 'urn:ogc:def:identifier:OGC:1.0:shortName']) = 1">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: one identifier has to be of the type 'urn:ogc:def:identifier:OGC:1.0:shortName'.</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//sml:Component/sml:identification" priority="1013" mode="M6">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//sml:Component/sml:identification"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="count(sml:IdentifierList/sml:identifier/sml:Term[@definition = 'urn:ogc:def:identifier:OGC:1.0:parentSystemUniqueID']) = 1"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(sml:IdentifierList/sml:identifier/sml:Term[@definition = 'urn:ogc:def:identifier:OGC:1.0:parentSystemUniqueID']) = 1">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: one identifier has to be of the type 'urn:ogc:def:identifier:OGC:1.0:parentSystemUniqueID'.</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//sml:classification/sml:ClassifierList/sml:classifier/sml:Term" priority="1012" mode="M6">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//sml:classification/sml:ClassifierList/sml:classifier/sml:Term"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="string-length(@definition) &gt; 0"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="string-length(@definition) &gt; 0">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: 'definition' attribute has to be present and its value has to be &gt; 0.</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//sml:capabilities/swe:DataRecord/swe:field" priority="1011" mode="M6">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//sml:capabilities/swe:DataRecord/swe:field"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="string-length(child::node()[@definition]) &gt; 0"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="string-length(child::node()[@definition]) &gt; 0">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: 'definition' attribute has to be present and its value has to be &gt; 0.</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//sml:capabilities/swe:DataRecord/swe:field/swe:Quantity/swe:uom" priority="1010" mode="M6">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//sml:capabilities/swe:DataRecord/swe:field/swe:Quantity/swe:uom"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="string-length(@code) &gt; 0"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="string-length(@code) &gt; 0">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: 'code' attribute has to be present and its value has to be &gt; 0.</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//sml:System" priority="1009" mode="M6">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//sml:System"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="sml:contact"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="sml:contact">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: 'sml:contact' element has to be present</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//sml:Component" priority="1008" mode="M6">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//sml:Component"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="sml:contact"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="sml:contact">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: 'sml:contact' element has to be present</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//sml:contact/sml:ResponsibleParty" priority="1007" mode="M6">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//sml:contact/sml:ResponsibleParty"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="sml:organizationName"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="sml:organizationName">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: 'sml:organizationName' element has to be present</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//sml:System" priority="1006" mode="M6">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//sml:System"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="sml:inputs"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="sml:inputs">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: 'sml:inputs' has to be present.</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//sml:Component" priority="1005" mode="M6">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//sml:Component"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="sml:inputs"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="sml:inputs">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: 'sml:inputs' has to be present.</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//sml:inputs/sml:InputList/sml:input" priority="1004" mode="M6">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//sml:inputs/sml:InputList/sml:input"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="swe:ObservableProperty/@definition"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="swe:ObservableProperty/@definition">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: 'swe:ObservableProperty' has to contain 'definition' attribute.</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//sml:System" priority="1003" mode="M6">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//sml:System"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="sml:outputs"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="sml:outputs">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: 'sml:outputs' has to be present.</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//sml:Component" priority="1002" mode="M6">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//sml:Component"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="sml:outputs"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="sml:outputs">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: 'sml:outputs' has to be present.</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//sml:outputs/sml:OutputList/sml:output" priority="1001" mode="M6">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//sml:outputs/sml:OutputList/sml:output"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="child::node()[@definition]"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="child::node()[@definition]">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: child-node of 'output' has to contain 'definition' attribute.</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
</xsl:template>

	<!--RULE -->
<xsl:template match="//sml:outputs/sml:OutputList/sml:output/swe:Quantity" priority="1000" mode="M6">
<svrl:fired-rule xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//sml:outputs/sml:OutputList/sml:output/swe:Quantity"/>

		<!--ASSERT -->
<xsl:choose>
<xsl:when test="string-length(swe:uom/@code) &gt; 0"/>
<xsl:otherwise>
<svrl:failed-assert xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="string-length(swe:uom/@code) &gt; 0">
<xsl:attribute name="location">
<xsl:apply-templates select="." mode="schematron-get-full-path"/>
</xsl:attribute>
<svrl:text>Error: 'code' attribute has to be present and its value has to be &gt; 0.</svrl:text>
</svrl:failed-assert>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
</xsl:template>
<xsl:template match="text()" priority="-1" mode="M6"/>
<xsl:template match="@*|node()" priority="-2" mode="M6">
<xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
</xsl:template>
</xsl:stylesheet>
