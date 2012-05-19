<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    version="1.0">
    
    <!-- 2012-05-18: Supports NISO JATS 0.4 --> 
    
    <!-- *****CONSTANTS: modify according to specific need***** -->

    <!-- *** Base URLs (omitting language prefixes) of articles in the wiki to which articles will be imported *** --> 
    <xsl:variable name="wikiLinkBase1">wikipedia.org/w/index.php?title=</xsl:variable>
    <xsl:variable name="wikiLinkBase2">wikipedia.org/wiki</xsl:variable>
    
    
    <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    
    <!-- TODO: how to handle element:sub-article? -->
    <xsl:template match="/article">
        
        <!-- Start MediaWiki document -->
        <xsl:element  name="mediawiki" namespace="http://www.mediawiki.org/xml/export-0.6/">
            <xsl:attribute name="xmlns">http://www.mediawiki.org/xml/export-0.6/</xsl:attribute>
            <xsl:attribute name="xmlns:xsi">http://www.w3.org/2001/XMLSchema-instance</xsl:attribute>
            <xsl:attribute name="xsi:schemaLocation">http://www.mediawiki.org/xml/export-0.6/ http://www.mediawiki.org/xml/export-0.6.xsd</xsl:attribute>
            <xsl:attribute name="version">0.6</xsl:attribute>
            <xsl:attribute name="xml:lang"><xsl:value-of select="/article/@xml:lang"/></xsl:attribute>

            <!-- skip siteinfo element; contains information about the wiki this xml was exported FROM, so does not pertain to our scenario. -->
                
            <xsl:element name="page">
                <xsl:element name="title">
                    <!-- DEBUG: check for multiple article-title elements in dataset -->
                    <xsl:value-of select="/article/front/article-meta/title-group/article-title"/>
                </xsl:element>
                 
                 <!-- Value of 0 seems to connote what shows up in "Read" view in MediaWiki, i.e. the current version of the article -->
                <xsl:element name="ns">0</xsl:element>
                
                <!-- skip element:id, will be generated on import -->
                <!-- skip element:redirect -->
                <!-- skip element:restrictions -->

                <xsl:element name="revision">
                    <!-- skip element:id -->
                    <!-- skip element:timestamp ... MediaWiki will stamp at at time of import -->
                    <!-- element:contributor
                         QUESTION: Is this the username who uploaded the file, or the original author?
                         If the former, should a value be supplied here, or is this supplied a s afunction of authenticating to the Wiki on input? -->
                    
                    <!-- element:comment
                         QUESTION: do we want to have a standard comment for the initial import version of the article?  Perhaps describing the import process. -->
                    
                    <!-- skip element:type ... use not documented -->
                    <!-- skip element:action ... use not documented -->
                    

                    <xsl:element name="text">
                        <xsl:attribute name="xml:space">preserve</xsl:attribute>

                        <!-- Here's the meat of the article. -->
                        <xsl:apply-templates select="//body"/>
                        <xsl:apply-templates select="//back"/>
                    </xsl:element>
                </xsl:element>    

                <!-- skip element:upload ... no documentation to explain what this is, but requires things like filesize which we couldn't support -->
                <!-- skip element:logitem -->
                <!-- skip element:discussionthreadinginfo -->

            </xsl:element>

        </xsl:element>        
    </xsl:template>
    
    <xsl:template match="body">
            <xsl:apply-templates select="p"/>
            <xsl:apply-templates select="sec"/>
    <!--    TODO: look into what this is    
            <xsl:apply-templates select="sig-block"/>
    -->    
        
    </xsl:template>
    
    <xsl:template match="sec">
        <xsl:if test="title!=''">
            <xsl:call-template name="CreateHeading"/>
            <!-- newline for readability of output -->
            <xsl:text>
      
            </xsl:text>
        </xsl:if>
        
        
        <!-- CONTINUE HERE-->
        <xsl:apply-templates select="sec|p|list"/>
    </xsl:template>
    
    
    <!-- *****WIKIMEDIA TAGGING***** -->
    
       
    <!-- ***FORMATTING*** -->
    <xsl:template match="italic">
        <xsl:text>''</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>''</xsl:text>
    </xsl:template>    

    <xsl:template match="bold">
        <xsl:text>'''</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>'''</xsl:text>
    </xsl:template>    

    <xsl:template match="break">
        <br/>
    </xsl:template>
    
    <xsl:template match="underline">
        <span style="text-decoration: underline;"><xsl:apply-templates/></span>
    </xsl:template>
    <xsl:template match="underline-start">
        <!-- double-escape the entity refs so the resulting XML contains '&lt;' instead of '<' and therefore remains well-formed -->
        &amp;lt;span style="text-decoration: underline;"&amp;gt;
    </xsl:template>
    <xsl:template match="underline-end">
        &amp;lt;/span&amp;gt;
    </xsl:template>
    
    <xsl:template match="strike">
        <del><xsl:apply-templates/></del>
    </xsl:template>
    
    <xsl:template match="monospace">
        <code><xsl:apply-templates/></code>
    </xsl:template>
    
    <xsl:template match="preformat">
        <pre><xsl:apply-templates/></pre>
    </xsl:template>
    
    <xsl:template match="disp-quote">
        <blockquote><xsl:apply-templates/></blockquote>
    </xsl:template>
    <xsl:template match="attrib">
        <br/><xsl:apply-templates/>
    </xsl:template>
    
    
    <!-- ***LINKS*** -->    
    <xsl:template match="ext-link">
        <xsl:text>[[</xsl:text>
        <xsl:choose>
            <!-- test for internal link -->
            <xsl:when test="contains(@xlink:href, $wikiLinkBase1)">
                <xsl:value-of select="translate(substring-after(@xlink:href, $wikiLinkBase1), '_', ' ')"/>
                <xsl:text>|</xsl:text>
            </xsl:when>
            <xsl:when test="contains(@xlink:href, $wikiLinkBase2)">
                <xsl:value-of select="translate(substring-after(@xlink:href, $wikiLinkBase2), '_', ' ')"/>
                <xsl:text>|</xsl:text>
            </xsl:when>
            <xsl:otherwise> <!-- external link -->
                <xsl:value-of select="@xlink:href"/>
                <xsl:text> </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="."/>
        <xsl:text>]]</xsl:text>
    </xsl:template>
    
    
    <!-- ***HEADINGS*** -->
    <xsl:template name="CreateHeading">
        <!-- context is <sec> -->
        <xsl:call-template name="CreateHeadingTag"/>
        <xsl:value-of select="title"/>
        <xsl:call-template name="CreateHeadingTag"/>
    </xsl:template>
    
    <!-- Determine depth of current sec to format wiki heading to same depth -->
    <xsl:template name="CreateHeadingTag">
        <xsl:for-each select="ancestor-or-self::sec">
            <xsl:text>=</xsl:text>
        </xsl:for-each>
    </xsl:template>
    

    <!-- ***LISTS*** -->
    <!-- Note: no support for <label> (JATS 0.4) -->
    <xsl:template match="list">
            <xsl:apply-templates select="label"/>
            <xsl:apply-templates select="title"/>
        <!-- TODO: fix whitespace / newlines in list output -->
        <xsl:for-each select="list-item">
            <xsl:choose>
                <xsl:when test="parent::list/@list-type='bullet|simple'">
                    <xsl:text>* </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text># </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="parent::list/@prefix-word">
                <xsl:value-of select="concat(parent::list/@prefix-word, ' ')"/>
            </xsl:if>
            <xsl:apply-templates/>    
        </xsl:for-each>        
    </xsl:template>

    <!-- DEBUG: need test data -->
    <!-- Definition list, without headers -->
    <xsl:template match="def-list[not(term-head|def-head)]">
        <xsl:apply-templates select="label"/>
        <xsl:apply-templates select="title"/>
        <xsl:apply-templates select="def-item|x" mode="HeadlessDefList"/>
        <xsl:apply-templates select="def-list"/>        
    </xsl:template>
    <xsl:template match="def-item" mode="HeadlessDefList">
            <xsl:apply-templates select="term|def|x" mode="HeadlessDefList"/>
    </xsl:template>
    <xsl:template match="term" mode="HeadlessDefList">
        <xsl:text>;</xsl:text><xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="def" mode="HeadlessDefList">
        <xsl:text>: </xsl:text><xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="x" mode="HeadlessDefList">
        <xsl:apply-templates/>
    </xsl:template>
    
    
    
    <!-- ***FILES*** -->    



    <!-- ***TABLES*** -->
    <xsl:template match="def-list[term-head|def-head]">
        <!-- treat as a 2-column table -->
    </xsl:template>

    



</xsl:stylesheet>




