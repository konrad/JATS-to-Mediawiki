<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:ex="http://exslt.org/dates-and-times"
    xmlns:mml="http://www.w3.org/1998/Math/MathML"   
    extension-element-prefixes="ex"
    version="1.0">

    <xsl:import href="lib/serialize.xsl"/>
  
    <!-- Output: targeting schema:http://www.mediawiki.org/xml/export-0.8.xsd
         For article content, targeting features listed on, or linked to from, x -->
    
    <!-- Input: 2012-05-18: Supports NISO JATS Archival and Interchange Tagset 0.4 --> 
    
    <!-- *****CONSTANTS: modify according to specific need***** -->

    <!-- *** Base URLs (omitting language prefixes) of articles in the wiki to which articles will be imported *** --> 
    <xsl:variable name="wikiLinkBase1">wikipedia.org/w/index.php?title=</xsl:variable>
    <xsl:variable name="wikiLinkBase2">wikipedia.org/wiki</xsl:variable>
    
    <!-- Default border for all tables -->
    <xsl:variable name="tableBorder">1</xsl:variable>


    <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    
    <!-- match and drop any elements intended for print only -->   
    <xsl:template match="*[@specific-use='print-only']"/>
    
    
    <!-- TODO: how to handle element:sub-article? -->
    <xsl:template match="/article">
        
        <!-- Start MediaWiki document -->
        <xsl:element  name="mediawiki">
            <xsl:attribute name="xmlns">http://www.mediawiki.org/xml/export-0.8/</xsl:attribute>
            <xsl:attribute name="xsi:schemaLocation">http://www.mediawiki.org/xml/export-0.8/ http://www.mediawiki.org/xml/export-0.8.xsd</xsl:attribute>
            <xsl:attribute name="version">0.8</xsl:attribute>
            <xsl:attribute name="xml:lang"><xsl:value-of select="/article/@xml:lang"/></xsl:attribute>

            <!-- skip siteinfo element; contains information about the wiki this xml was exported FROM, so does not pertain to our scenario. -->
                
            <xsl:element name="page">
                <xsl:element name="title">
                    <!-- DEBUG: check for multiple article-title elements in dataset -->
                    <xsl:value-of select="/article/front/article-meta/title-group/article-title"/>
                </xsl:element>
                 
                <!-- Value of 0 connotes a main article, see http://meta.wikimedia.org/wiki/Namespaces#List_of_namespaces -->
               <xsl:element name="ns">0</xsl:element>
                
                
                <xsl:element name="id"><xsl:number value="position()" format="1" /></xsl:element>
                <!-- skip element:redirect -->
                <!-- skip element:restrictions -->

                <xsl:element name="revision">
                    <xsl:element name="id"><xsl:number value="position()" format="1" /></xsl:element>
                    <xsl:element name="timestamp">
                        <xsl:value-of select="ex:date-time()"/> 
                    </xsl:element>
                    <!-- element:contributor
                         QUESTION: Is this the username who uploaded the file, or the original author? -->
                <xsl:element name="contributor">
                    <xsl:element name="username">Daniel Mietchen</xsl:element>
                </xsl:element>
                    
                    <!-- element:comment
                         QUESTION: do we want to have a standard comment for the initial import version of the article?  Perhaps describing the import process. -->

                    <xsl:element name="text">
                        <xsl:attribute name="xml:space">preserve</xsl:attribute>

                        <!-- Here's the meat of the article. -->
                        <xsl:apply-templates select="front"/>
                        <xsl:apply-templates select="front/article-meta/abstract"/>
                        <xsl:apply-templates select="body"/>
                        <xsl:apply-templates select="back"/>
                        <xsl:apply-templates select="front/article-meta//license"/>
                    </xsl:element>
                    
                    <!-- Not clear what exactly to checksum, so leaving blank -->
                    <xsl:element name="sha1"></xsl:element>                    
                    
                    <xsl:element name="model">wikitext</xsl:element>
                    
                    <xsl:element name="format">text/x-wiki</xsl:element>
                </xsl:element>    

                <!-- skip element:upload ... no documentation to explain what this is, but requires things like filesize which we couldn't support -->
                <!-- skip element:logitem -->
                <!-- skip element:discussionthreadinginfo -->

            </xsl:element>

        </xsl:element>        
    </xsl:template>

    <xsl:template match="front">
        <!-- Per Wikisource policy, all articles must begin with a populated header as defined in
            http://en.wikisource.org/wiki/Template:Header, which specifies that unused template parameters
            should *NOT* be removed -->
        <xsl:text>{{header
    | title      = </xsl:text><xsl:apply-templates select="article-meta//article-title[1]"/>
        <xsl:for-each select="article-meta//subtitle">
            <xsl:text>: </xsl:text>
            <xsl:value-of select="."/>
        </xsl:for-each>
        <xsl:text>
    | author     = </xsl:text>
        <!-- Wikisource header template auto-links authors but does not support multple authors;
        If we have more than one, we must manually turn off wikilinking, since it will try to link
        to one enrtry whose title is the combined names. -->
        <xsl:if test="count(article-meta/contrib-group/contrib[starts-with(@contrib-type, 'a')]) > 1">
            <xsl:text> |override_author= </xsl:text>            
        </xsl:if>
        <xsl:apply-templates select="article-meta/contrib-group/contrib[starts-with(@contrib-type, 'a')]" mode="headerTemplateContrib">
            <xsl:with-param name="stem">a</xsl:with-param>     
        </xsl:apply-templates>
        <xsl:text>
    | editor = </xsl:text>
        <xsl:apply-templates select="article-meta/contrib-group/contrib[starts-with(@contrib-type, 'e')]" mode="headerTemplateContrib">
            <xsl:with-param name="stem">e</xsl:with-param>     
        </xsl:apply-templates>        
        <xsl:text>
    | translator = </xsl:text>
        <xsl:apply-templates select="article-meta/contrib-group/contrib[starts-with(@contrib-type, 'tran')]" mode="headerTemplateContrib">
            <xsl:with-param name="stem">a</xsl:with-param>     
        </xsl:apply-templates>
        <xsl:text>
    | section    = </xsl:text>
        <xsl:call-template name="journalCitation"/>
        <xsl:text>
    | contributor= </xsl:text>
        <xsl:apply-templates select="article-meta/contrib-group/contrib[not(starts-with(@contrib-type, 'a')) and not(starts-with(@contrib-type, 'e')) and not(starts-with(@contrib-type, 'tran'))]" mode="headerTemplateContrib">
            <xsl:with-param name="stem">a</xsl:with-param>     
        </xsl:apply-templates>
        <xsl:text>
    | previous   = </xsl:text>
        <xsl:text>
    | next       = </xsl:text>
        <xsl:text>
    | year       = </xsl:text>
        <!-- There could be several pub-dates based on @pub-type, but since that attribute does not
            have a controlled vocabulary, trying to perform logic on it is perilous -->
        <xsl:value-of select="article-meta/pub-date[1]/year"/>
        <xsl:text>
    | edition     = </xsl:text>
        <xsl:text>
    | categories     = </xsl:text>
        <xsl:for-each select="article-meta//subject">
            <xsl:value-of select="."/>
            <xsl:if test="position()!=last()">
                <xsl:text> / </xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:text>
    | shortcut     = </xsl:text>
        <xsl:text>
    | portal     = </xsl:text>
        <xsl:text>
    | wikipedia  = </xsl:text>
        <xsl:text>
    | commons    = </xsl:text>
        <xsl:text>
    | commonscat = </xsl:text>
        <xsl:text>
    | wikiquote  = </xsl:text>
        <xsl:text>
    | wikinews   = </xsl:text>
        <xsl:text>
    | wiktionary = </xsl:text>
        <xsl:text>
    | wikibooks  = </xsl:text>
        <xsl:text>
    | wikiversity= </xsl:text>
        <xsl:text>
    | wikispecies= </xsl:text>
        <xsl:text>
    | wikivoyage = </xsl:text>
        <xsl:text>
    | wikidata   = </xsl:text>
        <xsl:text>
    | wikilivres = </xsl:text>
        <xsl:text>
    | meta       = </xsl:text>
        <xsl:text>
    | notes      = </xsl:text>
        <xsl:text>
}}
</xsl:text>
    </xsl:template>

    <xsl:template match="contrib" mode="headerTemplateContrib">
        <xsl:param name="stem"/>
        <xsl:if test="preceding-sibling::contrib[starts-with(@contrib-type, $stem)]">
            <xsl:text>; </xsl:text>
        </xsl:if>
        <xsl:apply-templates select="name" mode="headerTemplateContrib"/>
    </xsl:template>

    <xsl:template match="name" mode="headerTemplateContrib">
        <xsl:apply-templates select="prefix"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="given-names"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="surname"/>
        <xsl:if test="suffix">
            <xsl:text>, </xsl:text>
            <xsl:apply-templates select="suffix"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="journalCitation">
        <xsl:if test="journal-meta//journal-title">
            <xsl:text>''</xsl:text> <!-- itlaics -->
            <xsl:apply-templates select="journal-meta//journal-title[1]"/>
            <xsl:text>''</xsl:text>
            <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:if test="journal-meta//journal-title and (article-meta/volume | article-meta/issue)">
            <xsl:text>, </xsl:text>
        </xsl:if>
        <xsl:if test="article-meta/volume">
            <xsl:text>vol. </xsl:text><xsl:value-of select="article-meta/volume[1]"/>    
        </xsl:if>
        <xsl:if test="article-meta/volume and article-meta/issue">
            <xsl:text>, </xsl:text>
        </xsl:if>
        <xsl:if test="article-meta/issue">
            <xsl:text>iss. </xsl:text><xsl:value-of select="article-meta/isse[1]"/>
        </xsl:if>
        <xsl:if test="(journal-meta//journal-title | article-meta/volume | article-meta/issue) and (article-meta/fpage | article-meta/lpage | article-meta/page-range)">
            <xsl:text>, </xsl:text>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="article-meta/page-range">
                <xsl:text>pp.</xsl:text>
                <xsl:value-of select="article-meta/page-range"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="article-meta/fpage != article-meta/lpage">pp.</xsl:when>
                    <xsl:otherwise>p.</xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="article-meta/fpage"/>
                <xsl:if test="article-meta/fpage != article-meta/lpage">
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="article-meta/lpage"/>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="abstract">
        <xsl:text>==Abstract==</xsl:text>
        <xsl:text>
</xsl:text>
        <xsl:apply-templates/>
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
    
    <xsl:template match="sub">
        <xsl:text>&lt;sub&gt;</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>&lt;/sub&gt;</xsl:text>
    </xsl:template>
    <xsl:template match="sup">
        <xsl:text>&lt;sup&gt;</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>&lt;/sup&gt;</xsl:text>
    </xsl:template>

    <!-- ***MATH*** -->
    <xsl:template match="mml:math">
        <xsl:text>&lt;math type="pmml"&gt;</xsl:text>
            <!-- <xsl:copy-of select="."/> includes the mml prefix and does not escape <> -->
            <xsl:apply-templates select="./*"/>
        <xsl:text>&lt;/math&gt;</xsl:text>
    </xsl:template>
    <xsl:template match="mml:*">
        <xsl:text> &lt;</xsl:text>
        <xsl:value-of select="local-name()" />
        <xsl:for-each select="@*">
            <xsl:text> </xsl:text>
            <xsl:value-of select="local-name()" />
            <xsl:text> = "</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>"</xsl:text>
        </xsl:for-each>
        <xsl:text>&gt; </xsl:text>
        <xsl:apply-templates />
        <xsl:text>&lt;/</xsl:text>
        <xsl:value-of select="local-name()"/>
        <xsl:text>&gt; </xsl:text>
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
        <xsl:for-each select="ancestor-or-self::sec|ancestor-or-self::label[parent::table-wrap]|ancestor::abstract">
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
            <xsl:when test="parent::fig/caption">
                <xsl:text>|</xsl:text>
                <xsl:apply-templates select="ancestor::fig/caption"/>
            </xsl:when>
            <xsl:when test="parent::fig-group/caption">
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
    

    <xsl:template match="supplementary-material">
        <xsl:text>
</xsl:text>
        <xsl:call-template name="CreateHeadingTag"/><xsl:text>=</xsl:text>
        <xsl:choose>
            <xsl:when test="label!=''">
                <xsl:value-of select="label"/>
            </xsl:when>
            <xsl:when test="caption/title!=''">
                <xsl:value-of select="caption/title"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>Supplemental file</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="CreateHeadingTag"/><xsl:text>=
</xsl:text>
        <xsl:apply-templates/>
    </xsl:template>

    <!-- skip, since we called this explicitly when writing the section head -->
    <xsl:template match="supplementary-material/label|supplementary-material/caption/title"/>
    

    
    <!-- ***FOOTNOTES & REFERENCES*** -->
	<!-- NOTE: WikiMedia autio-wraps footnote links in square brackets; if the source data explicitly wraps <xref> elements in square brackets, then you end up with some uglyu rendering like '[[5]]'.  Since the outside brackets are CDATA children of the xref's parent element, and xref is in the content model for a wide array of elements, scrubbing out those outside square brackets is very difficult (impossible?) in XSLT.  -->
    
    <!-- Using Wikipedia List-defined references (see: http://en.wikipedia.org/wiki/Help:List-defined_references ) to reflect JATS/NLM document structure -->
    <!-- The ref to the footnote -->
    <xsl:template match="xref">
        <xsl:variable name="rid">
            <xsl:value-of select="@rid"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="//ref[@id=$rid]">
                <!-- escaping xml tags -->
                <xsl:text>&lt;ref name="</xsl:text><xsl:value-of select="$rid"/><xsl:text>"&gt;</xsl:text>
                <xsl:apply-templates/>
                <xsl:text>&lt;/ref&gt;</xsl:text>
            </xsl:when>
            <!-- Internal links to tables -->
            <xsl:when test="//table[@id=$rid]|//table-wrap[@id=$rid]">
                <xsl:text>[[#</xsl:text>
                <xsl:value-of select="translate(//node()[@id=$rid]/label,' ','_')"/>
                <xsl:text>|</xsl:text>
                <xsl:apply-templates/>
                <xsl:text>]]</xsl:text>                
            </xsl:when>
            <!-- Internal links to supplemental materials -->
            <xsl:when test="//supplementary-material[@id=$rid]">
                <xsl:text>[[#</xsl:text>
                <xsl:choose>
                    <xsl:when test="//node()[@id=$rid]/label">
                        <xsl:value-of select="translate(//node()[@id=$rid]/label,' ','_')"/>
                    </xsl:when>
                    <xsl:when test="//node()[@id=$rid]/caption/title">
                        <xsl:value-of select="translate(//node()[@id=$rid]/caption/title,' ','_')"/>
                    </xsl:when>
                </xsl:choose>
                <xsl:text>|</xsl:text>
                <xsl:apply-templates/>
                <xsl:text>]]</xsl:text>                
            </xsl:when>
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
        <xsl:text>&lt;references&gt;</xsl:text>
            <xsl:apply-templates/>
        <xsl:text>&lt;/references&gt;</xsl:text>
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
            <xsl:text>&lt;ref name="</xsl:text><xsl:value-of select="$refID"/><xsl:text>"&gt;</xsl:text>
                <xsl:apply-templates select="citation|element-citation|mixed-citation|nlm-citation"/>
                <xsl:text>&lt;/ref&gt;</xsl:text>
            <xsl:text> <!-- newline -->
</xsl:text>
        </xsl:if>   
    </xsl:template>
    
    <!-- Using Template:Citation ( http://en.wikipedia.org/wiki/Template:Citation )
            which chooses formatting based on which field are populated; more reliable than attempting
            to parse JATS/NLM attributes such as @publication-type or @citation-type, since any text value is permitted
            in those attributes. -->
    <xsl:template match="citation|element-citation|mixed-citation|nlm-citation">
        <xsl:text>{{Citation
</xsl:text>
        <!-- TODO: attempt to differentiate editors from authors?  JATS/NLM tagset is not reliable for this -->
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
        <xsl:for-each select="descendant::collab">
            <xsl:text>| coauthors = </xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>
</xsl:text> 
        </xsl:for-each>
        <!-- PUBLICATION DATES : be careful not to get other dates that can appear in citations, which use same tags-->
        <xsl:if test="year|date/year">
            <xsl:text>| year = </xsl:text>
            <xsl:value-of select="year|date/year"/>
            <xsl:text>
</xsl:text> 
        </xsl:if>
        <xsl:if test="month|date/month">
            <xsl:text>| month = </xsl:text>
            <xsl:value-of select="month|date/month"/>
            <xsl:text>
</xsl:text> 
        </xsl:if>
        <xsl:if test="string-date">
            <xsl:text>| date = </xsl:text>
            <xsl:value-of select="string-date"/>
            <xsl:text>
</xsl:text> 
        </xsl:if>
        <!-- OTHER DATES -->
        <xsl:for-each select="date-in-citation[contains(@content-type, 'access|stamp')]|access-date|time-stamp">
            <xsl:text>| accessdate = </xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>
</xsl:text> 
        </xsl:for-each>
        <xsl:for-each select="date-in-citation[contains(@content-type, 'copyright')]">
            <xsl:text>| origyear = </xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>
</xsl:text> 
        </xsl:for-each>
        <!-- TITLE -->
        <xsl:choose>
            <!-- ARTICLE -->
            <xsl:when test="article-title">
                <xsl:text>| title = </xsl:text>
                <xsl:apply-templates select="article-title"/>
                <xsl:text>
</xsl:text>
                <xsl:if test="source">
                    <xsl:text>| work = </xsl:text>
                    <xsl:apply-templates select="source"/>
                    <xsl:text>
</xsl:text> 
                </xsl:if>
                <xsl:if test="trans-title">
                    <xsl:text>| trans_title = </xsl:text>
                    <xsl:apply-templates select="trans-title"/>
                    <xsl:text>
</xsl:text> 
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="source">
                    <xsl:text>| title = </xsl:text>
                    <xsl:apply-templates select="source"/>
                    <xsl:text>
</xsl:text> 
                </xsl:if>
                <xsl:if test="trans-source">
                    <xsl:text>| trans_title = </xsl:text>
                    <xsl:apply-templates select="trans-title"/>
                    <xsl:text>
</xsl:text> 
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="chapter-title">
            <xsl:text>| chapter = </xsl:text>
            <xsl:apply-templates select="chapter"/>
            <xsl:text>
</xsl:text> 
        </xsl:if>
        
        <!-- ISSUE -->
        <xsl:if test="issue">
            <xsl:text>| issue = </xsl:text>
            <xsl:apply-templates select="issue"/>
            <xsl:text>
</xsl:text> 
        </xsl:if>
        <xsl:if test="volume">
            <xsl:text>| volume = </xsl:text>
            <xsl:apply-templates select="volume"/>
            <xsl:text>
</xsl:text> 
        </xsl:if>
        <xsl:if test="publisher-name">
            <xsl:text>| publisher = </xsl:text>
            <xsl:apply-templates select="publisher-name"/>
            <xsl:text>
</xsl:text> 
        </xsl:if>
        <xsl:if test="publisher-loc">
            <xsl:text>| location = </xsl:text>
            <xsl:apply-templates select="publisher-loc"/>
            <xsl:text>
</xsl:text> 
        </xsl:if>        
        <xsl:if test="series">
            <xsl:text>| series = </xsl:text>
            <xsl:apply-templates select="series"/>
            <xsl:text>
</xsl:text> 
        </xsl:if>
        <xsl:if test="edition">
            <xsl:text>| edition = </xsl:text>
            <xsl:apply-templates select="edition"/>
            <xsl:text>
</xsl:text> 
        </xsl:if>
        
        <!-- LANGUAGES -->
        <xsl:if test="article-title[@xml:lang!='']|chapter-title[@xml:lang!='']|source[@xml:lang!='']">
            <xsl:text>| language = </xsl:text>
            <xsl:choose>
                <xsl:when test="article-title[@xml:lang!='']">
                    <xsl:value-of select="article-title/@xml:lang!=''"/>
                </xsl:when>
                <xsl:when test="chapter-title[@xml:lang!='']">
                    <xsl:value-of select="chapter-title/@xml:lang!=''"/>
                </xsl:when>
                <xsl:when test="source[@xml:lang!='']">
                    <xsl:value-of select="source/@xml:lang!=''"/>
                </xsl:when>
            </xsl:choose>
            <xsl:text>
</xsl:text> 
        </xsl:if>
        
        <!-- PAGES -->
        <xsl:choose>
            <xsl:when test="page-range">
                <xsl:text>| pages = </xsl:text>
                <xsl:apply-templates select="page-range"/>
                <xsl:text>
</xsl:text>                
            </xsl:when>
            <xsl:when test="fpage and lpage">
                <xsl:text>| pages = </xsl:text>
                <xsl:value-of select="fpage"/><xsl:text>–</xsl:text><xsl:value-of select="lpage"/>
                <xsl:text>
</xsl:text>
            </xsl:when>                
            <xsl:when test="fpage and not(lpage)">
                <xsl:text>| page = </xsl:text>
                <xsl:apply-templates select="fpage"/>
                <xsl:text>
</xsl:text>
            </xsl:when>
            <xsl:when test="elocation-id">
                <xsl:text>| at = </xsl:text>
                <xsl:apply-templates select="elocation-id"/>
                <xsl:text>
</xsl:text>
            </xsl:when>
        </xsl:choose>

        <!-- URIs -->
        <xsl:choose>
            <xsl:when test="@xlink:href">
                <xsl:text>| url = </xsl:text>
                <xsl:apply-templates select="@xlink:href"/>
                <xsl:text>
</xsl:text>            
            </xsl:when>
            <!-- Avoid redundancy with specific ID fields below-->
            <xsl:when test="ext-link[not(@ext-link-type='doi|pmcid|pmid')]">
                <xsl:text>| url = </xsl:text>
                <xsl:apply-templates select="ext-link"/>
                <xsl:text>
</xsl:text>     
            </xsl:when>
            <xsl:when test="uri">
                <xsl:text>| url = </xsl:text>
                <xsl:apply-templates select="uri"/>
                <xsl:text>
</xsl:text>
            </xsl:when>
        </xsl:choose>
        
        <!-- IDENTIFIERS -->
        <xsl:if test="issn">
            <xsl:text>| issn = </xsl:text>
            <xsl:apply-templates select="issn"/>
            <xsl:text>
</xsl:text>            
        </xsl:if>
        <xsl:if test="isbn">
            <xsl:text>| isbn = </xsl:text>
            <xsl:apply-templates select="isbn"/>
            <xsl:text>
</xsl:text>            
        </xsl:if>
        <xsl:choose>
            <xsl:when test="pub-id[@pub-id-type='doi']">
                <xsl:text>| doi = </xsl:text>
                <xsl:apply-templates select="pub-id[@pub-id-type='doi']"/>
                <xsl:text>
</xsl:text>            
                
            </xsl:when>
            <xsl:when test="ext-link[@ext-link-type='doi']">
                <xsl:text>| doi = </xsl:text>
                <xsl:apply-templates select="ext-link[@ext-link-type='doi']"/>
                <xsl:text>
</xsl:text>            
            </xsl:when>
        </xsl:choose>
        
        <xsl:choose>
            <xsl:when test="pub-id[@pub-id-type='pmcid']">
                <xsl:text>| pmc = </xsl:text>
                <xsl:apply-templates select="pub-id[@pub-id-type='pmcid']"/>
                <xsl:text>
</xsl:text>     
            </xsl:when>
            <xsl:when test="ext-link[@ext-link-type='pmcid']">
                <xsl:text>| pmc = </xsl:text>
                <xsl:apply-templates select="ext-link[@ext-link-type='pmcid']"/>
                <xsl:text>
</xsl:text>            
            </xsl:when>
        </xsl:choose>
        
        <xsl:choose>
            <xsl:when test="pub-id[@pub-id-type='pmid']">
                <xsl:text>| pmid = </xsl:text>
                <xsl:apply-templates select="pub-id[@pub-id-type='pmid']"/>
                <xsl:text>
</xsl:text>     
            </xsl:when>
            <xsl:when test="ext-link[@ext-link-type='pmid']">
                <xsl:text>| pmid = </xsl:text>
                <xsl:apply-templates select="ext-link[@ext-link-type='pmid']"/>
                <xsl:text>
</xsl:text>            
            </xsl:when>
        </xsl:choose>
        
        <!-- default catch-all id -->
        <xsl:if test="pub-id[not(@pub-id-type='doi|pmcid|pmid')]">
            <xsl:text>| id = </xsl:text>
            <xsl:apply-templates select="pub-id"/>
            <xsl:text>
</xsl:text>     
        </xsl:if>
        
        <!-- MISCELLANIA -->
        <xsl:if test="patent">
            <xsl:text>| patent-number = </xsl:text>
            <xsl:apply-templates select="patent"/>
            <xsl:text>
</xsl:text>     
        </xsl:if>
        
        <!-- UNFORMATTED CITATION BITS 
                i.e. everything else.
                NOTE: We might want to further prune the elements that 
                    will be output here if things get too sloppy;
                    or perhaps only target <comment> and <annotation>?
                These should come at the end of the ref block, which is why
                  we don't do a generic <apply-templates select="*"/>for these
                  and the cases handled above, as that would output 
                  all elements in document order.
        -->
        <xsl:apply-templates select="*[not(self::string-name|self::person-group|self::date|self::year|self::month|self::string-date|self::date-in-citation|self::article-title|self::source|self::trans-title|self::trans-source|self::chapter-title|self::issue|self::volume|self::publisher-name|self::publisher-loc|self::series|self::edition|self::page-range|self::fpage|self::lpage|self::elocation-id|self::ext-link|self::uri|self::issn|self::isbn|self::pub-id|self::patent)]"/>

        <!-- close citations block -->
        <xsl:text>
}}
</xsl:text>
    </xsl:template>

    
    <xsl:template match="license">
        <!-- We need controlled vocabulary to match a license description in the article markup
            with the appropriate license template in WikiSource.  For this purpose, we'll examine the 
            <license> element for a URI, however, NLM/JATS are quite flexible in how this is encoded. -->
        <xsl:variable name="licenseURI">
            <xsl:choose>
                <!-- order these by reliability -->
                <xsl:when test="@xlink:href">
                    <xsl:value-of select="@xlink:href"/>
                </xsl:when>
                <xsl:when test="license-p/uri">
                    <xsl:value-of select="license-p/uri"/>
                </xsl:when>
                <xsl:when test="p/uri">
                    <xsl:value-of select="p/uri"/>
                </xsl:when>
                <xsl:when test="p/ext-link[@ext-link-type='uri']">
                    <xsl:value-of select="p/ext-link[@ext-link-type='uri']"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$licenseURI">
            <xsl:text>
{{</xsl:text>
            <!-- attempt to match the URI to an appropriate template -->
            <xsl:choose>
                <xsl:when test="contains($licenseURI, 'creativecommons.org/licenses/by/2.0')">CC-BY-2.0</xsl:when>
                <xsl:when test="contains($licenseURI, 'creativecommons.org/licenses/by/2.5')">CC-BY-2.5</xsl:when>
                <xsl:when test="contains($licenseURI, 'creativecommons.org/licenses/by/3.0/au')">CC-by-3.0-au</xsl:when>
                <xsl:when test="contains($licenseURI, 'creativecommons.org/licenses/by/3.0/us')">CC-by-3.0-us</xsl:when>
                <xsl:when test="contains($licenseURI, 'creativecommons.org/licenses/by/3.0')">Cc-by-3.0</xsl:when>            
                <xsl:when test="contains($licenseURI, 'creativecommons.org/licenses/by-sa/3.0/us/')">CC-by-sa-3.0-us</xsl:when>
                <xsl:when test="contains($licenseURI, 'creativecommons.org/licenses/by-sa/3.0')">CC-BY-SA-3.0</xsl:when>
                <xsl:when test="contains($licenseURI, 'creativecommons.org/licenses/by-sa/2.0')">CC-BY-SA-2.0</xsl:when>
            </xsl:choose>
            <xsl:text>}}</xsl:text>
        </xsl:if>
    </xsl:template>
    
    <!-- TODO: include table-wrap-foot -->


    <!-- TODO: Notes section -->

</xsl:stylesheet>




