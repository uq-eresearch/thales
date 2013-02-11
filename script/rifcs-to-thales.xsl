<?xml version="1.0"?>
<!--
    Converts RIF-CS to Thales dump format.

    Copyright (C) 2013, The University of Queensland (eResearch Lab).
  -->

<xsl:transform
   version="1.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:rif="http://ands.org.au/standards/rif-cs/registryObjects"
   xmlns:t="http://ns.research.data.uq.edu.au/2012/thales/db"
   xmlns:cs="http://ns.research.data.uq.edu.au/2012/cornerstone"
   exclude-result-prefixes="rif"
   >

  <xsl:output
     method="xml"
     encoding="UTF-8"
     standalone="yes"
     indent="yes"
     />

  <!-- **************************************************************** -->
  <!-- Top-level rule -->

  <xsl:template match="/">
    <t:records>
      <xsl:apply-templates select="//rif:registryObject"/>
    </t:records>
  </xsl:template>

  <!-- **************************************************************** -->

  <xsl:template match="rif:registryObject">

    <t:record>
      <xsl:comment>group: <xsl:value-of select="@group"/></xsl:comment>
      <xsl:comment>originatingSource: <xsl:value-of select="rif:originatingSource"/></xsl:comment>

      <t:id>
	<xsl:choose>
	  <xsl:when test="starts-with(rif:key, 'http://115.146.93.74/redbox/published/detail/')">
	    <xsl:value-of select="substring-after(rif:key, 'http://115.146.93.74/redbox/published/detail/')"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="rif:key"/>
	  </xsl:otherwise>
	</xsl:choose>
      </t:id>

      <xsl:choose>
	<xsl:when test="rif:collection">
	  <xsl:apply-templates select="rif:collection"/>
	</xsl:when>
	<xsl:when test="rif:party">
	  <xsl:apply-templates select="rif:party"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:message terminate="yes">Error: record is not a collection or party: key=<xsl:value-of select="rif:key"/></xsl:message>
	</xsl:otherwise>
      </xsl:choose>

    </t:record>
  </xsl:template>

  <xsl:template match="rif:collection">
    <t:type>http://ns.research.data.uq.edu.au/2012/eResearch/type/collection</t:type>
    <cs:data>
      <cs:prop type="http://ns.research.data.uq.edu.au/2012/eResearch/property/subtype">
	<xsl:text>http://ns.research.data.uq.edu.au/2012/eResearch/subtype/collection/</xsl:text>
	<xsl:value-of select="@type"/>
      </cs:prop>

      <xsl:apply-templates/>
    </cs:data>
  </xsl:template>

  <xsl:template match="rif:party">
    <t:type>http://ns.research.data.uq.edu.au/2012/eResearch/type/party</t:type>
    <cs:data>
      <cs:prop type="http://ns.research.data.uq.edu.au/2012/eResearch/property/subtype">
	<xsl:text>http://ns.research.data.uq.edu.au/2012/eResearch/subtype/party/</xsl:text>
	<xsl:value-of select="@type"/>
      </cs:prop>

      <xsl:apply-templates/>
    </cs:data>
  </xsl:template>

  <!--****************************************************************-->

  <xsl:template match="rif:name">
    <xsl:choose>
      <xsl:when test="local-name(..)='collection'">
	<!-- Collections must only have one name, and that is the title -->
	<xsl:if test="count(rif:namePart)!=1">
	  <xsl:message terminate="no">Error: number of namePart elements != 1: <xsl:value-of select="../../rif:key"/></xsl:message>
	</xsl:if>
	<cs:prop type="http://ns.research.data.uq.edu.au/2012/eResearch/property/title">
	  <xsl:value-of select="rif:namePart"/>
	</cs:prop>
      </xsl:when>

      <xsl:when test="local-name(..)='party'">
	<xsl:apply-templates mode="party-name"/>
      </xsl:when>

      <xsl:otherwise>
	<xsl:message terminate="yes">Error: unexpected form of name: <xsl:value-of select="local-name(..)"/> - <xsl:value-of select="../../rif:key"/></xsl:message>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <xsl:template match="rif:namePart" mode="party-name">
    <xsl:choose>
      <xsl:when test="@type='title'">
	<cs:prop type="http://ns.research.data.uq.edu.au/2012/eResearch/property/name_title">
	  <xsl:value-of select="."/>
	</cs:prop>
      </xsl:when>
      <xsl:when test="@type='given'">
	<cs:prop type="http://ns.research.data.uq.edu.au/2012/eResearch/property/name_given">
	  <xsl:value-of select="."/>
	</cs:prop>
      </xsl:when>
      <xsl:when test="@type='family'">
	<cs:prop type="http://ns.research.data.uq.edu.au/2012/eResearch/property/name_family">
	  <xsl:value-of select="."/>
	</cs:prop>
      </xsl:when>
      <xsl:otherwise>
	<xsl:message terminate="yes">Error: unexpected namePart @type: <xsl:value-of select="@type"/> in party/name</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="rif:pref_name" mode="party-name">
    <!--<xsl:message terminate="no">Warning: rif:pref_name element in name ignored: <xsl:value-of select="."/></xsl:message>-->
  </xsl:template>

  <xsl:template match="*" mode="party-name">
    <xsl:message terminate="yes">Error: unexpected element: <xsl:value-of select="local-name()"/> in party/name</xsl:message>
  </xsl:template>

  <!--................................................................-->

  <xsl:template match="rif:description">
    <cs:prop type="http://ns.research.data.uq.edu.au/2012/eResearch/property/description">
      <xsl:value-of select="."/>
    </cs:prop>
  </xsl:template>

  <xsl:template match="rif:identifier">
    <cs:prop type="http://ns.research.data.uq.edu.au/2012/eResearch/property/identifier">
      <xsl:choose>
	<xsl:when test="starts-with(., 'http://115.146.93.74/redbox/published/detail/')">
	  <xsl:value-of select="substring-after(., 'http://115.146.93.74/redbox/published/detail/')"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="."/>
	</xsl:otherwise>
      </xsl:choose>
    </cs:prop>
  </xsl:template>

  <xsl:template match="rif:location">
    <!-- xsl:message terminate="no">Warning: location (discarded): <xsl:value-of select="../../rif:key"/></xsl:message-->
    <xsl:if test="count(*) != 1">
      <xsl:message terminate="yes">Error: number of child elements in location != 1: <xsl:value-of select="../../rif:key"/></xsl:message>
    </xsl:if>
    <xsl:if test="count(rif:address) != 1">
      <xsl:message terminate="yes">Error: number of address in location != 1: <xsl:value-of select="../../rif:key"/></xsl:message>
    </xsl:if>

    <xsl:apply-templates mode="location_address" select="rif:address/*"/>
  </xsl:template>

  <xsl:template match="rif:electronic" mode="location_address">
    <xsl:choose>
      <xsl:when test="@type='email'">
	<cs:prop type="http://ns.research.data.uq.edu.au/2012/eResearch/property/contact_email"><xsl:value-of select="rif:value"/></cs:prop>
      </xsl:when>
      <xsl:when test="@type='url'">
	<cs:prop type="http://ns.research.data.uq.edu.au/2012/eResearch/property/web_page"><xsl:value-of select="rif:value"/></cs:prop>
      </xsl:when>
      <xsl:otherwise>
	<xsl:message terminate="yes">Error: unexpected type in rif:electronic: <xsl:value-of select="@type"/></xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="rif:physical" mode="location_address">
    <xsl:message terminate="no">
      <xsl:text>Warning: location/address/physical (discarded): </xsl:text>
      <xsl:value-of select="rif:addressPart"/>
    </xsl:message>
  </xsl:template>

  <xsl:template match="*" mode="location_address">
    <xsl:message terminate="yes">
      <xsl:text>Error: unexpected element in location/address: {</xsl:text>
      <xsl:value-of select="namespace-uri()"/>
      <xsl:text>}</xsl:text>
      <xsl:value-of select="local-name()"/>
  </xsl:message>
  </xsl:template>

  <!-- Coverage -->

  <xsl:template match="rif:coverage">
    <xsl:apply-templates mode="coverage"/>
  </xsl:template>

  <xsl:template match="rif:temporal" mode="coverage">
    <cs:prop type="http://ns.research.data.uq.edu.au/2012/eResearch/property/temporal">
      <xsl:choose>
	<xsl:when test="count(rif:date)=2">
	  <xsl:value-of select="rif:date[@type='dateFrom']"/>
	  <xsl:text>/</xsl:text>
	  <xsl:value-of select="rif:date[@type='dateTo']"/>
	</xsl:when>
	<xsl:when test="count(rif:date)=1">
	  <xsl:value-of select="rif:date"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:message terminate="yes">Error: unexpected number of rif:date elements: <xsl:value-of select="../../../rif:key"/></xsl:message>
	</xsl:otherwise>
      </xsl:choose>
    </cs:prop>
  </xsl:template>

  <xsl:template match="rif:spatial[@type='text']" mode="coverage">
    <xsl:choose>
      <xsl:when test="starts-with(text(), 'POLYGON')">
	<cs:prop type="http://ns.research.data.uq.edu.au/2012/eResearch/property/spatial_polygon">
	  <!-- convert "POLYGON((lat1 long1,lat2 long2,lat3 long3))"
	       to "lat1,long1 lat2,long2 lat3,long3" -->
	  <xsl:value-of select="translate(substring-after(., 'POLYGON'), ', ()', ' ,')"/>
	</cs:prop>
      </xsl:when>

      <xsl:when test="starts-with(text(), 'LINESTRING')">
	<cs:prop type="http://ns.research.data.uq.edu.au/2012/eResearch/property/spatial_polygon">
	  <!-- convert "LINESTRING(lat1 long1,lat2 long2,lat3 long3)"
	       to "lat1,long1 lat2,long2 lat3,long3" -->
	  <xsl:value-of select="translate(substring-after(., 'LINESTRING'), ', ()', ' ,')"/>
	</cs:prop>
      </xsl:when>

      <xsl:otherwise>
	<cs:prop type="http://ns.research.data.uq.edu.au/2012/eResearch/property/spatial_text">
	  <xsl:value-of select="."/>
	</cs:prop>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*" mode="coverage">
    <xsl:message terminate="no">Error: unexpected element in coverage: <xsl:value-of select="local-name()"/></xsl:message>
  </xsl:template>



  <xsl:template match="rif:subject">
    <xsl:choose>
      <xsl:when test="@type='local'">
	<cs:prop type="http://ns.research.data.uq.edu.au/2012/eResearch/property/tag_keyword">
	  <xsl:value-of select="."/>
	</cs:prop>
      </xsl:when>

      <xsl:when test="@type='anzsrc-for'">
	<cs:link type="http://ns.research.data.uq.edu.au/2012/eResearch/property/tag_FoR">
	  <xsl:attribute name="uri">
	    <xsl:text>http://purl.org/asc/1297.0/2008/for/</xsl:text>
	    <xsl:value-of select="."/>
	  </xsl:attribute>
	  <xsl:value-of select="."/>
	</cs:link>
      </xsl:when>

      <xsl:otherwise>
	<xsl:message terminate="no">Warning: unexpected subject type (discarded): <xsl:value-of select="@type"/>: "<xsl:value-of select="."/>"</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="rif:rights">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="rif:accessRights">
    <cs:prop type="http://ns.research.data.uq.edu.au/2012/eResearch/property/rights_access">
      <xsl:value-of select="."/>
    </cs:prop>
  </xsl:template>

  <xsl:template match="rif:relatedInfo">
    <cs:prop type="http://ns.research.data.uq.edu.au/2012/eResearch/property/relatedInfo">
      <xsl:value-of select="."/>
    </cs:prop>
  </xsl:template>

  <xsl:template match="*">
    <xsl:message terminate="yes">
      <xsl:text>Error: unexpected element: {</xsl:text>
      <xsl:value-of select="namespace-uri()"/>
      <xsl:text>}</xsl:text>
      <xsl:value-of select="local-name()"/>
    </xsl:message>
  </xsl:template>

</xsl:transform>

<!--EOF-->
