<?xml version="1.0" encoding="ISO-8859-1"?>	
<xsl:stylesheet 	
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 	
   xmlns:asp="http://www.microsoft.com/ASP.NET"
   version="1.0"	
>	

<xsl:output method="text" indent="no"/>
<xsl:template match="DTD">
  <xsl:apply-templates select="ELEMNTGROUP">
      <xsl:sort select="@Order" data-type="number" order="ascending"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="ELEMNTGROUP">
  <xsl:variable name="OROP">OR</xsl:variable>
  <xsl:variable name="ANDOP">AND</xsl:variable>
  <xsl:variable name="REQUIREDOP">REQUIRED</xsl:variable>
  <xsl:variable name="ELEMNTGROUPOPERATOR"><xsl:value-of select="$OROP"/></xsl:variable>
  <xsl:variable name="EXACTLYONE">EXACTLYONE</xsl:variable>
  <xsl:variable name="ZEROORMORE">ZEROORMORE</xsl:variable>
  <xsl:variable name="ONEORMORE">ONEORMORE</xsl:variable>
  <xsl:variable name="ZEROORMOREOP">*</xsl:variable>
  <xsl:variable name="ONEORMOREOP">+</xsl:variable>
  <xsl:variable name="QUESTION">?</xsl:variable>
  <xsl:for-each select="ELEMNT">
   <xsl:variable name="GT"> &gt; </xsl:variable>
   <xsl:variable name="LT"> &lt; </xsl:variable>
   <xsl:variable name="LEFTPAR"> ( </xsl:variable>
	<xsl:variable name="RIGHTPAR"> ) </xsl:variable>
	<xsl:variable name="COMMA"> , </xsl:variable>
	<xsl:variable name="ORSYMBOL"> | </xsl:variable>
 	<xsl:variable name="elementName"> <xsl:value-of select="@Name"/> </xsl:variable>
 	<xsl:variable name="CDATA">CDATA</xsl:variable>
	<xsl:variable name="TRUE">TRUE</xsl:variable>
	<xsl:value-of select="$LT"/><xsl:value-of select="concat(concat(&quot;!ELEMENT &quot;,$elementName),&quot; &quot;)"/>
	<xsl:value-of select="$LEFTPAR"/>
	<xsl:variable name="ELEMENTGROUPOPERATOR"><xsl:value-of select="$OROP"/></xsl:variable>
 	<xsl:for-each select="ELEMNTGROUP">
 	   <xsl:variable name="ORLOGIC"><xsl:value-of select="@LogicalOR"/></xsl:variable>
   	   <xsl:variable name="ANDLOGIC"><xsl:value-of select="@LogicalAND"/></xsl:variable>
   	   <xsl:variable name="GRPREQUIRED"><xsl:value-of select="@Required"/></xsl:variable>
	   <xsl:if test="$ORLOGIC=$TRUE"><xsl:variable name="ELEMENTGROUPOPERATOR"><xsl:value-of select="$OROP"/></xsl:variable></xsl:if>
	   <xsl:if test="$ANDLOGIC=$TRUE"><xsl:variable name="ELEMENTGROUPOPERATOR"><xsl:value-of select="$ANDOP"/></xsl:variable></xsl:if>   	   
       <xsl:value-of select="$LEFTPAR"/>
 	   <xsl:for-each select="ELEMNT">
  		<xsl:variable name="eleName"><xsl:value-of select="concat(concat(&quot; &quot;,@Name),&quot; &quot;)"/></xsl:variable>
  		<xsl:variable name="eleRequired"><xsl:value-of select="@Required"/></xsl:variable>
  		<xsl:variable name="eleMultiplicity"><xsl:value-of select="@Multiplicity"/></xsl:variable>
  		<xsl:variable name="eleDefaultValue"><xsl:value-of select="@DefaultValue"/></xsl:variable>
  	    <xsl:if test="position()!=1">
	     <xsl:if test="$ELEMENTGROUPOPERATOR=$OROP"><xsl:value-of select="$ORSYMBOL"/></xsl:if>
	     <xsl:if test="$ELEMENTGROUPOPERATOR=$ANDOP"><xsl:value-of select="$COMMA"/></xsl:if>
	    </xsl:if>
        <xsl:value-of select="$LEFTPAR"/>
 		<xsl:choose>
         <xsl:when test="$eleMultiplicity!=$EXACTLYONE">
 	        <xsl:if test="$eleMultiplicity=$ONEORMORE"><xsl:value-of select="$LEFTPAR"/><xsl:value-of select="$eleName"/><xsl:value-of select="$RIGHTPAR"/><xsl:value-of select="$ONEORMOREOP"/></xsl:if>
 	        <xsl:if test="$eleMultiplicity=$ZEROORMORE"><xsl:value-of select="$LEFTPAR"/><xsl:value-of select="$eleName"/><xsl:value-of select="$RIGHTPAR"/><xsl:value-of select="$ZEROORMOREOP"/></xsl:if>
 		 </xsl:when>
	     <xsl:otherwise>      
			<xsl:value-of select="$eleName"/>
		 </xsl:otherwise>
		</xsl:choose>
	    <xsl:value-of select="$RIGHTPAR"/>
	    <xsl:if test="$TRUE!=$eleRequired">
		   	<xsl:value-of select="$QUESTION"/>
		</xsl:if>
   	  </xsl:for-each>
     <xsl:value-of select="$RIGHTPAR"/>
     <xsl:if test="$TRUE!=$GRPREQUIRED">
		<xsl:value-of select="$QUESTION"/>
	 </xsl:if>
     </xsl:for-each>
     <xsl:value-of select="$RIGHTPAR"/>
     
	 <xsl:variable name="PCDAT"> (#PCDATA) </xsl:variable>
	 
     <xsl:value-of select="$PCDAT"/><xsl:value-of select="$GT"/>
     
     <xsl:for-each select="ATTLST">
 	   <xsl:value-of select="$LT"/><xsl:value-of select="concat(concat(&quot;!ATTLIST &quot;,$elementName),&quot; &quot;)"/>
  	   <xsl:for-each select="ATT">
  		<xsl:variable name="attName"><xsl:value-of select="concat(concat(&quot; &quot;,@Name),&quot; &quot;)"/></xsl:variable>
  		<xsl:variable name="attRequired"><xsl:value-of select="@Required"/></xsl:variable>
  		<xsl:variable name="attDefaultValue"><xsl:value-of select="@DefaultValue"/></xsl:variable>
  		<xsl:value-of select="$attName"/>
		<xsl:choose>
		  <xsl:when test="$CDATA=@Type">
		   <xsl:variable name="CDAT"> CDATA </xsl:variable>
		   <xsl:value-of select="$CDAT"/>
		   <xsl:choose><xsl:when test="$TRUE=string($attRequired)"> <xsl:variable name="REQ"> #REQUIRED </xsl:variable><xsl:value-of select="$REQ"/> </xsl:when><xsl:otherwise> <xsl:variable name="IMP"> #IMPLICIT </xsl:variable><xsl:value-of select="$IMP"/> </xsl:otherwise></xsl:choose>
		  </xsl:when>
		  <xsl:otherwise>
			<xsl:variable name="LEFTPAR"> ( </xsl:variable>
			<xsl:variable name="RIGHTPAR"> ) </xsl:variable>
			<xsl:value-of select="$LEFTPAR"/><xsl:for-each select="ATTITEM"><xsl:if test="position()!=1">|</xsl:if>"<xsl:value-of select="@Name"/>"</xsl:for-each><xsl:value-of select="$RIGHTPAR"/>
	     </xsl:otherwise>
	    </xsl:choose> 
	   <xsl:if test="string-length(string($attDefaultValue))!=0"> "<xsl:value-of select="$attDefaultValue"/>" </xsl:if>
 	  </xsl:for-each>
 	  <xsl:value-of select="$GT"/>
     </xsl:for-each>
    <xsl:apply-templates select="ELEMNTGROUP">
      <xsl:sort select="@Order" data-type="number" order="ascending"/>
    </xsl:apply-templates>
   </xsl:for-each> 
</xsl:template>
</xsl:stylesheet>





