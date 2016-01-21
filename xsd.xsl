<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.w3.org/1999/xhtml"
  >
  <!-- Template for top-level doc element -->
  <xsl:template match="//xs:schema">
    <xsl:for-each select="current()//xs:complexType">
      <xsl:if test="current()/xs:sequence">
        <xsl:if test="@name">
          <xsl:variable name="schemaName" select="@name"/>
          <div class="schema_def" target="schema_of_{$schemaName}">
            <div class="model-signature slider">
              <div class="signature-container">
                <span class="description">
                  <span class="strong">{</span>
                  <xsl:for-each select="current()/xs:sequence">
                    <xsl:if test="current()/xs:element">
                      <xsl:for-each select="current()/xs:element">
                        <xsl:variable name="schemaType" select="@type"/>
                        <div class="indent">
                          <span class="propOpt propName">
                            <xsl:value-of select="@name"/>
                          </span>
                          <xsl:text> : </xsl:text>
                          <xsl:call-template name="getHyperlinkedElement">
                            <xsl:with-param name="qname" select="@type"/>
                          </xsl:call-template>
                        </div>
                      </xsl:for-each>
                    </xsl:if>
                  </xsl:for-each>
                  <span class="strong">}</span>
                </span>
              </div>
            </div>
          </div>
        </xsl:if>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="getHyperlinkedElement">
    <xsl:param name="qname"/>
    <xsl:variable name="prefix" select="substring-before($qname,':')"/>
    <xsl:variable name="ns-uri" select="./namespace::*[name()=$prefix]"/>
    <xsl:variable name="localname" select="substring-after($qname, ':')"/>
    <xsl:choose>
      <xsl:when test="$ns-uri='http://www.w3.org/2001/XMLSchema' or $ns-uri='http://www.w3.org/2001/XMLSchema-instance'">
        <a target="_blank" href="http://www.w3.org/TR/xmlschema-2/#{$localname}"><xsl:value-of select="$localname"/></a>
      </xsl:when>
      <xsl:when test="not(normalize-space($ns-uri) = '') and starts-with($ns-uri, 'http://www.w3.org/XML/') = false">
        <a target="_blank" href="{$ns-uri}#{$localname}"><xsl:value-of select="$localname"/></a>
      </xsl:when>
      <xsl:when test="not($ns-uri) and ($prefix != '') and (count(ancestor::*/namespace::*) = 0)">
        <!-- we're in Firefox without ns support -->
        <a><xsl:value-of select="$localname"/></a>
      </xsl:when>
      <xsl:when test="$qname">
        <span class="active_schema schema_of_{$qname} slideContainer">
          <a onclick="" class="schema_link">
            <xsl:value-of select="$qname"/>
          </a>
        </span>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
