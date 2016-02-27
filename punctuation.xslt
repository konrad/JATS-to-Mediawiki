<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xlink="http://www.w3.org/1999/xlink"
		extension-element-prefixes="xlink">



	<xsl:template name="fix-punct">
		<xsl:param name="punct"/>
		<xsl:param name="last"/>
		<xsl:choose>
			<xsl:when test="substring(following-sibling::node()[1],1,1) = normalize-space($punct)"/>
			<xsl:when test="contains('.', translate(substring(following-sibling::node()[1],1,1), '!?;:-+,', '.......'))"/>
			<!--xsl:when test="contains($punct,$last)"/-->
			<xsl:when test="$last = '@#x00021;'"/><!-- ! -->
			<xsl:when test="$last = '@#x0003f;'"/><!-- ? -->
			<xsl:when test="$last = '@#x0003b;'"/><!-- ; -->
			<xsl:when test="$last = '@#x0003a;'"/><!-- : -->
			<xsl:when test="$last = '@#x0002d;'"/><!-- - -->
			<xsl:when test="$last = '@#x0002b;'"/><!-- + -->
			<xsl:when test="$last = '@#x0002c;'"/><!-- , -->
			<xsl:when test="contains('.', translate($last, '!?;:-+=,()[]$%/\{}', '..................'))"/>
			<xsl:otherwise>
				<xsl:value-of select="$punct"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:template>

	<xsl:template name="chk4punct">
			<xsl:if test="not(following-sibling::node()[position() = 1 and (name() = 'x' or name() = '')])"><xsl:text> </xsl:text></xsl:if>
		</xsl:template>


	</xsl:stylesheet>
