<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:msdn="http://msdn.microsoft.com/"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt">

<xsl:template match="/">
	<ul>
		<xsl:attribute name="style">cursor:hand;text-indent:10pxl;list-style-type:none;margin-left:5px;margin-right:15px;margin-top:5px;</xsl:attribute>
		<xsl:apply-templates select="/dir/fold"/>
		<xsl:apply-templates select="/dir/file"/>
	</ul>
</xsl:template>

<xsl:template match="fold">
	<li>
		<xsl:attribute name="value"><xsl:value-of select="@path"/></xsl:attribute>
		<xsl:attribute name="protected"><xsl:value-of select="@protected"/></xsl:attribute>

		<img hspace="2">
			<xsl:attribute name="src">images\greenfolder.gif</xsl:attribute>
		</img>

		<a class="folderelement">
			<xsl:value-of select="@title"/>
		</a>

		<ul>
			<xsl:attribute name="style">list-style-type:none;margin-left:5px;margin-right:15px;margin-top:2px;display:none</xsl:attribute>
			<xsl:apply-templates select="fold"/>
			<xsl:apply-templates select="file"/>
		</ul>
	</li>
</xsl:template>

<xsl:template match="file">
	<li>
		<xsl:attribute name="value"><xsl:value-of select="@path"/></xsl:attribute>
		<xsl:attribute name="style">text-indent:0px;list-style-type:none;margin-left:2px;margin-right:15px;margin-top:2px;</xsl:attribute>
		<xsl:attribute name="protected"><xsl:value-of select="@protected"/></xsl:attribute>

		<img hspace="2">
			<xsl:attribute name="src">images\bluepage.gif</xsl:attribute>
		</img>

		<a class="fileelement">
			<xsl:value-of select="text()"/>
		</a>
	</li>
</xsl:template>

</xsl:stylesheet>