<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:disco="http://schemas.xmlsoap.org/disco/" xmlns:scl="http://schemas.xmlsoap.org/disco/scl/"
	 xmlns:xsd="http://www.w3.org/2001/XMLSchema/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance/" xmlns:ms="urn:schemas-microsoft-com:xslt" xmlns:s="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="disco scl ms s xsi xsd">
	<xsl:output method="html" />
	<xsl:template match="/">
		<h1 class="listpage" id="113">Discovery Page</h1>
		<p class="listpage" id="114">This discovery document represents a
			group of web services (e.g. service.wsdl), datasets (e.g. dataset.xsd), and
			other discovery documents (e.g. group.disco) that may be consumed together. </p>
		<h3 id="115">Web Service Group contents:</h3>
		<table class="listpage" borderColor="#ffffff" cellSpacing="0" cellPadding="0" rules="rows" width="100%" align="center" frame="void">
			<xsl:choose>
				<xsl:when test="disco:discovery/scl:contractRef">
			        <tr valign="center" align="left">
				        <td class="tbltext">
					        <table borderColor="#ffffff" cellSpacing="0" cellPadding="3" rules="rows" width="100%" border="1" frame="void">
        						<tr>
		        					<td class="header" id="100">Services</td>
		        			    </tr>
					            <xsl:for-each select="disco:discovery/scl:contractRef">
                					<xsl:sort select="@ref" />
						            <tr vAlign="center">
							            <td class="tbltext">
							                <xsl:value-of select="@ref" /><br />
							                    <a id="101"><xsl:call-template name ="writeHrefAttrib"> <xsl:with-param name="url" select="@ref" /></xsl:call-template>View Service</a>
									        &#160;&#160;&#160;&#160;&#160;<a id="102"><xsl:call-template name ="writeHrefAttrib"> <xsl:with-param name="url" select="@docRef" /></xsl:call-template>View Documentation</a>
									    </td>
									</tr>
    				            </xsl:for-each>
    				        </table>
				        </td>
			        </tr>
					<tr>
						<td class="spacer" bgColor="white" height="5">&#160;</td>
					</tr>
				</xsl:when>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="disco:discovery/scl:schemaRef">
					<tr valign="center" align="left">
						<td class="tbltext">
					        <table borderColor="#ffffff" cellSpacing="0" cellPadding="3" rules="rows" width="100%" border="1" frame="void">
								<tr>
									<td class="header" id="112">DataSets</td>
								</tr>
            					<xsl:for-each select="disco:discovery/scl:schemaRef">
                					<xsl:sort select="@ref" />
			        			    <tr valign="center">
					        		    <td class="tbltext"><xsl:value-of select="@ref" /><br /><a id="103"><xsl:call-template name ="writeHrefAttrib"> <xsl:with-param name="url" select="@ref" /></xsl:call-template><BR/>View Schema</a>
									    </td>
								    </tr>
            					    </xsl:for-each>
    				        </table>
				        </td>
			        </tr>
					<tr>
						<td class="spacer" bgColor="white" height="5">&#160;</td>
					</tr>
				</xsl:when>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="disco:discovery/scl:discoveryRef">
					<tr valign="center" align="left">
						<td class="tbltext">
					        <table borderColor="#ffffff" cellSpacing="0" cellPadding="3" rules="rows" width="100%" border="1" frame="void">
								<tr>
									<td class="header" id="104">Discovery Documents</td>
								</tr>
            					<xsl:for-each select="disco:discovery/scl:discoveryRef">
                					<xsl:sort select="@ref" />
			        			    <tr valign="center">
					        		    <td class="tbltext"><xsl:value-of select="@ref" /><br /><a id="106"><xsl:call-template name ="writeHrefAttrib"> <xsl:with-param name="url" select="@ref" /></xsl:call-template><BR/>View Discovery Document</a>
									    </td>
								    </tr>
            					    </xsl:for-each>
    				        </table>
				        </td>
			        </tr>
					<tr>
						<td class="spacer" bgColor="white" height="5">&#160;</td>
					</tr>
				</xsl:when>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="disco:discovery/scl:contractRef | disco:discovery/scl:schemaRef | disco:discovery/scl:discoveryRef"></xsl:when>
				<xsl:otherwise>
					<tr valign="center">
						<td class="tbltext" id="105">No Web References were defined by this discovery document.</td>
					</tr>
				</xsl:otherwise>
			</xsl:choose>
		</table>
	</xsl:template>
	
	<xsl:template name="writeHrefAttrib">
	    <xsl:param name="url" />
	    <xsl:variable name="urllower" select="normalize-space(translate($url,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'))" />
            <xsl:choose>
                <xsl:when test="starts-with($urllower,'http:') or starts-with($urllower,'https:') or starts-with($urllower,'ftp:')">
                    <xsl:attribute name="href">
                        <xsl:value-of select="$url" />
                    </xsl:attribute>
                </xsl:when>
            </xsl:choose>
	</xsl:template>
</xsl:stylesheet>
