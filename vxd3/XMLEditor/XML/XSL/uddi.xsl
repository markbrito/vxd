<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/TR/WD-xsl">
	<xsl:template match="/">
		<h1 id="102">UDDI Servers</h1>
		<p id="103">The UDDI servers available on your local area network are listed below. Click the server link to browse that server.</p>
        <table class="listpage" cellpadding="3" cellspacing="1" frame="void" bordercolor="#ffffff" rules="rows" width="100%" align="center">
    	    <xsl:choose>
				<xsl:when test="uddiservers/serverRef">
					<tr valign="center" align="left">
						<td class="header" width="125" id="100" nowrap="true">Description</td>
						<td class="header" id="120">Server Address</td>
					</tr>
					<xsl:for-each select="uddiservers/serverRef" order-by='@ref'>
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
				<xsl:when test="uddiservers/serverRef"></xsl:when>
				<xsl:otherwise>
					<tr>
						<td class="tbltext" colspan="2" id="111">No UDDI servers were found on the local network.</td>
					</tr>
				</xsl:otherwise>
			</xsl:choose>
		</table>
	</xsl:template>
</xsl:stylesheet>
