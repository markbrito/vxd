<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 	xmlns:msdn="http://msdn.microsoft.com/"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt">

<msxsl:script language="jscript" implements-prefix="msdn">
		function PresentEncodedText(oNode, sAttribute) {
			var sReturn = "";
			var sText = "";
			if (sAttribute != "null") {
				sText = oNode.nextNode().getAttribute(sAttribute);
			} else {
				sText = oNode.nextNode().text;
			}
			
			try {
				return unescape(sText);
				
			} catch (e) {
				return decodeURI(sText);
			}
			return sReturn;
		}
</msxsl:script>


<xsl:variable name="fontname">verdana</xsl:variable>
<xsl:variable name="fontsize">1</xsl:variable>
<xsl:variable name="fontcolor">windowtext</xsl:variable>
<xsl:variable name="baseclass">homepageinactive</xsl:variable>

<xsl:template match="/">
<!-- ****** RESULTS CONTAINER ****** -->
<xsl:if test="/root/totalresultcount[.!=0]">
<table border="0" width="100%" cellpadding="2" cellspacing="0" style="border: none">
<tr>
	<td valign="center">
	<div style="border-bottom:1px solid menu;font-size:8pt">
		<xsl:if test="/root/prevnav[.='y']">
			<a>
				<xsl:attribute name="href">javascript:fnSrchMsdn('recurse','<xsl:value-of select="/root/prevnavqs" />')</xsl:attribute>
				<font face="webdings" size="2">3</font>
			</a>
		</xsl:if>
		<xsl:value-of select="/root/resultsctrlmsg" />
		<xsl:if test="/root/nextnav[.='y']">
			<a>
				<xsl:attribute name="href">javascript:fnSrchMsdn('recurse','<xsl:value-of select="/root/nextnavqs" />')</xsl:attribute>
				<font face="webdings" size="2">4</font>
			</a>
		</xsl:if>
	</div>
	</td>
</tr>
<tr>
<td>
	<table id="tblDisplayResults" class="tblDisplayResults" width="100%" cellpadding="0" cellspacing="0" style="border: none">
	<tbody>
	<!--
	'  **********************************************************************
	'  *** BEGIN - BestBets
	'  **********************************************************************
	-->
		<xsl:if test="/root/totalbestbetscount[.!=0]">
			<xsl:apply-templates mode="msdn:bestbetsrecord" select="/root/bestbets/record" />
		</xsl:if>

	<!--
	'  **********************************************************************
	'  *** END - BestBets
	'  **********************************************************************
	-->
	</tbody>
	</table>
</td>
</tr>

<tr>
<td>
	<table id="tblDisplayResults" class="tblDisplayResults" width="100%" cellpadding="0" cellspacing="0" style="border: none">
	<tbody>
	<!--
	'  **********************************************************************
	'  *** BEGIN - Results
	'  **********************************************************************
	-->
		<xsl:apply-templates mode="msdn:resultrecord" select="/root/searchresults/record" />
	<!--
	'  **********************************************************************
	'  *** END - Results
	'  **********************************************************************
	-->
	</tbody>
	</table>
</td>
</tr>

</table>
</xsl:if>

<!-- END RESULTS -->
</xsl:template>


<xsl:template mode="msdn:cgscopetext" match="catgroup">
	<xsl:if test="position() = last()"><xsl:text> </xsl:text><xsl:value-of select="/root/searchusingscopeconjuncttxt" /><xsl:text disable-output-escaping="yes"> </xsl:text></xsl:if>
	<xsl:if test="(position() &lt; last()) and (position() &gt; 1)">, </xsl:if>
	<xsl:value-of select="@description"/>
</xsl:template>


<xsl:template mode="msdn:bestbetsrecord" match="record">
		<xsl:variable name="url">
			<xsl:call-template name="validateurl">
				<xsl:with-param name="url">
					<xsl:value-of select="./url"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<tr>
		<td>
				<font>
				<xsl:attribute name="class"><xsl:value-of select="$baseclass"/></xsl:attribute>
				<xsl:attribute name="color">red</xsl:attribute>			
					<nobr><xsl:value-of select="/root/bestbetstext"/></nobr>
				</font>
		</td>
		<td>
			<font>
			<a>
				<xsl:attribute name="class"><xsl:value-of select="$baseclass"/></xsl:attribute>
				<xsl:attribute name="href"><xsl:value-of select="./url"/></xsl:attribute>
				<xsl:attribute name="browserNavigateURL"><xsl:value-of select="$url"/></xsl:attribute>
				<xsl:attribute name="onclick">browserNavigate(0,this.browserNavigateURL); return false;</xsl:attribute>
				<xsl:attribute name="onMouseOver">
					javascript:fnvsSetStatus('<xsl:value-of select="$url" />'); return false;
				</xsl:attribute>
				<xsl:attribute name="onMouseOut">
					javascript:fnvsClearStatus(); return false;
				</xsl:attribute>
				<xsl:value-of select="title" />
			</a>
			<br/>
			</font>
	</td>
	<td></td>
	</tr>

</xsl:template>

<!-- Results Record Templates /root/results-->

<xsl:template match="summary">
	<font>
	<xsl:attribute name="class"><xsl:value-of select="$baseclass"/></xsl:attribute>
	<b><xsl:value-of select="/root/resultsummarytxt"/>:</b>
	<xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>
	<xsl:value-of select="msdn:PresentEncodedText(., 'null')" />
	</font>

</xsl:template>

<xsl:template match="resultcategorytxt">
	<font>
	<xsl:attribute name="class"><xsl:value-of select="$baseclass"/></xsl:attribute>
	<b><xsl:value-of select="."/></b><xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text><xsl:value-of select="./category"/>:<xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text><xsl:value-of select="./sitename"/>
	</font>
</xsl:template>

<xsl:template mode="msdn:hiddenqu" match="qu">
	<input type="hidden" name="qu">
		<xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
	</input>
</xsl:template>

<xsl:template mode="quqsbuilder" match="qu">
	<xsl:text disable-output-escaping="yes">&amp;qu=</xsl:text><xsl:value-of select="."/>
</xsl:template>

<xsl:template mode="msdn:resultrecord" match="record">
		<xsl:variable name="url">
			<xsl:call-template name="validateurl">
				<xsl:with-param name="url">
					<xsl:value-of select="vpath"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="/root/sortorder[.!='RECCNT']">
			<!--
			<xsl:if test="./@isheader[.='y']">
				<tr>
				<td colspan="2">
					<font>
					<xsl:attribute name="color">maroon</xsl:attribute>
					<div>
						<xsl:attribute name="id"><xsl:value-of select="./category"/></xsl:attribute>
						<xsl:attribute name="class"><xsl:value-of select="$baseclass"/></xsl:attribute>
						<b><xsl:value-of select="categoryname"/></b>
					</div>
					</font>
				</td>
				</tr>
			</xsl:if>
			-->
		</xsl:if>
		<tr>
			<td width="4%" valign="top">
			<nobr>
				<font>
					<xsl:attribute name="class"><xsl:value-of select="$baseclass"/></xsl:attribute>
					<xsl:value-of select="reccnt"/>.
				</font>		
				<font>
					<xsl:attribute name="color">#999999</xsl:attribute>
					<xsl:attribute name="class"><xsl:value-of select="$baseclass"/></xsl:attribute>
					<xsl:value-of select="relevancy"/>
				</font>
			</nobr>
			</td>
			<td width="96%" valign="top">
				
				<font>
				<a>
					<xsl:attribute name="class"><xsl:value-of select="$baseclass"/></xsl:attribute>
					<xsl:attribute name="href"><xsl:value-of select="vpath"/></xsl:attribute>
					<xsl:attribute name="browserNavigateURL"><xsl:value-of select="$url"/></xsl:attribute>
					<xsl:attribute name="onclick">browserNavigate(0,this.browserNavigateURL); return false;</xsl:attribute>
					<!--<xsl:value-of select="msdn:PresentEncodedText(./title, null)" />-->
					<xsl:attribute name="onMouseOver">
						javascript:fnvsSetStatus('<xsl:value-of select="$url" />'); return false;
					</xsl:attribute>
					<xsl:attribute name="onMouseOut">
						javascript:fnvsClearStatus(); return false;
					</xsl:attribute>
					<xsl:value-of select="title" />
				</a>
				</font>
				<br />
					<xsl:apply-templates select="summary" />
					<xsl:if test="/root/showcategorysite[.='y']">
						<br />
							<xsl:apply-templates select="/root/resultscategorytxt" />
					</xsl:if>
			</td>
		
		<td valign="top" align="left" nowrap="true">
			<xsl:apply-templates select="sitename" />
		</td>
		</tr>
		<tr><td colspan="3"><br/></td></tr>

</xsl:template>

<xsl:template match="sitename">
	<font>
		<b>
		<xsl:attribute name="class"><xsl:value-of select="$baseclass"/></xsl:attribute>
			<xsl:value-of select="."/>
		</b>
	</font>

</xsl:template>

<xsl:template match="resultsctrlmsg">

	<xsl:if test="/root/totalresultcount[.!=0]">
		<font>
		<xsl:attribute name="class"><xsl:value-of select="$baseclass"/></xsl:attribute>
		<xsl:value-of select="/root/resultsctrlmsg"/>
		</font>
	</xsl:if>

</xsl:template>


<xsl:template mode="msdn:pagenavctrl" match="prevnav">

<xsl:if test="/root/totalresultcount[.!=0]">
	<xsl:if test="/root/prevnav[.='y']">
		<xsl:apply-templates select="/root/prevnavtext" />
	</xsl:if>

	<xsl:apply-templates select="/root/pagesnav" />

	<xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>
	<xsl:if test="/root/nextnav[.='y']">
		<xsl:apply-templates select="/root/nextnavtext" />
	</xsl:if>
</xsl:if>

</xsl:template>

<!-- This template is used to validate urls -->
<xsl:template name="validateurl">
	<xsl:param name="url" /><xsl:choose><xsl:when test="starts-with($url, 'http:') or starts-with($url, '&#x2F;') or starts-with($url, 'https:') or starts-with($url, 'news:') or starts-with($url, 'ms-help:') or starts-with($url, 'vs:')"><xsl:value-of select="$url" /></xsl:when><xsl:otherwise>about:blank</xsl:otherwise></xsl:choose>
</xsl:template>

</xsl:stylesheet>