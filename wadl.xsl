<?xml version="1.0" encoding="UTF-8"?>
<!-- 
wadl.xsl (07-Sep-2012)

Transforms Web Application Description Language (WADL) XML documents into HTML.

Mark Sawers <mark.sawers@ipc.com>

  See example_wadl.xml at http://github.com/ipcsystems/wadl-stylesheet to explore this stylesheet's capabilities
  and the README.txt for other usage information.
  Note that the contents of a doc element is rendered as a:
  * hyperlink if the title attribute contains is equal to 'Example'
  * mono-spaced font ('pre' tag) if content contains the text 'Example'

  Limitations:
  * Ignores globally defined methods, referred to from a resource using a method reference element.
  Methods must be embedded in a resource element.
  * Ditto for globally defined representations. Representations must be embedded within request
  and response elements.
  * Ignores type and queryType attributes of resource element.
  * Ignores resource_type element.
  * Ignores profile attribute of representation element.
  * Ignores path attribute and child link elements of param element.

  Copyright (c) 2012 IPC Systems, Inc.

  Parts of this work are adapted from Mark Notingham's wadl_documentation.xsl, at
  https://github.com/mnot/wadl_stylesheets.

  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 License.
  To view a copy of this license, visit 
  http://creativecommons.org/licenses/by-sa/3.0/
  or send a letter to 
  Creative Commons
  543 Howard Street, 5th Floor
  San Francisco, California, 94105, USA
  -->
  <xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:wadl="http://wadl.dev.java.net/2009/02"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns="http://www.w3.org/1999/xhtml"
    >

    <!-- Global variables -->
    <xsl:variable name="g_resourcesBase" select="wadl:application/wadl:resources/@base"/>

    <!-- Template for top-level doc element -->
    <xsl:template match="wadl:application">
      <html>
        <head>
          <meta charset="UTF-8" />
          <xsl:call-template name="getStyle"/>
          <title><xsl:call-template name="getTitle"/></title>
        </head>
        <body>
          <div id="header">
            <div class="swagger-ui-wrap">
              <img src="swadl.png"></img><a id="logo">Swadl</a>
            </div>
          </div>
          <h1><xsl:call-template name="getTitle"/></h1>
          <xsl:call-template name="getDoc">
            <xsl:with-param name="base" select="$g_resourcesBase"/>
          </xsl:call-template>

          <div id="swagger-ui-container" class="swagger-ui-wrap">

            <!-- Summary -->
            <div id="info" class="api-info">
              <h2>Summary</h2>
              <table>
                <div class="info-title">
                  <tr>
                    <th>Resource</th>
                    <th>Method</th>
                    <th>Description</th>
                  </tr>
                </div>
                <div class="info-description">
                  <xsl:for-each select="wadl:resources/wadl:resource">
                    <xsl:call-template name="processResourceSummary">
                      <xsl:with-param name="resourceBase" select="$g_resourcesBase"/>
                      <xsl:with-param name="resourcePath" select="@path"/>
                      <xsl:with-param name="lastResource" select="position() = last()"/>
                    </xsl:call-template>
                  </xsl:for-each>
                </div>
              </table>
              <p></p>
            </div>

            <!-- Grammars -->
            <xsl:if test="wadl:grammars/wadl:include">
              <h2>Grammars</h2>
              <p>
                <xsl:for-each select="wadl:grammars/wadl:include">
                  <xsl:variable name="href" select="@href"/>
                  <a href="{$href}"><xsl:value-of select="$href"/></a>
                  <xsl:if test="position() != last()"><br/></xsl:if>  <!-- Add a spacer -->
                </xsl:for-each>
              </p>
            </xsl:if>

            <ul id="resources">

              <!-- Detail -->
              <h2 class="info_title">Resources</h2>
              <xsl:for-each select="wadl:resources">
                <xsl:call-template name="getDoc">
                  <xsl:with-param name="base" select="$g_resourcesBase"/>
                </xsl:call-template>
              </xsl:for-each>

              <xsl:for-each select="wadl:resources/wadl:resource">
                <xsl:call-template name="processResourceDetail">
                  <xsl:with-param name="resourceBase" select="$g_resourcesBase"/>
                  <xsl:with-param name="resourcePath" select="@path"/>
                </xsl:call-template>
              </xsl:for-each>
            </ul>
          </div>

        </body>
      </html>
    </xsl:template>

    <!-- Supporting templates (functions) -->

    <xsl:template name="processResourceSummary">
      <xsl:param name="resourceBase"/>
      <xsl:param name="resourcePath"/>
      <xsl:param name="lastResource"/>

      <xsl:if test="wadl:method">
        <tr>
          <!-- Resource -->
          <td class="summary">
            <xsl:variable name="id"><xsl:call-template name="getId"/></xsl:variable>
            <a href="#{$id}">
              <xsl:call-template name="getFullResourcePath">
                <xsl:with-param name="base" select="$resourceBase"/>                
                <xsl:with-param name="path" select="$resourcePath"/>                
              </xsl:call-template>
            </a>
          </td>
          <!-- Method -->
          <td class="summary">
            <xsl:for-each select="wadl:method">
              <xsl:variable name="name" select="@name"/>
              <xsl:variable name="id2"><xsl:call-template name="getId"/></xsl:variable>
              <a href="#{$id2}"><xsl:value-of select="$name"/></a>
              <xsl:for-each select="wadl:doc"><br/></xsl:for-each>
              <xsl:if test="position() != last()"><br/></xsl:if>  <!-- Add a spacer -->
            </xsl:for-each>
            <br/>
          </td>
          <!-- Description -->
          <td class="summary">
            <xsl:for-each select="wadl:method">
              <xsl:call-template name="getDoc">
                <xsl:with-param name="base" select="$resourceBase"/>
              </xsl:call-template>
              <br/>
              <xsl:if test="position() != last()"><br/></xsl:if>  <!-- Add a spacer -->
            </xsl:for-each>
          </td>
        </tr>
        <!-- Add separator if not the last resource -->
        <xsl:if test="wadl:method and not($lastResource)">
          <tr><td class="summarySeparator"></td><td class="summarySeparator"/><td class="summarySeparator"/></tr>
        </xsl:if>
      </xsl:if>   <!-- wadl:method -->

      <!-- Call recursively for child resources -->
      <xsl:for-each select="wadl:resource">
        <xsl:variable name="base">
          <xsl:call-template name="getFullResourcePath">
            <xsl:with-param name="base" select="$resourceBase"/>                
            <xsl:with-param name="path" select="$resourcePath"/>           
          </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="processResourceSummary">
          <xsl:with-param name="resourceBase" select="$base"/>
          <xsl:with-param name="resourcePath" select="@path"/>
          <xsl:with-param name="lastResource" select="$lastResource and position() = last()"/>
        </xsl:call-template>
      </xsl:for-each>

    </xsl:template>

    <xsl:template name="processResourceDetail">
      <xsl:param name="resourceBase"/>
      <xsl:param name="resourcePath"/>

      <xsl:if test="wadl:method">
        <li class="resource">
          <div class="heading">
            <xsl:variable name="id"><xsl:call-template name="getId"/></xsl:variable>
            <h2>
              <a href="#" onclick="$(this).closest('.resource').children('.methods').slideToggle('slow')">
              Operations for <xsl:value-of select="$resourcePath"/>
              </a>
            </h2>
            <ul class="options">
              <li>
                <a href="#" onclick="$(this).closest('.resource').children('.methods').slideToggle('slow')">
                  Show/Hide
                </a>
              </li>
              <li>
                <a href="#" onclick="$(this).closest('.resource').find('.content').hide();$(this).closest('.resource').children('.methods').slideDown('slow');">
                  List Operations
                </a>
              </li>
              <li>
                <a href="#" onclick="$(this).closest('.resource').find('.content').add($(this).closest('.resource').find('.methods')).slideDown('slow')">
                  Expand Operations
                </a>
              </li>
              <li>
                <a href="#" onclick="goToWadl()">Raw</a>
            </li></ul>
          </div>
          <p>
            <xsl:call-template name="getDoc">
              <xsl:with-param name="base" select="$resourceBase"/>
            </xsl:call-template>
          </p>

          <div class="methods">
            <xsl:for-each select="wadl:method">
              <xsl:variable name="name" select="@name"/>
              <div class="method">
                <ul class="endpoints">
                  <li class="endpoint">
                    <ul class="operations">
                      <li class="{$name} operation">
                        <div class="heading" onclick="$(this.parentNode.getElementsByClassName('content')[0]).slideToggle('slow')">
                          <xsl:variable name="id2"><xsl:call-template name="getId"/></xsl:variable>
                          <h3>
                            <span class="http_method">
                              <a name="{$id2}"><xsl:value-of select="$name"/></a>
                            </span>
                            <span class="path">
                              <a>
                                <xsl:value-of select="$resourcePath"/>
                              </a>
                            </span>
                          </h3>
                          <ul class="options">
                            <li>
                              <xsl:if test="@id">
                                <xsl:value-of select="@id"/>() 
                              </xsl:if>
                            </li>
                          </ul>
                        </div>
                        <div class="content">
                          <p>
                            <xsl:call-template name="getDoc">
                              <xsl:with-param name="base" select="$resourceBase"/>
                            </xsl:call-template>
                          </p>

                          <!-- Request -->
                          <xsl:variable name="fullPath">
                            <xsl:call-template name="getFullResourcePath">
                              <xsl:with-param name="base" select="$resourceBase"/>
                              <xsl:with-param name="path" select="$resourcePath"/>
                            </xsl:call-template>
                          </xsl:variable>
                          <a href="{$fullPath}">
                            <xsl:value-of select="$fullPath"/>
                          </a>
                          <xsl:choose>
                            <xsl:when test="wadl:request">
                              <h4>Parameters</h4>
                              <div style="margin-left: 2em">  <!-- left indent -->
                                <xsl:for-each select="wadl:request">
                                  <xsl:call-template name="getParamBlock">
                                    <xsl:with-param name="style" select="'template'"/>
                                  </xsl:call-template>

                                  <xsl:call-template name="getParamBlock">
                                    <xsl:with-param name="style" select="'matrix'"/>
                                  </xsl:call-template>

                                  <xsl:call-template name="getParamBlock">
                                    <xsl:with-param name="style" select="'header'"/>
                                  </xsl:call-template>

                                  <xsl:call-template name="getParamBlock">
                                    <xsl:with-param name="style" select="'query'"/>
                                  </xsl:call-template>

                                  <xsl:call-template name="getRepresentations"/>
                                </xsl:for-each> <!-- wadl:request -->
                              </div>  <!-- left indent for request -->
                            </xsl:when>

                            <xsl:when test="not(wadl:request) and (ancestor::wadl:*/wadl:param)">
                              <h4>Parameters</h4>
                              <div style="margin-left: 2em">  <!-- left indent -->
                                <xsl:call-template name="getParamBlock">
                                  <xsl:with-param name="style" select="'template'"/>
                                </xsl:call-template>

                                <xsl:call-template name="getParamBlock">
                                  <xsl:with-param name="style" select="'matrix'"/>
                                </xsl:call-template>

                                <xsl:call-template name="getParamBlock">
                                  <xsl:with-param name="style" select="'header'"/>
                                </xsl:call-template>

                                <xsl:call-template name="getParamBlock">
                                  <xsl:with-param name="style" select="'query'"/>
                                </xsl:call-template>

                                <xsl:call-template name="getRepresentations"/>
                              </div>  <!-- left indent for request -->
                            </xsl:when>

                            <xsl:otherwise>
                            </xsl:otherwise>
                          </xsl:choose>

                          <!-- Response -->
                          <xsl:choose>
                            <xsl:when test="wadl:response">
                              <h4>Responses</h4>
                              <div style="margin-left: 2em">  <!-- left indent -->
                                <xsl:for-each select="wadl:response">
                                  <div class="h8">status: </div>
                                  <xsl:choose>
                                    <xsl:when test="@status">
                                      <xsl:value-of select="@status"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                      200 - OK
                                    </xsl:otherwise>
                                  </xsl:choose>
                                  <xsl:for-each select="wadl:doc">
                                    <xsl:if test="@title">
                                      - <xsl:value-of select="@title"/>
                                    </xsl:if>
                                    <xsl:if test="text()">
                                      - <xsl:value-of select="text()"/>
                                    </xsl:if>
                                  </xsl:for-each>

                                  <!-- Get response headers/representations -->
                                  <xsl:if test="wadl:param or wadl:representation">
                                    <div style="margin-left: 2em"> <!-- left indent -->
                                      <xsl:if test="wadl:param">
                                        <div class="h7">headers</div>
                                        <table>
                                          <xsl:for-each select="wadl:param[@style='header']">
                                            <xsl:call-template name="getParams"/>
                                          </xsl:for-each>
                                        </table>
                                      </xsl:if>

                                      <xsl:call-template name="getRepresentations"/>
                                    </div>  <!-- left indent for response headers/representations -->
                                  </xsl:if>
                                </xsl:for-each> <!-- wadl:response -->
                              </div>
                            </xsl:when>
                            <xsl:otherwise>
                            </xsl:otherwise>
                          </xsl:choose>                
                        </div>
                      </li>
                    </ul>
                  </li>
                </ul>

              </div>  <!-- class=method -->
            </xsl:for-each> <!-- wadl:method  -->

          </div> <!-- class=methods -->
        </li>

      </xsl:if>   <!-- wadl:method -->

      <!-- Call recursively for child resources -->
      <xsl:for-each select="wadl:resource">
        <xsl:variable name="base">
          <xsl:call-template name="getFullResourcePath">
            <xsl:with-param name="base" select="$resourceBase"/>                
            <xsl:with-param name="path" select="$resourcePath"/>           
          </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="processResourceDetail">
          <xsl:with-param name="resourceBase" select="$base"/>
          <xsl:with-param name="resourcePath" select="@path"/>
        </xsl:call-template>
      </xsl:for-each> <!-- wadl:resource -->
    </xsl:template>

    <xsl:template name="getFullResourcePath">
      <xsl:param name="base"/>
      <xsl:param name="path"/>
      <xsl:choose>
        <xsl:when test="substring($base, string-length($base)) = '/'">
          <xsl:value-of select="$base"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($base, '/')"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="starts-with($path, '/')">
          <xsl:value-of select="substring($path, 2)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$path"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>

    <xsl:template name="getDoc">
      <xsl:param name="base"/>
      <xsl:for-each select="wadl:doc">
        <xsl:if test="position() > 1"></xsl:if>
        <xsl:if test="@title and local-name(..) != 'application'">
          <xsl:value-of select="@title"/>:
        </xsl:if>
        <xsl:variable name="content" select="."/>
        <xsl:choose>
          <xsl:when test="@title = 'Example'">
            <xsl:variable name="url">
              <xsl:choose>
                <xsl:when test="string-length($base) > 0">
                  <xsl:call-template name="getFullResourcePath">
                    <xsl:with-param name="base" select="$base"/>                
                    <xsl:with-param name="path" select="text()"/>
                  </xsl:call-template>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="text()"/></xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <a href="{$url}"><xsl:value-of select="$url"/></a>
          </xsl:when>
          <xsl:when test="contains($content, 'Example')">
            <div style="white-space:pre-wrap"><pre><xsl:value-of select="."/></pre></div>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$content"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:template>

    <xsl:template name="getId">
      <xsl:choose>
        <xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="generate-id()"/></xsl:otherwise>
      </xsl:choose>
    </xsl:template>

    <xsl:template name="getParamBlock">
      <xsl:param name="style"/>
      <xsl:if test="ancestor-or-self::wadl:*/wadl:param[@style=$style]">
        <div class="h7"><xsl:value-of select="$style"/> params</div>
        <table>
          <xsl:for-each select="ancestor-or-self::wadl:*/wadl:param[@style=$style]">
            <xsl:call-template name="getParams"/>
          </xsl:for-each>
        </table>
        <p/>
      </xsl:if>
    </xsl:template>

    <xsl:template name="getParams">
      <tr>
        <td style="font-weight: bold"><xsl:value-of select="@name"/></td>
        <td>
          <xsl:if test="not(@type) and not(@fixed)">
            unspecified type
          </xsl:if>
          <xsl:call-template name="getHyperlinkedElement">
            <xsl:with-param name="qname" select="@type"/>
          </xsl:call-template>
          <xsl:if test="@required = 'true'"><br/>(required)</xsl:if>
          <xsl:if test="@repeating = 'true'"><br/>(repeating)</xsl:if>
          <xsl:if test="@default"><br/>default: <tt><xsl:value-of select="@default"/></tt></xsl:if>
          <xsl:if test="@type and @fixed"><br/></xsl:if>
          <xsl:if test="@fixed">fixed: <tt><xsl:value-of select="@fixed"/></tt></xsl:if>
          <xsl:if test="wadl:option">
            <br/>options:
            <xsl:for-each select="wadl:option">
              <xsl:choose>
                <xsl:when test="@mediaType">
                  <br/><tt><xsl:value-of select="@value"/> (<xsl:value-of select="@mediaType"/>)</tt>
                </xsl:when>
                <xsl:otherwise>
                  <tt><xsl:value-of select="@value"/></tt>
                  <xsl:if test="position() != last()">, </xsl:if>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
          </xsl:if>
        </td>
        <xsl:if test="wadl:doc">
          <td><xsl:value-of select="wadl:doc"/></td>
        </xsl:if>
      </tr>
    </xsl:template>

    <xsl:template name="getHyperlinkedElement">
      <xsl:param name="qname"/>
      <xsl:variable name="prefix" select="substring-before($qname,':')"/>
      <xsl:variable name="ns-uri" select="./namespace::*[name()=$prefix]"/>
      <xsl:variable name="localname" select="substring-after($qname, ':')"/>
      <xsl:choose>
        <xsl:when test="$ns-uri='http://www.w3.org/2001/XMLSchema' or $ns-uri='http://www.w3.org/2001/XMLSchema-instance'">
          <a href="http://www.w3.org/TR/xmlschema-2/#{$localname}"><xsl:value-of select="$localname"/></a>
        </xsl:when>
        <xsl:when test="$ns-uri and starts-with($ns-uri, 'http://www.w3.org/XML/') = false">
          <a href="{$ns-uri}#{$localname}"><xsl:value-of select="$localname"/></a>
        </xsl:when>
        <xsl:when test="$qname">
          <xsl:value-of select="$qname"/>
        </xsl:when>
      </xsl:choose>
    </xsl:template>



    <xsl:template name="getRepresentations">
      <xsl:if test="wadl:representation">
        <div class="h7">representations</div>
        <table>
          <xsl:for-each select="wadl:representation">
            <tr>
              <td style="font-weight: bold"><xsl:value-of select="@mediaType" /></td>
              <xsl:choose>
                <xsl:when test="@href or @element">
                  <td>
                    <xsl:variable name="href" select="@href" />
                    <xsl:choose>
                      <xsl:when test="@href">
                        <xsl:variable name="localname" select="substring-after(@element, ':')"/>
                        <a href="{$href}"><xsl:value-of select="$localname" /></a>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:call-template name="getHyperlinkedElement">
                          <xsl:with-param name="qname" select="@element" />
                        </xsl:call-template>
                      </xsl:otherwise>
                    </xsl:choose>
                  </td>
                </xsl:when>
                <xsl:otherwise><td/></xsl:otherwise>
              </xsl:choose>  

              <xsl:if test="wadl:doc">
                <td>
                  <xsl:call-template name="getDoc">
                    <xsl:with-param name="base" select="''" />
                  </xsl:call-template>
                </td>
              </xsl:if>
            </tr>
            <xsl:call-template name="getRepresentationParamBlock">
              <xsl:with-param name="style" select="'template'" />
            </xsl:call-template>

            <xsl:call-template name="getRepresentationParamBlock">
              <xsl:with-param name="style" select="'matrix'" />
            </xsl:call-template>

            <xsl:call-template name="getRepresentationParamBlock">
              <xsl:with-param name="style" select="'header'" />
            </xsl:call-template>

            <xsl:call-template name="getRepresentationParamBlock">
              <xsl:with-param name="style" select="'query'" />
            </xsl:call-template>
          </xsl:for-each>
        </table>
      </xsl:if> 
      </xsl:template><xsl:template name="getRepresentationParamBlock">
      <xsl:param name="style"/>
      <xsl:if test="wadl:param[@style=$style]">
        <tr>
          <td style="padding: 0em, 0em, 0em, 2em">
            <div class="h7"><xsl:value-of select="$style"/> params</div>
            <table>
              <xsl:for-each select="wadl:param[@style=$style]">
                <xsl:call-template name="getParams"/>
              </xsl:for-each>
            </table>
            <p/>
          </td>
        </tr>
      </xsl:if>
    </xsl:template>

    <xsl:template name="getStyle">
      <link href="screen.css" media="screen" rel="stylesheet" type="text/css"></link>
    </xsl:template>

    <xsl:template name="getTitle">
      <xsl:choose>
        <xsl:when test="wadl:doc/@title">
          <xsl:value-of select="wadl:doc/@title"/>
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>

  </xsl:stylesheet>
