<?xml version="1.0" encoding="utf-16"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output omit-xml-declaration="no" method="xml" encoding="utf-16" indent="yes"/>
	<xsl:strip-space elements="&#x020;&#x09;&#x0D;&#x0A;"/>
	<xsl:template match="/">
		<xsl:element name="DsJob">
			<xsl:element name="Job">

				<xsl:apply-templates select="/html/body/table/tr/td/div/table"/>

				<xsl:element name="applyURL">
					<xsl:value-of select="/html/body/table/tr/td/div/table/tr/td/table/tr/td/a/@href"/>
				</xsl:element>
				<xsl:element name="logoImageURL">
					<xsl:value-of select="/html/body/table/tr/td/div/a/img/@src"/>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<xsl:template match="tr">
		<xsl:variable name="ndLabel" select="normalize-space(./td[1]/b/node())"/>
		<xsl:variable name="ndValue" select="concat(normalize-space(./td[2]/node()),normalize-space(./td[2]/b/node()))"/>
		<xsl:if test="contains($ndLabel,':') and (string-length($ndValue) &gt; 0)">
			<xsl:choose>
				<xsl:when test="$ndLabel='Title:'">
					<xsl:element name="title">
						<xsl:value-of select="normalize-space(./td[2]/b/node())"/>
					</xsl:element>
				</xsl:when>
				<xsl:when test="$ndLabel='Position ID:'">
					<xsl:element name="code">
						<xsl:value-of select="$ndValue"/>
					</xsl:element>
				</xsl:when>
				<xsl:when test="$ndLabel='Length:'">
					<xsl:element name="jobLength">
						<xsl:value-of select="$ndValue"/>
					</xsl:element>
				</xsl:when>
				<xsl:when test="$ndLabel='Area code:'">
					<xsl:element name="areacode">
						<xsl:value-of select="$ndValue"/>
					</xsl:element>
				</xsl:when>
				<xsl:when test="$ndLabel='Skills:'">
					<xsl:element name="skills">
						<xsl:value-of select="$ndValue"/>
					</xsl:element>
				</xsl:when>
				<xsl:when test="$ndLabel='Dice ID:'">
					<xsl:element name="recruitingCompany">
						<xsl:value-of select="$ndValue"/>
					</xsl:element>
				</xsl:when>
				<xsl:when test="$ndLabel='Pay rate:'">
					<xsl:element name="payRate">
						<xsl:value-of select="$ndValue"/>
					</xsl:element>
				</xsl:when>
				<xsl:when test="$ndLabel='Area code:'">
					<xsl:element name="zip">
						<xsl:value-of select="$ndValue"/>
					</xsl:element>
				</xsl:when>
				<xsl:when test="$ndLabel='Date:'">
					<xsl:element name="postDate">
						<xsl:value-of select="$ndValue"/>
					</xsl:element>
				</xsl:when>
				<xsl:when test="$ndLabel='Travel required:'">
					<xsl:element name="travelRequired">
						<xsl:value-of select="$ndValue"/>
					</xsl:element>
				</xsl:when>
				<xsl:when test="$ndLabel='Telecommute:'">
					<xsl:element name="telecommute">
						<xsl:value-of select="$ndValue"/>
					</xsl:element>
				</xsl:when>
				<xsl:when test="$ndLabel='Tax term:'">
					<xsl:element name="TaxTerm">
						<xsl:value-of select="$ndValue"/>
					</xsl:element>
				</xsl:when>
				<xsl:when test="$ndLabel='Location:'">
					<xsl:element name="location">
						<xsl:value-of select="$ndValue"/>
					</xsl:element>
					<xsl:element name="city">
						<xsl:value-of select="normalize-space(substring-before($ndValue,','))"/>
					</xsl:element>
					<xsl:element name="state">
						<xsl:value-of select="normalize-space(substring-after($ndValue,','))"/>
					</xsl:element>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
		<xsl:if test="contains(./td[@colspan='2']/b/node(),':')">
			<xsl:choose>
				<xsl:when test="contains(./td[@colspan='2']/b/node(),'Job description:')">
					<xsl:element name="description">
						<xsl:value-of select="(following-sibling::node())/*"/>

					</xsl:element>
				</xsl:when>
				<xsl:when test="contains(./td[@colspan='2']/b/node(),'Contact for more information:')">
					<xsl:element name="company">
						<xsl:value-of select="normalize-space(./td[@colspan='2']/text()[position() = 1])"/>
					</xsl:element>
					<xsl:element name="contactName">
						<xsl:value-of select="normalize-space(substring-after(./td[@colspan='2']/../*,'Contact for more information:'))"/>
					</xsl:element>
					<xsl:element name="zip">
						<xsl:value-of select="concat(normalize-space(substring-after(substring-after(./td[@colspan='2']/text()[position()=6],', '),' ')),normalize-space(substring-after(substring-after(./td[@colspan='2']/text()[position()=5],', '),' ')))"/>
					</xsl:element>
					<xsl:element name="phoneNumber">
						<xsl:value-of select="normalize-space(substring-after(./td[@colspan='2']/../*,'Phone: '))"/>
					</xsl:element>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
		<xsl:if test="contains(./td[@colspan='2']/node(),'Web: ')">
			<xsl:element name="homePageURL">
				<xsl:value-of select="./td/a/@href"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="contains(./td[@colspan='2']/node(),'E-mail: ')">
			<xsl:element name="email">
				<xsl:value-of select="./td/a/@href"/>
			</xsl:element>
		</xsl:if>


	</xsl:template>
</xsl:stylesheet>