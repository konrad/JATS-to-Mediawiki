<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY pd-sp '<xsl:call-template xmlns:xsl="http://www.w3.org/1999/XSL/Transform" name="fix-punct">
								<xsl:with-param name="punct">.</xsl:with-param>
								<xsl:with-param name="last" select="substring(.,string-length(.),1)"/>
								</xsl:call-template><xsl:text xmlns:xsl="http://www.w3.org/1999/XSL/Transform"> </xsl:text>'>

<!ENTITY pd '<xsl:call-template xmlns:xsl="http://www.w3.org/1999/XSL/Transform" name="fix-punct">
								<xsl:with-param name="punct">.</xsl:with-param>
								<xsl:with-param name="last" select="substring(.,string-length(.),1)"/>
								</xsl:call-template>'>

<!ENTITY cma-sp '<xsl:call-template xmlns:xsl="http://www.w3.org/1999/XSL/Transform" name="fix-punct">
								<xsl:with-param name="punct">,</xsl:with-param>
								<xsl:with-param name="last" select="substring(.,string-length(.),1)"/>
								</xsl:call-template><xsl:text xmlns:xsl="http://www.w3.org/1999/XSL/Transform"> </xsl:text>'>

<!ENTITY cma '<xsl:call-template xmlns:xsl="http://www.w3.org/1999/XSL/Transform" name="fix-punct">
								<xsl:with-param name="punct">,</xsl:with-param>
								<xsl:with-param name="last" select="substring(.,string-length(.),1)"/>
								</xsl:call-template>'>

<!ENTITY cln-sp '<xsl:call-template xmlns:xsl="http://www.w3.org/1999/XSL/Transform" name="fix-punct">
								<xsl:with-param name="punct">:</xsl:with-param>
								<xsl:with-param name="last" select="substring(.,string-length(.),1)"/>
								</xsl:call-template><xsl:text xmlns:xsl="http://www.w3.org/1999/XSL/Transform"> </xsl:text>'>

<!ENTITY cln '<xsl:call-template xmlns:xsl="http://www.w3.org/1999/XSL/Transform" name="fix-punct">
								<xsl:with-param name="punct">:</xsl:with-param>
								<xsl:with-param name="last" select="substring(.,string-length(.),1)"/>
								</xsl:call-template>'>

<!ENTITY semi-sp '<xsl:call-template xmlns:xsl="http://www.w3.org/1999/XSL/Transform" name="fix-punct">
								<xsl:with-param name="punct">;</xsl:with-param>
								<xsl:with-param name="last" select="substring(.,string-length(.),1)"/>
								</xsl:call-template><xsl:text xmlns:xsl="http://www.w3.org/1999/XSL/Transform"> </xsl:text>'>

<!ENTITY semi '<xsl:call-template xmlns:xsl="http://www.w3.org/1999/XSL/Transform" name="fix-punct">
								<xsl:with-param name="punct">;</xsl:with-param>
								<xsl:with-param name="last" select="substring(.,string-length(.),1)"/>
								</xsl:call-template>'>

<!ENTITY space '<xsl:call-template xmlns:xsl="http://www.w3.org/1999/XSL/Transform" name="chk4punct"/>'>



<!ENTITY break '<xsl:text xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
</xsl:text>'>

<!ENTITY l20    "====================">
<!ENTITY red-pipe  '<b style="color:red;">|</b>'>
]>

<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xlink="http://www.w3.org/1999/xlink"
		extension-element-prefixes="xlink">

	<!-- including string and whitespace management templates -->
	<xsl:include href="../../strings.xsl"/>
	<xsl:include href="../../whitespace.xsl"/>

	<!-- including a template to format untagged citations -->
	<xsl:include href="punctuation.xsl"/>
	<xsl:strip-space elements="element-citation nlm-citation"/>

	<!-- ######################################################        -->
	<xsl:template match="ref-list/ref">
		<xsl:param name="li-class"/>
		<li>
			<xsl:if test="string-length($li-class) &gt; 0">
				<xsl:attribute name="class"><xsl:value-of select="$li-class"/></xsl:attribute>
			</xsl:if>
			<xsl:call-template name="utils-generate-id-attr"/>
			<xsl:apply-templates select="." mode="back-ref"/>
		</li>
	</xsl:template>

	 <!-- ######################################################        -->
	<xsl:template match="ref">
		<div class="ref half_rhythm">
			<xsl:call-template name="utils-generate-id-attr"/>
			<xsl:apply-templates mode="back-ref"/>
		</div>
	</xsl:template>
        <!-- ######################################################        -->
	<xsl:template match="label" mode="back-ref"> <!-- this should change to CSS -->
			<strong>
			<xsl:if test="preceding-sibling::citation or preceding-sibling::nlm-citation or parent::*[preceding-sibling::citation or preceding-sibling::nlm-citation]">
				<xsl:text> </xsl:text>
				</xsl:if>
				 <xsl:apply-templates mode="back-ref"/>
			<xsl:choose>
				<xsl:when test="contains(.,')')">
					<xsl:text> </xsl:text>
					</xsl:when>
				<xsl:otherwise>
					&pd-sp;
					</xsl:otherwise>
					</xsl:choose>
			</strong>
		</xsl:template>

	 <!-- ######################################################        -->
	 <xsl:template match="citation-alternatives" name="ref-citation-alternatives" mode="back-ref">
		<xsl:choose>
			<xsl:when test="mixed-citation">
				<xsl:apply-templates select="mixed-citation" mode="back-ref"/>
			</xsl:when>
			<xsl:when test="nlm-citation">
				<xsl:apply-templates select="nlm-citation" mode="back-ref"/>
			</xsl:when>
			<xsl:when test="element-citation">
				<xsl:apply-templates select="element-citation" mode="back-ref"/>
			</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	 </xsl:template>
		
	 <!-- ==================================================================== -->
	 <!-- TEMPLATE: citation | nlm-citation; also name="refs-citation"
				NOTES:    If a citation is completely tagged, we will process it
		like an nlm-citation. If not, the text gets dumped with
		tagged elements formatted.
		 -->
	 <!-- ==================================================================== -->
	 <xsl:template match="citation | element-citation | mixed-citation | nlm-citation"
		 name="refs-citation" mode="back-ref">
		<!--xsl:call-template name="utils-class-name-attr"/-->
		<span>
			<xsl:call-template name="utils-class-name-attr"/>
			<xsl:apply-templates select="@id" mode="id-attr"/>
			<xsl:call-template name="refs-citation-inline"/>
		</span>
		<xsl:if test="position() != last() and parent::ref"><br/></xsl:if>
	 </xsl:template>
	 <!-- ==================================================================== -->
	 <xsl:template 	name="refs-citation-inline">
		<xsl:if test="not(following-sibling::*[self::citation or self::element-citation 
							or self::mixed-citation or self::nlm-citation]
						      [@citation-type='display-unstructured'])">
			<xsl:choose>
				<xsl:when test="text()[not(normalize-space(.) = '')] | italic | bold | monospace | overline | overline-start
					| overline-end | roman | sc | strike | styled-content | sub | sup
					| underline | underline-start | underline-end | x">
					<xsl:call-template name="citation-dump"/>
					</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="nlm-citation"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:call-template name="back-ref-pmc-full-text-link">
					<xsl:with-param name="id" select="ancestor-or-self::*[@id][self::ref or self::mixed-citation or self::citation or self::element-citation or self::nlm-citation][1]/@id"/>
				</xsl:call-template>
		</xsl:if>
	</xsl:template>
	 <!-- ==================================================================== -->
	 <!-- TEMPLATE: nlm-citation
				NOTES:    Switch on basic type, and issue all the relevant data.
		 -->
	 <!-- ==================================================================== -->
	 <xsl:template name="nlm-citation">
		<xsl:variable name="augroupcount" select="count(person-group) + count(collab)"/>

		<xsl:apply-templates select="label" mode="back-ref"/>
		<xsl:choose>

<!-- CONFERENCE PROCEEDINGS -->
				 <xsl:when test="@citation-type='confproc' or @publication-type='confproc'
					 or conf-name or conf-date or conf-loc or conf-sponsor">
						<xsl:choose>
							 <xsl:when test="$augroupcount>1 and person-group[@person-group-type!='author']">
									<xsl:apply-templates select="person-group[@person-group-type='author']" mode="book"/>
									<xsl:apply-templates select="collab" mode="back-ref"/>
									<xsl:apply-templates select="article-title | chapter-title" mode="inconf"/>
									<xsl:text>In: </xsl:text>
									<xsl:apply-templates select="person-group[@person-group-type='editor']
										 | person-group[@person-group-type='allauthors']
										 | person-group[@person-group-type='translator']
										 | person-group[@person-group-type='transed'] " mode="book"/>
									<xsl:apply-templates select="source" mode="conf"/>
									<xsl:apply-templates select="conf-name | conf-date | conf-loc" mode="conf"/>
									<xsl:apply-templates select="publisher-loc" mode="back-ref"/>
									<xsl:apply-templates select="publisher-name" mode="back-ref"/>
									<xsl:apply-templates select="year | month | time-stamp | season | access-date | date-in-citation"
										mode="book"/>
									<xsl:apply-templates select="fpage | lpage | elocation-id | size" mode="book"/>
							 </xsl:when>
							 <xsl:otherwise>
									<xsl:apply-templates select="person-group" mode="book"/>
									<xsl:apply-templates select="collab" mode="back-ref"/>
									<xsl:apply-templates select="article-title | chapter-title" mode="conf"/>
									<xsl:apply-templates select="source" mode="conf"/>
									<xsl:apply-templates select="conf-name | conf-date | conf-loc" mode="conf"/>
									<xsl:apply-templates select="publisher-loc" mode="back-ref"/>
									<xsl:apply-templates select="publisher-name" mode="back-ref"/>
									<xsl:apply-templates select="year | month | time-stamp | season | access-date | date-in-citation"
										mode="book"/>
									<xsl:apply-templates select="fpage | lpage | elocation-id | size" mode="book"/>
							 </xsl:otherwise>
						</xsl:choose>
				 </xsl:when>

<!-- BOOK or BOOKLIKE things -->
				 <xsl:when test="@citation-type='book' or @citation-type='thesis'
					 or @publication-type='book' or @publication-type='thesis'">
						<xsl:choose>
							 <xsl:when test="$augroupcount>1 and person-group[@person-group-type!='author'] and article-title
								 or $augroupcount>1 and person-group[@person-group-type!='author'] and chapter-title">
						<xsl:variable name="_authors">
							<xsl:apply-templates select="person-group[@person-group-type='author'
								or not(@person-group-type)]" mode="book"/>
							</xsl:variable>
						<xsl:if test="string-length($_authors) &gt; 0">
							<xsl:call-template name="utils-put-missing-period">
								<xsl:with-param name="input-str" select="$_authors"/>
							</xsl:call-template>
							<xsl:text> </xsl:text>
						</xsl:if>
									<xsl:apply-templates select="collab" mode="back-ref"/>
									<xsl:apply-templates select="article-title | chapter-title" mode="editedbook"/>
									<xsl:text>In: </xsl:text>
									<xsl:apply-templates select="person-group[@person-group-type='editor']
																						 | person-group[@person-group-type='allauthors']
																						 | person-group[@person-group-type='translator']
																						 | person-group[@person-group-type='transed'] " mode="book"/>
									<xsl:apply-templates select="source" mode="book"/>
									<xsl:apply-templates select="edition|issue" mode="book"/>
									<xsl:apply-templates select="volume" mode="book"/>
									<xsl:apply-templates select="trans-source" mode="book"/>
									<xsl:apply-templates select="publisher-name | publisher-loc" mode="back-ref"/>
									<xsl:apply-templates select="year | month | time-stamp | season | access-date | date-in-citation"
										mode="book"/>
									<xsl:apply-templates select="fpage | lpage | elocation-id | page-count | size | ext-link" mode="book"/>
							 </xsl:when>
							 <xsl:when test="person-group[@person-group-type='author']
											or person-group[@person-group-type='compiler']
											or name">
								<xsl:variable name="_authors">
									<xsl:apply-templates select="person-group[@person-group-type='author']
																		 | person-group[@person-group-type='compiler']
																		 | name" mode="book"/>
									<xsl:apply-templates select="collab" mode="back-ref"/>
									</xsl:variable>
								<xsl:if test="string-length($_authors) &gt; 0">
									<xsl:call-template name="utils-put-missing-period">
										<xsl:with-param name="input-str" select="$_authors"/>
									</xsl:call-template>
									<xsl:text> </xsl:text>
								</xsl:if>
								 <xsl:if test="person-group[@person-group-type!='author']">
									 <xsl:text>In: </xsl:text>
								 </xsl:if>
									<xsl:apply-templates select="source" mode="book"/>
									<xsl:apply-templates select="edition|issue" mode="book"/>
									<xsl:apply-templates select="person-group[@person-group-type='editor']
																						 | person-group[@person-group-type='translator']
																						 | person-group[@person-group-type='transed'] " mode="book"/>
									<xsl:apply-templates select="volume" mode="book"/>
									<xsl:apply-templates select="trans-source" mode="book"/>
									<xsl:apply-templates select="publisher-name | publisher-loc" mode="back-ref"/>
									<xsl:apply-templates select="year | month | time-stamp | season | access-date | date-in-citation"
										mode="book"/>
									<xsl:apply-templates select="article-title | chapter-title | fpage | lpage | elocation-id | page-count | size | ext-link" mode="book"/>
							 </xsl:when>
							 <xsl:otherwise>
						<xsl:choose>
							<xsl:when test="person-group[@person-group-type]">
								<xsl:apply-templates select="person-group[@person-group-type='editor']
																						 | person-group[@person-group-type='translator']
																						 | person-group[@person-group-type='transed']
																						 | person-group[@person-group-type='guest-editor']" mode="book"/>
								</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="person-group | name" mode="book"/>
								</xsl:otherwise>
							</xsl:choose>
									<xsl:apply-templates select="collab" mode="back-ref"/>
									<xsl:apply-templates select="source" mode="book"/>
									<xsl:apply-templates select="edition|issue" mode="book"/>
									<xsl:apply-templates select="volume" mode="book"/>
									<xsl:apply-templates select="trans-source" mode="book"/>
									<xsl:apply-templates select="publisher-name | publisher-loc" mode="back-ref"/>
									<xsl:apply-templates select="year | month | time-stamp | season | access-date | date-in-citation"
										mode="book"/>
									<xsl:apply-templates select="article-title | chapter-title | fpage | lpage | elocation-id | ext-link | page-count | size" mode="book"/>
							 </xsl:otherwise>
						</xsl:choose>
						<xsl:apply-templates select="series" mode="back-ref"/>
				 </xsl:when>


<!-- GOVERNMENT AND OTHER REPORTS and OTHER and WEB and COMMUN -->
				 <xsl:when test="@citation-type='gov' or @citation-type='other' or @citation-type='web'
					 or @citation-type='commun' or @publication-type='commun' or @publication-type='webpage'
					 or @publication-type='database' or @publication-type='wiki' or @publication-type='blog'
					 or @publication-type='other'">
						<xsl:apply-templates select="person-group | name" mode="book"/>
						<xsl:apply-templates select="collab" mode="back-ref"/>
						<xsl:choose>
							 <xsl:when test="publisher-loc | publisher-name">
									<xsl:apply-templates select="source" mode="book"/>
									<xsl:apply-templates select="edition" mode="back-ref"/>
									<xsl:apply-templates select="publisher-loc" mode="back-ref"/>
									<xsl:apply-templates select="publisher-name" mode="back-ref"/>
									<xsl:apply-templates select="year | month | time-stamp | season | access-date | date-in-citation"
										mode="book"/>
									<xsl:apply-templates select="article-title | chapter-title | gov" mode="back-ref"/>
							 </xsl:when>
							 <xsl:otherwise>
									<xsl:apply-templates select="article-title | chapter-title | gov" mode="back-ref"/>
									<xsl:apply-templates select="source" mode="book"/>
									<xsl:apply-templates select="edition" mode="back-ref"/>
									<xsl:apply-templates select="publisher-loc" mode="back-ref"/>
									<xsl:apply-templates select="publisher-name" mode="back-ref"/>
									<xsl:apply-templates select="year | month | time-stamp | season | access-date | date-in-citation | uri" mode="book"/>
							 </xsl:otherwise>
						</xsl:choose>
						<xsl:apply-templates select="fpage | lpage | elocation-id | size" mode="book"/>
						<xsl:apply-templates select="series" mode="back-ref"/>
						<xsl:apply-templates select="ext-link | uri"/>
				 </xsl:when>

<!-- PATENTS  -->
				 <xsl:when test="@citation-type='patent'">
						<xsl:apply-templates select="person-group | name" mode="book"/>
						<xsl:apply-templates select="collab" mode="back-ref"/>
						<xsl:apply-templates select="article-title | chapter-title | trans-title" mode="back-ref"/>
						<xsl:apply-templates select="source" mode="back-ref"/>
						<xsl:apply-templates select="patent" mode="back-ref"/>
						<xsl:apply-templates select="year | month | time-stamp | season | access-date | date-in-citation"
							mode="book"/>
						<xsl:apply-templates select="fpage | lpage | elocation-id | size" mode="book"/>
						<xsl:apply-templates select="series" mode="back-ref"/>
				 </xsl:when>

<!-- DISCUSSION  -->
				 <xsl:when test="@citation-type='discussion'">
						<xsl:apply-templates select="person-group | name" mode="book"/>
						<xsl:apply-templates select="collab" mode="back-ref"/>
						<xsl:apply-templates select="article-title | chapter-title" mode="editedbook"/>
						<xsl:text>In: </xsl:text>
						<xsl:apply-templates select="source" mode="back-ref"/>
						<xsl:if test="publisher-name | publisher-loc">
							 <xsl:text> [</xsl:text>
							 <xsl:apply-templates select="publisher-loc" mode="back-ref"/>
							 <xsl:value-of select="publisher-name"/>
							 <xsl:text>]; </xsl:text>
						</xsl:if>
						<xsl:apply-templates select="year | month | time-stamp | season | access-date | date-in-citation"
							mode="book"/>
						<xsl:apply-templates select="fpage | lpage | elocation-id | size" mode="book"/>
						<xsl:apply-templates select="series" mode="back-ref"/>
				 </xsl:when>

<!-- ANYTHING ELSE BUT RAW TEXT  (INCLUDES ARTICLES) -->
				 <xsl:when test="not(text()[not(normalize-space(.) = '')])">
						<xsl:apply-templates mode="back-ref-any-no-raw-text"/>
			<span>
				<xsl:apply-templates select="source"      mode="back-ref"/>
							<xsl:apply-templates select="year"        mode="back-ref"/>
							<xsl:apply-templates select="month"       mode="back-ref"/>
							<xsl:apply-templates select="day"         mode="back-ref"/>
							<xsl:apply-templates select="season"      mode="back-ref"/>
							<xsl:apply-templates select="volume"      mode="back-ref"/>
							<xsl:apply-templates select="issue"       mode="back-ref"/>
							<xsl:apply-templates select="supplement"  mode="back-ref"/>
							<xsl:apply-templates select="fpage"       mode="back-ref"/>
							<xsl:apply-templates select="elocation-id"  mode="back-ref"/>
							<xsl:apply-templates select="access-date" mode="back-ref"/>
							<xsl:apply-templates select="pub-id[@pub-id-type='doi']" mode="back-ref"/>
				<xsl:apply-templates select="ext-link"    mode="back-ref"/>
							</span>
						</xsl:when>

<!-- RAW TEXT -->
				 <xsl:otherwise>
						<xsl:apply-templates select="*[not(self::label)
												and not(self::annotation)
			and not(self::edition)
			and not(self::lpage)
			and not(self::comment)
			and not(self::source)
			and not(self::year)
			and not(self::month)
			and not(self::day)
			and not(self::volume)
			and not(self::issue)
			and not(self::fpage)
			and not(self::elocation-id)
			and not(self::pub-id)
			and not(self::season)
			and not(self::page-range)
			and not(self::object-id)
				]" mode="back-ref"/>
				 <span>
					<xsl:apply-templates select="*[self::source or self::year or self::month or self::day
						or self::volume or self::issue or self::fpage or self::elocation-id or self::season
						or self::pub-id[@pub-id-type='doi']]|text()" mode="back-ref"/>
				 </span>
				 <xsl:apply-templates select="text()" mode="back-ref"/>
				 </xsl:otherwise>
			</xsl:choose>

				<!-- This piece grabs the language from the translated title and writes it after the citation -->
				<xsl:choose>
						<xsl:when test="article-title[@xml:lang!='en' or @xml:lang!='EN']">
								<xsl:call-template name="language">
										<xsl:with-param name="lang" select="article-title/@xml:lang"/>
								 </xsl:call-template>
						</xsl:when>
						<xsl:when test="source[@xml:lang!='en' or @xml:lang!='EN']">
								<xsl:call-template name="language">
										<xsl:with-param name="lang" select="source/@xml:lang"/>
								</xsl:call-template>
						</xsl:when>
						<xsl:otherwise/>
				</xsl:choose>
				<xsl:apply-templates select="comment" mode="back-ref"/>
				<xsl:apply-templates select="*[self::pub-id[not(@pub-id-type = 'doi')]]" mode="back-ref"/>
				<xsl:apply-templates select="annotation" mode="back-ref"/>

	 </xsl:template> <!-- nlm-citation -->


<!-- =========================== Default (Journal) citation templates ============================= -->
	<!-- ######################################################        -->
	<xsl:template match="label
	|annotation
	|edition
	|lpage
	|comment
	|source
	|year
	|month
	|day
	|volume
	|supplement
	|issue
	|fpage
	|elocation-id
	|pub-id
	|season
	|page-range
	|object-id
	|ext-link
	|access-date" mode="back-ref-any-no-raw-text"/>

	<!-- ######################################################        -->
	<xsl:template match="*" mode="back-ref-any-no-raw-text">
		<xsl:apply-templates select="." mode="back-ref"/>
	</xsl:template>
	<!-- ######################################################        -->
	<xsl:template match="label" mode="back-ref-ignore-label"/>

	<!-- ######################################################        -->
	<xsl:template match="*" mode="back-ref-ignore-label">
		<xsl:apply-templates select="." mode="back-ref"/>
	</xsl:template>

	<!-- ######################################################        -->
	<xsl:template match="person-group" name="pgroup" mode="back-ref">
		<xsl:apply-templates select="." mode="book"/>
	</xsl:template>

	<!-- ######################################################        -->
	<xsl:template match="name" mode="back-ref">
		<xsl:call-template name="refs-name"/>
		<xsl:call-template name="refs-after-name-not-in-person-group-punctuation"/>

	</xsl:template>

	<!-- ######################################################        -->
	<xsl:template name="refs-name">
		<xsl:choose>
			<xsl:when test="given-names">
				<xsl:apply-templates select="surname" mode="back-ref"/>
				<xsl:if test="given-names">
					<xsl:text> </xsl:text>
					<xsl:apply-templates select="given-names" mode="back-ref"/>
				</xsl:if>
				<xsl:if test="suffix">
					<xsl:text> </xsl:text>
					<xsl:apply-templates select="suffix" mode="back-ref"/>
				</xsl:if>
					</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="surname" mode="back-ref"/>
				 </xsl:otherwise>
			 </xsl:choose>
	</xsl:template>

	<!-- ######################################################        -->
	<xsl:template name="refs-after-name-not-in-person-group-punctuation">
		<!-- try to figure out the requirements of the "," (comma) next to this author -->
		<xsl:choose>
			<!-- n, n, n -->
			<xsl:when test="following-sibling::*[position() =1 and name() = 'x']"/>
			<xsl:when test="following-sibling::*[position() = 1 and name() = 'name']
							and following-sibling::*[position() = 2 and name() = 'name']">
				<xsl:text>, </xsl:text>
			</xsl:when>
			<!-- n -->
			<xsl:when test="following-sibling::*[position() = 1 and not(name() = 'name')]">
				<xsl:text>. </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>, </xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ######################################################        -->
	<xsl:template match="person-group/name" mode="back-ref">
			<xsl:variable name="nodetotal" select="count(../*)"/>
			<xsl:variable name="position" select="position()"/>

			<xsl:variable name="_name">
		<xsl:call-template name="refs-name"/>
			</xsl:variable>

		<xsl:choose>
			<xsl:when test="$nodetotal=$position">
				<xsl:choose>
					<xsl:when test="parent::person-group/@person-group-type!='author'
						or parent::person-group[not(@person-group-type)]">
						<xsl:call-template name="refs-name"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="utils-put-missing-period">
							<xsl:with-param name="input-str" select="$_name"/>
						</xsl:call-template>
						<xsl:text> </xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="utils-put-missing-period">
					<xsl:with-param name="input-str" select="$_name"/>
					<xsl:with-param name="punct-char" select="','"/>
													 <xsl:with-param name="enforce-missing-period" select="'yes'"/>
				</xsl:call-template>
				<xsl:text> </xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	 <xsl:template match="aff" mode="back-ref">
			<xsl:variable name="nodetotal" select="count(../*)"/>
			<xsl:variable name="position" select="position()"/>
			<xsl:text> (</xsl:text>
			<xsl:apply-templates mode="back-ref"/>
			<xsl:text>)</xsl:text>
			<xsl:choose>
				 <xsl:when test="$nodetotal=$position">. </xsl:when>
				 <xsl:otherwise>, </xsl:otherwise>
			</xsl:choose>
	 </xsl:template>

	<xsl:template match="etal" mode="back-ref" name="etal">
			<xsl:text>et al.</xsl:text>
			<xsl:choose>
				 <xsl:when test="parent::person-group/@person-group-type">
				<xsl:choose>
					<xsl:when test="parent::person-group/@person-group-type='author'">
						<xsl:text> </xsl:text></xsl:when>
					<xsl:otherwise/>
					</xsl:choose>
				</xsl:when>
			<xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise>
			</xsl:choose>
		</xsl:template>

	<xsl:template match="article-title | chapter-title | gov" mode="back-ref">
		<xsl:choose>
			<xsl:when test="../trans-title">
				<xsl:apply-templates mode="back-ref"/>
				</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="back-ref"/>
				</xsl:otherwise>
			</xsl:choose>
		&pd-sp;
	</xsl:template>

	 <xsl:template match="trans-title" mode="back-ref">
			<xsl:text> [</xsl:text>
			<xsl:apply-templates mode="back-ref"/>
			<xsl:text>]. </xsl:text>
		</xsl:template>

	 <xsl:template match="access-date | date-in-citation" mode="back-ref">
			<xsl:text> [</xsl:text>
			<xsl:apply-templates mode="back-ref"/>
			<xsl:text>];</xsl:text>
		</xsl:template>

	 <xsl:template match="trans-title" mode="back-ref">
			<xsl:text> [</xsl:text>
			<xsl:apply-templates mode="back-ref"/>
			<xsl:text>]. </xsl:text>
		</xsl:template>

	 <xsl:template match="collab" mode="back-ref">
	<xsl:choose>
		<xsl:when test="@collab-type = 'on_behalf'">
			<xsl:text> on behalf of </xsl:text>
			<xsl:apply-templates mode="back-ref"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates mode="back-ref"/>
			<xsl:if test="@collab-type">
				<xsl:text>, </xsl:text>
				<xsl:value-of select="@collab-type"/>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:choose>
		<xsl:when test="following-sibling::collab">
			<xsl:text>; </xsl:text>
		</xsl:when>
		<xsl:when test="../@person-group-type='editor'
						or ../@person-group-type='allauthors'
						or ../@person-group-type='translator'
						or ../@person-group-type='transed'"/>
		<xsl:otherwise>
			&pd-sp;
		</xsl:otherwise>
	</xsl:choose>

		</xsl:template>

	<xsl:template match="source" mode="back-ref">
		<span class="ref-journal"><xsl:apply-templates mode="back-ref"/>&pd-sp;</span>
		<xsl:choose>
			<xsl:when test="../access-date or ../date-in-citation">
				<xsl:if test="../edition">
					<xsl:text> (</xsl:text><xsl:apply-templates select="../edition" mode="plain"/><xsl:text>)</xsl:text>
					<xsl:text>. </xsl:text>
					</xsl:if>

				</xsl:when>
			<xsl:when test="../volume | ../fpage | ../elocation-id">
				<xsl:if test="../edition">
					<xsl:text> (</xsl:text><xsl:apply-templates select="../edition" mode="plain"/><xsl:text>)</xsl:text>
					<xsl:text> </xsl:text>
					</xsl:if>

				</xsl:when>
			<xsl:otherwise>
				<xsl:if test="../edition">
					<xsl:text> (</xsl:text><xsl:apply-templates select="../edition" mode="plain"/><xsl:text>)</xsl:text>
					<xsl:text> </xsl:text>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:template>

	<!-- ==================================================================== -->
	<xsl:template match="year" mode="back-ref">
		<xsl:choose>
			<xsl:when test="../month or ../season or ../access-date or ../date-in-citation">
				<xsl:apply-templates mode="back-ref"/>
						<xsl:text> </xsl:text>
				</xsl:when>
				 <xsl:otherwise>
						<xsl:apply-templates mode="back-ref"/>
						<xsl:if test="../volume or ../issue">
							 <xsl:text>;</xsl:text>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:template>


	 <!-- ==================================================================== -->
	 <!-- TEMPLATE: month
				NOTES:    Recode from number to 3-letter abbreviation.
							Should this be factored into language-dependent module?
		 -->
	 <!-- ==================================================================== -->
	 <xsl:template match="month" mode="back-ref">
			<xsl:variable name="month" select="."/>
			<xsl:choose>
				 <xsl:when test="$month='01' or $month='1' ">Jan</xsl:when>
				 <xsl:when test="$month='02' or $month='2' ">Feb</xsl:when>
				 <xsl:when test="$month='03' or $month='3' ">Mar</xsl:when>
				 <xsl:when test="$month='04' or $month='4' ">Apr</xsl:when>
				 <xsl:when test="$month='05' or $month='5' ">May</xsl:when>
				 <xsl:when test="$month='06' or $month='6'">Jun</xsl:when>
				 <xsl:when test="$month='07' or $month='7'">Jul</xsl:when>
				 <xsl:when test="$month='08' or $month='8' ">Aug</xsl:when>
				 <xsl:when test="$month='09' or $month='9' ">Sep</xsl:when>
				 <xsl:when test="$month='10' ">Oct</xsl:when>
				 <xsl:when test="$month='11' ">Nov</xsl:when>
				 <xsl:when test="$month='12' ">Dec</xsl:when>
				 <xsl:otherwise>
						<xsl:value-of select="$month"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="../day">
				 <xsl:text> </xsl:text>
				 <xsl:value-of select="../day"/>
				</xsl:if>
		&semi;
	 </xsl:template>

	 <xsl:template match="day" mode="back-ref"/>

	 <xsl:template match="season" mode="back-ref">
			<xsl:apply-templates mode="back-ref"/>
			&semi;
		</xsl:template>

	 <xsl:template match="patent | edition" mode="back-ref">
			<xsl:apply-templates mode="back-ref"/>
			&pd-sp;
		</xsl:template>

	 <xsl:template match="volume" mode="back-ref">
			<span class="ref-vol"><xsl:apply-templates mode="back-ref"/></span>
		</xsl:template>

	 <xsl:template match="supplement" mode="back-ref">
			<xsl:text> </xsl:text>
			<xsl:apply-templates mode="back-ref"/>
		</xsl:template>

	 <xsl:template match="issue" mode="back-ref">
			<xsl:text>(</xsl:text>
			<xsl:apply-templates mode="back-ref"/>
			<xsl:text>)</xsl:text>
		</xsl:template>


	 <!-- ==================================================================== -->
	 <!-- TEMPLATE: fpage
				MODE:     back-ref
				NOTES:    Punctuate it right, depending on surroundings.

		ALGORITHM:
				if there's a sibling page-range
			 colon
			 apply that page-range(s)
			 period
				else if there's a preceding fpage,
			 if there's a following fpage
					space, apply
				if next sibling is lpage
					 hyphen
								 apply the next sibling
							comma
					 else
					space, apply
							if next sibling is lpage
								 hyphen
				apply the next sibling
							period
					 endif
				else (we're the first fpage)
			 colon
			 apply
				if next sibling is lpage
				hyphen
							apply the next sibling
							period
				else if next sibling is fpage
							comma
			 else
					period
			 endif
				endif
		 -->
	 <!-- ==================================================================== -->
	<xsl:template match="fpage" mode="back-ref">
		<xsl:variable name="fpgct" select="count(../fpage)"/>
		<xsl:variable name="lpgct" select="count(../lpage)"/>
		<xsl:variable name="hermano" select="name(following-sibling::node())"/>
			<xsl:choose>
				<xsl:when test="../page-range">
					<xsl:text>:</xsl:text>
					<xsl:apply-templates select="../page-range" mode="back-ref"/>
					<xsl:text>.</xsl:text>
				</xsl:when>
				<xsl:when test="preceding-sibling::fpage">
					<xsl:choose>
						<xsl:when test="following-sibling::fpage">
							<xsl:text> </xsl:text>
							<xsl:apply-templates mode="back-ref"/>
							<xsl:if test="$hermano='lpage'">
								<xsl:text>&#x2013;</xsl:text>
								<xsl:apply-templates select="following-sibling::lpage[1]" mode="back-ref"/>
								</xsl:if>
							<xsl:text>,</xsl:text>
							</xsl:when>
						<xsl:otherwise>
							<xsl:text> </xsl:text>
							<xsl:apply-templates mode="back-ref"/>
							<xsl:if test="$hermano='lpage'">
								<xsl:text>&#x2013;</xsl:text>
								<xsl:apply-templates select="following-sibling::lpage[1]" mode="back-ref"/>
								</xsl:if>
							<xsl:text>.</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
				<xsl:otherwise>
					<xsl:text>:</xsl:text><xsl:apply-templates mode="back-ref"/>
					<xsl:choose>
						<xsl:when test="$hermano='lpage'
										or (
											$hermano = ''
											and normalize-space(following-sibling::node()[1]) = ''
											and name(following-sibling::node()[2]) = 'lpage'
										)"> <!-- 2nd condition (the one after or) should overcome the bug from the converter,
												which was putting citation into mixed-citation element for no reason.
												see PMC-11141 -->
							<xsl:text>&#x2013;</xsl:text>
							<xsl:apply-templates select="following-sibling::lpage[1]" mode="back-ref"/>
							<xsl:text>.</xsl:text>
							</xsl:when>
						<xsl:when test="$hermano='fpage'">
							<xsl:text>,</xsl:text>
							</xsl:when>
						<xsl:otherwise>
							<xsl:text>.</xsl:text>
							</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template> <!-- fpage -->

	<!-- ==================================================================== -->
	<xsl:template match="lpage" mode="back-ref">
		<xsl:apply-templates mode="back-ref"/>
		</xsl:template>

	<!-- ==================================================================== -->
	<xsl:template match="page-range" mode="back-ref">
		<xsl:apply-templates mode="back-ref"/>
		</xsl:template>

	<!-- ==================================================================== -->
	<xsl:template match="elocation-id" mode="back-ref">
	    <xsl:text>:</xsl:text><xsl:apply-templates mode="back-ref"/>
	</xsl:template>

	<!-- ==================================================================== -->
	 <xsl:template match="series" mode="back-ref">
			<xsl:text> (</xsl:text>
			<xsl:apply-templates mode="back-ref"/>
			<xsl:text>).</xsl:text>
		</xsl:template>

	<!-- ==================================================================== -->
	 <xsl:template match="comment" mode="back-ref">
		<xsl:variable name="_comment-markup">
		<xsl:text> </xsl:text>
		<xsl:apply-templates mode="back-ref"/>
		</xsl:variable>

		<xsl:call-template name="utils-put-missing-period">
			<xsl:with-param name="input-str" select="$_comment-markup"/>
		</xsl:call-template>

	</xsl:template>

	 <xsl:template match="annotation" mode="back-ref">
			<br/>
			<span>
				 <xsl:text> [</xsl:text>
				 <xsl:apply-templates mode="back-ref"/>
				 <xsl:text>]</xsl:text>
			</span>
		</xsl:template>

	<xsl:template match="ext-link" mode="back-ref">
		<xsl:text> </xsl:text>
		<xsl:call-template name="ext-link"/>
		</xsl:template>
	 <!-- ***************************** End Default (Journal) citation templates ************************** -->


	 <!-- ***************************** Book citation templates ******************************************** -->
	 <xsl:template match="person-group" mode="book">
			<xsl:variable name="auno" select="count(name)"/>
			<xsl:variable name="gnms" select="string(descendant::given-names)"/>
			<xsl:variable name="GNMS">
			<xsl:call-template name="capitalize">
				<xsl:with-param name="str" select="string(descendant::given-names)"/>
				</xsl:call-template>
			</xsl:variable>

			<xsl:choose>
				 <xsl:when test="@person-group-type='editor'">
					<xsl:choose>
						 <xsl:when test="$gnms!=$GNMS">
						<xsl:apply-templates mode="book"/>
						</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates mode="back-ref"/>
						</xsl:otherwise>
				</xsl:choose>
						<xsl:choose>
					<xsl:when test="starts-with(following-sibling::node()[1][name() = 'comment'], 'editors')">
						<xsl:text>, </xsl:text>
						</xsl:when>
					<xsl:when test="$auno > 1">
						 <xsl:text>, editors</xsl:text>
						</xsl:when>
					<xsl:when test="etal">
						 <xsl:text>, editors</xsl:text>
						 </xsl:when>
					<xsl:otherwise>
						 <xsl:text>, editor</xsl:text>
						</xsl:otherwise>
							</xsl:choose>
				<xsl:choose>
					<xsl:when test="following-sibling::person-group">
						<xsl:text>; </xsl:text>
						</xsl:when>
					<xsl:otherwise>
						<xsl:text>. </xsl:text>
						</xsl:otherwise>
					</xsl:choose>
					</xsl:when>

				 <xsl:when test="@person-group-type='assignee'">
					<xsl:choose>
						 <xsl:when test="$gnms!=$GNMS">
						<xsl:apply-templates mode="book"/>
						</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates mode="back-ref"/>
						</xsl:otherwise>
				</xsl:choose>
						<xsl:choose>
							 <xsl:when test="$auno > 1">
									<xsl:text>, assignees</xsl:text>
							 </xsl:when>
							 <xsl:when test="etal">
									<xsl:text>, assignees</xsl:text>
									</xsl:when>
							 <xsl:otherwise>
									<xsl:text>, assignee</xsl:text>
							 </xsl:otherwise>
							</xsl:choose>
				<xsl:choose>
					<xsl:when test="following-sibling::person-group">
						<xsl:text>; </xsl:text>
						</xsl:when>
					<xsl:otherwise>
						<xsl:text>. </xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				 </xsl:when>
				 <xsl:when test="@person-group-type='translator'">
					<xsl:choose>
						 <xsl:when test="$gnms!=$GNMS">
						<xsl:apply-templates mode="book"/>
						</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates mode="back-ref"/>
						</xsl:otherwise>
				</xsl:choose>
						<xsl:choose>
							 <xsl:when test="$auno > 1">
									<xsl:text>, translators</xsl:text>
							 </xsl:when>
							 <xsl:when test="etal">
									<xsl:text>, translators</xsl:text>
									</xsl:when>
							 <xsl:otherwise>
									<xsl:text>, translator</xsl:text>
							 </xsl:otherwise>
							</xsl:choose>
				<xsl:choose>
					<xsl:when test="following-sibling::person-group">
						<xsl:text>; </xsl:text>
						</xsl:when>
					<xsl:otherwise>
						<xsl:text>. </xsl:text>
						</xsl:otherwise>
					</xsl:choose>
					 </xsl:when>
				 <xsl:when test="@person-group-type='transed'">
					<xsl:choose>
						 <xsl:when test="$gnms!=$GNMS">
						<xsl:apply-templates mode="book"/>
						</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates mode="back-ref"/>
						</xsl:otherwise>
				</xsl:choose>
						<xsl:choose>
							 <xsl:when test="$auno > 1">
									<xsl:text>, translators and editors</xsl:text>
							 </xsl:when>
							 <xsl:when test="etal">
									<xsl:text>, translators and editors</xsl:text>
									</xsl:when>
							 <xsl:otherwise>
									<xsl:text>, translator and editor</xsl:text>
							 </xsl:otherwise>
							</xsl:choose>
				<xsl:choose>
					<xsl:when test="following-sibling::person-group">
						<xsl:text>; </xsl:text>
						</xsl:when>
					<xsl:otherwise>
						<xsl:text>. </xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				 </xsl:when>
				 <xsl:when test="@person-group-type='guest-editor'">
					<xsl:choose>
						 <xsl:when test="$gnms!=$GNMS">
						<xsl:apply-templates mode="book"/>
						</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates mode="back-ref"/>
						</xsl:otherwise>
				</xsl:choose>
						<xsl:choose>
							 <xsl:when test="$auno > 1">
									<xsl:text>, guest editors</xsl:text>
							 </xsl:when>
							 <xsl:when test="etal">
									<xsl:text>, guest editors</xsl:text>
									</xsl:when>
							 <xsl:otherwise>
									<xsl:text>, guest editor</xsl:text>
							 </xsl:otherwise>
							</xsl:choose>
				<xsl:choose>
					<xsl:when test="following-sibling::person-group">
						<xsl:text>; </xsl:text>
						</xsl:when>
					<xsl:otherwise>
						<xsl:text>. </xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				 </xsl:when>
				 <xsl:when test="@person-group-type='compiler'">
					<xsl:choose>
						 <xsl:when test="$gnms!=$GNMS">
						<xsl:apply-templates mode="book"/>
						</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates mode="back-ref"/>
						</xsl:otherwise>
				</xsl:choose>
						<xsl:choose>
							 <xsl:when test="$auno > 1">
									<xsl:text>, compilers</xsl:text>
							 </xsl:when>
							 <xsl:when test="etal">
									<xsl:text>, compilers</xsl:text>
									</xsl:when>
							 <xsl:otherwise>
									<xsl:text>, compiler</xsl:text>
							 </xsl:otherwise>
					</xsl:choose>
				<xsl:choose>
					<xsl:when test="following-sibling::person-group">
						<xsl:text>; </xsl:text>
						</xsl:when>
					<xsl:otherwise>
						<xsl:text>. </xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				 </xsl:when>
				 <xsl:when test="@person-group-type='inventor'">
					<xsl:choose>
						 <xsl:when test="$gnms!=$GNMS">
						<xsl:apply-templates mode="book"/>
						</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates mode="back-ref"/>
						</xsl:otherwise>
				</xsl:choose>
						<xsl:choose>
							 <xsl:when test="$auno > 1">
									<xsl:text>, inventors</xsl:text>
							 </xsl:when>
							 <xsl:when test="etal">
									<xsl:text>, inventors</xsl:text>
									</xsl:when>
							 <xsl:otherwise>
									<xsl:text>, inventor</xsl:text>
							 </xsl:otherwise>
					</xsl:choose>
				<xsl:choose>
					<xsl:when test="following-sibling::person-group">
						<xsl:text>; </xsl:text>
						</xsl:when>
					<xsl:otherwise>
						<xsl:text>. </xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				 </xsl:when>
				 <xsl:when test="@person-group-type='allauthors'">
					<xsl:choose>
						 <xsl:when test="$gnms!=$GNMS">
						<xsl:apply-templates mode="book"/>
						</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates mode="back-ref"/>
						</xsl:otherwise>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="following-sibling::person-group">
						<xsl:text>; </xsl:text>
						</xsl:when>
					<xsl:otherwise>
						<xsl:text>. </xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				 </xsl:when>
				 <xsl:otherwise>
					<xsl:apply-templates mode="book"/>
					&space;
				</xsl:otherwise>
			</xsl:choose>
	 </xsl:template>

<xsl:template match="name" mode="book">
	<xsl:choose>
		<xsl:when test="given-names">
			<xsl:apply-templates select="surname" mode="back-ref"/>
			<xsl:text> </xsl:text>
			<xsl:call-template name="firstnames" >
				<xsl:with-param name="names" select="given-names"/>
			</xsl:call-template>
			<xsl:if test="suffix">
				<xsl:text>, </xsl:text>
				<xsl:apply-templates select="suffix" mode="back-ref"/>
			</xsl:if>
		</xsl:when>
		<xsl:otherwise>
			 <xsl:apply-templates select="surname" mode="back-ref"/>
				 </xsl:otherwise>
	</xsl:choose>
	<!-- -->
	<xsl:choose>
		<xsl:when test="name(following-sibling::node()[1])='aff'"/>
		<xsl:when test="count(following-sibling::*[name() = 'name' or name() = 'collab' or name() = 'etal'][1])
						= 0"/>
		<xsl:otherwise>, </xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="firstnames" >
	<xsl:param name="names"/>
		<xsl:if test="$names">
		<xsl:variable name="_names-markup">
			<xsl:apply-templates select="$names" mode="back-ref"/>
		</xsl:variable>

		<xsl:choose>
		<xsl:when test="not(following-sibling::*[self::name or self::etal or self::collab])">
			<xsl:call-template name="utils-put-missing-period">
				<xsl:with-param name="input-str" select="$_names-markup"/>
				</xsl:call-template>
			<xsl:if test="not(parent::person-group)">
				<xsl:text> </xsl:text>
			</xsl:if>
			</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$_names-markup"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
</xsl:template>

	 <xsl:template match="etal" mode="book">
		<xsl:call-template name="etal"/>
	 </xsl:template>


	 <xsl:template match="aff" mode="book">
			<xsl:variable name="nodetotal" select="count(../*)"/>
			<xsl:variable name="position" select="position()"/>
			<xsl:text> (</xsl:text>
			<xsl:apply-templates mode="back-ref"/>
			<xsl:text>)</xsl:text>
			<xsl:choose>
				 <xsl:when test="$nodetotal=$position">. </xsl:when>
				 <xsl:otherwise>, </xsl:otherwise>
			</xsl:choose>
		</xsl:template>

	 <xsl:template match="publisher-loc" mode="back-ref">
			<xsl:apply-templates mode="back-ref"/>
			<xsl:text>: </xsl:text>
	 </xsl:template>

	<xsl:template match="publisher-loc" mode="dump">
		<xsl:apply-templates mode="dump"/>
		<xsl:call-template name="fix-punct">
			<xsl:with-param name="punct">: </xsl:with-param>
			<xsl:with-param name="last" select="substring(.,string-length(.),1)"/>
		</xsl:call-template>
	</xsl:template>

	 <xsl:template match="publisher-name" mode="back-ref">
			<xsl:apply-templates mode="back-ref"/>
			<xsl:text>; </xsl:text>
	 </xsl:template>

	<xsl:template match="publisher-name" mode="dump">
		<xsl:apply-templates mode="dump"/>
		<xsl:call-template name="fix-punct">
			<xsl:with-param name="punct">; </xsl:with-param>
			<xsl:with-param name="last" select="substring(.,string-length(.),1)"/>
		</xsl:call-template>
	</xsl:template>

	 <xsl:template match="fpage" mode="book">
			<xsl:choose>
	<xsl:when test="../page-range">
		<xsl:text>pp. </xsl:text>
		<xsl:apply-templates select="../page-range" mode="back-ref"/>
		<xsl:text>.</xsl:text>
	</xsl:when>
				 <xsl:when test="../lpage">
						<xsl:text>pp. </xsl:text>
						<xsl:apply-templates mode="back-ref"/>
				 </xsl:when>
				 <xsl:otherwise>
						<xsl:text>p. </xsl:text>
						<xsl:apply-templates mode="back-ref"/>
						<xsl:text>.</xsl:text>
				 </xsl:otherwise>
			</xsl:choose>
	 </xsl:template>

	 <xsl:template match="lpage" mode="book">
			<xsl:choose>
	<xsl:when test="../page-range"/>
				 <xsl:when test="../fpage">
						<xsl:text>&#x2013;</xsl:text>
						<xsl:apply-templates mode="back-ref"/>
						<xsl:text>.</xsl:text>
				 </xsl:when>
				 <xsl:otherwise>
						<xsl:apply-templates mode="back-ref"/>
						<xsl:text> pp.</xsl:text>
				 </xsl:otherwise>
			</xsl:choose>
	 </xsl:template>

	 <xsl:template match="page-count" mode="book">
			<xsl:choose>
				 <xsl:when test="../fpage"/>
				 <xsl:otherwise>
						<xsl:value-of select="@count"/>
						<xsl:text> p.</xsl:text>
				 </xsl:otherwise>
			</xsl:choose>
	 </xsl:template>

	<!-- ==================================================================== -->
	<xsl:template match="elocation-id" mode="book"> <!-- not sure, that we will see elocation-id in book mode, but nevertheless it is here -->
	    <xsl:apply-templates mode="book"/>
	</xsl:template>


	<xsl:template match="size" mode="book">
		<xsl:apply-templates/>
		&pd-sp;
	</xsl:template>
	 <xsl:template match="edition | season | collab | issue" mode="book">
			<xsl:apply-templates mode="back-ref"/>
			&pd-sp;
	 </xsl:template>

	 <xsl:template match="volume" mode="book">
		<xsl:if test="string(number(.)) = string(.)">
		<xsl:text>Vol. </xsl:text>
		</xsl:if>
			<xsl:apply-templates mode="back-ref"/>
			&pd-sp;
	 </xsl:template>

	 <xsl:template match="article-title | chapter-title" mode="book">
			<xsl:apply-templates mode="back-ref"/>
			<xsl:choose>
				 <xsl:when test="../fpage or ../lpage or ../elocation-id">
						&semi-sp;
				 </xsl:when>
				 <xsl:otherwise>
						&pd;
				 </xsl:otherwise>
			</xsl:choose>
	 </xsl:template>

	<xsl:template match="article-title | chapter-title" mode="editedbook">
			<xsl:apply-templates mode="back-ref"/>
			&pd-sp;
		</xsl:template>

	 <xsl:template match="source" mode="book">
		<xsl:variable name="_section-title">
			<xsl:apply-templates mode="back-ref"/>
		</xsl:variable>
		<span class="ref-journal">
			<xsl:call-template name="utils-put-missing-period">
				<xsl:with-param name="input-str" select="$_section-title"/>
			</xsl:call-template>
		</span>
		<xsl:text> </xsl:text>
	 </xsl:template>

	 <xsl:template match="trans-source | access-date | date-in-citation" mode="book">
			<xsl:text> [</xsl:text>
			<xsl:apply-templates mode="back-ref"/>
			<xsl:text>]. </xsl:text>
	 </xsl:template>

	 <xsl:template match="year" mode="book">
			<xsl:choose>
				 <xsl:when test="../month or ../season or ../access-date or ../date-in-citation">
						<xsl:apply-templates mode="back-ref"/>
						<xsl:text>. </xsl:text>
				 </xsl:when>
				 <xsl:otherwise>
						<xsl:apply-templates mode="back-ref"/>
						<xsl:text>. </xsl:text>
				 </xsl:otherwise>
			</xsl:choose>
	 </xsl:template>

	 <xsl:template match="month" mode="book">
			<xsl:variable name="month" select="."/>
			<xsl:choose>
				 <xsl:when test="$month='01' or $month='1' or $month='January'">Jan</xsl:when>
				 <xsl:when test="$month='02' or $month='2' or $month='February'">Feb</xsl:when>
				 <xsl:when test="$month='03' or $month='3' or $month='March'">Mar</xsl:when>
				 <xsl:when test="$month='04' or $month='4' or $month='April'">Apr</xsl:when>
				 <xsl:when test="$month='05' or $month='5' or $month='May'">May</xsl:when>
				 <xsl:when test="$month='06' or $month='6' or $month='June'">Jun</xsl:when>
				 <xsl:when test="$month='07' or $month='7' or $month='July'">Jul</xsl:when>
				 <xsl:when test="$month='08' or $month='8' or $month='August'">Aug</xsl:when>
				 <xsl:when test="$month='09' or $month='9' or $month='September'">Sep</xsl:when>
				 <xsl:when test="$month='10' or $month='October'">Oct</xsl:when>
				 <xsl:when test="$month='11' or $month='November'">Nov</xsl:when>
				 <xsl:when test="$month='12' or $month='December'">Dec</xsl:when>
				 <xsl:otherwise>
						<xsl:value-of select="$month"/>
				 </xsl:otherwise>
			</xsl:choose>
			<xsl:if test="../day">
				 <xsl:text> </xsl:text>
				 <xsl:value-of select="../day"/>
			</xsl:if>
			<xsl:choose>
				 <xsl:when test="../time-stamp">
						<xsl:text>, </xsl:text>
						<xsl:value-of select="../time-stamp"/>
						<xsl:text> </xsl:text>
				 </xsl:when>
				 <xsl:when test="../access-date"/>
				 <xsl:otherwise>
						<xsl:text>, </xsl:text>
				 </xsl:otherwise>
			</xsl:choose>
	 </xsl:template>
	 <xsl:template match="time-stamp" mode="book"/>
	 <!-- **************************** End Book citation templates ***************************************  -->


	 <!-- **************************** Conference citation templates ***************************************  -->
	 <xsl:template match="article-title | chapter-title" mode="conf">
			<xsl:apply-templates mode="back-ref"/>
			<xsl:choose>
				 <xsl:when test="../conf-name">
						<xsl:text>. </xsl:text>
				 </xsl:when>
				 <xsl:otherwise>
						<xsl:text>; </xsl:text>
				 </xsl:otherwise>
			</xsl:choose>
	 </xsl:template>
	 <xsl:template match="article-title | chapter-title" mode="inconf">
			<xsl:apply-templates mode="back-ref"/>
			<xsl:text>. </xsl:text>
	 </xsl:template>
	 <xsl:template match="conf-name | source | conf-date" mode="conf">
			<xsl:apply-templates mode="back-ref"/>
			<xsl:choose>
				<xsl:when test="count(following-sibling::node()) = 0">
					<xsl:text>.</xsl:text>
				</xsl:when>
				<xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise>
		</xsl:choose>
	 </xsl:template>

	 <xsl:template match="conf-loc" mode="conf">
			<xsl:apply-templates mode="back-ref"/>
			<xsl:text>. </xsl:text>
	 </xsl:template>
	 <!-- ************************** End Conference citation templates **********************************  -->

	 <!-- Language template -->
	 <xsl:template name="language">
			<xsl:param name="lang"/>
			<xsl:choose>
				 <xsl:when test="$lang='fr' or $lang='FR'"> (Fre).</xsl:when>
				 <xsl:when test="$lang='jp' or $lang='JP'"> (Jpn).</xsl:when>
				 <xsl:when test="$lang='ru' or $lang='RU'"> (Rus).</xsl:when>
				 <xsl:when test="$lang='de' or $lang='DE'"> (Ger).</xsl:when>
				 <xsl:when test="$lang='se' or $lang='SE'"> (Swe).</xsl:when>
				 <xsl:when test="$lang='it' or $lang='IT'"> (Ita).</xsl:when>
				 <xsl:when test="$lang='he' or $lang='HE'"> (Heb).</xsl:when>
				 <xsl:when test="$lang='sp' or $lang='SP'"> (Spa).</xsl:when>
			</xsl:choose>
	 </xsl:template>


	<!-- ************************** DUMP  citation templates **********************************  -->
	<xsl:template name="citation-dump">
		<xsl:apply-templates select="label" mode="back-ref"/>
		<xsl:apply-templates select="node()[not(self::label or self::pub-id)]" mode="dump"/>
		<xsl:apply-templates select="pub-id" mode="dump"/>
		</xsl:template>

	<xsl:template match="person-group" mode="dump">
		<!-- see articlerender.fcgi?artid=2646662 and ticket PEZ-941 if you need to change;
			Choose added: see articlerender.fcgi?artid=2694093, ticket PMC-6329 -->
		<xsl:choose>
			<xsl:when test="normalize-space(text())">
				<xsl:apply-templates mode="dump"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="pgroup"/>
			</xsl:otherwise>
		</xsl:choose>
		</xsl:template>

	<xsl:template match="name" mode="dump">
		<xsl:call-template name="refs-name"/>
		<xsl:if test="not(position() = last())">&space;</xsl:if>
		</xsl:template>

	<xsl:template match="string-name" mode="dump">
		<xsl:call-template name="refs-name"/>
		</xsl:template>

	<xsl:template match="name">
		<xsl:call-template name="refs-name"/>
		</xsl:template>

	<xsl:template match="surname" mode="dump">
		<xsl:apply-templates mode="dump"/>
		</xsl:template>

	<xsl:template match="collab | season" mode="dump">
		<xsl:apply-templates mode="dump"/>
		&space;
		</xsl:template>

	<xsl:template match="given-names" mode="dump">
		<xsl:apply-templates mode="dump"/>
		</xsl:template>

	<xsl:template match="etal" mode="dump">
		<xsl:call-template name="etal"/>
		</xsl:template>

	<xsl:template match="source" mode="dump">
		<span class="ref-journal"><xsl:apply-templates mode="dump"/></span>
		&space;
		</xsl:template>

	<xsl:template match="italic" mode="dump">
		<em><xsl:apply-templates mode="back-ref"/></em>
		</xsl:template>

	<xsl:template match="bold" mode="dump">
		<strong><xsl:apply-templates mode="back-ref"/></strong>
		</xsl:template>

	<xsl:template match="sup" mode="dump">
		<sup><xsl:apply-templates mode="back-ref"/></sup>
		</xsl:template>

	<xsl:template match="sub" mode="dump">
		<sub><xsl:apply-templates mode="back-ref"/></sub>
		</xsl:template>

	<xsl:template match="article-title" mode="dump">
		<span class="ref-title"><xsl:apply-templates mode="dump"/>&space;</span>
		</xsl:template>

	<xsl:template match="year" mode="dump">
		<xsl:apply-templates mode="back-ref"/>
		<xsl:choose>
			<xsl:when test="name(following-sibling::node()[1])='' and starts-with(following-sibling::node()[1], '@#')">
				<xsl:call-template name="fix-punct">
					<xsl:with-param name="punct">. </xsl:with-param>
					<xsl:with-param name="last" select="concat(substring-before(following-sibling::node()[1],';'), ';')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="name(following-sibling::node()[1])=''">
				<xsl:call-template name="fix-punct">
					<xsl:with-param name="punct">. </xsl:with-param>
					<xsl:with-param name="last" select="substring(following-sibling::node()[1],1,1)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				&pd-sp;
				</xsl:otherwise>
			</xsl:choose>
		</xsl:template>

	<xsl:template match="ext-link" mode="dump">
			<xsl:call-template name="ext-link"/>
		</xsl:template>

	<xsl:template match="ext-link" mode="book">
			<xsl:call-template name="ext-link"/>
		</xsl:template>

	<xsl:template match="named-content[@content-type='formula']" mode="dump">
		<xsl:apply-templates mode="back-ref"/>
		</xsl:template>

	<xsl:template match="month" mode="dump">
	    <xsl:variable name="_month">
		<xsl:call-template name="dates-month-number-to-month-name">
		    <xsl:with-param name="month" select="."/>
		</xsl:call-template>
	    </xsl:variable>
	    <xsl:choose>
		<xsl:when test="string-length($_month) &gt;0 ">
		    <xsl:copy-of select="$_month"/>
		</xsl:when>
		<xsl:otherwise>
		    <xsl:apply-templates/>
		</xsl:otherwise>
	    </xsl:choose>
	</xsl:template>

	<xsl:template match="volume" mode="dump">
		<span class="ref-vol"><xsl:apply-templates mode="back-ref"/></span>
		</xsl:template>

	<xsl:template match="issue" mode="dump">
		<span class="ref-iss"><xsl:apply-templates mode="back-ref"/></span>
		</xsl:template>

	<xsl:template match="fpage" mode="dump">
		<xsl:variable name="fpgct" select="count(../fpage)"/>
		<xsl:variable name="lpgct" select="count(../lpage)"/>
		<xsl:variable name="hermano" select="name(following-sibling::node()[1])"/>
			<xsl:choose>
				<xsl:when test="preceding-sibling::fpage">
					<xsl:choose>
						<xsl:when test="following-sibling::fpage">
							<xsl:text> </xsl:text>
							<xsl:apply-templates mode="back-ref"/>
							<xsl:if test="$hermano='lpage'">
								<xsl:text>&#x2013;</xsl:text><xsl:apply-templates select="following-sibling::lpage[1]" mode="back-ref"/>
								</xsl:if>
							<xsl:text>,</xsl:text>
							</xsl:when>
						<xsl:otherwise>
							<xsl:text> </xsl:text>
							<xsl:apply-templates mode="back-ref"/>
							<xsl:choose>
								<xsl:when test="$hermano='lpage'">
									<xsl:text>&#x2013;</xsl:text><xsl:apply-templates select="following-sibling::lpage[1]" mode="back-ref"/>
									<xsl:text>.</xsl:text>
								</xsl:when>
								<xsl:otherwise/>
							</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates mode="back-ref"/>
					<xsl:choose>
						<xsl:when test="$hermano='lpage'"><xsl:text>&#x2013;</xsl:text>
							<xsl:apply-templates select="following-sibling::lpage[1]" mode="back-ref"/>
							<xsl:text>.</xsl:text>
							</xsl:when>
						<xsl:when test="$hermano='fpage'">
							<xsl:text>,</xsl:text>
							</xsl:when>
						<xsl:when test="name(following-sibling::node()[1])=''"/>
						<xsl:when test="name(following-sibling::node()[1])='x'"/>
						<xsl:otherwise>
							<xsl:text>.</xsl:text>
							</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
		</xsl:template>

	<xsl:template match="lpage" mode="dump">
			<xsl:apply-templates mode="back-ref"/>
	</xsl:template>

	<!-- ==================================================================== -->
	<xsl:template match="elocation-id" mode="dump">
	    <xsl:apply-templates mode="dump"/>
	</xsl:template>

	<xsl:template match="uri" mode="dump">
		<xsl:call-template name="uri"/>
	</xsl:template>
	
	<xsl:template match="uri" mode="book">
		<xsl:call-template name="uri"/>&pd-sp;
		</xsl:template>

	<xsl:template match="uri" mode="back-ref">
		<xsl:call-template name="uri"/>&pd-sp;
	</xsl:template>


	<!-- these nodes are processed elsewhere -->
	<xsl:template match="day" mode="dump">
	    <xsl:apply-templates/>
	</xsl:template>

	<!-- need to catch x nodes with non breaking space -->
	<xsl:template match="x" mode="dump">
	    <xsl:choose>
		<xsl:when test="count(following-sibling::node()) = 0
				and string(.) = '@#x000a0;'"/>
		<xsl:otherwise><xsl:apply-templates/></xsl:otherwise>
	    </xsl:choose>
	</xsl:template>

	<xsl:template match="pub-id[@pub-id-type='coden'] | issn" mode="dump"/>

	<xsl:template match="pub-id[@pub-id-type='coden'] | issn" mode="back-ref"/>


	<xsl:template match="table-wrap" mode="back-ref">
		<div class="sec">
			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<!-- ######################################################        -->
	<xsl:template match="note" mode="back-ref">
		<span>
			<xsl:apply-templates select="@id" mode="id-attr"/>
			<xsl:apply-templates mode="back-ref"/>
		</span>
		<xsl:if test="position() != last()"><br/></xsl:if>
	</xsl:template>

	<!-- ######################################################        -->
	<xsl:template match="note/p|note/label" mode="back-ref">
			<xsl:apply-templates mode="back-ref"/>
			<xsl:if test="position() != last()"><br/></xsl:if>
	</xsl:template>

	<!-- ######################################################        -->
	<xsl:template match="disp-formula" mode="back-ref">
			<xsl:apply-templates select="."/>
	</xsl:template>

</xsl:stylesheet>




