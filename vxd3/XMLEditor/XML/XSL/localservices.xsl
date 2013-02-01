<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/TR/WD-xsl">
	<xsl:template match="/">
		<h1 id="112">Web Services on the Local Machine</h1>
		<p id="113">The Web services and Discovery Documents available on your VS.NET developer
			machine are listed below. Click the service link to browse that service.</p>
		<table class="listpage" cellpadding="3" cellspacing="1" frame="void" bordercolor="#ffffff" rules="rows" width="100%" align="center">
    	    <xsl:choose>
				<xsl:when test="localDiscovery/contractRef">
					<tr valign="center" align="left">
						<td class="header" width="125" id="100" nowrap="true">Services</td>
						<td class="header" id="120">URL</td>
					</tr>
					<xsl:for-each select="localDiscovery/contractRef" order-by='@ref'>
						<tr valign="center" align="left">
							<td class="tbltext">
								<a id="101"><xsl:attribute name="href"><xsl:value-of select="@ref" /></xsl:attribute><xsl:value-of select="@name" /></a>
							</td>
							<td class="tbltext" nowrap="true">
								<xsl:value-of select="@ref" />
							</td>
						</tr>
					</xsl:for-each>
				</xsl:when>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="localDiscovery/discoveryRef">
					<tr valign="center" align="left">
						<td class="header" id="200">Discovery Documents</td>
						<td class="header" id="220">URL</td>
					</tr>
					<xsl:for-each select="localDiscovery/discoveryRef" order-by='@ref'>
						<tr valign="center" align="left">
							<td class="tbltext">
								<a id="102"><xsl:attribute name="href"><xsl:value-of select="@ref" /></xsl:attribute><xsl:value-of select="@name" /></a>
							</td>
							<td class="tbltext" nowrap="true">
								<xsl:value-of select="@ref" />
							</td>
						</tr>
					</xsl:for-each>
				</xsl:when>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="localDiscovery/contractRef | localDiscovery/discoveryRef"></xsl:when>
				<xsl:otherwise>
					<tr>
						<td class="tbltext" colspan="2" id="111">None - No Web services were found on the local computer.</td>
					</tr>
				</xsl:otherwise>
			</xsl:choose>
		</table>
	</xsl:template>
</xsl:stylesheet>
