<?xml version="1.0" encoding="ISO-8859-1"?>	
<xsl:stylesheet 	
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 	
   xmlns:asp="http://www.microsoft.com/ASP.NET"
   version="1.0"	
>	

<xsl:output method="text" indent="no"/>
<xsl:template match="VisualHTML">
  <xsl:apply-templates select="*">
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="*">
&lt;<xsl:value-of select="name()"/> ID=&quot;<xsl:value-of select="@Name"/>&quot;&gt;
  <xsl:apply-templates select="*"/>
&lt;/<xsl:value-of select="name()"/>&gt;
</xsl:template>
</xsl:stylesheet>





