<?xml version="1.0" encoding="ISO-8859-1"?>	
<xsl:stylesheet 	
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 	
   version="1.0"	
>	

<xsl:output method="text" indent="no"/>

<xsl:template match="VisualWeb">
  <xsl:apply-templates select="HTML">
    <xsl:sort select="@Order" data-type="number" order="ascending"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="HTML">
package <xsl:value-of select="../@Package"/>;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;

public class <xsl:value-of select="@Name"/>_<xsl:value-of select="@ID"/>
extends HttpServlet
{
  public String html="";


  public void init(ServletConfig conf) throws ServletException
  {
    super.init(conf);
    <xsl:call-template name="ServletInitBody"/>
  }

  public void doGet(HttpServletRequest req,HttpServletResponse resp)
    throws ServletException, IOException
  {
    resp.setContentType("text/html");
    PrintWriter out=resp.getWriter();
    out.println(html);
    <xsl:apply-templates select="*">
      <xsl:sort select="@Order" data-type="number" order="ascending"/>
      <xsl:with-param name="Action">SubmitBody</xsl:with-param>
    </xsl:apply-templates>
  }

  public void doPost(HttpServletRequest req,HttpServletResponse resp)
    throws ServletException, IOException
  {
    doGet(req,resp);
  }
}
</xsl:template>

<xsl:template name="setVariables">
<xsl:param name="Str"></xsl:param>
<xsl:param name="StrCt"></xsl:param>
     <xsl:if test="not(contains($Str,'@'))">
	<xsl:value-of select="$Str"/>
     </xsl:if>
     <xsl:for-each select="../@*[position()>number($StrCt)]">
        <xsl:if test="contains($Str,concat('@',name(),'@'))">
	   <xsl:call-template name="setVariables">
	   <xsl:with-param name="Str">
	     <xsl:value-of select="concat(substring-before($Str,concat('@',name(),'@')),translate(.,'&quot;',&quot;&apos;&quot;),substring-after($Str,concat('@',name(),'@')))"/>
           </xsl:with-param>
	   <xsl:with-param name="StrCt" select="string(number($StrCt)+position())"/>
  	   </xsl:call-template>
        </xsl:if>
     </xsl:for-each>
</xsl:template>

<xsl:template name="ServletInitBody">
    <xsl:if test="string-length(@BeforeHtml)!=0">
    <xsl:variable name="NodeVal" select="translate(@BeforeHtml,'&quot;',&quot;&apos;&quot;)"/>
     <xsl:variable name="NodeValue">
      <xsl:choose>
      <xsl:when test="name()='Form'">	
	<xsl:variable name="FormVal">
        <xsl:apply-templates select=".">
	  <xsl:with-param name="Action">ServletInitBody</xsl:with-param>
      	  <xsl:with-param name="NodeValue">
	    <xsl:value-of select="$NodeVal"/>
	  </xsl:with-param>
        </xsl:apply-templates>
	</xsl:variable>
	<xsl:if test="string-length($FormVal)=0">
	    <xsl:value-of select="$NodeVal"/>
	</xsl:if>
	<xsl:if test="string-length($FormVal)!=0">
	    <xsl:value-of select="$FormVal"/>
	</xsl:if>
      </xsl:when>
      <xsl:when test="name()='Href'">	
        <xsl:variable name="HrefVal">
	<xsl:apply-templates select=".">
	  <xsl:with-param name="Action">ServletInitBody</xsl:with-param>
      	  <xsl:with-param name="NodeValue">
	    <xsl:value-of select="$NodeVal"/>
	  </xsl:with-param>
        </xsl:apply-templates>
	</xsl:variable>
	<xsl:if test="string-length($HrefVal)=0">
	    <xsl:value-of select="$NodeVal"/>
	</xsl:if>
	<xsl:if test="string-length($HrefVal)!=0">
	    <xsl:value-of select="$HrefVal"/>
	</xsl:if>
      </xsl:when>
      <xsl:otherwise>
	    <xsl:value-of select="$NodeVal"/>
      </xsl:otherwise>
      </xsl:choose>
     </xsl:variable>

      <xsl:choose>
      <xsl:when test="not(contains($NodeValue,'@'))">
    html+="<xsl:value-of select="$NodeValue"/>";
      </xsl:when>
      <xsl:otherwise>
    html+="<xsl:for-each select="@*">
 	<xsl:choose>
	<xsl:when test="contains($NodeValue,concat('@',name(),'@'))">
	   <xsl:call-template name="setVariables">
	   <xsl:with-param name="Str">
	     <xsl:value-of select="concat(substring-before($NodeValue,concat('@',name(),'@')),translate(.,'&quot;',&quot;&apos;&quot;),substring-after($NodeValue,concat('@',name(),'@')))"/>
           </xsl:with-param>
	   <xsl:with-param name="StrCt" select="string(position())"/>
  	   </xsl:call-template>
	</xsl:when>
	</xsl:choose>
      </xsl:for-each>";
      </xsl:otherwise>
      </xsl:choose>

    </xsl:if>

    <xsl:for-each select="*">
    <xsl:sort select="@Order" data-type="number" order="ascending"/>
      <xsl:call-template name="ServletInitBody"/>
    </xsl:for-each>

    <xsl:if test="string-length(@AfterHtml)!=0">
    <xsl:variable name="NodeValue" select="translate(@AfterHtml,'&quot;',&quot;&apos;&quot;)"/>
      <xsl:choose>
      <xsl:when test="not(contains($NodeValue,'@'))">
    html+="<xsl:value-of select="$NodeValue"/>";
      </xsl:when>
      <xsl:otherwise>
    html+="<xsl:for-each select="@*">
 	<xsl:choose>
	<xsl:when test="contains($NodeValue,concat('@',name(),'@'))">
	   <xsl:call-template name="setVariables">
	   <xsl:with-param name="Str">
	     <xsl:value-of select="concat(substring-before($NodeValue,concat('@',name(),'@')),translate(.,'&quot;',&quot;&apos;&quot;),substring-after($NodeValue,concat('@',name(),'@')))"/>
           </xsl:with-param>
	   <xsl:with-param name="StrCt" select="string(position())"/>
  	   </xsl:call-template>
	</xsl:when>
	</xsl:choose>
      </xsl:for-each>";
      </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
</xsl:template>

<xsl:template match="Form">
<xsl:param name="Action"></xsl:param>
<xsl:param name="NodeValue"></xsl:param>
<xsl:if test="$Action='ServletInitBody'">
  <xsl:if test="contains($NodeValue,&quot;Action=&apos;&apos;&quot;)">
    <xsl:for-each select="Connection">
    <xsl:variable name="DestID"><xsl:value-of select="@DestID"/></xsl:variable>
    <xsl:for-each select="/VisualWeb/*">
    <xsl:if test="$DestID=@ID">
    <xsl:variable name="URI">Action='<xsl:value-of select="/VisualWeb[1]/@URI"/>/<xsl:value-of select="@Name"/>'</xsl:variable>
    <xsl:value-of select="concat(substring-before($NodeValue,&quot;Action=&apos;&apos;&quot;),$URI,substring-after($NodeValue,&quot;Action=&apos;&apos;&quot;))"/>
    </xsl:if>
    </xsl:for-each>
    </xsl:for-each>
  </xsl:if>
</xsl:if>
</xsl:template>

<xsl:template match="Href">
<xsl:param name="Action"></xsl:param>
<xsl:param name="NodeValue"></xsl:param>
<xsl:if test="$Action='ServletInitBody'">
  <xsl:if test="contains($NodeValue,&quot;Href=&apos;&apos;&quot;)">
    <xsl:for-each select="Connection">
    <xsl:variable name="DestID"><xsl:value-of select="@DestID"/></xsl:variable>
    <xsl:for-each select="/VisualWeb/*">
    <xsl:if test="$DestID=@ID">
    <xsl:variable name="URI">Href='<xsl:value-of select="/VisualWeb[1]/@URI"/>/<xsl:value-of select="@Name"/>'</xsl:variable>
    <xsl:value-of select="concat(substring-before($NodeValue,&quot;Href=&apos;&apos;&quot;),$URI,substring-after($NodeValue,&quot;Href=&apos;&apos;&quot;))"/>
    </xsl:if>
    </xsl:for-each>
    </xsl:for-each>
  </xsl:if>
</xsl:if>
</xsl:template>

</xsl:stylesheet>
