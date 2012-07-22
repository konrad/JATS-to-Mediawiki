<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    version="1.0">

    <xsl:import href="lib/serialize.xsl"/>
  
    <!-- Output: targeting schema:http://www.mediawiki.org/xml/export-0.6.xsd
         For article content, targeting features listed on, or linked to from, x -->
    
    <!-- Input: 2012-05-18: Supports NISO JATS Archival and Interchange Tagset 0.4 --> 
    
    <!-- *****CONSTANTS: modify according to specific need***** -->

    <!-- *** Base URLs (omitting language prefixes) of articles in the wiki to which articles will be imported *** --> 
    <xsl:variable name="wikiLinkBase1">wikipedia.org/w/index.php?title=</xsl:variable>
    <xsl:variable name="wikiLinkBase2">wikipedia.org/wiki</xsl:variable>
    
    <!-- Default border for all tables -->
    <xsl:variable name="tableBorder">1</xsl:variable>


    <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    
    <!-- match and drop any elements intended for print only -->   
    <xsl:template match="*[@specific-use='print-only']"/>
    
    
    <!-- TODO: how to handle element:sub-article? -->
    <xsl:template match="/article">
        
        <!-- Start MediaWiki document -->
        <xsl:element  name="mediawiki" namespace="http://www.mediawiki.org/xml/export-0.6/">
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
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="sec/p">
        <!-- newline for legibility
          [CFM] Also, need an extra newline between paragraphs in wiki markup.          
        -->
        <xsl:text>

</xsl:text>
        <xsl:apply-templates/>
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
    <!-- Note on <email>: "If both a textual phrase (“the Moody Institute’s email address”) and a mailto URL are required, the <ext-link> element should be used."
         (http://jats.nlm.nih.gov/archiving/tag-library/0.4/index.html?elem=email) -->
    <xsl:template match="ext-link|uri|self-uri">
        <xsl:choose>
            <!-- test for internal link -->
            <xsl:when test="contains(@xlink:href, $wikiLinkBase1)">
                <xsl:text>[[</xsl:text>
                <xsl:value-of select="translate(substring-after(@xlink:href, $wikiLinkBase1), '_', ' ')"/>
                <xsl:text>|</xsl:text>
                <xsl:choose>
                    <xsl:when test="@xlink:title">
                        <xsl:value-of select="@xlink:title"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>]]</xsl:text>
            </xsl:when>
            <xsl:when test="contains(@xlink:href, $wikiLinkBase2)">
                <xsl:text>[[</xsl:text>
                <xsl:value-of select="translate(substring-after(@xlink:href, $wikiLinkBase2), '_', ' ')"/>
                <xsl:text>|</xsl:text>
                <xsl:choose>
                    <xsl:when test="@xlink:title">
                        <xsl:value-of select="@xlink:title"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>]]</xsl:text>
            </xsl:when>
            <xsl:otherwise> <!-- external link -->
                <xsl:text>[</xsl:text>
                <xsl:value-of select="@xlink:href"/>
                <xsl:text> </xsl:text>
                <xsl:choose>
                    <xsl:when test="@xlink:title">
                        <xsl:value-of select="@xlink:title"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>]</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- TODO: anchor links to section heads -->
    <!-- TODO: "Internal link to an image or a file of other types" (http://www.mediawiki.org/wiki/Help:Links) -->
        
    <!-- ***HEADINGS*** -->
    <xsl:template name="CreateHeading">
        <!-- context is <sec> -->
        <!-- newline for legibility -->
        <xsl:text>
            
</xsl:text>
        <xsl:call-template name="CreateHeadingTag"/>
        <xsl:value-of select="title"/>
        <xsl:call-template name="CreateHeadingTag"/>
        <!-- newline for legibility -->
        <xsl:text>
            
</xsl:text>
        </xsl:template>
    
    <!-- Determine depth of current sec to format wiki heading to same depth -->
    <xsl:template name="CreateHeadingTag">
        <xsl:text>=</xsl:text> <!-- Start at level 2 (level 1 is article title) -->
        <xsl:for-each select="ancestor-or-self::sec|ancestor-or-self::label[parent::table-wrap]">
            <xsl:text>=</xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Avoid redundant sec titles -->
    <xsl:template match="sec/title"/>

    <!-- ***LISTS*** -->
    <!-- Note: no support for <label> (JATS 0.4) -->
    <xsl:template match="list">
            <xsl:apply-templates select="label"/>
            <xsl:apply-templates select="title"/>
        <!-- ": fix whitespace / newlines in list output -->
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
    <!-- Bypass (optional) wrapper elements so we can get to the actionable bits inside. -->
    <xsl:template match="fig|fig-group">
        <xsl:apply-templates select="fig|graphic"/>
    </xsl:template>
    
    
    <xsl:template match="graphic|inline-graphic|media">
        <!-- target output is [[File:filename.extension|options|caption]] -->
        <xsl:text>[[File:</xsl:text>
        <xsl:value-of select="@xlink:href"/>
     
        <!-- format option -->
        <xsl:choose>
            <xsl:when test="position='anchor'">
                <xsl:text>|frame</xsl:text>
            </xsl:when>
            <xsl:when test="name()='inline-graphic'">
                <xsl:text>|frameless</xsl:text>
            </xsl:when>
            <xsl:otherwise> <!-- in JATS 0.4, default value of position is 'float' -->
                <xsl:text>|thumb</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        
        <!-- Vertical alignment -->
        <!-- Note: no values are prescribed.  Tests are for values suggested in the JATS 0.4 Tag Library. -->
        <xsl:choose>
            <xsl:when test="@baseline-shift='baseline'">
                <xsl:text>|baseline</xsl:text>
            </xsl:when>
            <xsl:when test="@baseline-shift='sub'">
                <xsl:text>|sub</xsl:text>
            </xsl:when>
            <xsl:when test="@baseline-shift='sup'">
                <xsl:text>|super</xsl:text>
            </xsl:when>
            <xsl:when test="@baseline-shift='top'">
                <xsl:text>|top</xsl:text>
            </xsl:when>
            <xsl:when test="@baseline-shift='text-top'">
                <xsl:text>|text-top</xsl:text>
            </xsl:when>
            <xsl:when test="@baseline-shift='middle'">
                <xsl:text>|middle</xsl:text>
            </xsl:when>
            <xsl:when test="@baseline-shift='bottom'">
                <xsl:text>|bottom</xsl:text>
            </xsl:when>
            <xsl:when test="@baseline-shift='text-bottom'">
                <xsl:text>|text-bottom</xsl:text>
            </xsl:when>
        </xsl:choose>
        
        
        
        <!-- caption: use closest-proximity caption -->
        <xsl:choose>
            <xsl:when test="caption">
                <xsl:text>|</xsl:text>
                <xsl:apply-templates select="caption"/>
            </xsl:when>
            <xsl:when test="ancestor::fig/caption">
                <xsl:text>|</xsl:text>
                <xsl:apply-templates select="ancestor::fig/caption"/>
            </xsl:when>
            <xsl:when test="ancestor::fig-group/caption">
                <xsl:text>|</xsl:text>
                <xsl:apply-templates select="ancestor::fig-group/caption"/>
            </xsl:when>            
        </xsl:choose>
        <xsl:text>]]</xsl:text>
    </xsl:template>


    <!-- The following is cribbed from jpub3-html.xsl v1.0, a module of the JATS Journal Publishing 3.0 Preview Stylesheets. -->
    <!-- ============================================================= -->
    <!--  TABLES                                                       -->
    <!-- ============================================================= -->
    <!--  
      Tables are already in XHTML, and can simply be copied
      through.
      [CFM]  Actually, it looks like tables need to be copied into the output
      as escaped markup.  See github issue #6.
    -->
    
    <xsl:template match="table | tr | th | td">
        <xsl:apply-templates select='.' mode='serialize'/>
      <!--
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="table-copy"/>
            <xsl:if test="name()='table'">
                <xsl:if test="not(@border)">
                    <xsl:attribute name="border">
                        <xsl:value-of select="$tableBorder"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
      -->
    </xsl:template>
  
    <!-- not supported in WikiMedia; any formatting included here is lost -->
    <xsl:template match="col | colgroup"/>
    
    <!-- not supported in WikiMedia but children are, so pass through -->
    <xsl:template match="thead | tbody | tfoot">
        <xsl:apply-templates/>
    </xsl:template>
    
    
    <xsl:template match="array/tbody">
        <table>
            <xsl:copy>
                <xsl:apply-templates select="@*" mode="table-copy"/>
                <xsl:apply-templates/>
            </xsl:copy>
        </table>
    </xsl:template>
    
    
    <xsl:template match="@*" mode="table-copy">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    
    <xsl:template match="@content-type" mode="table-copy"/>
    <!-- end excerpt from jpub3-html.xsl v1.0, a module of the JATS Journal Publishing 3.0 Preview Stylesheets. -->



    <!-- ***MORE TABLES*** -->
    <!-- handle elements within table-wrap -->
    <xsl:template match="table-wrap">
        <xsl:if test="label">
            <!-- create section heading for table itself, at the level of the parent <sec> +1 -->
            <!-- newline-->
            <xsl:text>
</xsl:text>
            <xsl:call-template name="CreateHeadingTag"/><xsl:text>=</xsl:text>
            <xsl:apply-templates select="label" mode="table-wrap"/>
            <xsl:call-template name="CreateHeadingTag"/><xsl:text>=</xsl:text>
        </xsl:if>
        
        <!-- TODO: is there a better way to format this? -->
        <xsl:if test="caption|object-id">
            <!-- newline-->
            <xsl:text>
</xsl:text>
            <xsl:text>:"</xsl:text>
            <xsl:apply-templates select="caption" mode="table-wrap"/>
            <xsl:apply-templates select="object-id" mode="table-wrap"/>
            <xsl:text>"</xsl:text>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- overridden by mode="table-wrap" templates -->
    <xsl:template match="table-wrap/label|table-wrap/caption|table-wrap/object-id"/>
    
    <xsl:template match="label|caption" mode="table-wrap">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="object-id" mode="table-wrap">
        <xsl:text>(</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>)</xsl:text>
    </xsl:template>
    
    
    <!-- Additional formatting to handle lists that should be treated as a 2-column table -->
    <xsl:template match="def-list[term-head|def-head]">
    
    </xsl:template>
    
    

    
    <!-- ***FOOTNOTES & REFERENCES*** -->
    <!-- TODO! -->
    
    <!-- Using Wikipedia List-defined references (see: http://en.wikipedia.org/wiki/Help:List-defined_references ) to reflect JATS/NLM document structure -->
    <!-- The ref to the footnote -->
    <xsl:template match="xref">
        <xsl:variable name="rid">
            <xsl:value-of select="@rid"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="//ref[@id=$rid]">
                <xsl:element name="ref">
                    <xsl:attribute name="name">
                        <xsl:value-of select="$rid"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <!-- No matching ID to link to, so don't build link. -->
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- The footnotes themselves -->
    <xsl:template match="ref-list">
        <!-- header tag -->
        <xsl:text>
== </xsl:text>
        <xsl:choose>
            <xsl:when test="title!=''">
                <xsl:value-of select="title"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>References</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text> ==
</xsl:text>
        <xsl:element name="references">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="ref">
        <xsl:variable name="refID">
            <xsl:choose>
                <xsl:when test="@id!=''">
                    <xsl:value-of select="@id"/>
                </xsl:when>
                <!-- Best practice dictates <ref> will have @id, but the DTD permits the @id to be on the child citation as well.  DTD also permits more than one citation per <ref>.  
                    Since we need an id to point to, grab the @id from the first child element of <ref> that isn't <label> or <x>. -->  
                <xsl:otherwise>
                    <xsl:value-of select="child::*[not(name(label|x))][1]/@id"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- QUESTION: better to let the error display, or suppress and fail quietly? -->
        <!-- Test that there's a link to this footnote; if not, Wiki will display an error, so don't bother. -->
        <xsl:if test="//xref[@rid=$refID]">
            <xsl:element name="ref">
                <xsl:attribute name="name">
                    <xsl:value-of select="$refID"/>  
                </xsl:attribute>
                <xsl:apply-templates select="citation|element-citation|mixed-citation|nlm-citation"/>
            </xsl:element>
            <xsl:text> <!-- newline -->
</xsl:text>
        </xsl:if>   
    </xsl:template>
    
    <!-- Using Template:Citation ( http://en.wikipedia.org/wiki/Template:Citation ) -->
    <xsl:template match="citation|element-citation|mixed-citation|nlm-citation">
        <xsl:text>{{Citation </xsl:text>
        <xsl:for-each select="string-name|person-group/string-name">
            <xsl:text>| author</xsl:text><xsl:value-of select="position()"/><xsl:text> = </xsl:text>
            <xsl:apply-templates/>
        </xsl:for-each>
        <xsl:for-each select="name|person-group/name">
            <xsl:text>| last</xsl:text><xsl:value-of select="position()"/><xsl:text> = </xsl:text>
            <xsl:value-of select="surname"/>
            <xsl:text>
</xsl:text>
            <xsl:text>| first</xsl:text><xsl:value-of select="position()"/><xsl:text> = </xsl:text>
            <xsl:value-of select="given-names"/>
            <xsl:text>
</xsl:text> 
        </xsl:for-each>

        <!-- close citations block -->
        <xsl:text>
}}
</xsl:text>
    </xsl:template>

    
    
    
    <!-- TODO: include table-wrap-foot -->


    <!-- TODO: Notes section -->

</xsl:stylesheet>




