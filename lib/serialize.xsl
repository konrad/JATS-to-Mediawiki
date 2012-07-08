<!--
     XSLT 1.0 serializer for XML.
     
     Adapted from serializer by Hermann Stamm-Wilbrandt, as described in this thread:
     http://www.biglist.com/lists/lists.mulberrytech.com/xsl-list/archives/201008/msg00186.html
     and downloaded from http://stamm-wilbrandt.de/en/xsl-list/serialize/serialize.xsl.
     
     [CFM] Changes for JATS-To-Mediawiki:
       - Removed stuff not used, doOutput template, namespaces, comments, pi's, etc.
       - Changed mode name from "output" to "serialize".
       - Change the recursion mechanism.  Now, it doesn't recurse with the mode 'serialize';
         instead, it applies the default (no mode) template to all the children of an element.  
         This way, the importing stylesheet must explicitly specify those elements it wants to 
         serialize.
       - The mechanism for serializing text nodes is kept, but I don't think it will ever be
         used.  From my experiments, it looks like it's unnecessary almost all of the time,
         but on the other hand, doesn't do any harm.
-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="@*" mode="serialize">
    <xsl:value-of select="concat(' ',name(),'=&quot;',.,'&quot;')"/>
  </xsl:template>

  <!-- Only serialize certain table elements, not everything -->

  <xsl:template match="node()" mode="serialize">
    <xsl:value-of select="concat('&lt;',name())"/>
    <xsl:apply-templates select="@*" mode="serialize"/>

    <xsl:choose>
      <xsl:when test="*|text()">
        <xsl:text>></xsl:text>
        <xsl:apply-templates select="*|text()"/>
        <xsl:value-of select="concat('&lt;/',name(),'>')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>/></xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="text()" mode="serialize">
    <xsl:call-template name="escapeLtGtAmp">
      <xsl:with-param name="str" select="."/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="escapeLtGtAmp">
    <xsl:param name="str"/>

    <xsl:choose>
      <xsl:when test="contains($str,'&lt;') or 
                      contains($str,'&gt;') or
                      contains($str,'&amp;')">
        <xsl:variable name="lt" 
          select="substring-before(concat($str,'&lt;'),'&lt;')"/>
        <xsl:variable name="gt" 
          select="substring-before(concat($str,'&gt;'),'&gt;')"/>
        <xsl:variable name="amp" 
          select="substring-before(concat($str,'&amp;'),'&amp;')"/>

        <xsl:choose>
          <xsl:when test="string-length($gt) > string-length($amp)">
            <xsl:choose>
              <xsl:when test="string-length($amp) > string-length($lt)">
                <xsl:value-of 
                  select="concat(substring-before($str,'&lt;'),'&amp;lt;')"/>
    
                <xsl:call-template name="escapeLtGtAmp">
                  <xsl:with-param name="str" 
                    select="substring-after($str,'&lt;')"/>
                </xsl:call-template>
              </xsl:when>
    
              <xsl:otherwise>
                <xsl:value-of 
                  select="concat(substring-before($str,'&amp;'),'&amp;amp;')"/>
    
                <xsl:call-template name="escapeLtGtAmp">
                  <xsl:with-param name="str" 
                    select="substring-after($str,'&amp;')"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>

          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="string-length($gt) > string-length($lt)">
                <xsl:value-of 
                  select="concat(substring-before($str,'&lt;'),'&amp;lt;')"/>
    
                <xsl:call-template name="escapeLtGtAmp">
                  <xsl:with-param name="str" 
                    select="substring-after($str,'&lt;')"/>
                </xsl:call-template>
              </xsl:when>
    
              <xsl:otherwise>
                <xsl:value-of 
                  select="concat(substring-before($str,'&gt;'),'&amp;gt;')"/>
    
                <xsl:call-template name="escapeLtGtAmp">
                  <xsl:with-param name="str" 
                    select="substring-after($str,'&gt;')"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <xsl:otherwise>
        <xsl:value-of select="$str"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
