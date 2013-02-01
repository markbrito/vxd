<?xml version="1.0" encoding="ISO-8859-1"?>	
<xsl:stylesheet 	
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 	
   xmlns:asp="http://www.microsoft.com/ASP.NET"
   version="1.0"	
>	

<xsl:output method="text" indent="no"/>
<xsl:template match="ASP.NET">
  <xsl:apply-templates select="*">
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="ASPXPage">
&lt;%@ Page Language="C#"%&gt;
  <xsl:apply-templates select="*"/>
</xsl:template>
<xsl:template match="*">
&lt;asp:
<xsl:value-of select="name()"/> 
<xsl:variable name="idname">
<xsl:for-each select="@*">
<xsl:value-of select="concat(idname,.)"/>
</xsl:for-each>
</xsl:variable>
<xsl:value-of select="concat(' ID=&quot;',$idname)"/>&quot;
<xsl:for-each select="@*">
<xsl:if test="string-length(.)!=0">
<xsl:value-of select="concat(' ',name())"/>=&quot;<xsl:value-of select="."/>&quot;
</xsl:if>

  <xsl:apply-templates select="*"/>
</xsl:for-each>&gt;
&lt;/<xsl:value-of select="name()"/>
&gt;
</xsl:template>
</xsl:stylesheet>





