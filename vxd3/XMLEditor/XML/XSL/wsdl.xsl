<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/"
	xmlns:ms="urn:schemas-microsoft-com:xslt" xmlns:s="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="wsdl ms s">
	<xsl:output method="html" />
	<xsl:template match="wsdl:definitions">

		<xsl:choose>
        <xsl:when test="wsdl:service | wsdl:portType">
		<xsl:choose>
			<xsl:when test="wsdl:service">
				<xsl:for-each select="wsdl:service">
					<xsl:sort select="@name" />
					<h1 class="listpage" id="100">"<xsl:value-of select="@name" />" Description</h1>

					<xsl:if test="wsdl:documentation">
						<h2 id="101">Documentation</h2>
						<p>
							<xsl:value-of select="."/>
						</p>

					</xsl:if>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="wsdl:documentation">
					<h1 class="listpage" id="121">Description</h1>
					<h2 id="120">Documentation</h2>
					<p>
						<xsl:value-of select="."/>
					</p>

				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
		<!-- walk the methods in the binding operation elements -->
		<xsl:choose>
			<xsl:when test="wsdl:portType">
				<p></p>

			    <h2 id="107">Methods</h2>

					<!-- walk the bindings (protocols) -->
					<xsl:variable name="varMethods">
						<xsl:copy-of select="//wsdl:operation" />
					</xsl:variable>
					<!-- Just saving the root -->
					<xsl:variable name="root" select="/" />
					<xsl:for-each select="ms:node-set($varMethods)//wsdl:operation">
						<xsl:sort select="@name" />
						<xsl:if test="not(preceding-sibling::*[@name=current()/@name])">
							<ul class="wsdl">
								<li class="wsdl">
									<span class="method"><span class="method_name">
											<xsl:value-of select="@name" />
										</span><!-- show param info if params exist -->(<xsl:if test="$root/wsdl:definitions/wsdl:types/s:schema/s:element[@name=current()/@name]/s:complexType/s:sequence/s:element/@name">
											<xsl:for-each select="$root/wsdl:definitions/wsdl:types/s:schema/s:element[@name=current()/@name]/s:complexType/s:sequence/s:element"><xsl:if test="not(position()=1)">,&#160;</xsl:if><span class="method_param"><xsl:value-of select="@name"></xsl:value-of>
											</span> As <span class="method_type">
													<xsl:value-of select="substring-after(@type, ':')"></xsl:value-of>
												</span></xsl:for-each>
										</xsl:if>)
<!-- show return type if this is not a void function -->
<xsl:if test="substring-after($root/wsdl:definitions/wsdl:types/s:schema/s:element[(starts-with(@name, current()/@name))and(substring-after(@name, current()/@name)='Response')]/s:complexType/s:sequence/s:element/@type, ':')"> 
As <span class="method_type">
												<xsl:value-of select="substring-after($root/wsdl:definitions/wsdl:types/s:schema/s:element[(starts-with(@name, current()/@name))and(substring-after(@name, current()/@name)='Response')]/s:complexType/s:sequence/s:element/@type, ':')" />
											</span>
</xsl:if>
</span>
									<br />
									<xsl:if test="wsdl:documentation">
										<span class="methoddescription">
											<xsl:value-of select="." />
											<p />
										</span>
									</xsl:if>
								</li>
							</ul>
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
				<br/><p class="heading2" id="106">No Ports or Methods were found on this page.</p>
				
				<p id="108">If this is an ASP.NET Web service, make sure that all WebMethods are public and 
			        have a &lt;WebMethod&gt; attribute. 
		        </p>
				<p id="109">Visual Basic example:</p>
				<BLOCKQUOTE dir="ltr" style="MARGIN-RIGHT: 0px">
					<p id="111">&lt;WebMethod()&gt; _<br />
				Public Function HelloWorld() as String<br />
				&#160;&#160;&#160;Return "Hello World!"<br />
				End Sub</p>
				</BLOCKQUOTE>
				<p dir="ltr" id="112">Visual C# example:</p>
				<BLOCKQUOTE dir="ltr" style="MARGIN-RIGHT: 0px">
					<p dir="ltr" id="113">[WebMethod]<br />
				public string HelloWorld() {<br />
				   &#160;&#160;&#160;return "Hello World!";<br />
				}</p>
				</BLOCKQUOTE>

			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
    <xsl:otherwise>
			<p class="heading2" id="105">No Web Services were found on this page.</p>
	</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="text()" />
</xsl:stylesheet>
