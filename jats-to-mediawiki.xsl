<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:ex="http://exslt.org/dates-and-times" 
                xmlns:str="http://exslt.org/strings"
                xmlns:mml="http://www.w3.org/1998/Math/MathML" 
                xmlns="http://www.mediawiki.org/xml/export-0.8/"
                extension-element-prefixes="ex str" version="1.0">

  <xsl:import href="serialize.xsl"/>

  <!-- 
    Output: targeting schema:http://www.mediawiki.org/xml/export-0.8.xsd
  -->


  <!-- *****CONSTANTS: modify according to specific need***** -->

  <!-- *** Base URLs (omitting language prefixes) of articles in the wiki to which articles will be imported *** -->
  <xsl:variable name="wikiLinkBase1">wikipedia.org/w/index.php?title=</xsl:variable>
  <xsl:variable name="wikiLinkBase2">wikipedia.org/wiki</xsl:variable>

  <!-- Default border for all tables -->
  <xsl:variable name="tableBorder">1</xsl:variable>


  <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" indent="yes"/>
  <xsl:strip-space elements="*"/>
  <xsl:preserve-space elements="named-content"/>


  <!-- match and drop any elements intended for print only -->
  <xsl:template match="*[@specific-use='print-only']"/>


  <!-- fixme: how to handle element:sub-article? -->
  <xsl:template match="/article">

    <!-- Start MediaWiki document -->
    <xsl:element name="mediawiki">
      <xsl:attribute name="xsi:schemaLocation">http://www.mediawiki.org/xml/export-0.8/
        http://www.mediawiki.org/xml/export-0.8.xsd</xsl:attribute>
      <xsl:attribute name="version">0.8</xsl:attribute>
      <xsl:attribute name="xml:lang">
        <xsl:value-of select="/article/@xml:lang"/>
      </xsl:attribute>

      <!-- 
        Skip siteinfo element; contains information about the wiki this xml was exported FROM, so 
        does not pertain to our scenario. 
      -->

      <xsl:element name="page">
        <xsl:element name="title">
          <!-- DEBUG: check for multiple article-title elements in dataset -->
          <xsl:apply-templates select="/article/front/article-meta/title-group/article-title"/>
        </xsl:element>

        <!-- 
          Value of 0 connotes a main article, see 
          http://meta.wikimedia.org/wiki/Namespaces#List_of_namespaces
        -->
        <xsl:element name="ns">0</xsl:element>


        <xsl:element name="id">
          <xsl:number value="position()" format="1"/>
        </xsl:element>
        <!-- skip element:redirect -->
        <!-- skip element:restrictions -->

        <xsl:element name="revision">
          <xsl:element name="id">
            <xsl:number value="position()" format="1"/>
          </xsl:element>
          <xsl:element name="timestamp">
            <xsl:value-of select="ex:date-time()"/>
          </xsl:element>
          <!-- 
            element:contributor
            QUESTION: Is this the username who uploaded the file, or the original author? 
          -->
          <xsl:element name="contributor">
            <xsl:element name="username">Daniel Mietchen</xsl:element>
          </xsl:element>

          <!-- 
            element:comment
            QUESTION: do we want to have a standard comment for the initial import version of the 
            article?  Perhaps describing the import process. 
          -->

          <xsl:element name="text">
            <xsl:attribute name="xml:space">preserve</xsl:attribute>

            <!-- Here's the meat of the article. -->
            <xsl:apply-templates select="front"/>
            <xsl:apply-templates select="front/article-meta/abstract"/>
            <xsl:apply-templates select="body"/>
            <!-- reference list should come last -->
            <xsl:apply-templates select="back/*[not(self::ref-list)]"/>
            <xsl:apply-templates select="back/ref-list"/>
            <xsl:apply-templates select="front/article-meta//license"/>
          </xsl:element>

          <!-- Not clear what exactly to checksum, so leaving blank -->
          <xsl:element name="sha1"/>

          <xsl:element name="model">wikitext</xsl:element>

          <xsl:element name="format">text/x-wiki</xsl:element>
        </xsl:element>

        <!-- skip element:upload ... no documentation to explain what this is, but requires 
          things like filesize which we couldn't support -->
        <!-- skip element:logitem -->
        <!-- skip element:discussionthreadinginfo -->

      </xsl:element>

    </xsl:element>
  </xsl:template>

  <xsl:template match="front">
    <!-- 
      Per Wikisource policy, all articles must begin with a populated header as defined in
      http://en.wikisource.org/wiki/Template:Header, which specifies that unused template parameters
      should *NOT* be removed.
    -->
    <xsl:text>{{header-wpoa&#xA;    | title      = </xsl:text>
    <xsl:apply-templates select="article-meta/title-group/article-title[1]"/>
    <xsl:for-each select="article-meta/title-group/subtitle">
      <xsl:text>: </xsl:text>
      <xsl:value-of select="."/>
    </xsl:for-each>
    <xsl:text>&#xA;    | author     = </xsl:text>
    <!-- 
      Wikisource header template auto-links authors but does not support multple authors;
      If we have more than one, we must manually turn off wikilinking, since it will try to link
      to one enrtry whose title is the combined names. 
    -->
    <xsl:if test="count(article-meta/contrib-group/contrib[starts-with(@contrib-type, 'a')]) > 1">
      <xsl:text> |override_author= </xsl:text>
    </xsl:if>
    
    <xsl:apply-templates 
      select="article-meta/contrib-group/contrib[starts-with(@contrib-type, 'a')]"
      mode="headerTemplateContrib">
      <xsl:with-param name="stem">a</xsl:with-param>
    </xsl:apply-templates>
    
    <xsl:text>&#xA;    | editor = </xsl:text>
    
    <xsl:apply-templates
      select="article-meta/contrib-group/contrib[starts-with(@contrib-type, 'e')]"
      mode="headerTemplateContrib">
      <xsl:with-param name="stem">e</xsl:with-param>
    </xsl:apply-templates>
    
    <xsl:text>&#xA;    | translator = </xsl:text>
    
    <xsl:apply-templates
      select="article-meta/contrib-group/contrib[starts-with(@contrib-type, 'tran')]"
      mode="headerTemplateContrib">
      <xsl:with-param name="stem">a</xsl:with-param>
    </xsl:apply-templates>
    
    <xsl:text>&#xA;    | section    = </xsl:text>
    
    <xsl:call-template name="journalCitation"/>
    
    <xsl:text>&#xA;    | contributor= </xsl:text>
    
    <xsl:apply-templates
      select="article-meta/contrib-group/contrib[not(starts-with(@contrib-type, 'a')) and not(starts-with(@contrib-type, 'e')) and not(starts-with(@contrib-type, 'tran'))]"
      mode="headerTemplateContrib">
      <xsl:with-param name="stem">a</xsl:with-param>
    </xsl:apply-templates>
    
    <xsl:text>&#xA;    | previous   = </xsl:text>
    <xsl:text>&#xA;    | next       = </xsl:text>
    <xsl:text>&#xA;    | year       = </xsl:text>
    
    <!-- 
      There could be several pub-dates based on @pub-type, but since that attribute does not
      have a controlled vocabulary, trying to perform logic on it is perilous 
    -->
    <xsl:value-of select="article-meta/pub-date[1]/year"/>
    <xsl:text>&#xA;    | edition     = </xsl:text>
    <xsl:text>&#xA;    | categories     = </xsl:text>
    <xsl:for-each select="article-meta//subject">
      <xsl:value-of select="."/>
      <xsl:if test="position()!=last()">
        <xsl:text> / </xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:text>&#xA;    | shortcut     = </xsl:text>
    <xsl:text>&#xA;    | portal     = </xsl:text>
    <xsl:text>&#xA;    | wikipedia  = </xsl:text>
    <xsl:text>&#xA;    | commons    = </xsl:text>
    <xsl:text>&#xA;    | commonscat = </xsl:text>
    <xsl:text>&#xA;    | wikiquote  = </xsl:text>
    <xsl:text>&#xA;    | wikinews   = </xsl:text>
    <xsl:text>&#xA;    | wiktionary = </xsl:text>
    <xsl:text>&#xA;    | wikibooks  = </xsl:text>
    <xsl:text>&#xA;    | wikiversity= </xsl:text>
    <xsl:text>&#xA;    | wikispecies= </xsl:text>
    <xsl:text>&#xA;    | wikivoyage = </xsl:text>
    <xsl:text>&#xA;    | wikidata   = </xsl:text>
    <xsl:text>&#xA;    | wikilivres = </xsl:text>
    <xsl:text>&#xA;    | meta       = </xsl:text>
    <xsl:text>&#xA;    | notes      = </xsl:text>
    <xsl:text>&#xA;}}&#xA;</xsl:text>
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
      <xsl:text>''</xsl:text>
      <!-- italics -->
      <xsl:apply-templates select="journal-meta//journal-title[1]"/>
      <xsl:text>''</xsl:text>
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:if test="journal-meta//journal-title and (article-meta/volume | article-meta/issue)">
      <xsl:text>, </xsl:text>
    </xsl:if>
    <xsl:if test="article-meta/volume">
      <xsl:text>vol. </xsl:text>
      <xsl:value-of select="article-meta/volume[1]"/>
    </xsl:if>
    <xsl:if test="article-meta/volume and article-meta/issue">
      <xsl:text>, </xsl:text>
    </xsl:if>
    <xsl:if test="article-meta/issue">
      <xsl:text>iss. </xsl:text>
      <xsl:value-of select="article-meta/isse[1]"/>
    </xsl:if>
    <xsl:if test="( journal-meta//journal-title | article-meta/volume | article-meta/issue ) and 
                  ( article-meta/fpage | article-meta/lpage | article-meta/page-range )">
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
    <xsl:text>&#xA;</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="body">
    <xsl:apply-templates select="p"/>
    <xsl:apply-templates select="sec"/>
    <!--    
      fixme: look into what this is    
      <xsl:apply-templates select="sig-block"/>
    -->
  </xsl:template>

  <xsl:template match="sec|ack|app">
    <xsl:if test="title!=''">
      <xsl:call-template name="CreateHeading"/>
    </xsl:if>
    <xsl:apply-templates select="*[not(self::title)]"/>
  </xsl:template>

  <xsl:template match="sec/p">
    <!-- extra newline between paragraphs in wiki markup. -->
    <xsl:text>&#xA;&#xA;</xsl:text>
    <xsl:apply-templates/>

    <!--
      See issue #23.  This should handle figures that are referenced from the text, but that
      appear inside <floats-group> at the end of the article.  Only process them the first time
      they are referenced. 
    -->
    <xsl:for-each select='xref[@ref-type="fig"]'>
      <xsl:variable name="rid" select="@rid"/>
      <xsl:if
        test='not(preceding::xref[@ref-type="fig" and @rid=$rid]) and
                          //floats-group/fig[@id=$rid]'>
        <xsl:apply-templates select="//fig[@id=$rid]"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>


  <!-- *****WIKIMEDIA TAGGING***** -->


  <!-- ***FORMATTING*** -->
  <xsl:template match="italic">
    <xsl:text>''</xsl:text>
    <xsl:apply-templates mode="inline"/>
    <xsl:text>''</xsl:text>
  </xsl:template>

  <!-- 
    Trying to fix #24.  Whitespace handling is a Hard Problem.  This hack attempts to identify
    those elements that should be transformed in "inline" mode.  In this mode:
    - text nodes are whitespace normalized, with the catch that whitespace-only nodes are
      converted into single spaces
    - the `inline` mode should get passed along to descendent nodes as processing continues.
  -->
  <xsl:template match="text()" mode="inline">
    <xsl:variable name="ns" select="normalize-space(.)"/>
    <!-- Convert whitespace-only nodes into single spaces -->
    <xsl:choose>
      <xsl:when test="$ns = '' and $ns != .">
        <xsl:text> </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$ns"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="@*|*" mode="inline">
    <xsl:choose>
      <xsl:when test="self::named-content">
        <xsl:apply-templates select="*|text()" mode="inline"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="title" mode="inline">
    <xsl:apply-templates mode="inline"/>
  </xsl:template>

  <xsl:template match="bold">
    <xsl:text>'''</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>'''</xsl:text>
  </xsl:template>

  <!-- Replaces <br/> tag with newline character, to be rendered by mediawiki  -->
  <xsl:template match="break">&amp;#xA;</xsl:template>

  <xsl:template match="underline">
    <xsl:text> &amp;lt;span style="text-decoration: underline;"&amp;gt;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&amp;lt;/span&amp;gt; </xsl:text>
  </xsl:template>
  
  <xsl:template match="underline-start">
    <!-- 
      double-escape the entity refs so the resulting XML contains '&lt;' instead 
      of '<' and therefore remains well-formed 
    -->
    &amp;lt;span style="text-decoration: underline;"&amp;gt; 
  </xsl:template>
  
  <xsl:template match="underline-end">
    <xsl:text> &amp;lt;/span&amp;gt; </xsl:text>
  </xsl:template>

  <xsl:template match="strike">
    <xsl:text>&lt;del></xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&lt;/del></xsl:text>
  </xsl:template>

  <xsl:template match="monospace">
    <xsl:text>&lt;code></xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&lt;/code></xsl:text>
  </xsl:template>

  <xsl:template match="preformat">
    <xsl:text>&lt;pre></xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&lt;/pre></xsl:text>
  </xsl:template>

  <xsl:template match="disp-quote">
    <xsl:text>&lt;blockquote></xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&lt;/blockquote></xsl:text>
  </xsl:template>

  <xsl:template match="attrib">
    <br/>
    <xsl:apply-templates/>
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
    <xsl:value-of select="local-name()"/>
    <xsl:for-each select="@*">
      <xsl:text> </xsl:text>
      <xsl:value-of select="local-name()"/>
      <xsl:text> = "</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>"</xsl:text>
    </xsl:for-each>
    <xsl:text>&gt; </xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&lt;/</xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:text>&gt; </xsl:text>
  </xsl:template>

  <!-- ***LINKS*** -->
  <!-- 
    Note on <email>: "If both a textual phrase (“the Moody Institute’s email address”) and a mailto 
    URL are required, the <ext-link> element should be used."
    (http://jats.nlm.nih.gov/archiving/tag-library/0.4/index.html?elem=email) 
  -->
  <xsl:template match="ext-link|uri|self-uri">
    <xsl:variable name="href"
      select='str:replace(str:replace(@xlink:href, "&lt;", "%3C"), "&gt;", "%3E")'/>
    <xsl:choose>
      <!-- test for internal link -->
      <xsl:when test="contains($href, $wikiLinkBase1)">
        <xsl:text>[[</xsl:text>
        <xsl:value-of select="translate(substring-after($href, $wikiLinkBase1), '_', ' ')"/>
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
      <xsl:when test="contains($href, $wikiLinkBase2)">
        <xsl:text>[[</xsl:text>
        <xsl:value-of select="translate(substring-after($href, $wikiLinkBase2), '_', ' ')"/>
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
      <xsl:otherwise>
        <!-- external link -->
        <xsl:text>[</xsl:text>
        <xsl:value-of select="$href"/>
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

  <!-- fixme: anchor links to section heads -->

  <!-- ***HEADINGS*** -->
  <xsl:template name="CreateHeading">
    <!-- context is <sec> -->
    <!-- newline for legibility -->
    <xsl:text>&#xA;</xsl:text>
    <xsl:call-template name="CreateHeadingTag"/>
    <xsl:apply-templates select="title" mode="inline"/>
    <xsl:call-template name="CreateHeadingTag"/>
    <!-- newline for legibility -->
    <xsl:text>&#xA;</xsl:text>
  </xsl:template>

  <!-- Determine depth of current sec to format wiki heading to same depth -->
  <xsl:template name="CreateHeadingTag">
    <xsl:text>=</xsl:text>
    <!-- Start at level 2 (level 1 is article title) -->
    <xsl:for-each select="ancestor-or-self::sec | ancestor-or-self::app | ancestor-or-self::ack |
                          ancestor-or-self::label[parent::table-wrap] | ancestor::abstract">
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
    <xsl:text>;</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="def" mode="HeadlessDefList">
    <xsl:text>: </xsl:text>
    <xsl:apply-templates/>
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
      <xsl:when test="name()='inline-graphic'"> <!-- also matches on inline equations -->
        <xsl:text>|frameless</xsl:text>
      </xsl:when>
      <xsl:when test="name(..)='disp-formula'">
        <xsl:text>|none</xsl:text> <!-- keeps image in original size; adds text in new line below image -->
      </xsl:when>
      <xsl:otherwise>
        <!-- in JATS 0.4, default value of position is 'float' -->
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


  <!--
    TABLES.
    The following is cribbed from jpub3-html.xsl v1.0, a module of the JATS Journal 
    Publishing 3.0 Preview Stylesheets. 

    Tables are already in XHTML, and need to be copied into the output
    as escaped markup.  See github issue #6.
  -->

  <xsl:template match="table | tr | th | td">
    <xsl:apply-templates select="." mode="serialize"/>
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
  
  <!-- 
    End tables excerpt 
  -->


  <!-- ***MORE TABLES*** -->
  <!-- handle elements within table-wrap -->
  <xsl:template match="table-wrap">
    <xsl:if test="label">
      <!-- create section heading for table itself, at the level of the parent <sec> +1 -->
      <xsl:text>&#xA;</xsl:text>
      <xsl:call-template name="CreateHeadingTag"/>
      <xsl:text>=</xsl:text>
      <xsl:apply-templates select="label" mode="table-wrap"/>
      <xsl:call-template name="CreateHeadingTag"/>
      <xsl:text>=</xsl:text>
    </xsl:if>

    <!-- fixme: is there a better way to format this? -->
    <xsl:if test="caption|object-id">
      <xsl:text>&#xA;</xsl:text>
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
  <xsl:template match="def-list[term-head|def-head]"> </xsl:template>


  <xsl:template match="supplementary-material">
    <xsl:text>&#xA;</xsl:text>
    <xsl:call-template name="CreateHeadingTag"/>
    <xsl:text>=</xsl:text>
    <xsl:choose>
      <xsl:when test="label!=''">
        <xsl:value-of select="label"/>
      </xsl:when>
      <xsl:when test="caption/title!=''">
        <xsl:value-of select="normalize-space(caption/title)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>Supplemental file</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="CreateHeadingTag"/>
    <xsl:text>=&#xA;</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

  <!-- skip, since we called this explicitly when writing the section head -->
  <xsl:template match="supplementary-material/label|supplementary-material/caption/title"/>



  <!-- ***FOOTNOTES & REFERENCES*** -->
  <!-- 
    NOTE: WikiMedia auto-wraps footnote links in square brackets; if the source data explicitly 
    wraps <xref> elements in square brackets, then you end up with some uglyu rendering like 
    '[[5]]'.  Since the outside brackets are CDATA children of the xref's parent element, and 
    xref is in the content model for a wide array of elements, scrubbing out those outside square 
    brackets is very difficult (impossible?) in XSLT.  
  -->

  <!-- 
    Using Wikipedia List-defined references (see: 
    http://en.wikipedia.org/wiki/Help:List-defined_references ) to reflect JATS/NLM document structure 
  -->
  <!-- The ref to the footnote -->
  <xsl:template match="xref">
    <xsl:variable name="rid">
      <xsl:value-of select="@rid"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="//ref[@id=$rid]">
        <!-- escaping xml tags -->
        <xsl:text>&lt;ref name="</xsl:text>
        <xsl:value-of select="$rid"/>
        <xsl:text>"&gt;</xsl:text>
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
    <xsl:text>&#xA;== </xsl:text>
    <xsl:choose>
      <xsl:when test="title!=''">
        <xsl:value-of select="title"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>References</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text> ==&#xA;</xsl:text>
    <xsl:text>&lt;references&gt;</xsl:text>
    <xsl:apply-templates select="*[not(self::title)]"/>
    <xsl:text>&lt;/references&gt;</xsl:text>
  </xsl:template>

  <xsl:template match="ref">
    <xsl:variable name="refID">
      <xsl:choose>
        <xsl:when test="@id!=''">
          <xsl:value-of select="@id"/>
        </xsl:when>
        <!-- 
          Best practice dictates <ref> will have @id, but the DTD permits the @id to be on the 
          child citation as well.  DTD also permits more than one citation per <ref>.  
          Since we need an id to point to, grab the @id from the first child element of <ref> 
          that isn't <label> or <x>. 
        -->
        <xsl:otherwise>
          <xsl:value-of select="child::*[not(name(label|x))][1]/@id"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!-- QUESTION: better to let the error display, or suppress and fail quietly? -->
    <!-- Test that there's a link to this footnote; if not, Wiki will display an error, so don't bother. -->
    <xsl:if test="//xref[@rid=$refID]">
      <xsl:text>&lt;ref name="</xsl:text>
      <xsl:value-of select="$refID"/>
      <xsl:text>"&gt;</xsl:text>
      <xsl:apply-templates select="citation|element-citation|mixed-citation|nlm-citation"/>
      <xsl:text>&lt;/ref&gt;</xsl:text>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
  </xsl:template>

  <!--
    Using Template:Citation-wpoa ( http://en.wikipedia.org/wiki/Template:Citation-wpoa ),
    which is, for the most part, a proxy of Tempate:Citation/core.
  -->
  <xsl:template match="citation | element-citation | mixed-citation | nlm-citation">
    <xsl:text>{{citation-wpoa&#xA;</xsl:text>

    <!-- fixme: attempt to differentiate editors from authors?  JATS/NLM tagset is not reliable for this -->
    <xsl:for-each select="string-name | person-group/string-name">
      <xsl:text>| author</xsl:text>
      <xsl:value-of select="position()"/>
      <xsl:text> = </xsl:text>
      <xsl:apply-templates/>
    </xsl:for-each>

    <xsl:for-each select="name | person-group/name">
      <xsl:text>| Surname</xsl:text>
      <xsl:value-of select="position()"/>
      <xsl:text> = </xsl:text>
      <xsl:value-of select="surname"/>
      <xsl:text>&#xA;</xsl:text>
      <xsl:text>| Given</xsl:text>
      <xsl:value-of select="position()"/>
      <xsl:text> = </xsl:text>
      <xsl:value-of select="given-names"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:for-each>

    <!-- FIXME:  what is this? "coauthors" is not among the Citation/core parameters. -->
    <xsl:for-each select="descendant::collab">
      <xsl:text>| coauthors = </xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:for-each>

    <!-- PUBLICATION DATES : be careful not to get other dates that can appear in citations, which use same tags-->
    <xsl:if test="year | date/year">
      <xsl:text>| Year = </xsl:text>
      <xsl:value-of select="year | date/year"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>

    <xsl:if test="month | date/month">
      <xsl:text>| month = </xsl:text>
      <xsl:value-of select="month|date/month"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
    
    <xsl:if test="string-date">
      <xsl:text>| date = </xsl:text>
      <xsl:value-of select="string-date"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
    
    <!-- OTHER DATES -->
    <xsl:for-each
      select="date-in-citation[contains(@content-type, 'access|stamp')]|access-date|time-stamp">
      <xsl:text>| accessdate = </xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:for-each>
    <xsl:for-each select="date-in-citation[contains(@content-type, 'copyright')]">
      <xsl:text>| origyear = </xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:for-each>

    <!-- TITLE -->
    <xsl:choose>
      <!-- ARTICLE -->
      <xsl:when test="article-title">
        <xsl:text>| Title = </xsl:text>
        <xsl:apply-templates select="article-title"/>
        <xsl:text>&#xA;</xsl:text>

        <xsl:if test="source">
          <xsl:text>| Periodical = </xsl:text>
          <xsl:apply-templates select="source"/>
          <xsl:text>&#xA;</xsl:text>
        </xsl:if>
        <xsl:if test="trans-title">
          <xsl:text>| trans_title = </xsl:text>
          <xsl:apply-templates select="trans-title"/>
          <xsl:text>&#xA;</xsl:text>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="source">
          <xsl:text>| title = </xsl:text>
          <xsl:apply-templates select="source"/>
          <xsl:text>&#xA;</xsl:text>
        </xsl:if>
        <xsl:if test="trans-source">
          <xsl:text>| trans_title = </xsl:text>
          <xsl:apply-templates select="trans-title"/>
          <xsl:text>&#xA;</xsl:text>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="chapter-title">
      <xsl:text>| chapter = </xsl:text>
      <xsl:apply-templates select="chapter"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>

    <!-- ISSUE -->
    <xsl:if test="issue">
      <xsl:text>| Issue = </xsl:text>
      <xsl:apply-templates select="issue"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
    <xsl:if test="volume">
      <xsl:text>| Volume = </xsl:text>
      <xsl:apply-templates select="volume"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
    <xsl:if test="publisher-name">
      <xsl:text>| publisher = </xsl:text>
      <xsl:apply-templates select="publisher-name"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
    <xsl:if test="publisher-loc">
      <xsl:text>| location = </xsl:text>
      <xsl:apply-templates select="publisher-loc"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
    <xsl:if test="series">
      <xsl:text>| series = </xsl:text>
      <xsl:apply-templates select="series"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
    <xsl:if test="edition">
      <xsl:text>| edition = </xsl:text>
      <xsl:apply-templates select="edition"/>
      <xsl:text>&#xA;</xsl:text>
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
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>

    <!-- PAGES -->
    <xsl:choose>
      <xsl:when test="page-range">
        <xsl:text>| At = </xsl:text>
        <xsl:apply-templates select="page-range"/>
        <xsl:text>&#xA;</xsl:text>
      </xsl:when>
      <xsl:when test="fpage and lpage">
        <xsl:text>| At = </xsl:text>
        <xsl:value-of select="fpage"/>
        <xsl:text>–</xsl:text>
        <xsl:value-of select="lpage"/>
        <xsl:text>&#xA;</xsl:text>
      </xsl:when>
      <xsl:when test="fpage and not(lpage)">
        <xsl:text>| At = </xsl:text>
        <xsl:apply-templates select="fpage"/>
        <xsl:text>&#xA;</xsl:text>
      </xsl:when>
      <xsl:when test="elocation-id">
        <xsl:text>| At = </xsl:text>
        <xsl:apply-templates select="elocation-id"/>
        <xsl:text>&#xA;</xsl:text>
      </xsl:when>
    </xsl:choose>

    <!-- URIs -->
    <xsl:choose>
      <xsl:when test="@xlink:href">
        <xsl:text>| url = </xsl:text>
        <xsl:apply-templates select="@xlink:href"/>
        <xsl:text>&#xA;</xsl:text>
      </xsl:when>

      <!-- Avoid redundancy with specific ID fields below-->
      <xsl:when test="ext-link[not(@ext-link-type='doi' or @ext-link-type='pmcid' or
                                   @ext-link-type='pmid' or
                                   starts-with(@xlink:href, 'http://dx.doi.org/'))]">
        <xsl:text>| url = </xsl:text>
        <xsl:apply-templates select="ext-link"/>
        <xsl:text>&#xA;</xsl:text>
      </xsl:when>
      <xsl:when test="uri">
        <xsl:text>| url = </xsl:text>
        <xsl:apply-templates select="uri"/>
        <xsl:text>&#xA;</xsl:text>
      </xsl:when>
    </xsl:choose>


    <!-- IDENTIFIERS -->

    <xsl:if test="issn">
      <xsl:text>| issn = </xsl:text>
      <xsl:apply-templates select="issn"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>

    <xsl:if test="isbn">
      <xsl:text>| isbn = </xsl:text>
      <xsl:apply-templates select="isbn"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
    
    <xsl:choose>
      <xsl:when test="pub-id[@pub-id-type='doi']">
        <xsl:text>| DOI = </xsl:text>
        <xsl:apply-templates select="pub-id[@pub-id-type='doi']"/>
        <xsl:text>&#xA;</xsl:text>
      </xsl:when>
      <xsl:when test="ext-link[@ext-link-type='doi']">
        <xsl:text>| DOI = </xsl:text>
        <xsl:apply-templates select="ext-link[@ext-link-type='doi']"/>
        <xsl:text>&#xA;</xsl:text>
      </xsl:when>
      <xsl:when test="ext-link[starts-with(., 'http://dx.doi.org/')]">
        <xsl:text>| DOI = </xsl:text>
        <xsl:apply-templates select="ext-link[starts-with(@xlink:href, 'http://dx.doi.org/')]"/>
        <xsl:text>&#xA;</xsl:text>
      </xsl:when>
    </xsl:choose>

    <xsl:choose>
      <xsl:when test="pub-id[@pub-id-type='pmcid']">
        <xsl:text>| PMC = </xsl:text>
        <xsl:apply-templates select="pub-id[@pub-id-type='pmcid']"/>
        <xsl:text>&#xA;</xsl:text>
      </xsl:when>
      <xsl:when test="ext-link[@ext-link-type='pmcid']">
        <xsl:text>| PMC = </xsl:text>
        <xsl:apply-templates select="ext-link[@ext-link-type='pmcid']"/>
        <xsl:text>&#xA;</xsl:text>
      </xsl:when>
    </xsl:choose>

    <xsl:choose>
      <xsl:when test="pub-id[@pub-id-type='pmid']">
        <xsl:text>| PMID = </xsl:text>
        <xsl:apply-templates select="pub-id[@pub-id-type='pmid']"/>
        <xsl:text>&#xA;</xsl:text>
      </xsl:when>
      <xsl:when test="ext-link[@ext-link-type='pmid']">
        <xsl:text>| PMID = </xsl:text>
        <xsl:apply-templates select="ext-link[@ext-link-type='pmid']"/>
        <xsl:text>&#xA;</xsl:text>
      </xsl:when>
    </xsl:choose>

    <!-- default catch-all id -->
    <xsl:if test="pub-id[not(@pub-id-type='doi' or @pub-id-type='pmcid' or
                             @pub-id-type='pmid')]">
      <xsl:text>| ID = </xsl:text>
      <xsl:apply-templates select="pub-id"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>

    <!-- MISCELLANIA -->
    <xsl:if test="patent">
      <xsl:text>| patent-number = </xsl:text>
      <xsl:apply-templates select="patent"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>

    <!-- 
      UNFORMATTED CITATION BITS 
      i.e. everything else.
      NOTE: We might want to further prune the elements that 
      will be output here if things get too sloppy;
      or perhaps only target <comment> and <annotation>?
      These should come at the end of the ref block, which is why
      we don't do a generic <apply-templates select="*"/>for these
      and the cases handled above, as that would output 
      all elements in document order.
    -->
    <xsl:apply-templates 
      select="*[not(self::string-name | self::person-group | self::date | self::year |
                    self::month | self::string-date | self::date-in-citation | self::article-title |
                    self::source | self::trans-title | self::trans-source | self::chapter-title |
                    self::issue | self::volume | self::publisher-name | self::publisher-loc | 
                    self::series | self::edition | self::page-range | self::fpage | self::lpage |
                    self::elocation-id | self::ext-link | self::uri | self::issn | self::isbn |
                    self::pub-id | self::patent)]"/>

    <!-- close citations block -->
    <xsl:text>&#xA;}}&#xA;</xsl:text>
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
      <xsl:text>&#xA;{{</xsl:text>
      <!-- attempt to match the URI to an appropriate template -->
      <!-- FIXME:  why do the outputs of these differ by case? -->
      <xsl:choose>
        <xsl:when test="contains($licenseURI, 'creativecommons.org/licenses/by/2.0')"
          >CC-BY-2.0</xsl:when>
        <xsl:when test="contains($licenseURI, 'creativecommons.org/licenses/by/2.5')"
          >CC-BY-2.5</xsl:when>
        <xsl:when test="contains($licenseURI, 'creativecommons.org/licenses/by/3.0/au')"
          >CC-by-3.0-au</xsl:when>
        <xsl:when test="contains($licenseURI, 'creativecommons.org/licenses/by/3.0/us')"
          >CC-by-3.0-us</xsl:when>
        <xsl:when test="contains($licenseURI, 'creativecommons.org/licenses/by/3.0')"
          >Cc-by-3.0</xsl:when>
        <xsl:when test="contains($licenseURI, 'creativecommons.org/licenses/by/4.0')"
          >CC-BY-4.0</xsl:when>
        <xsl:when test="contains($licenseURI, 'creativecommons.org/licenses/by-sa/2.0')"
          >CC-BY-SA-2.0</xsl:when>
        <xsl:when test="contains($licenseURI, 'creativecommons.org/licenses/by-sa/3.0/us/')"
          >CC-by-sa-3.0-us</xsl:when>
        <xsl:when test="contains($licenseURI, 'creativecommons.org/licenses/by-sa/3.0')"
          >CC-BY-SA-3.0</xsl:when>
        <xsl:when test="contains($licenseURI, 'creativecommons.org/licenses/by-sa/4.0')"
          >CC-BY-SA-4.0</xsl:when>
      </xsl:choose>
      <xsl:text>}}</xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- Fix #12 - special cases with brackets around xrefs.  They must be removed. -->
  <xsl:template priority="2"
    match='text()[substring(., 1, 1) = "]" and 
                                preceding-sibling::*[1][self::xref] and
                                substring(., string-length(.), 1) = "[" and
                                following-sibling::*[1][self::xref]]'>
    <xsl:value-of select="substring(., 2, string-length(.) - 2)"/>
  </xsl:template>
  <xsl:template priority="1"
    match='text()[substring(., 1, 1) = "]" and 
                                preceding-sibling::*[1][self::xref]]'>
    <xsl:value-of select="substring(., 2)"/>
  </xsl:template>
  <xsl:template priority="1"
    match='text()[substring(., string-length(.), 1) = "[" and 
                                following-sibling::*[1][self::xref]]'>
    <xsl:value-of select="substring(., 1, string-length(.) - 2)"/>
  </xsl:template>

  <!-- fixme: include table-wrap-foot -->


  <!-- fixme: Notes section -->

</xsl:stylesheet>
