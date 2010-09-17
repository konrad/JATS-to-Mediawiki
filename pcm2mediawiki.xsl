<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- 

ABOUT
=====

Transforms PubMed Central's NLM Archiving and Interchange DTD 3.0 XML
(NXML) [1] into plain text with MediaWiki syntax [2].

[1] http://dtd.nlm.nih.gov/
[2] http://www.mediawiki.org/wiki/Help:Formatting


STATUS
======

"Experimental" would be an euphemism. Currently not really usable.

LICENSE
=======

Copyright (c) 2010, Konrad Förstner (konrad@foerstner.org)

Permission to use, copy, modify, and/or distribute this software for
any purpose with or without fee is hereby granted, provided that the
above copyright notice and this permission notice appear in all
copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR
PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
PERFORMANCE OF THIS SOFTWARE.  

-->

<!--
Todo:
=====

   * Publication detail
   * Copyright Statement
   * Authors
   * Supporting Material
   * Images
   * Acknowledgments
   * Footnotes
   * References
   * Font styles like 
   * Table
-->

<!-- Main -->
<xsl:output method="text" encoding="UTF-8"/>
<xsl:template match="/" name="main">
  <xsl:call-template name="base_data"/>
  <xsl:call-template name="authors"/>
  <xsl:call-template name="abstract"/>
  <xsl:call-template name="sections"/>
  <xsl:call-template name="references"/>
</xsl:template>

<!-- Article title and basic data -->
<xsl:template match="/" name="base_data">
= <xsl:value-of select="//article-title"/> =

''<xsl:value-of select="//journal-title"/>'', <xsl:value-of select="//pub-date"/>;(<xsl:value-of select="//volume"/>)<xsl:value-of select="//issue"/>:<xsl:value-of select="//elocation-id"/>
<xsl:text>&#10;&#10;</xsl:text> 
</xsl:template>

<!-- Author list -->
<!-- WIP: Make sure that this only finds the <contrib contrib-type="author"> -->
<xsl:template match="//contrib-group" name="authors">
  <!-- WIP: Replace with list join? -->
  <xsl:for-each select="//contrib"> <xsl:value-of select="name/given-names"/>&#160;<xsl:value-of select="name/surname"/>, </xsl:for-each>
  <xsl:text>&#10;&#10;</xsl:text> 
</xsl:template>

<!-- Abstract -->
<xsl:template match="/" name="abstract">
== Abstract == 
<xsl:value-of select="//abstract"/>
</xsl:template>

<!-- The sections -->
<xsl:template match="/" name="sections">
  <xsl:for-each select=".//sec">
== <xsl:value-of select="title" /> ==
    <xsl:for-each select="p">
      <xsl:value-of select="." />
<xsl:text>

</xsl:text> 
    </xsl:for-each>
  </xsl:for-each>
</xsl:template>

<!-- References  -->
<xsl:template match="/ref-list" name="references">
  <xsl:for-each select=".//ref">
    <xsl:value-of select="label" />. <xsl:value-of select=".//article-title" /> <xsl:value-of select=".//article-title" />

    <!-- WIP: destinguish between different types of references 
    <xsl:if test="citation-type='journal'">
    </xsl:if>
    <xsl:if test="citation-type='book'">
    </xsl:if>
    -->
    <xsl:text>

</xsl:text> 
    
  </xsl:for-each>

</xsl:template>

<xsl:template match="/">
  <xsl:call-template name="main"/>  
</xsl:template>

</xsl:stylesheet>


