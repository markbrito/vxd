<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msdn="http://msdn.microsoft.com/" xmlns:msxsl="urn:schemas-microsoft-com:xslt">
	<!--Samples Profile list uses profile strings -->
	<xsl:include href="vsprofileStrings.xsl" />
	<!--Include hosting application schemae -->
	<xsl:include href="vsapp.xsl" />
	<!--Text for XML Web Services search results -->
	<xsl:variable name="AddRefToProject">Add as web reference to current project</xsl:variable>
	<!-- Content elements -->
	<!-- Tab element - determines whether this is a "regular" tab or a hosting app tab -->
	<xsl:template match="Tab">
		<xsl:choose>
			<xsl:when test="@IsApplication='true'">
				<xsl:call-template name="HostingApplication" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="//TabData/Value">
		<span style="display:none">
			<xsl:attribute name="id">
				<xsl:value-of select="/Tab/@ID" />
				<xsl:value-of select="@Name" />
			</xsl:attribute>
			<xsl:value-of select="text()" />
		</span>
	</xsl:template>
	<xsl:template match="Application">
		<xsl:if test="/Tab/Config">
			<script>fnAddCfgMode("<xsl:value-of select="/Tab/@ID" />");</script>
		</xsl:if>
		<xsl:apply-templates />
	</xsl:template>
	<!-- ACTION - the action to take when an event occurs.
	This template generates the function that is called when an action event (such as a button click) happens.-->
	<xsl:template match="Action">
		<xsl:if test="InvokeMethod[@ToolID != '']">
			<script>
			function fn<xsl:value-of select="@ID" />(){
				<xsl:choose>
					<xsl:when test="InvokeMethod[@ToolID = 'vs_File_NewProject']">
						if(fnCheckToStopDebugging() == true)
							window.external.ExecuteCommand("File.NewProject");
					</xsl:when>
					<xsl:when test="InvokeMethod[@ToolID = 'vs_File_OpenProject']">
						if(fnCheckToStopDebugging() == true)
							window.external.ExecuteCommand("File.OpenProject");
					</xsl:when>
					<xsl:when test="InvokeMethod[@ToolID = 'vs_Help_CheckForUpdates']">
						window.external.ExecuteCommand("Help.CheckforUpdates");
					</xsl:when>
					<xsl:when test="InvokeMethod[@ToolID = 'vs_GetSamplesProfile']">
						var samplesProfile;
						try{
							samplesProfile = g_wshShell.regread(g_strRegistryHiveRoot+"SamplesProfile");
						}catch(e){
							samplesProfile = "vs";
						}
						
						if(samplesProfile != SamplesProfileList.options(SamplesProfileList.selectedIndex).value){
							for(var i = 0; i!=SamplesProfileList.options.length;i++){
								if(samplesProfile == SamplesProfileList.options(i).value)SamplesProfileList.selectedIndex=i;
							}
						}
					</xsl:when>
					<xsl:otherwise>
						fnAction<xsl:value-of select="@ID" />();
					</xsl:otherwise>
				</xsl:choose>
			}
		</script>
		</xsl:if>
	</xsl:template>
	<!-- PaneSet - a collection of panes, typically rendered as a tabset -->
	<xsl:template match="PaneSet">
		<span>
			<br />
			<table class="bugbugspc" cellspacing="0" cellpadding="0" border="0" width="95%" height="95%">
				<tr>
					<td VALIGN="bottom" height="0">
						<table class="clsTabTblHead" cellspacing="0" cellpadding="0" border="0" height="0">
							<xsl:if test="@ID">
								<xsl:attribute name="id">
									<xsl:value-of select="@ID" />
								</xsl:attribute>
							</xsl:if>
							<tr height="0">
								<xsl:attribute name="dispTgt">divGrpDisp<xsl:value-of select="@ID" /></xsl:attribute>
								<xsl:apply-templates>
									<xsl:with-param name="tabbed">true</xsl:with-param>
									<xsl:with-param name="tempstr">
										<xsl:value-of select="@ID" />
									</xsl:with-param>
								</xsl:apply-templates>
								<td class="clsTabTblCellFillTab" height="0">
									<br />
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td class="clsTabTblDispCell" valign="top" height="100%">
						<div>
							<xsl:attribute name="id">divGrpDisp<xsl:value-of select="@ID" /></xsl:attribute>
						</div>
					</td>
				</tr>
			</table>
		</span>
		<!-- This is clicking the first tab in an inner tabset, trying to make sure IE renders.-->
		<script defer="true"><xsl:value-of select="@ID" />.children[0].children[0].children[1].children[0].click();</script>
	</xsl:template>
	<!--Pane - a visual region -->
	<xsl:template match="Pane">
		<xsl:param name="tabbed" />
		<xsl:param name="tempstr" />
		<xsl:if test="$tempstr != ''">
			<td width="0" height="0"></td>
			<td class="clsTabTblCell" nowrap="true" width="0" height="0">
				<xsl:attribute name="onClick">
				
				// Save active pane data
				if(divGrpDisp<xsl:value-of select="$tempstr" />.ActivePane){
					divGrpDisp<xsl:value-of select="$tempstr" />.ActivePane.innerHTML = divGrpDisp<xsl:value-of select="$tempstr" />.innerHTML;
				}

				// Display stored pane data, set active pane
				divGrpDisp<xsl:value-of select="$tempstr" />.innerHTML = this.children[1].innerHTML; 
				divGrpDisp<xsl:value-of select="$tempstr" />.ActivePane = this.children[1];
				
				// Clear stored pane data
				this.children[1].innerHTML = "";
				
				//tab selection feedback
				if(this.parentElement.upCell){this.parentElement.upCell.className="clsTabTblCell";} 
				this.parentElement.upCell = this;
				this.className="clsTabTblCellUp";
				event.cancelBubble = true;
				
				//on click action
				<xsl:if test="@OnClick">
					fn<xsl:value-of select="@OnClick" />();
				</xsl:if>

				</xsl:attribute>
				<a>
					<xsl:if test="@ID">
						<xsl:attribute name="id">
							<xsl:value-of select="@ID" />
						</xsl:attribute>
					</xsl:if>
					<xsl:attribute name="href">
						<xsl:value-of select="@Title" />
					</xsl:attribute>
					<xsl:attribute name="onclick">return false;</xsl:attribute>
					<xsl:attribute name="TITLE">
						<xsl:value-of select="@Title" />
					</xsl:attribute>
					<b>
						<xsl:value-of select="@Title" />
					</b>
				</a>
				<div>
					<xsl:attribute name="style">display:none</xsl:attribute>
					<xsl:apply-templates />
				</div>
			</td>
			<td width="0" height="0">
				<img src="images\inrTabDn.gif" />
			</td>
		</xsl:if>
		<xsl:if test="$tempstr = ''">
			<xsl:apply-templates />
		</xsl:if>
	</xsl:template>
	<xsl:template match="LinkGroupSet">
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="LinkGroup">
		<xsl:if test="position() != 1">
			<hr class="homepagerule" />
		</xsl:if>
		<xsl:if test="@Title">
			<xsl:call-template name="titletext">
				<xsl:with-param name="title">
					<xsl:value-of select="@Title" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:apply-templates select="/Tab/Application/Data/Context/Links/LItemEx[LItem/@LinkGroup = current()/@ID]" />
	</xsl:template>
	<!-- LItemEx - a formatted, filterable link -->
	<xsl:template match="LItemEx">
		<xsl:variable name="url">
			<xsl:call-template name="validateurl">
				<xsl:with-param name="url">
					<xsl:value-of select="LItem/@URL" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="image">
			<xsl:call-template name="validateurl">
				<xsl:with-param name="url">
					<xsl:value-of select="LItem/@Image" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="position() != 1">
			<xsl:if test="LItem[@Image != '']">
				<xsl:if test="Blurb/text() != ''">
					<hr class="homepagerule" />
				</xsl:if>
			</xsl:if>
		</xsl:if>
		<xsl:if test="LItem[@Image != '']">
			<img class="homepageimage" align="left">
				<xsl:if test="@ID">
					<xsl:attribute name="id"><xsl:value-of select="@ID" />Image</xsl:attribute>
				</xsl:if>
				<xsl:attribute name="src">
					<xsl:value-of select="$image" />
				</xsl:attribute>
			</img>
		</xsl:if>
		<a class="homepageinactive">
			<xsl:if test="LItem[@ID != '']">
				<xsl:attribute name="id">
					<xsl:value-of select="LItem/@ID" />
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="title">
				<xsl:value-of select="LItem" />
			</xsl:attribute>
			<xsl:choose>
				<xsl:when test="$url != ''">
					<xsl:attribute name="onMouseOver">
						javascript:fnvsSetStatus('<xsl:value-of select="$url" />'); return false;
					</xsl:attribute>
					<xsl:attribute name="onMouseOut">
						javascript:fnvsClearStatus(); return false;
					</xsl:attribute>
					
					<xsl:attribute name="browserNavigateURL"><xsl:value-of select="$url"/></xsl:attribute>
					<xsl:attribute name="onclick">browserNavigate(0,this.browserNavigateURL); return false;</xsl:attribute>
					<xsl:attribute name="href"><xsl:value-of select="$url" /></xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="href"></xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="LItem[@Invokes != '']">
				<xsl:attribute name="onclick">fn<xsl:value-of select="LItem/@Invokes" />(); return false;</xsl:attribute>
			</xsl:if>
			<xsl:value-of select="LItem" />
		</a>
		<br />
		<xsl:if test="Blurb/text() != ''">
			<span class="homepageinactive">
				<xsl:value-of select="Blurb/text()" />
				<xsl:if test="LItem[@Image = '']">
					<br />
				</xsl:if>
			</span>
		</xsl:if>
		<xsl:if test="LItem[@Image != '']">
			<br clear="all" />
		</xsl:if>
	</xsl:template>
	<!-- Don't process these templates until they're called specifically -->
	<xsl:template match="Context"></xsl:template>
	<xsl:template match="Attributes"></xsl:template>
	<!-- Render tab content -->
	<xsl:template match="Feeds/Feed">
		<xsl:variable name="url">
			<xsl:call-template name="validateurl">
				<xsl:with-param name="url">
					<xsl:value-of select="Source/@URL" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="feedID">
			<xsl:value-of select="/Tab/@ID" />
		</xsl:variable>
		<script>
		function fn<xsl:value-of select="$feedID" />OnClick(){
		<xsl:if test="Source/@Normative = 'false'">
			return;
		</xsl:if>
		try{
			var sLCID = "";
			<xsl:if test="Source/@LCID">
				sLCID = window.external.LocaleID;
				var sFeedLCID = "<xsl:value-of select="Source/@LCID" />";
			</xsl:if>
			<xsl:if test="Source/Arg">
				var sArgs = "";
				<xsl:for-each select="Source/Arg">
					sArgs = sArgs + "<xsl:text disable-output-escaping="yes">&amp;</xsl:text><xsl:value-of select="/Tab/Feeds/Feed/Source/Arg/@Name" />=<xsl:value-of select="/Tab/Feeds/Feed/Source/Arg/text()" />";
				</xsl:for-each>
			</xsl:if>
			
			window.x<xsl:value-of select="$feedID" />XML = new ActiveXObject(g_MSXML_DOM);
			window.x<xsl:value-of select="$feedID" />XSL = new ActiveXObject(g_MSXML_DOM);

			window.x<xsl:value-of select="$feedID" />XML.async = false;
			window.x<xsl:value-of select="$feedID" />XSL.async = false;
			
			try{
				tab<xsl:value-of select="$feedID" />RenderDiv.innerHTML = "";
				tab<xsl:value-of select="$feedID" />RenderDiv.innerHTML = window.external.Globals.VariableValue("<xsl:value-of select="$feedID" />HTML");
			}catch(m){
				fnAssert(false, "Getting renderdiv: " + m.description);
			}

			<xsl:if test="@Expires != ''">
				var oNow = new Date();
				try{
					var iexpDate = window.external.Globals.VariableValue("<xsl:value-of select="$feedID" />Expires");
				}catch(e){
					var iexpDate = <xsl:value-of select="@Expires" />;
				}
				var oExpires = new Date(iexpDate);
				if(String(oNow - oExpires).indexOf("-")!=-1){
					//return;
				}
			</xsl:if>

			if(navigator.offline)return;

			try{
				sArgs = "?hasArgs=y" + sArgs;
			}catch(e){
				var sArgs = sLCID == ""?"":"?hasArgs=n";
			}
			
			if(sLCID!=""){
				try{
					sLCID = sArgs + "<xsl:text disable-output-escaping="yes">&amp;</xsl:text>FeedLCID="+sFeedLCID;
				}catch(e){
					fnAssert(false, "LCID processing: " + e.description);
				}
			}else{
				sLCID= sArgs;
			}

			// If the user has never configured the tab, give the server a chance to match the user's language
			if (!fnTabConfigured("<xsl:value-of select="$feedID" />")) {
				try {
					var sUserLang = navigator.userLanguage;
					if (sUserLang != "") {
						sLCID += "<xsl:text disable-output-escaping="yes">&amp;</xsl:text>UserLang="+sUserLang;
					}
				} catch (e) {
					fnAssert(false, "UserLang: " + e.description);
				}
			}	
					
			var xmlOkay = true;
			window.x<xsl:value-of select="$feedID" />XSL.load("vshome.xsl");
			fnvsSetStatus('<xsl:value-of select="$LoadingData" />');
			<xsl:choose>
				<xsl:when test="Source[@RootDir='AppData']">
					try{
						var xmlobj = new ActiveXObject(g_MSXML_DOM);
						xmlobj.load(g_AppDataFolder + "<xsl:value-of select="$url" />");
						if (xmlobj.parseError.errorCode == 0) { 
							// Load the Tab element (stripping off the TabDefinition element if present).
							window.x<xsl:value-of select="$feedID" />XML.loadXML(xmlobj.documentElement.selectSingleNode("//Tab").xml);
						}
					}catch(e){
						fnAssert(false, "Error loading XML from AppData: " + e.description);
						xmlOkay = false;
					}
				</xsl:when>
				<xsl:otherwise>
					try{
//alert("<xsl:value-of select="$url" />"+sLCID);
						var xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
						xmlhttp.open("GET", "<xsl:value-of select="$url" />"+sLCID, false);
						xmlhttp.send();
//alert(xmlhttp.responseXML.xml);
						// Load the Tab element (stripping off the TabDefinition element if present).
						var oTab = null;
						try {
							oTab = xmlhttp.responseXML.selectSingleNode("//Tab");
						} catch (e) {
							fnAssert(false, "Couldn't find Tab: " + e.description);
							xmlOkay = false;
						}
						if (oTab != null <xsl:text disable-output-escaping="yes">&amp;&amp;</xsl:text> oTab.xml != "") { 
							xmlOkay = fnLoadAndValidate(oTab, window.x<xsl:value-of select="$feedID" />XML);
						}
					}catch(e){
						fnAssert(false, "Error getting XML via http: " + e.description);
						xmlOkay = false;
					}
				</xsl:otherwise>
			</xsl:choose>
			
			fnvsClearStatus();
			
			
			xmlOkay = (xmlOkay 
						<xsl:text disable-output-escaping="yes">&amp;&amp;</xsl:text> 
						window.x<xsl:value-of select="$feedID" />XML.parseError == 0 
						<xsl:text disable-output-escaping="yes">&amp;&amp;</xsl:text> 
						window.x<xsl:value-of select="$feedID" />XSL.parseError == 0
						<xsl:text disable-output-escaping="yes">&amp;&amp;</xsl:text> 
						window.x<xsl:value-of select="$feedID" />XML.xml.length != 0);
			
			//if an error occured, get local content
			if (!xmlOkay) {
				window.x<xsl:value-of select="$feedID" />XML.loadXML(window.external.Globals.VariableValue("<xsl:value-of select="$feedID" />currXml"));
			}
			//else persist content to globals
			else {
				try {
					window.external.Globals.VariableValue("<xsl:value-of select="$feedID" />XML") = window.x<xsl:value-of select="$feedID" />XML.xml;
					window.external.Globals.VariablePersists("<xsl:value-of select="$feedID" />XML") = true;

				} catch(e){
					fnAssert(false, "Error persisting tab data: " + e.description);
				}
				
				// At this point, the XML object contains the web-equivalent of the local file

				// filtration code
				if(g_sFilter != ''){
					sMatchBaseIn = "Tab/Application/Data/Context[Attributes and not(Attributes[AItem[@Name='Ambient' and @Value='true'] or ";
					sMatchBaseOut = "])]";
					sPattern = "";
					var regex = /[\(]|[\)]|and|or|["][^"]*["][\s]*[\=][\s]*["][^"]*["]/gi;
					aFilter = g_sFilter.match(regex);
					for(var f = 0; f!=aFilter.length; f++){
						try{
							if(aFilter[f].indexOf("=")!=-1){
								aArg = aFilter[f].split("=");
								sPattern += " AItem[@Name="+aArg[0]+" and @Value="+aArg[1]+"] ";
							}else{
								sPattern += " " + aFilter[f].toLowerCase() + " "; 
							}
						}catch(e){
							fnAssert(false, "Error in filter processing: " + e.description);
						}
					}
					sMatchPattern = sMatchBaseIn + sPattern + sMatchBaseOut;
					try{
						var sDeadPool = window.x<xsl:value-of select="$feedID" />XML.selectNodes(sMatchPattern);
					}catch(e){
						fnAssert(false, "Error in filter processing: " + e.description);
					}
					for(var o = 0; o!=sDeadPool.length;o++){
						try{
							sDeadPool.item(o).parentNode.removeChild(sDeadPool.item(o));
						}catch(e){
							fnAssert(false, "Error in filter processing: " + e.description);
						}
					}
				} // end filter if
			
				// Transform the tab data part first
				var sHTMLTemp = "";
				var sKeyword = "";
				try{
					var oTabData = window.x<xsl:value-of select="$feedID" />XML.selectSingleNode("Tab/TabData");
					sHTMLTemp = oTabData.transformNode(window.x<xsl:value-of select="$feedID" />XSL);
					try {
						var oUpdate = oTabData.selectSingleNode("Value[@Name='VisualStudioServicePackLevel']");
						if (oUpdate != null) fnCheckForVsUpdate(oUpdate.text);
					} catch (e) {
						fnAssert(false, "Error handling service pack level: " + e.description);
					}
					try {
						var oKwd = oTabData.selectSingleNode("Value[@Name='VisualStudioF1Keyword']");
						if (oKwd != null) {
							sKeyword = oKwd.text;
						}
					} catch (e) {
						fnAssert(false, "Unable to find F1 keyword: " + e.description);
					}
				} catch (e) {
					fnAssert(false, "Error transforming new tab data: " + e.description);
				}

				// Change the content of the tab to be the web content
				tab<xsl:value-of select="$feedID" />TabDataDiv.innerHTML = sHTMLTemp;

				// Transform the application part 
				sHTMLTemp = "";
				try{
					var oApp = window.x<xsl:value-of select="$feedID" />XML.selectSingleNode("Tab/Application");
					sHTMLTemp = oApp.transformNode(window.x<xsl:value-of select="$feedID" />XSL);
				} catch (e) {
					fnAssert(false, "Error transforming new tab app: " + e.description);
				}

				try {
					var sStoredValue = window.external.Globals.VariableValue("<xsl:value-of select="$feedID" />HTML");
				}catch(e){
					fnAssert(false, "Error getting previous HTML: " + e.description);
				}

				if (sHTMLTemp!=sStoredValue) {
					try{
						window.external.Globals.VariableValue("<xsl:value-of select="$feedID" />HTML") = sHTMLTemp;
						window.external.Globals.VariablePersists("<xsl:value-of select="$feedID" />HTML") = true;
						var iExp = xmlhttp.responseXML.selectSingleNode("Tab/Feeds/Feed/@Expires").text;
						window.external.Globals.VariableValue("<xsl:value-of select="$feedID" />Expires") = iExp;
						window.external.Globals.VariablePersists("<xsl:value-of select="$feedID" />Expires") = true;
					} catch(e){
						fnAssert(false, "Error storing expiry data: " + e.description);
					}
					// Change the content of the tab to be the web content
					tab<xsl:value-of select="$feedID" />RenderDiv.innerHTML = sHTMLTemp;
				}

				// apply the keyword
				if (sKeyword != "") {
					tab<xsl:value-of select="$feedID" />RenderDiv.f1Keyword = sKeyword;
				}

				// Now transform the config part
				sHTMLTemp = "";

				// Get the Config application
				var xmlCfg = new ActiveXObject(g_MSXML_DOM);
				xmlCfg.load("configure.xml");
				var strCfg = "";
				try{
					var oCfgApp = xmlCfg.selectSingleNode("//Tab/Application");
					strCfg = oCfgApp.transformNode(window.x<xsl:value-of select="$feedID" />XSL);
				}catch(e){
					fnAssert(false, e.description);
				}

				// Insert the application
				sHTMLTemp += strCfg;

				try{
					var oCfg = window.x<xsl:value-of select="$feedID" />XML.selectSingleNode("Tab/Config");
					sHTMLTemp += oCfg.transformNode(window.x<xsl:value-of select="$feedID" />XSL);
				} catch (e) {
					fnAssert(false, "Error transforming config: " + e.description);
				}

				tab<xsl:value-of select="$feedID" />CfgDiv.innerHTML = sHTMLTemp;
			}
		}catch(m){
			fnAssert(false, "Feed: " + m.description);
		}
	}
	</script>
	</xsl:template>
	<!-- Configuration elements-->
	<xsl:template match="Config">
		<div>
			<xsl:attribute name="id">id<xsl:value-of select="/Tab/@ID" />ConfigSelectDiv</xsl:attribute>
			<xsl:apply-templates />
		</div>
	</xsl:template>
	<xsl:template match="Config/Feed">
		<div style="display:none">
			<xsl:value-of select="current()" />
		</div>
	</xsl:template>
	<xsl:template match="Config/Select">
		<select>
			<xsl:attribute name="id">
				<xsl:value-of select="@ID" />
			</xsl:attribute>
			<xsl:attribute name="onchange">fnChangeFeed("<xsl:value-of select="/Tab/@ID" />", this.options[this.selectedIndex].value);</xsl:attribute>
			<xsl:apply-templates />
		</select>
	</xsl:template>
	<xsl:template match="Config/Select/Option">
		<option>
			<xsl:if test="@Selected = 'true'">
				<xsl:attribute name="selected">true</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="value">
				<xsl:value-of select="@FeedID" />
			</xsl:attribute>
			<xsl:value-of select="text()" />
		</option>
	</xsl:template>
	<!--Include content -->
	<xsl:template match="Include">
		<xsl:variable name="url">
			<xsl:call-template name="validateurl">
				<xsl:with-param name="url">
					<xsl:value-of select="@URL" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="@ID">
			<xsl:attribute name="id">
				<xsl:value-of select="@ID" />
			</xsl:attribute>
		</xsl:if>
		<span style="display:none">
			<xsl:attribute name="id"><xsl:value-of select="@ID" />includeContent</xsl:attribute>
			<xsl:if test="Message">
				<xsl:if test="position() != 1">
					<hr class="homepagerule" />
				</xsl:if>
				<div class="HomePageInactive">
					<xsl:value-of select="Message/text()" />
				</div>
			</xsl:if>
			<xsl:if test="position() != 1 or Message">
				<hr class="homepagerule" />
			</xsl:if>
			<label class="homepageTitle">
				<xsl:value-of select="@Title" />
			</label>
			<br />
			<div>
				<xsl:attribute name="id"><xsl:value-of select="@ID" />includeData</xsl:attribute>
			</div>
		</span>
		<script defer="true">
		try{
			var oValidXML = new ActiveXObject(g_MSXML_DOM);
			var oXSL = new ActiveXObject(g_MSXML_DOM);

			oXSL.async = false;
								
			<xsl:if test="Arg">
				var sArgs = "";
				<xsl:for-each select="Arg">
					sArgs = sArgs + "<xsl:text disable-output-escaping="yes">&amp;</xsl:text><xsl:value-of select="@Name" />=<xsl:value-of select="text()" />";
				</xsl:for-each>
			</xsl:if>
			
			var oXML = new ActiveXObject("Microsoft.XMLHTTP");

			oXML.open("GET", encodeURI("<xsl:value-of select="$url" />?"+sArgs), false);
			oXML.send();
			
			oXSL.load("vshome.xsl");
			
			// validate content, cleanup any embedded HTML
			var oValidXML = new ActiveXObject(g_MSXML_DOM);
			var fValidated = fnLoadAndValidate(oXML.responseXML,oValidXML);

			if(oValidXML.selectSingleNode("ErrorReport/Message") != null){
				fValidated=false;
			}
			
			if(fValidated){
				sHTMLTemp=oValidXML.transformNode(oXSL);
 
     			regex=/&lt;/g;
   				sHTMLTemp=sHTMLTemp.replace(regex,"<xsl:text disable-output-escaping="yes">&lt;</xsl:text>");
    			regex=/&gt;/g;
                sHTMLTemp=sHTMLTemp.replace(regex,"<xsl:text disable-output-escaping="yes">&gt;</xsl:text>");
    			regex=/&apos;/g;
                sHTMLTemp=sHTMLTemp.replace(regex,"<xsl:text disable-output-escaping="yes">&apos;</xsl:text>");
                regex=/&amp;/g;
                sHTMLTemp=sHTMLTemp.replace(regex,"<xsl:text disable-output-escaping="yes">&amp;</xsl:text>");
				
				try{
					<xsl:value-of select="@ID" />includeData.innerHTML = sHTMLTemp;
					<xsl:value-of select="@ID" />includeContent.style.display="inline";
				} catch(e) {
					<xsl:value-of select="@ID" />includeData.innerHTML = sHTMLTemp;
					<xsl:value-of select="@ID" />includeContent.style.display="inline";
				}
			}
			}catch(m){
				fnAssert(false, "Getting include data: " + m.description);
			}
		</script>
	</xsl:template>
	<!-- Toolbox elements -->
	<!-- Break element -->
	<xsl:template match="Break">
		<BR />
	</xsl:template>
	<!-- This template is used whenever an access key (mnemonic) is used on a label-->
	<xsl:template name="accesskey">
		<xsl:param name="text" />
		<xsl:param name="key" />
		<xsl:value-of select="substring-before($text,$key)" />
		<U>
			<xsl:value-of select="$key" />
		</U>
		<xsl:value-of select="substring-after($text,$key)" />
	</xsl:template>
	<!-- This template is used whenever a "title" should appear in the text -->
	<xsl:template name="titletext">
		<xsl:param name="title" />
		<b class="homepageTitle">
			<xsl:value-of select="$title" />
		</b>
		<p />
	</xsl:template>
	<!-- Button  -->
	<xsl:template match="Button">
		<Button class="clsVsToolBtn">
			<xsl:if test="@ID">
				<xsl:attribute name="id">
					<xsl:value-of select="@ID" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@Name">
				<xsl:attribute name="name">
					<xsl:value-of select="@Name" />
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="onFocus">this.style.color = '#ff9933';</xsl:attribute>
			<xsl:attribute name="onMouseOver">this.style.color = '#ff9933';</xsl:attribute>
			<xsl:attribute name="onBlur">this.style.color = '#336699';</xsl:attribute>
			<xsl:attribute name="onMouseOut">this.style.color = '#336699';</xsl:attribute>
			<xsl:if test="@AccessKey">
				<xsl:attribute name="accesskey">
					<xsl:value-of select="@AccessKey" />
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="value">
				<xsl:value-of select="@Text" />
			</xsl:attribute>
			<xsl:attribute name="onclick">fn<xsl:value-of select="@OnClick" />();</xsl:attribute>
			<xsl:value-of select="@Text" />
		</Button>
	</xsl:template>
	<!-- ButtonField (INPUT type="button")  -->
	<xsl:template match="ButtonField">
		<input type="button" class="clsVsToolBtn">
			<xsl:if test="@ID">
				<xsl:attribute name="id">
					<xsl:value-of select="@ID" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@Name">
				<xsl:attribute name="name">
					<xsl:value-of select="@Name" />
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="onFocus">this.style.color = '#ff9933';</xsl:attribute>
			<xsl:attribute name="onMouseOver">this.style.color = '#ff9933';</xsl:attribute>
			<xsl:attribute name="onBlur">this.style.color = '#336699';</xsl:attribute>
			<xsl:attribute name="onMouseOut">this.style.color = '#336699';</xsl:attribute>
			<xsl:if test="@AccessKey">
				<xsl:attribute name="accesskey">
					<xsl:value-of select="@AccessKey" />
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="value">
				<xsl:value-of select="text()" />
			</xsl:attribute>
			<xsl:attribute name="onclick">fn<xsl:value-of select="@OnClick" />();</xsl:attribute>
		</input>
	</xsl:template>
	<!-- Submit Button (INPUT type="submit") -->
	<xsl:template match="SubmitButton">
		<input type="submit" class="clsVsToolBtn">
			<xsl:if test="@ID">
				<xsl:attribute name="id">
					<xsl:value-of select="@ID" />
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="onFocus">this.style.color = '#ff9933';</xsl:attribute>
			<xsl:attribute name="onMouseOver">this.style.color = '#ff9933';</xsl:attribute>
			<xsl:attribute name="onBlur">this.style.color = '#336699';</xsl:attribute>
			<xsl:attribute name="onMouseOut">this.style.color = '#336699';</xsl:attribute>
			<xsl:if test="@AccessKey">
				<xsl:attribute name="accesskey">
					<xsl:value-of select="@AccessKey" />
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="value">
				<xsl:value-of select="text()" />
			</xsl:attribute>
		</input>
	</xsl:template>
	<!-- CheckBox (INPUT type="checkbox") -->
	<xsl:template match="CheckBox">
		<input type="checkbox" class="clsVsCheckbox">
			<xsl:if test="@ID">
				<xsl:attribute name="id">
					<xsl:value-of select="@ID" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@Name">
				<xsl:attribute name="name">
					<xsl:value-of select="@Name" />
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="checked">
				<xsl:value-of select="@Checked" />
			</xsl:attribute>
			<xsl:attribute name="value">
				<xsl:value-of select="text()" />
			</xsl:attribute>
		</input>
		<label class="homepagelabel">
			<xsl:if test="@ID">
				<xsl:attribute name="id"><xsl:value-of select="@ID" />label</xsl:attribute>
				<xsl:attribute name="FOR">
					<xsl:value-of select="@ID" />
				</xsl:attribute>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="@AccessKey">
					<xsl:attribute name="accesskey">
						<xsl:value-of select="@AccessKey" />
					</xsl:attribute>
					<xsl:call-template name="accesskey">
						<xsl:with-param name="text">
							<xsl:value-of select="text()" />
						</xsl:with-param>
						<xsl:with-param name="key">
							<xsl:value-of select="@AccessKey" />
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="text()" />
				</xsl:otherwise>
			</xsl:choose>
		</label>
	</xsl:template>
	<!-- RadioGroup (group of RadioButtons) -->
	<xsl:template match="RadioGroup">
		<xsl:for-each select="RadioButton">
			<input type="radio" class="clsVsRadio">
				<xsl:attribute name="id">
					<xsl:value-of select="@ID" />
				</xsl:attribute>
				<xsl:attribute name="name">
					<xsl:value-of select="../@GroupName" />
				</xsl:attribute>
				<xsl:attribute name="value">
					<xsl:value-of select="text()" />
				</xsl:attribute>
				<xsl:if test="@Checked">
					<xsl:attribute name="checked">
						<xsl:value-of select="@Checked" />
					</xsl:attribute>
				</xsl:if>
				<label class="homepagelabel">
					<xsl:attribute name="for">
						<xsl:value-of select="@ID" />
					</xsl:attribute>
					<xsl:attribute name="id"><xsl:value-of select="@ID" />label</xsl:attribute>
					<xsl:choose>
						<xsl:when test="@AccessKey">
							<xsl:attribute name="accesskey">
								<xsl:value-of select="@AccessKey" />
							</xsl:attribute>
							<xsl:call-template name="accesskey">
								<xsl:with-param name="text">
									<xsl:value-of select="text()" />
								</xsl:with-param>
								<xsl:with-param name="key">
									<xsl:value-of select="@AccessKey" />
								</xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="text()" />
						</xsl:otherwise>
					</xsl:choose>
				</label>
				<xsl:if test="../@BreaksBetween='true'">
					<br />
				</xsl:if>
			</input>
		</xsl:for-each>
	</xsl:template>
	<!-- TextField (INPUT type="text") -->
	<xsl:template match="TextField">
		<input type="text" class="clsVsToolText">
			<xsl:if test="@ID">
				<xsl:attribute name="id">
					<xsl:value-of select="@ID" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@Name">
				<xsl:attribute name="name">
					<xsl:value-of select="@Name" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@Width">
				<xsl:attribute name="width">
					<xsl:value-of select="@Width" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@Size">
				<xsl:attribute name="size">
					<xsl:value-of select="@Size" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@MaxLength">
				<xsl:attribute name="maxlength">
					<xsl:value-of select="@MaxLength" />
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="value">
				<xsl:value-of select="text()" />
			</xsl:attribute>
		</input>
	</xsl:template>
	<!-- PasswordField (INPUT type="password") -->
	<xsl:template match="PasswordField">
		<input type="password" class="clsVsToolText">
			<xsl:if test="@ID">
				<xsl:attribute name="id">
					<xsl:value-of select="@ID" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@Name">
				<xsl:attribute name="name">
					<xsl:value-of select="@Name" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@Width">
				<xsl:attribute name="width">
					<xsl:value-of select="@Width" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@Size">
				<xsl:attribute name="size">
					<xsl:value-of select="@Size" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@MaxLength">
				<xsl:attribute name="maxlength">
					<xsl:value-of select="@MaxLength" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@OnBlur">
				<xsl:attribute name="onblur">fn<xsl:value-of select="@OnBlur" />()</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="value">
				<xsl:value-of select="text()" />
			</xsl:attribute>
		</input>
	</xsl:template>
	<!-- HiddenField (INPUT type="hidden") -->
	<xsl:template match="HiddenField">
		<input type="hidden">
			<xsl:if test="@ID">
				<xsl:attribute name="id">
					<xsl:value-of select="@ID" />
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="value">
				<xsl:value-of select="text()" />
			</xsl:attribute>
		</input>
	</xsl:template>
	<!-- TextArea -->
	<xsl:template match="TextArea">
		<textarea class="clsVsToolText">
			<xsl:if test="@ID">
				<xsl:attribute name="id">
					<xsl:value-of select="@ID" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@Cols">
				<xsl:attribute name="cols">
					<xsl:value-of select="@Cols" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@Disabled">
				<xsl:attribute name="disabled">
					<xsl:value-of select="@Disabled" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@Name">
				<xsl:attribute name="name">
					<xsl:value-of select="@Name" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@ReadOnly">
				<xsl:attribute name="readonly">
					<xsl:value-of select="@ReadOnly" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@Rows">
				<xsl:attribute name="rows">
					<xsl:value-of select="@Rows" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@Wrap">
				<xsl:attribute name="wrap">
					<xsl:value-of select="@Wrap" />
				</xsl:attribute>
			</xsl:if>
			<xsl:value-of select="text()" />
		</textarea>
	</xsl:template>
	<!-- FileField (INPUT type="file") -->
	<xsl:template match="FileField">
		<input type="file" class="clsVsToolText">
			<xsl:if test="@ID">
				<xsl:attribute name="id">
					<xsl:value-of select="@ID" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@Width">
				<xsl:attribute name="width">
					<xsl:value-of select="@Width" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@Size">
				<xsl:attribute name="size">
					<xsl:value-of select="@Size" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@MaxLength">
				<xsl:attribute name="maxlength">
					<xsl:value-of select="@MaxLength" />
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="Name">
				<xsl:value-of select="@Name" />
			</xsl:attribute>
			<xsl:attribute name="value">
				<xsl:value-of select="text()" />
			</xsl:attribute>
		</input>
	</xsl:template>
	<!-- Image (Img)-->
	<xsl:template match="Image">
		<xsl:variable name="source">
			<xsl:call-template name="validateurl">
				<xsl:with-param name="url">
					<xsl:value-of select="@Source" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<img class="homepageimage" Align="absmiddle" vspace="4">
			<!-- TODO: Put this in the style: hspace="14" vspace="4"> -->
			<xsl:if test="@ID">
				<xsl:attribute name="id">
					<xsl:value-of select="@ID" />
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="src">
				<xsl:value-of select="$source" />
			</xsl:attribute>
			<xsl:attribute name="align">
				<xsl:value-of select="@Align" />
			</xsl:attribute>
			<xsl:attribute name="height">
				<xsl:value-of select="@Height" />
			</xsl:attribute>
			<xsl:attribute name="width">
				<xsl:value-of select="@Width" />
			</xsl:attribute>
			<xsl:attribute name="alt">
				<xsl:value-of select="@AltText" />
			</xsl:attribute>
		</img>
	</xsl:template>
	<!-- Label -->
	<xsl:template match="Label">
		<label class="homepagelabel">
			<xsl:attribute name="for">
				<xsl:value-of select="@For" />
			</xsl:attribute>
			<xsl:if test="@ID">
				<xsl:attribute name="id">
					<xsl:value-of select="@ID" />
				</xsl:attribute>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="@AccessKey">
					<xsl:attribute name="accesskey">
						<xsl:value-of select="@AccessKey" />
					</xsl:attribute>
					<xsl:call-template name="accesskey">
						<xsl:with-param name="text">
							<xsl:value-of select="text()" />
						</xsl:with-param>
						<xsl:with-param name="key">
							<xsl:value-of select="@AccessKey" />
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="text()" />
				</xsl:otherwise>
			</xsl:choose>
		</label>
	</xsl:template>
	<!-- TextSpan - an optionally formatted span. Style can be p, h1-6, or span. -->
	<xsl:template match="TextSpan">
		<xsl:choose>
			<xsl:when test="@SpanStyle">
				<xsl:element name="{@SpanStyle}">
					<xsl:attribute name="class">homepageinactive</xsl:attribute>
					<xsl:if test="@ID">
						<xsl:attribute name="id">
							<xsl:value-of select="@ID" />
						</xsl:attribute>
					</xsl:if>
					<!-- Now set the appropriate text styles -->
					<xsl:if test="@FontFamily">
						<xsl:attribute name="style">
							font-family:<xsl:value-of select="@FontFamily" />
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="@FontSize">
						<xsl:attribute name="style">
							font-size:<xsl:value-of select="@FontSize" />
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="@Emphasis='1'">
						<xsl:attribute name="style">
							font-weight:bold
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="@Emphasis='2'">
						<xsl:attribute name="style">
							font-weight:bolder
						</xsl:attribute>
					</xsl:if>
					<!-- process the contents -->
					<xsl:apply-templates />
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="span">
					<xsl:attribute name="class">homepageinactive</xsl:attribute>
					<xsl:if test="@ID">
						<xsl:attribute name="id">
							<xsl:value-of select="@ID" />
						</xsl:attribute>
					</xsl:if>
					<!-- Now set the appropriate text styles -->
					<xsl:if test="@FontFamily">
						<xsl:attribute name="style">
							font-family:<xsl:value-of select="@FontFamily" />
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="@FontSize">
						<xsl:attribute name="style">
							font-size:<xsl:value-of select="@FontSize" />
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="@Emphasis='1'">
						<xsl:attribute name="style">
							font-weight:bold
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="@Emphasis='2'">
						<xsl:attribute name="style">
							font-weight:bolder
						</xsl:attribute>
					</xsl:if>
					<!-- process the contents -->
					<xsl:apply-templates />
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Title -->
	<xsl:template match="Title">
		<xsl:call-template name="titletext">
			<xsl:with-param name="title">
				<xsl:value-of select="text()" />
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<!-- HRule -->
	<xsl:template match="HRule">
		<hr class="homepagerule" />
	</xsl:template>
	<!-- FieldSet -->
	<xsl:template match="FieldSet">
		<fieldset>
			<xsl:if test="@ID">
				<xsl:attribute name="id">
					<xsl:value-of select="@ID" />
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="title">
				<xsl:value-of select="@Title" />
			</xsl:attribute>
			<xsl:if test="@Align">
				<xsl:attribute name="align">
					<xsl:value-of select="@Align" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@Width or @Height or @Margin">
				<xsl:attribute name="style">
					<xsl:if test="@Width">
						width:<xsl:value-of select="@Width" />
					</xsl:if>
					<xsl:if test="@Height">
						height:<xsl:value-of select="@Height" />
					</xsl:if>
					<xsl:if test="@Margin">
						margin:<xsl:value-of select="@Margin" />
					</xsl:if>
				</xsl:attribute>
			</xsl:if>
			<legend class="homepageinactive">
				<xsl:choose>
					<xsl:when test="@AccessKey">
						<xsl:attribute name="accesskey">
							<xsl:value-of select="@AccessKey" />
						</xsl:attribute>
						<xsl:call-template name="accesskey">
							<xsl:with-param name="text">
								<xsl:value-of select="@Title" />
							</xsl:with-param>
							<xsl:with-param name="key">
								<xsl:value-of select="@AccessKey" />
							</xsl:with-param>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@Title" />
					</xsl:otherwise>
				</xsl:choose>
			</legend>
			<xsl:apply-templates />
		</fieldset>
	</xsl:template>
	<!-- Hyperlink -->
	<xsl:template match="Hyperlink">
		<xsl:variable name="url">
			<xsl:call-template name="validateurl">
				<xsl:with-param name="url">
					<xsl:value-of select="@URL" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<a class="homepageinactive">
			<xsl:if test="@ID">
				<xsl:attribute name="id">
					<xsl:value-of select="@ID" />
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="title">
				<xsl:value-of select="text()" />
			</xsl:attribute>
			<xsl:attribute name="browserNavigateURL"><xsl:value-of select="$url"/></xsl:attribute>
			<xsl:attribute name="href">
				javascript:browserNavigate(
				<xsl:choose>
					<xsl:when test="@Relative">
						<xsl:value-of select="@Relative" />
					</xsl:when>
					<xsl:otherwise>0</xsl:otherwise>
				</xsl:choose>
				,this.browserNavigateURL);
			</xsl:attribute>
			<xsl:value-of select="text()" />
		</a>
	</xsl:template>
	<!--ListBox -->
	<xsl:template match="ListBox">
		<SELECT>
			<xsl:if test="@ID">
				<xsl:attribute name="id">
					<xsl:value-of select="@ID" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@Size">
				<xsl:attribute name="size">
					<xsl:value-of select="@Size" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@Type">
				<xsl:attribute name="type">
					<xsl:value-of select="@Type" />
				</xsl:attribute>
			</xsl:if>
			<xsl:for-each select="ListBoxItem">
				<OPTION>
					<xsl:attribute name="value">
						<xsl:value-of select="@Value" />
					</xsl:attribute>
					<xsl:value-of select="text()" />
				</OPTION>
			</xsl:for-each>
		</SELECT>
	</xsl:template>
	<!--Form -->
	<xsl:template match="Form">
		<form>
			<xsl:attribute name="action">
				<xsl:call-template name="validateurl">
					<xsl:with-param name="url">
						<xsl:value-of select="@Action" />
					</xsl:with-param>
				</xsl:call-template>
			</xsl:attribute>
			<xsl:attribute name="enctype">
				<xsl:value-of select="@EncType" />
			</xsl:attribute>
			<xsl:attribute name="method">
				<xsl:value-of select="@Method" />
			</xsl:attribute>
			<xsl:attribute name="title">
				<xsl:value-of select="@Title" />
			</xsl:attribute>
			<xsl:apply-templates />
		</form>
	</xsl:template>
	<!--Table-->
	<xsl:template match="Table">
		<table>
			<xsl:if test="@ID">
				<xsl:attribute name="id">
					<xsl:value-of select="@ID" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@Align">
				<xsl:attribute name="align">
					<xsl:value-of select="@Align" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@Border">
				<xsl:attribute name="border">
					<xsl:value-of select="@Border" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@CellPadding">
				<xsl:attribute name="cellsadding">
					<xsl:value-of select="@CellPadding" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@CellSpacing">
				<xsl:attribute name="cellspacing">
					<xsl:value-of select="@CellSpacing" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@Height">
				<xsl:attribute name="height">
					<xsl:value-of select="@Height" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@Width">
				<xsl:attribute name="width">
					<xsl:value-of select="@Width" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@Title">
				<xsl:attribute name="title">
					<xsl:value-of select="@Title" />
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates />
		</table>
	</xsl:template>
	<!--Table Row-->
	<xsl:template match="TableRow">
		<tr>
			<xsl:if test="@ID">
				<xsl:attribute name="id">
					<xsl:value-of select="@ID" />
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates />
		</tr>
	</xsl:template>
	<!--Table Cell-->
	<xsl:template match="TableCell">
		<td>
			<xsl:if test="@ID">
				<xsl:attribute name="id">
					<xsl:value-of select="@ID" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@Align">
				<xsl:attribute name="align">
					<xsl:value-of select="@Align" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@ColSpan">
				<xsl:attribute name="colspan">
					<xsl:value-of select="@ColSpan" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@NoWrap">
				<xsl:attribute name="nowrap"></xsl:attribute>
			</xsl:if>
			<xsl:if test="@RowSpan">
				<xsl:attribute name="rowspan">
					<xsl:value-of select="@RowSpan" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@Valign">
				<xsl:attribute name="valign">
					<xsl:value-of select="@Valign" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@Title">
				<xsl:attribute name="title">
					<xsl:value-of select="@Title" />
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates />
		</td>
	</xsl:template>
	<!--IFrame-->
	<xsl:template match="IFrame">
		<xsl:variable name="source">
			<xsl:call-template name="validateurl">
				<xsl:with-param name="url">
					<xsl:value-of select="@Source" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<IFRAME id="{@ID}" src="{$source}" frameborder="no" scrolling="{@Scrolling}" style="{@Style}"></IFRAME>
	</xsl:template>
	<!-- Components -->
	<!--Render search results-->
	<xsl:template match="RenderSearch">
		<xsl:variable name="url">
			<xsl:call-template name="validateurl">
				<xsl:with-param name="url">
					<xsl:value-of select="@URL" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<div>
			<xsl:attribute name="id"><xsl:value-of select="@ID" />SearchInput</xsl:attribute>
			<xsl:apply-templates select="RenderInput" />
		</div>
		<br />
		<div>
			<xsl:attribute name="id"><xsl:value-of select="@ID" />SearchResults</xsl:attribute>
		</div>
		<br />
		<script>
			function fnAction<xsl:value-of select="@ID" />SrchLoader(){
				// if search complete...
				<xsl:value-of select="@GoBtnID" />.disabled = false;
				if(window.oRender<xsl:value-of select="@ID" />SrchXML.readyState==4 <xsl:text disable-output-escaping="yes">&amp;</xsl:text><xsl:text disable-output-escaping="yes">&amp;</xsl:text> window.oRender<xsl:value-of select="@ID" />SrchXSL.readyState==4 ){
					fnvsSetStatus('<xsl:value-of select="$Done" />');

					var oValidXML = new ActiveXObject(g_MSXML_DOM);
					var fValidated = fnLoadAndValidate(window.oRender<xsl:value-of select="@ID" />SrchXML,oValidXML);

					if(fValidated<xsl:text disable-output-escaping="yes">&amp;</xsl:text><xsl:text disable-output-escaping="yes">&amp;</xsl:text>window.oRender<xsl:value-of select="@ID" />SrchXML.parseError.errorCode == 0<xsl:text disable-output-escaping="yes">&amp;</xsl:text><xsl:text disable-output-escaping="yes">&amp;</xsl:text>window.oRender<xsl:value-of select="@ID" />SrchXSL.parseError.errorCode == 0){
						if (window.oRender<xsl:value-of select="@ID" />SrchXML.childNodes(1).childNodes(0)==null){
							<xsl:value-of select="@ID" />SearchResults.innerHTML = '<xsl:text disable-output-escaping="yes">&lt;</xsl:text>span class="homepageinactive"<xsl:text disable-output-escaping="yes">&gt;</xsl:text><xsl:value-of select="@NoResults" /><xsl:text disable-output-escaping="yes">&lt;</xsl:text>/span<xsl:text disable-output-escaping="yes">&gt;</xsl:text><xsl:text disable-output-escaping="yes">&lt;</xsl:text>br/<xsl:text disable-output-escaping="yes">&gt;</xsl:text>'
						}else{
							sResults = window.oRender<xsl:value-of select="@ID" />SrchXML.transformNode(window.oRender<xsl:value-of select="@ID" />SrchXSL);
							<xsl:value-of select="@ID" />SearchResults.innerHTML = sResults;
						}
					}else{
						<xsl:value-of select="@ID" />SearchResults.innerHTML = '<xsl:text disable-output-escaping="yes">&lt;</xsl:text>span class="homepageinactive"<xsl:text disable-output-escaping="yes">&gt;</xsl:text><xsl:value-of select="$ErrorQueryOnline" /><xsl:text disable-output-escaping="yes">&lt;</xsl:text>/span<xsl:text disable-output-escaping="yes">&gt;</xsl:text><xsl:text disable-output-escaping="yes">&lt;</xsl:text>br/<xsl:text disable-output-escaping="yes">&gt;</xsl:text>';
					}
				}
			}

			function fnAction<xsl:value-of select="@ID" />Srch(){
				if(navigator.onLine){
					<xsl:value-of select="@GoBtnID" />.disabled = true;
					fnvsSetStatus('<xsl:value-of select="$SearchingDotDotDot" />');
					setTimeout("fnAction<xsl:value-of select="@ID" />SrchNow();", 0100, "javascript");
				}else{
					<xsl:value-of select="@ID" />SearchResults.innerHTML = '<xsl:text disable-output-escaping="yes">&lt;</xsl:text>span class=\"homePageInactive\"<xsl:text disable-output-escaping="yes">&gt;</xsl:text><xsl:value-of select="$NoOnlineFeaturesWhenOffline" /><xsl:text disable-output-escaping="yes">&lt;</xsl:text>/span<xsl:text disable-output-escaping="yes">&gt;</xsl:text>';
				}
			}

			function fnAction<xsl:value-of select="@ID" />SrchNow(){
				var sURL = "<xsl:value-of select="$url" />";
				var sArgs = "FeedLCID=<xsl:value-of select="@LCID" /><xsl:text disable-output-escaping="yes">&amp;</xsl:text>UserLang=" + navigator.userLanguage;

				<xsl:for-each select="RenderArgs/RenderArg">
					sArgs = sArgs + "<xsl:text disable-output-escaping="yes">&amp;</xsl:text><xsl:value-of select="@ItemID" />="+<xsl:value-of select="@ItemID" />.<xsl:value-of select="@ItemProp" />;
				</xsl:for-each>

				sURL += "?"+sArgs;
								
				window.oRender<xsl:value-of select="@ID" />SrchXML = new ActiveXObject("MSXML2.DOMDocument.3.0");
				window.oRender<xsl:value-of select="@ID" />SrchXSL = new ActiveXObject("MSXML2.DOMDocument.3.0");

				window.oRender<xsl:value-of select="@ID" />SrchXML.async = true;
				window.oRender<xsl:value-of select="@ID" />SrchXSL.async = true;

				window.oRender<xsl:value-of select="@ID" />SrchXML.onreadystatechange = fnAction<xsl:value-of select="@ID" />SrchLoader;
				window.oRender<xsl:value-of select="@ID" />SrchXSL.onreadystatechange = fnAction<xsl:value-of select="@ID" />SrchLoader;

				window.oRender<xsl:value-of select="@ID" />SrchXML.load(sURL);
				window.oRender<xsl:value-of select="@ID" />SrchXSL.load("vshome.xsl");
			}
		</script>
	</xsl:template>
	<!--Samples search tool -->
	<xsl:template match="ShowSamples">
		<xsl:variable name="url">
			<xsl:call-template name="validateurl">
				<xsl:with-param name="url">
					<xsl:value-of select="/Tab/Feeds/Feed/Source/@URL" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<span id="SamplesSearchSpan">
			<table style="MARGIN-LEFT: -3px; MARGIN-BOTTOM: -3px">
				<tr>
					<td>
						<div title="Search" class="homePageTitle">Samples Profile:</div>
					</td>
					<td colspan="2">
						<LABEL class="homePageTitle">Filter by:</LABEL>
						<INPUT id="SrchKwd" type="radio" value="SrchKwd" name="SrchGroup" checked="true" style="position:relative; top:3px">
							<xsl:attribute name="onclick">
							SamplesSrchQueryInpt.style.display="";
							SamplesSrchQueryTyp.style.display="none";
						</xsl:attribute>
						</INPUT>
						<LABEL for="SrchKwd">Keyword
						</LABEL>
						<INPUT id="SrchTyp" type="radio" value="SrchTyp" name="SrchGroup" style="position:relative; top:3px">
							<xsl:attribute name="onclick">
							SamplesSrchQueryInpt.style.display="none";
							SamplesSrchQueryTyp.style.display="";
						</xsl:attribute>
						</INPUT>
						<LABEL for="SrchTyp">Type</LABEL>
						<br />
					</td>
				</tr>
				<tr height="30">
					<td>
						<select id="SamplesProfileList">
							<xsl:attribute name="onchange">
								g_wshShell.regwrite(g_strRegistryHiveRoot+"SamplesProfile",SamplesProfileList.options(SamplesProfileList.selectedIndex).value);
							</xsl:attribute>
							<option value="vs">
								<xsl:value-of select="$VSDefaultProfile" />
							</option>
							<option value="vb">
								<xsl:value-of select="$VBDefaultProfile" />
							</option>
							<option value="vc">
								<xsl:value-of select="$VCDefaultProfile" />
							</option>
							<option value="cs">
								<xsl:value-of select="$CSDefaultProfile" />
							</option>
						</select>
					</td>
					<td width="200">
						<input id="SamplesSrchQueryInpt" type="text" style="width:100%; position:relative; top:0px">
							<xsl:attribute name="onkeypress">
								if(event.keyCode==13)btnGoSamplesSrch.click();
							</xsl:attribute>
						</input>
						<select id="SamplesSrchQueryTyp" style="display:none; width:100%; position:relative; top:0px">
							<xsl:for-each select="SampleType">
								<option>
									<xsl:value-of select="text()" />
								</option>
							</xsl:for-each>
						</select>
					</td>
					<td>
						<xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>
						<input id="btnGoSamplesSrch" type="button" value="Go" class="clsBtnFlat" style="position:relative; top:-1px">
							<xsl:attribute name="onclick">fnSamplesSrch();</xsl:attribute>
							<xsl:attribute name="onfocus">this.style.color = '#ff9933';</xsl:attribute>
							<xsl:attribute name="onblur">this.style.color = '#336699';</xsl:attribute>
							<xsl:attribute name="onmouseover">this.style.color = '#ff9933';</xsl:attribute>
							<xsl:attribute name="onmouseout">this.style.color = '#336699';</xsl:attribute>
						</input>
					</td>
				</tr>
			</table>
		</span>
		<br />
		<div class="homepageTitle" id="SamplesSearchTitle" style="display:none">Help Samples
				<br />
				<hr class="homepagerule" />
			</div>
		<span id="SamplesSearchResults"></span>
		<br />
		<div class="homepageTitle" id="OnlineSamplesSearchTitle" style="display:none">Online Samples
				<br />
				<hr class="homepagerule" />
			</div>
		<span id="OnlineSamplesSearchResults"></span>
		<br />
		<script>
			function fnSamplesSrchLoader(){
				// if online search complete...
				if(window.oSamplesSrchXML.readyState==4 <xsl:text disable-output-escaping="yes">&amp;</xsl:text><xsl:text disable-output-escaping="yes">&amp;</xsl:text> window.oSamplesSrchXSL.readyState==4 ){
					// ...search help
					fnGetHelpSamples();
					btnGoSamplesSrch.disabled = false;
					if(!document.activeElement.id){
						btnGoSamplesSrch.focus();
					}else{
						document.activeElement.focus();
					}
					fnvsSetStatus('<xsl:value-of select="$Done" />');
					OnlineSamplesSearchTitle.style.display = "";
					
					var oValidXML = new ActiveXObject(g_MSXML_DOM);
					var fValidated = fnLoadAndValidate(window.oSamplesSrchXML,oValidXML);

					if(fValidated<xsl:text disable-output-escaping="yes">&amp;</xsl:text><xsl:text disable-output-escaping="yes">&amp;</xsl:text>window.oSamplesSrchXML.parseError.errorCode == 0<xsl:text disable-output-escaping="yes">&amp;</xsl:text><xsl:text disable-output-escaping="yes">&amp;</xsl:text>window.oSamplesSrchXSL.parseError.errorCode == 0){
						sResults = window.oSamplesSrchXML.transformNode(window.oSamplesSrchXSL);
						if (window.oSamplesSrchXML.childNodes(1).childNodes(0)==null){
							OnlineSamplesSearchResults.innerHTML = '<xsl:text disable-output-escaping="yes">&lt;</xsl:text>span class="homepageinactive"<xsl:text disable-output-escaping="yes">&gt;</xsl:text><xsl:value-of select="$NoSamplesMatching" /><xsl:text disable-output-escaping="yes">&lt;</xsl:text>/span<xsl:text disable-output-escaping="yes">&gt;</xsl:text><xsl:text disable-output-escaping="yes">&lt;</xsl:text>br/<xsl:text disable-output-escaping="yes">&gt;</xsl:text>'
						}else{
							OnlineSamplesSearchResults.innerHTML = sResults;
						}
					}else{
						OnlineSamplesSearchResults.innerHTML = '<xsl:text disable-output-escaping="yes">&lt;</xsl:text>span class="homepageinactive"<xsl:text disable-output-escaping="yes">&gt;</xsl:text><xsl:value-of select="$ErrorQueryOnline" /><xsl:text disable-output-escaping="yes">&lt;</xsl:text>/span<xsl:text disable-output-escaping="yes">&gt;</xsl:text><xsl:text disable-output-escaping="yes">&lt;</xsl:text>br/<xsl:text disable-output-escaping="yes">&gt;</xsl:text>';
					}
				}
			}

			function fnSamplesSrch(){
				if(navigator.onLine){
					btnGoSamplesSrch.disabled = true;
					fnvsSetStatus('<xsl:value-of select="$SearchingDotDotDot" />');
					setTimeout("fnSamplesSrchNow();", 0100, "javascript");
				}else{
					OnlineSamplesSearchResults.innerHTML = '<xsl:text disable-output-escaping="yes">&lt;</xsl:text>span class=\"homePageInactive\"<xsl:text disable-output-escaping="yes">&gt;</xsl:text><xsl:value-of select="$NoOnlineFeaturesWhenOffline" /><xsl:text disable-output-escaping="yes">&lt;</xsl:text>/span<xsl:text disable-output-escaping="yes">&gt;</xsl:text>';
				}
			}

			function fnSamplesSrchNow(){
				var sURL = "<xsl:value-of select="$url" />";
				var sArgs = "FeedLCID=<xsl:value-of select="/Tab/Feeds/Feed/Source/@LCID" />";

				<xsl:for-each select="/Tab/Feeds/Feed/Source/Arg">
					sArgs = sArgs + "<xsl:text disable-output-escaping="yes">&amp;</xsl:text><xsl:value-of select="@Name" />=<xsl:value-of select="text()" />";
				</xsl:for-each>

				sURL += "?";
				
				try{
					samplesProfile = g_wshShell.regread(g_strRegistryHiveRoot+"SamplesProfile");
				}catch(e){
					samplesProfile = "vs";
				}

				if(samplesProfile != SamplesProfileList.options(SamplesProfileList.selectedIndex).value){
					for(var i = 0; i!=SamplesProfileList.options.length;i++){
						if(samplesProfile == SamplesProfileList.options(i).value)SamplesProfileList.selectedIndex=i;
					}
				}
				
				sArgs += "<xsl:text disable-output-escaping="yes">&amp;</xsl:text>profile="+SamplesProfileList.options[SamplesProfileList.selectedIndex].value;
				sURL += sArgs;
				
				sURL += "<xsl:text disable-output-escaping="yes">&amp;</xsl:text>keyword=";
				
				if (SrchKwd.checked){
					sURL += encodeURI(SamplesSrchQueryInpt.value);
				}else{
					sURL += encodeURI(SamplesSrchQueryTyp.options(SamplesSrchQueryTyp.selectedIndex).text);
				}

				window.oSamplesSrchXML = new ActiveXObject("MSXML2.DOMDocument.3.0");
				window.oSamplesSrchXSL = new ActiveXObject("MSXML2.DOMDocument.3.0");

				window.oSamplesSrchXML.async = true;
				window.oSamplesSrchXSL.async = true;

				window.oSamplesSrchXML.onreadystatechange = fnSamplesSrchLoader;
				window.oSamplesSrchXSL.onreadystatechange = fnSamplesSrchLoader;

				window.oSamplesSrchXML.load(sURL);
				window.oSamplesSrchXSL.load("vshome.xsl");
			}
			
			function fnGetHelpSamples(){
				SamplesSearchResults.innerHTML = "";

				try {
					// Get help object.
					var oSession = window.external.GetObject("Help").HxSession;
						
					// Get profile.
					fnGetSamplesProfile();

					// Set filter
					var sFilter;
					
					sFilter = "(\"TopicType\" = \"kbSampleProd\" AND (";
					
					switch (SamplesProfileList.options(SamplesProfileList.selectedIndex).value){
						case "vb":
							sFilter += "\"DocSet\" = \"Visual Basic\" OR (\"DocSet\" = \"MSDN\" AND \"ProductVers\" = \"kbVBp700\")";
							break;
						case "vc":
							sFilter += "\"DocSet\" = \"Visual C++\" OR (\"DocSet\" = \"MSDN\" AND \"ProductVers\" = \"kbVC700\")";
							break;
						case "cs":
							sFilter += "\"DocSet\" = \"C#\" OR (\"DocSet\" = \"MSDN\" AND \"ProductVers\" = \"C#\")";
							break;
						default:
							sFilter += "\"DocSet\" = \"Visual Studio\" OR \"DocSet\" = \"Visual Studio SDK\" OR \"DocSet\" = \"CrystalReports\" OR \"DocSet\" = \"Visual Source Safe\" OR \"DocSet\" = \"VSAnalyzer\" OR \"DocSet\" = \"VCM\" OR (\"DocSet\" = \"MSDN\" AND \"ProductVers\" = \"kbVS700\")";
							break;
					}
					
					sFilter += "))";

					// Set keyword.
					var sKeyword;
					
					if (SrchKwd.checked){
						sKeyword = SamplesSrchQueryInpt.value;
					}else{
						sKeyword = SamplesSrchQueryTyp.options(SamplesSrchQueryTyp.selectedIndex).text;
					}

					// Perform query
					fnvsSetStatus("<xsl:value-of select="$SearchingDotDotDot" />");
					if(sKeyword == "")
						sKeyword = "a*";
					
					var oTopicList = oSession.Query(sKeyword, "!DefaultFullTextSearch", 0, sFilter) ;
					
					// Show section title.
					SamplesSearchTitle.style.display="";

					// Process results
					var nNumberOfTopics = oTopicList.Count ;
					
					if (nNumberOfTopics){
						<xsl:text disable-output-escaping="yes">
						for (var i = 1 ; i &lt;= oTopicList.Count ; i++)
						{
							var oTopic = oTopicList.ItemAt(i) ;
							var sTitle = oTopic.Title(0,0);
							var sLocation = oTopic.Location;
							var sUrl = oTopic.URL;
							SamplesSearchResults.insertAdjacentHTML("BeforeEnd", "&lt;a class=\"homepageinactive\" href=\"javascript:browserNavigate(2,'" + sUrl + "');\"&gt;" + sTitle + ":" + sLocation + "&lt;/a&gt;&lt;BR&gt;");
						}
						</xsl:text>
					}else{
						SamplesSearchResults.innerHTML = '<xsl:text disable-output-escaping="yes">&lt;</xsl:text>span class="homepageinactive"<xsl:text disable-output-escaping="yes">&gt;</xsl:text><xsl:value-of select="$NoSamplesMatching" /><xsl:text disable-output-escaping="yes">&lt;</xsl:text>/span<xsl:text disable-output-escaping="yes">&gt;</xsl:text><br></br>'
					}
				}catch(e){
				}
			}
			
			fnGetSamplesProfile();
		</script>
			</xsl:template>
	<!--Render online samples -->
	<xsl:template match="Samples/Context">
		<xsl:apply-templates />
	</xsl:template>
	<!--Render search error -->
	<xsl:template match="ErrorReport">
		<br />
		<div class="homePageInactive">Unexpected error searching for services. If problems continue, please contact product support.</div>
	</xsl:template>
	<!--Render GotDotNet resource center resources (used by GDN include tool) -->
	<xsl:template match="resources/resource">
		<a class="homePageInactive">
			<xsl:attribute name="id">rsc<xsl:value-of select="position()" /></xsl:attribute>
			<xsl:attribute name="title">
				<xsl:value-of select="title/text()" />
			</xsl:attribute>
			<xsl:attribute name="browserNavigateURL"><xsl:value-of select="url/text()" /></xsl:attribute>
			<xsl:attribute name="href">javascript:browserNavigate(<xsl:choose>
					<xsl:when test="@Relative">
						<xsl:value-of select="@Relative"></xsl:value-of>
					</xsl:when>
					<xsl:otherwise>0</xsl:otherwise>
				</xsl:choose>, this.browserNavigateURL)</xsl:attribute>
			<xsl:value-of select="title/text()" />
		</a>
		<br />
	</xsl:template>
	<!--Render uddi resources (used by UDDI Find XML Web Services tool) -->
	<xsl:template match="BusinessEntityCollection/BusinessEntity/name"></xsl:template>
	<xsl:template match="BusinessEntityCollection/BusinessEntity/businessServices/businessService/name"></xsl:template>
	<xsl:template match="BusinessEntityCollection/BusinessEntity/businessServices/businessService/description"></xsl:template>
	<xsl:template match="BusinessEntityCollection/BusinessEntity">
		<xsl:if test="count(businessServices/businessService/bindingTemplates)!=0">
			<br />
			<a class="homePageInactive">
				<xsl:attribute name="href">javascript:NavigateToUDDIBusiness('<xsl:value-of select="@businessKey" />');</xsl:attribute>
				<xsl:attribute name="title">
					<xsl:value-of select="name/text()" />
				</xsl:attribute>
				<xsl:value-of select="name/text()" />
			</a>
			<hr class="homepagerule" />
			<xsl:apply-templates />
		</xsl:if>
	</xsl:template>
	<xsl:template match="businessServices/businessService">
		<xsl:if test="count(bindingTemplates)!=0">
			<a class="homePageInactive">
				<xsl:attribute name="href">javascript:NavigateToUDDIService('<xsl:value-of select="@serviceKey" />');</xsl:attribute>
				<xsl:attribute name="title">
					<xsl:value-of select="name/text()" />
				</xsl:attribute>
				<xsl:value-of select="name/text()" />
			</a>
			<br />
			<div class="homePageStatic">
				<xsl:value-of select="description/text()" />
			</div>
			<xsl:apply-templates />
			<br />
		</xsl:if>
	</xsl:template>
	<xsl:template match="bindingTemplate">
		<a class="homePageInactive">
			<xsl:attribute name="href">javascript:NavigateToUDDIBinding('<xsl:value-of select="@serviceKey" />','<xsl:value-of select="@bindingKey" />');</xsl:attribute>
			<xsl:attribute name="title">
				<xsl:value-of select="name/text()" />
			</xsl:attribute>
			<xsl:value-of select="accessPoint/text()" />
		</a>
		<br />
		<IMG src="vs:/images/update.bmp" class="homepageimage" Align="absmiddle"></IMG>
		<font size="3em">
			<a>
				<xsl:attribute name="href">
					<xsl:value-of select="accessPoint/text()" />
				</xsl:attribute>
				<xsl:attribute name="title">
					<xsl:value-of select="$AddRefToProject" />
				</xsl:attribute>
				<xsl:attribute name="onclick">
					var arrActiveSlnProjects = new VBArray(window.external.ActiveSolutionProjects);
					var nUBound = arrActiveSlnProjects.ubound(arrActiveSlnProjects.dimensions());
					if (nUBound == -1){
						alert('<xsl:value-of select="$AddReferencesDocs" />');
						return false;
					} else
					{
						var prj = arrActiveSlnProjects.getItem(arrActiveSlnProjects.lbound(arrActiveSlnProjects.dimensions()));
						try
						{
							var refProjectItem = prj.Object.AddWebReference("<xsl:value-of select="accessPoint/text()" />");
						}
						catch(e)
						{
							alert('<xsl:value-of select="$ReferencesNotSupported" />');
						}
						return false;
					}
				</xsl:attribute>
				<xsl:value-of select="$AddRefToProject" />
			</a>
		</font>
		<br />
	</xsl:template>
	<!-- ProjectMRUList -->
	<xsl:template match="ProjectMRUList">
		<DIV id="MRUTable">
			<TABLE width="400" cellspacing="0" cellpadding="0" border="0">
				<xsl:attribute name="id"><xsl:value-of select="Tab/@ID" />MruListTable</xsl:attribute>
				<THEAD>
					<TD width="60%" valign="top" id="mips1" class="homePageInactive">Name</TD>
					<TD width="35%" valign="top" id="mips2" class="homePageInactive">Modified</TD>
				</THEAD>
				<TBODY>
					<script>
						if(shouldGenerateMRU())
							document.write(generateMRUTableItems());
						else
							document.all("MRUTable").style.display = "none"; 
					</script>
				</TBODY>
			</TABLE>
		</DIV>
		<br clear="all" />
	</xsl:template>
	<xsl:template match="SearchMSDN">
		<xsl:variable name="url">
			<xsl:call-template name="validateurl">
				<xsl:with-param name="url">
					<xsl:value-of select="/Tab/Feeds/Feed/Source/@URL" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="srchID">
			<xsl:value-of select="/Tab/@ID" />
		</xsl:variable>
		<span id="spnPoobaOfSrch">
			<div TITLE="Library Online" class="homePageInactive">
				<b>MSDN Online Library</b>
			</div>
			<input selected="true" type="text" size="24">
				<xsl:attribute name="id">SrchVSOnlineSrchQueryInpt</xsl:attribute>
				<xsl:attribute name="onkeypress">if(event.keyCode==13)btnVSOnlineSrch.click();</xsl:attribute>
			</input>
			<xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>
			<input type="button" value="Go" class="clsBtnFlat" id="btnVSOnlineSrch">
				<xsl:attribute name="onclick">fnSrchMsdn(encodeURI(SrchVSOnlineSrchQueryInpt.value));</xsl:attribute>
				<xsl:attribute name="onfocus">this.style.color = '#ff9933';</xsl:attribute>
				<xsl:attribute name="onblur">this.style.color = '#336699';</xsl:attribute>
				<xsl:attribute name="onmouseover">this.style.color = '#ff9933';</xsl:attribute>
				<xsl:attribute name="onmouseout">this.style.color = '#336699';</xsl:attribute>
			</input>
			<xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>
			<input type="button" value="Advanced" class="clsBtnFlat">
				<xsl:attribute name="id">SrchVSOnlineSrchFullSEARCH</xsl:attribute>
				<xsl:attribute name="onclick">fnAdvancedSrch();</xsl:attribute>
				<xsl:attribute name="onfocus">this.style.color = '#ff9933';</xsl:attribute>
				<xsl:attribute name="onblur">this.style.color = '#336699';</xsl:attribute>
				<xsl:attribute name="onmouseover">this.style.color = '#ff9933';</xsl:attribute>
				<xsl:attribute name="onmouseout">this.style.color = '#336699';</xsl:attribute>
			</input>
			<p />
			<span id="VsMsdnOnlineSearchDisplayRegion"></span>
		</span>
		<script>
		function fnSrchMsdnLoader(){
			if( window.oSchXML.readyState==4 <xsl:text disable-output-escaping="yes">&amp;</xsl:text><xsl:text disable-output-escaping="yes">&amp;</xsl:text> window.oSchXSL.readyState==4 ){
				btnVSOnlineSrch.disabled = false;
				fnvsSetStatus('<xsl:value-of select="$Done" />');

				if(window.oSchXML.parseError.errorCode == 0<xsl:text disable-output-escaping="yes">&amp;</xsl:text><xsl:text disable-output-escaping="yes">&amp;</xsl:text>window.oSchXSL.parseError.errorCode == 0){
					sResults = window.oSchXML.transformNode(window.oSchXSL);
					if(sResults.indexOf("tbody")==-1){
						sResults = '<xsl:text disable-output-escaping="yes">&lt;</xsl:text>span class="homepageinactive"<xsl:text disable-output-escaping="yes">&gt;</xsl:text><xsl:value-of select="$NoDataAvail" /><xsl:text disable-output-escaping="yes">&lt;</xsl:text>/span<xsl:text disable-output-escaping="yes">&gt;</xsl:text>';
					}
					VsMsdnOnlineSearchDisplayRegion.innerHTML = sResults;

					// store query
					try{
						window.external.Globals.VariableValue("VSOnlineSrchHTML") = sResults;
						window.external.Globals.VariablePersists("VSOnlineSrchHTML") = true;
						window.external.Globals.VariableValue("VSOnlineSrchQuery") = SrchVSOnlineSrchQueryInpt.value;
						window.external.Globals.VariablePersists("VSOnlineSrchQuery") = true;
					}catch(m){
						//noop;
					}
				}else{
					VsMsdnOnlineSearchDisplayRegion.innerHTML = '<xsl:text disable-output-escaping="yes">&lt;</xsl:text>span class="homepageinactive"<xsl:text disable-output-escaping="yes">&gt;</xsl:text><xsl:value-of select="$ErrorQueryOnline" /><xsl:text disable-output-escaping="yes">&lt;</xsl:text>/span<xsl:text disable-output-escaping="yes">&gt;</xsl:text>';
				}
			}
		}

		function fn<xsl:value-of select="$srchID" />OnClick(){
			try{
				window.srchBitBucket = spnPoobaOfSrch.outerHTML;
				
				if(g_args["query"]){
					SrchVSOnlineSrchQueryInpt.value = decodeURI(g_args["query"]);
					setTimeout("btnVSOnlineSrch.click();", 0200, "javascript");
					g_args["query"]='';
				}else{
					SrchVSOnlineSrchQueryInpt.value = window.external.Globals.VariableValue("VSOnlineSrchQuery");
					VsMsdnOnlineSearchDisplayRegion.innerHTML =  window.external.Globals.VariableValue("VSOnlineSrchHTML");
				}
			}catch(m){
				//noop;
			}
		}

		function fnSrchMsdn(sQuery,sArgs){
			if(navigator.onLine){
				btnVSOnlineSrch.disabled = true;
				fnvsSetStatus('<xsl:value-of select="$SearchingDotDotDot" />');
				document.body.VSOnlineSrchQUERY = sQuery;
				document.body.VSOnlineSrchARGS = sArgs;
				setTimeout(" fnSrchMsdnNow();", 0100, "javascript");
			}else{
				VsMsdnOnlineSearchDisplayRegion.innerHTML = '<xsl:text disable-output-escaping="yes">&lt;</xsl:text>span class=\"homePageInactive\"<xsl:text disable-output-escaping="yes">&gt;</xsl:text><xsl:value-of select="$NoOnlineFeaturesWhenOffline" /><xsl:text disable-output-escaping="yes">&lt;</xsl:text>/span<xsl:text disable-output-escaping="yes">&gt;</xsl:text>';
			}
		}

		function fnSrchMsdnNow(){
			var sQuery = document.body.VSOnlineSrchQUERY;
			var sArgs = document.body.VSOnlineSrchARGS;
			var sURL = "";
			
			if(!sArgs){
				sArgs = "asxml=y";
				<xsl:for-each select="/Tab/Feeds/Feed/Source/Arg">
					sArgs = sArgs + "<xsl:text disable-output-escaping="yes">&amp;</xsl:text><xsl:value-of select="@Name" />=<xsl:value-of select="text()" />";
				</xsl:for-each>

				sURL += "?";
				sURL += sArgs + "<xsl:text disable-output-escaping="yes">&amp;</xsl:text>qu="+sQuery;
			}else{
				sURL += sArgs + "<xsl:text disable-output-escaping="yes">&amp;</xsl:text>asxml=y";
			}
			
			window.oSchXML = new ActiveXObject("MSXML2.DOMDocument.3.0");
			window.oSchXSL = new ActiveXObject("MSXML2.DOMDocument.3.0");

			window.oSchXML.onreadystatechange = fnSrchMsdnLoader;
			window.oSchXSL.onreadystatechange = fnSrchMsdnLoader;

			var sXSLURL = "LHsrch.xsl";
			
			var sTarget = "<xsl:value-of select="$url" />?tab=vs_msdn_search_online";
			var sUserLang = "<xsl:text disable-output-escaping="yes">&amp;</xsl:text>UserLang="+navigator.userLanguage;
			
			sURL = sTarget+sUserLang+"<xsl:text disable-output-escaping="yes">&amp;</xsl:text>Args="+sURL;
			
			window.oSchXML.async = true;
			window.oSchXSL.async = true;

			window.oSchXML.load(sURL);
			window.oSchXSL.load(sXSLURL);
		}
		
		function fnAdvancedSrch(){
			var sTarget = "<xsl:value-of select="$url" />?tab=vs_msdn_search_online";
			var sUserLang = "<xsl:text disable-output-escaping="yes">&amp;</xsl:text>UserLang="+navigator.userLanguage;

			browserNavigate(3,sTarget+sUserLang+"<xsl:text disable-output-escaping="yes">&amp;</xsl:text>AdvancedSrch=true");
		}
	</script>
	</xsl:template>
	<!--Search for XML Web Services tool-->
	<xsl:template match="SearchGotDotNet">
		<xsl:variable name="url">
			<xsl:call-template name="validateurl">
				<xsl:with-param name="url">
					<xsl:value-of select="@URL" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="srchID">
			<xsl:value-of select="/Tab/@ID" />
		</xsl:variable>
		<span id="spnGotDotNetSrch">
			<LABEL class="homePageTitle">Search in:</LABEL>
			<INPUT id="SrchUDDIProd" type="radio" name="SrchUDDI" checked="true" style="position:relative; top:3px" />
			<LABEL for="SrchUDDIProd">UDDI Production Environment</LABEL>
			<INPUT id="SrchUDDITest" type="radio" name="SrchUDDI" style="position:relative; top:3px" />
			<LABEL for="SrchUDDITest">UDDI Test Environment</LABEL>
			<hr class="homepagerule" />
			<table style="MARGIN-LEFT: -3px">
				<tr>
					<td>
						<div TITLE="Category:" class="HomePageTitle">Category:</div>
					</td>
					<td colspan="3">
						<div TITLE="Search for:" class="HomePageTitle">Search for:</div>
					</td>
				</tr>
				<tr>
					<td>
						<SELECT id="WSCategory">
							<xsl:for-each select="Classification">
								<OPTION>
									<xsl:attribute name="value">
										<xsl:value-of select="@GUID" />
									</xsl:attribute>
									<xsl:value-of select="text()" />
								</OPTION>
							</xsl:for-each>
						</SELECT>
					</td>
					<td width="200">
						<input type="text" style="width:100%">
							<xsl:attribute name="id">SrchGDNSrchQueryInpt</xsl:attribute>
							<xsl:attribute name="onkeypress">
								if(event.keyCode==13)btnGDNSrch.click();
							</xsl:attribute>
						</input>
					</td>
					<td>
						<input type="button" value="Go" class="clsBtnFlat" id="btnGDNSrch">
							<xsl:attribute name="onclick">
							var sArgs="";
							
							if(!document.body.VSGDNSrchARGS){
								<xsl:for-each select="Arg">
									sArgs += "<xsl:value-of select="@Name" />=<xsl:value-of select="text()" /><xsl:text disable-output-escaping="yes">&amp;</xsl:text>";
								</xsl:for-each>
							}
							fnSrchGDN(encodeURI(SrchGDNSrchQueryInpt.value),sArgs,'<xsl:value-of select="$url" />');
							</xsl:attribute>
							<xsl:attribute name="onfocus">this.style.color = '#ff9933';</xsl:attribute>
							<xsl:attribute name="onblur">this.style.color = '#336699';</xsl:attribute>
							<xsl:attribute name="onmouseover">this.style.color = '#ff9933';</xsl:attribute>
							<xsl:attribute name="onmouseout">this.style.color = '#336699';</xsl:attribute>
						</input>
					</td>
					<td>
						<input type="button" value="Advanced" class="clsBtnFlat">
							<xsl:attribute name="id">SrchGDNSrchFullSEARCH</xsl:attribute>
							<xsl:attribute name="browserNavigateURL"><xsl:value-of select="@AdvancedSrch" /></xsl:attribute>
							<xsl:attribute name="onclick">browserNavigate(3,this.browserNavigateURL);</xsl:attribute>
							<xsl:attribute name="onfocus">this.style.color = '#ff9933';</xsl:attribute>
							<xsl:attribute name="onblur">this.style.color = '#336699';</xsl:attribute>
							<xsl:attribute name="onmouseover">this.style.color = '#ff9933';</xsl:attribute>
							<xsl:attribute name="onmouseout">this.style.color = '#336699';</xsl:attribute>
						</input>
					</td>
				</tr>
			</table>
		</span>
		<span id="VsGDNSearchDisplayRegion"></span>
	</xsl:template>
	<!--Tree component-->
	<xsl:template match="RootNode">
		<ul style="margin-left: 0px; list-style-type:none">
			<xsl:attribute name="style">cursor:hand;list-style-type:none; margin-left: 0px; margin-bottom: 0px</xsl:attribute>
			<xsl:apply-templates />
		</ul>
	</xsl:template>
	<xsl:template match="ContainerNode">
		<xsl:variable name="openedimage">
			<xsl:call-template name="validateurl">
				<xsl:with-param name="url">
					<xsl:value-of select="@OpenedImage" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="closedimage">
			<xsl:call-template name="validateurl">
				<xsl:with-param name="url">
					<xsl:value-of select="@ClosedImage" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<li>
			<img align="absbottom" vspace="0">
				<xsl:if test="@ID">
					<xsl:attribute name="id"><xsl:value-of select="@ID" />Image</xsl:attribute>
				</xsl:if>
				<xsl:attribute name="alt">
					<xsl:value-of select="@AltText" />
				</xsl:attribute>
				<xsl:attribute name="title">
					<xsl:value-of select="@Title" />
				</xsl:attribute>
				<xsl:attribute name="height">
					<xsl:value-of select="@Height" />
				</xsl:attribute>
				<xsl:attribute name="width">
					<xsl:value-of select="@Width" />
				</xsl:attribute>
				<xsl:attribute name="src">
					<xsl:choose>
						<xsl:when test="@State='closed'">
							<xsl:value-of select="$openedimage" />
						</xsl:when>
						<xsl:when test="@State='opened'">
							<xsl:value-of select="$closedimage" />
						</xsl:when>
					</xsl:choose>
				</xsl:attribute>
			</img>
			<a class="homePageActive" href="">
				<xsl:attribute name="title">
					<xsl:value-of select="@Title" />
				</xsl:attribute>
				<xsl:attribute name="onClick">
					//set container state
					if(<xsl:value-of select="@ID" />Child.style.display=="none")
					{
						<xsl:value-of select="@ID" />Image.src = "<xsl:value-of select="$closedimage" />";
						<xsl:value-of select="@ID" />Child.style.display="list-item";
					} else {
						<xsl:value-of select="@ID" />Image.src = "<xsl:value-of select="$openedimage" />";
						<xsl:value-of select="@ID" />Child.style.display="none";
					}
					return false;
				</xsl:attribute>
				<xsl:value-of select="@Title" />
			</a>
			<ul>
				<xsl:if test="@ID">
					<xsl:attribute name="id"><xsl:value-of select="@ID" />Child</xsl:attribute>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="@State='closed'">
						<xsl:attribute name="style">list-style-type:none; display:none; margin-left: <xsl:value-of select="@Width" /></xsl:attribute>
					</xsl:when>
					<xsl:when test="@State='opened'">
						<xsl:attribute name="style">list-style-type:none; display:list-item; margin-left: <xsl:value-of select="@Width" /></xsl:attribute>
					</xsl:when>
				</xsl:choose>
				<xsl:apply-templates />
			</ul>
		</li>
	</xsl:template>
	<xsl:template match="ItemNode">
		<xsl:variable name="image">
			<xsl:call-template name="validateurl">
				<xsl:with-param name="url">
					<xsl:value-of select="@Image" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<li>
			<xsl:if test="@Image">
				<img>
					<xsl:attribute name="src">
						<xsl:value-of select="$image" />
					</xsl:attribute>
				</img>
			</xsl:if>
			<xsl:apply-templates />
		</li>
	</xsl:template>
	<!-- Supporting elements -->
	<!-- This template is used to determine if a tab is a hosted application -->
	<xsl:template name="HostingApplication"></xsl:template>
	<!-- This template is used to validate urls -->
	<xsl:template name="validateurl">
		<xsl:param name="url" /><xsl:choose><xsl:when test="starts-with($url, 'http:') or starts-with($url, '&#x2F;') or starts-with($url, 'https:') or starts-with($url, 'news:') or starts-with($url, 'ms-help:') or starts-with($url, 'vs:')"><xsl:value-of select="$url" /></xsl:when><xsl:otherwise>about:blank</xsl:otherwise></xsl:choose>
	</xsl:template>
</xsl:stylesheet>
