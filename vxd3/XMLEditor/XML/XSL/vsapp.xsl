<?xml version="1.0" standalone="yes" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msdn="http://msdn.microsoft.com/" xmlns:msxsl="urn:schemas-microsoft-com:xslt">
	<xsl:variable name="fontname">verdana</xsl:variable>
	<xsl:variable name="fontsize">1</xsl:variable>
	<xsl:variable name="fontcolor">windowtext</xsl:variable>
	<xsl:template match="vsapp">
		<BODY>
			<TABLE border="0" cellspacing="0" cellpadding="0" height="100%" width="100%">
				<tr>
					<td class="clsLogo" valign="middle" align="left" nowrap="true">
						<span class="clsSmallLogoCell">
							<xsl:value-of select="/vsapp/@name" />
						</span>
					</td>
				</tr>
				<tr align="left" valign="top">
					<td width="100%" background="images\dropshadow.gif">
						<div class="clsSubPgTlBarHidden" id="spnSubPageToolbar"></div>
					</td>
				</tr>
				<tr height="100%">
					<td id="tdContentCell" class="clsTabContent" colspan="3" valign="top">
						<br />
						<xsl:apply-templates />
					</td>
				</tr>
			</TABLE>
			<span id="alrt"></span>
			<script language="javascript">
		var oFSO =  new ActiveXObject("Scripting.FileSystemObject");
		var WshShell = new ActiveXObject("WScript.Shell");
		var MiscFilesProjectGuid = "{66A2671D-8FB5-11D2-AA7E-00C04F688DDE}"

		var L_defaultLocation_HTMLText = "images\\";
		var fo = L_defaultLocation_HTMLText + "greenfoldero.gif";
		var fc = L_defaultLocation_HTMLText + "greenfolder.gif";
		
		var L_Confirm_HTMLText = "Are you sure?";
		var L_ErrorEncountered_HTMLText = "Error encountered";
		var L_ContactVendor_HTMLText = "Please contact vendor.";

		var L_FPSEERROR_HTMLText = "Unable to upload selected project.\n"+L_ContactVendor_HTMLText;
		var L_MustOpenProject_HTMLText = "A project must be open.";
		var L_MustOpenProjectUpload_HTMLText = "A project must be open in order to upload.";
		var L_AccessForbidden_HTMLText = "Access forbidden.";
		var L_AuthenticateUser_HTMLText = L_ErrorEncountered_HTMLText+" authenticating user.\n"+L_ContactVendor_HTMLText;
		var L_LoadAuthenticationData_HTMLText = L_ErrorEncountered_HTMLText+" loading authentication data.\n"+L_ContactVendor_HTMLText;
		var L_LoadApplicationData_HTMLText = L_ErrorEncountered_HTMLText+" loading application.\n"+L_ContactVendor_HTMLText;
		var L_ParseApplication_HTMLText = L_ErrorEncountered_HTMLText+" parsing application.\n"+L_ContactVendor_HTMLText;
		var L_UnableToRemove_HTMLText = "Item may not be removed.";
		var L_Removed_HTMLText = "Removed: ";
		var L_Confirm_Unsafe_Transmission = "The web hosting site does not support secure transfer of the selected files. Do you wish to continue?";

		document.title = "<xsl:value-of select="//vsapp/@name" />";

		function fnCheckSSL(URL)
		{
			re = /https/;
			if(URL.search(re))
			{
				return confirm(L_Confirm_Unsafe_Transmission);
			}
			return true;
		}

		function fnAPPDEPLOY(sLoc, bInteractive){
			var xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
			xmlhttp.open("POST", sLoc, false);

			for(var i =0; i!=vsInstallField.length; i++){
				xmlhttp.setRequestHeader(vsInstallField[i].name,String(vsInstallField[i].value));
			}

			xmlhttp.send();

			if(xmlhttp.status == "403"){
				alert(L_AccessForbidden_HTMLText);
				return;
			}

			var oTmpXML = null;
					
			if(xmlhttp.responseXML.xml != ""){
				oTmpXML = new ActiveXObject("MSXML2.DOMDocument.3.0");
				oTmpXML.async = false;
				oTmpXML.loadXML(xmlhttp.responseXML.xml);
				if(oTmpXML.parseError != 0){
					alert(L_AuthenticateUser_HTMLText);
					return;
				}
			}else{
				alert(L_LoadAuthenticationData_HTMLText);
				return;
			}

			// received authentication data from app provider
			
			try{	
				// get provider's hosting app from 
				xmlhttp.open("GET", sURL+"/hosting.xml", false);	
				xmlhttp.send();
			}catch(e){
				alert(L_LoadApplicationData_HTMLText);
				return;
			}
			
			// received app 
				
			if(xmlhttp.responseXML.xml != ''){
				var oTmpXML2 = new ActiveXObject("MSXML2.DOMDocument.3.0");
				oTmpXML2.async = false;
				oTmpXML2.loadXML(xmlhttp.responseXML.xml);
				if(oTmpXML2.parseError.reason==""){
					var oUserData = oTmpXML2.selectSingleNode("//userdata");
					oTmpXML2.documentElement.replaceChild(oTmpXML.selectSingleNode("//userdata"), oUserData);
					window.external.Globals.VariableValue(sAppID) = oTmpXML2.xml;		
					location.reload();
				}else{
					alert(L_ParseApplication_HTMLText);
				}
			}else{
				alert(L_LoadApplicationData_HTMLText);
			}
		}

		function document.onclick(){
			//set selection state of current element
			var elemClicked=event.srcElement;
			
			//user clicked on project
			if(elemClicked.outerHTML.indexOf("xpiProjNum")!=-1){
				if(elemClicked.innerHTML.indexOf("xpiProjNum") == -1){
					var s = elemClicked.outerHTML.substr(elemClicked.outerHTML.indexOf("xpiProjNum")+12,1);

					window.xpiProjNum = parseInt(s);

					//set selection feedback
					if(window.xpiSelect){
						window.xpiSelect.style.background = "";
						window.xpiSelect.style.color = "#333366";
					}
					window.xpiSelect = elemClicked;
					window.xpiSelect.style.background = "#336699";
					window.xpiSelect.style.color = "ddeeff";

					if(window.xpeSelect){
						window.xpeSelect.style.background = "";
						window.xpeSelect.style.color = "#333366";
						window.xpeSelect="";
					}
				}

			//user clicked on folder or file
			}else if(elemClicked.className=="folderelement"||elemClicked.className=="fileelement"){
				var elementList=elemClicked;

				//get outer id of SPAN - set the target list
				while(elementList.tagName != "SPAN")
					elementList = elementList.parentElement;
				elementListTgt=document.getElementById(elementList.getAttribute("id")+"Target");

				//set target of upload (hidden form field) to path of selected element
				uploadTgtPath = elemClicked.parentElement.getAttribute("value");
				
				//if user clicked on folder, append name of folder to path
				if(elemClicked.className=="folderelement"){
					uploadTgtPath=uploadTgtPath+"\\"+elemClicked.innerText;
				}

				//save path for current list
				document.body.all[elementListTgt.id].item(1).value=uploadTgtPath;
				document.getElementById(elementList.id).CurrentItem = elemClicked;
				
				//set folder state
				if(elemClicked.className=="folderelement"){
					if(elemClicked.parentNode.children[2].style.display!="none"){
						elemClicked.parentNode.children[0].src = fc;
						elemClicked.parentNode.children[2].style.display="none";
					}else{
						elemClicked.parentNode.children[0].src = fo;
						elemClicked.parentNode.children[2].style.display="list-item";
					}
				}

				//set selection feedback
				if(window.xpeSelect){
					window.xpeSelect.style.background = "";
					window.xpeSelect.style.color = "#333366";
				}
				window.xpeSelect = elemClicked;
				window.xpeSelect.style.background = "#336699";
				window.xpeSelect.style.color = "ddeeff";
							
				if(window.xpiSelect){
					window.xpiSelect.style.background = "";
					window.xpiSelect.style.color = "#333366";
					window.xpiSelect="";
				}
			}
		}

		function addElem(oTgt, sType){
			//add file field to upload form
			oEl = document.createElement("INPUT");
			oEl.style.width = "90%";
			oEl.style.margin = 2;
			oEl.style.borderWidth = 1;
			oEl.style.fontSize = "70%";
			oEl.type = "file";
			oEl.name = "vsfileupl" + (oTgt.children.length + 1);
			oEl.onclick = new Function("window.filetgt = this; ");
			oTgt.appendChild(oEl);
		}

		function fnRemoveTgt(sHost, sTgt){
			var tgtItem=document.getElementById(sTgt).CurrentItem;
			var tgtPath=tgtItem.parentElement.getAttribute("value");
			var tgtProtected=tgtItem.parentElement.getAttribute("protected");
			var tgtItemPath=tgtPath+"\\"+tgtItem.innerText;

			if(tgtProtected){
				alert(L_UnableToRemove_HTMLText);
				return;
			}
			
			if(!confirm(L_Confirm_HTMLText)){return};

			var xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");

			xmlhttp.open("POST", sSiteMgr, false);
			
			xmlhttp.setRequestHeader("USER",sUserName);
			xmlhttp.setRequestHeader("PASS",sUserPass);
			xmlhttp.setRequestHeader("GUID",sGUID);
			xmlhttp.setRequestHeader("TARGETPATH",tgtItemPath);

			xmlhttp.send();

			if(xmlhttp.status == "403"){
				alert(L_AccessForbidden_HTMLText);
				return;
			}
			
			alert(L_Removed_HTMLText+tgtItem.innerText);
			
			tgtItem.parentElement.removeNode(1);
		}

		function fnFileWalk(oList){
			var dte = window.external.dte;
			var sln = dte.solution.projects;
			if(sln.Count){
				for(i=1;i!=sln.Count+1;i++){
					if(sln.Item(i).kind!=MiscFilesProjectGuid){
						try{
							var oEL = document.createElement("LI");
							var oIMG = document.createElement("IMG");
							var oSPN = document.createElement("SPAN");

							oIMG.alt = sln.item(i).Name;
							oIMG.style.cursor ="hand";
							oIMG.hspace = 2;
							oIMG.src = fc;
							
							oEL.title = sln.item(i).Name;
							oEL.style.listStyleType = "none";

							oSPN.innerHTML = sln.item(i).Name;
							oSPN.className = "homepageinactive";
							oSPN.xpiProjNum = i;
							oSPN.tabIndex = 0;
							
							var oUL = document.createElement("UL");
							
							oUL.style.marginLeft="5px";
							oUL.style.marginRight="15px";
							oUL.style.cursor ="hand";

							oEL.appendChild(oIMG);
							oEL.appendChild(oSPN);
							oEL.appendChild(oUL);
							
							oList.appendChild(oEL);
						}catch(oErr){
							alert(oErr.message);
						}
					}
				}
			}
		}

		function fnUploadFILL(){
			Upload.innerHTML = "";
			try{
				oList = document.createElement("UL");
				oList.style.marginLeft="5px";
				oList.style.marginRight="15px";
				oList.style.marginTop="5px";
				oList.style.cursor ="hand";
				
				fnFileWalk(oList);

				Upload.appendChild(oList);
				
				try{
					if(oList.children[0]){
						window.xpiProjNum = 1;
						window.xpiSelect = oList.children[0].children[1];
					}else{
						oSpn = document.createElement("SPAN");
						oSpn.innerText = L_MustOpenProject_HTMLText;
						oSpn.className = "homepageinactive";
						Upload.appendChild(oSpn);
					}
				}catch(e){

				}
			}catch(m){
				alert(m.message);// no projects;
			}
		}

		function fnListFILL(sHost, sTgt){
			var oXML = new ActiveXObject("MSXML2.DOMDocument.3.0");
			var oXSL = new ActiveXObject("MSXML2.DOMDocument.3.0");
			var xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");

			oXML.async = false;
			oXSL.async = false;

			xmlhttp.open("POST", sHost, false);

			xmlhttp.setRequestHeader("USER", sUserName);
			xmlhttp.setRequestHeader("PASS", sUserPass);
			xmlhttp.setRequestHeader("GUID",sGUID);

			xmlhttp.send();
			
			oXML.loadXML(xmlhttp.responseXML.xml);
			oXSL.load("list.xsl");
			
			if(fnLoadAndValidate(oXML, oXML))
			{
			    oTgt = document.all[sTgt];
			    oTgt.innerHTML = oXML.transformNode(oXSL);
			}
		}

		function fnUpload()
		{
			var dte = window.external.dte;
			var sln = dte.solution.projects;
			try
			{
				if(sln.Count==0)
				{
					alert(L_MustOpenProjectUpload_HTMLText);
					return;
				}
				if(fnCheckSSL(sTgtLoc))
				{
					sln.item(window.xpiProjNum).object.copyproject(sTgtLoc+window.xpiSelect.innerText,'',0,sUserName,sUserPass);
				}
			}
			catch(oErr)
			{
				//bugbug remove debugging code
				if(oErr.number = -2147467259)alert(L_FPSEERROR_HTMLText);
			}
			dte.executecommand("View.Refresh");
		}
		</script>
		</BODY>
	</xsl:template>
	<xsl:template match="hyperlink">
		<a>
			<xsl:variable name="url">
				<xsl:call-template name="validateurl">
					<xsl:with-param name="url">
						<xsl:value-of select="@url" />
					</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<xsl:if test="@ID">
				<xsl:attribute name="ID">
					<xsl:value-of select="@ID" />
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="href">
				<xsl:value-of select="$url" />
			</xsl:attribute>
			<xsl:attribute name="onclick">window.open("<xsl:value-of select="$url" />", "_blank"); return false;</xsl:attribute>
			<xsl:value-of select="text()" />
		</a>
	</xsl:template>
	<xsl:template match="br">
		<br />
	</xsl:template>
	<xsl:template match="section">
		<span class="homepageinactive">
			<xsl:value-of select="text()" />
		</span>
	</xsl:template>
	<xsl:template match="p">
		<p class="homepageinactive">
			<xsl:value-of select="text()" />
		</p>
	</xsl:template>
	<xsl:template match="logo">
		<xsl:variable name="src">
			<xsl:call-template name="validateurl">
				<xsl:with-param name="url">
					<xsl:value-of select="@src" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<img vspace="2" hspace="2">
			<xsl:attribute name="alt">
				<xsl:value-of select="@alt" />
			</xsl:attribute>
			<xsl:attribute name="src">
				<xsl:value-of select="$src" />
			</xsl:attribute>
		</img>
	</xsl:template>
	<xsl:template match="userdata">
		<script>
		var sUserName = "<xsl:value-of select="name/text()" />";
		var sUserPass = "<xsl:value-of select="pass/text()" />";
		var sGUID = "<xsl:value-of select="guid/text()" />";
		var sTgtLoc = "<xsl:value-of select="basetgt/text()" />";
		var sDataset = "<xsl:value-of select="dataset/text()" />";
		var sFileDataset1 = "<xsl:value-of select="filedataset1/text()" />";
		var sFileDataset2 = "<xsl:value-of select="filedataset2/text()" />";
		var sSiteMgr = "<xsl:value-of select="sitemgr/text()" />";
	</script>
	</xsl:template>
	<xsl:template match="paneset">
		<span>
			<br />
			<table class="bugbugspc" cellspacing="0" cellpadding="0" border="0">
				<tr>
					<td VALIGN="bottom" height="0">
						<table class="clsTabTblHead" cellspacing="0" cellpadding="0" border="0" height="0">
							<xsl:attribute name="ID">
								<xsl:value-of select="@id" />
							</xsl:attribute>
							<tr height="0">
								<xsl:attribute name="dispTgt">divGrpDisp<xsl:value-of select="@id" /></xsl:attribute>
								<xsl:apply-templates>
									<xsl:with-param name="tabbed">true</xsl:with-param>
									<xsl:with-param name="tempstr">
										<xsl:value-of select="@id" />
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
							<xsl:attribute name="ID">divGrpDisp<xsl:value-of select="@id" /></xsl:attribute>
						</div>
					</td>
				</tr>
			</table>
		</span>
		<script defer="true"><xsl:value-of select="@id" />.children[0].children[0].children[1].children[0].click();</script>
	</xsl:template>
	<xsl:template match="pane">
		<xsl:param name="tabbed" />
		<xsl:param name="tempstr" />
		<xsl:if test="$tempstr != ''">
			<td width="0" height="0"></td>
			<td class="clsTabTblCell" nowrap="true" width="0" height="0">
				<xsl:attribute name="onClick">
				// Save the currently active pane
				if(divGrpDisp<xsl:value-of select="$tempstr" />.ActivePane){
					divGrpDisp<xsl:value-of select="$tempstr" />.ActivePane.innerHTML=divGrpDisp<xsl:value-of select="$tempstr" />.innerHTML;
				}

				// Set the current paneset's active pane
				divGrpDisp<xsl:value-of select="$tempstr" />.innerHTML = this.children[1].innerHTML; 
				divGrpDisp<xsl:value-of select="$tempstr" />.ActivePane=this.children[1];

				//tab selection feedback
				if(this.parentElement.upCell){this.parentElement.upCell.className="clsTabTblCell";} 
				this.parentElement.upCell = this;
				this.className="clsTabTblCellUp";
				event.cancelBubble = true;
			</xsl:attribute>
				<a>
					<xsl:if test="@id">
						<xsl:attribute name="ID">
							<xsl:value-of select="@id" />
						</xsl:attribute>
					</xsl:if>
					<xsl:attribute name="href">
						<xsl:value-of select="@title" />
					</xsl:attribute>
					<xsl:attribute name="onclick">return false;</xsl:attribute>
					<xsl:attribute name="TITLE">
						<xsl:value-of select="@title" />
					</xsl:attribute>
					<b>
						<xsl:value-of select="@title" />
					</b>
				</a>
				<div>
					<xsl:attribute name="ID">divGrpDisp<xsl:value-of select="$tempstr" /><xsl:value-of select="@id" /></xsl:attribute>
					<xsl:attribute name="style">display:none</xsl:attribute>
					<BR />
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
	<xsl:template match="projectUploader">
		<table cellpadding="5" border="0" style="margin-right:5px">
			<tr align="left">
				<td valign="top" width="250">
					<table id="puplo" width="100%" height="100%" cellspacing="0" cellpadding="0">
						<tr id="projrw">
							<td height="100%">
								<span onclick="" style="overflow-x:none;height:250;margin-bottom:5px;width:100%;border:1pxl solid #669999;overflow:auto">
									<xsl:attribute name="id">Upload</xsl:attribute>
									<script defer="true">fnUploadFILL()</script>
								</span>
								<br />
								<input class="clsBtnFlat" id="uploadBtn" type="button" value="Upload" onclick="this.disabled = true; fnUpload(); this.disabled = false;" />
							</td>
						</tr>
					</table>
				</td>
				<td valign="middle">
					<center></center>
				</td>
				<td valign="top" width="250">
					<div style="float:left;height:250pxl" id="ProjList" nowrap="true">
						<span id="List" style="height:250;margin-bottom:5px; width:100%;border:1pxl solid #669999;overflow:auto;margin-bottom:5px">
							<script defer="true">fnListFILL(sDataset,'List');</script>
						</span>
						<br />
						<input id="ListTarget" name="uploadTgt" type="hidden"></input>
						<input class="clsBtnFlat" id="delBtn5" type="button" value="Remove">
							<xsl:attribute name="onclick">fnRemoveTgt(sDataset,'List')</xsl:attribute>
						</input>
					</div>
				</td>
			</tr>
		</table>
		<br />
	</xsl:template>
	<xsl:template match="fileUploader1">
		<iframe id="hiddenIframe1" name="hiddenIframe2" style="display:none"></iframe>
		<table cellpadding="5" border="0" style="margin-right:5px">
			<tr align="left">
				<td valign="top" width="250">
					<table id="fuplo1" width="100%" height="100%" cellspacing="0" cellpadding="0">
						<tr id="filerw1">
							<td margin="10">
								<form id="fileUplForm1" target="hiddenIfram2" enctype="multipart/form-data" method="post">
									<xsl:attribute name="action">
										<xsl:value-of select="//userdata/filetgt1/text()" />
									</xsl:attribute>
									<span id="UploadFiles1" style="height:250; margin-bottom:5; width:100%;border:1pxl solid #669999;overflow:auto"></span>
									<br />
									<input id="TgtFileList1Target" name="uploadTgt" type="hidden"></input>
									<input name="userName" type="hidden">
										<xsl:attribute name="value">
											<xsl:value-of select="//userdata/name/text()" />
										</xsl:attribute>
									</input>
									<input name="userPass" type="hidden">
										<xsl:attribute name="value">
											<xsl:value-of select="//userdata/pass/text()" />
										</xsl:attribute>
									</input>
									<input class="clsBtnFlat" id="addBtn1" type="button" value="Add" onclick="addElem(this.parentElement.children[0], 'file');" />
									<input class="clsBtnFlat" id="delBtn1" type="button" value="Remove" onclick="if(window.filetgt)window.filetgt.outerHTML = '';" />
									<input class="clsBtnFlat" id="uploadBtn1" type="submit" value="Upload">
										<xsl:attribute name="onclick">javascript:return fnCheckSSL('<xsl:value-of select="//userdata/filetgt1/text()" />');</xsl:attribute>
									</input>
								</form>
							</td>
						</tr>
					</table>
				</td>
				<td valign="middle">
					<center></center>
				</td>
				<td valign="top" width="250">
					<div style="float:left;height:250pxl" id="FileList1" nowrap="true">
						<span id="TgtFileList1" style="height:250;margin-bottom:5px; width:100%;border:1pxl solid #669999;overflow:auto">
							<script defer="true">fnListFILL(sFileDataset1, 'TgtFileList1');</script>
						</span>
						<br />
						<input class="clsBtnFlat" id="delBtn3" type="button" value="Remove">
							<xsl:attribute name="onclick">fnRemoveTgt(sFileDataset1,'TgtFileList1')</xsl:attribute>
						</input>
					</div>
				</td>
			</tr>
		</table>
	</xsl:template>
	<xsl:template match="fileUploader2">
		<iframe id="hiddenIframe2" name="hiddenIframe2" style="display:none"></iframe>
		<table cellpadding="5" border="0" style="margin-right:5px">
			<tr align="left">
				<td valign="top" width="250">
					<table id="fuplo2" width="100%" height="100%" cellspacing="0" cellpadding="0">
						<tr id="filerw2">
							<td>
								<form id="fileUplForm2" target="hiddenIfram2" enctype="multipart/form-data" method="post">
									<xsl:attribute name="action">
										<xsl:value-of select="//userdata/filetgt2/text()" />
									</xsl:attribute>
									<span id="UploadFiles2" style="height:250;margin-bottom:5px;width:100%;border:1pxl solid #669999;overflow:auto"></span>
									<br />
									<input id="TgtFileList2Target" name="uploadTgt" type="hidden"></input>
									<input name="userName" type="hidden">
										<xsl:attribute name="value">
											<xsl:value-of select="//userdata/name/text()" />
										</xsl:attribute>
									</input>
									<input name="userPass" type="hidden">
										<xsl:attribute name="value">
											<xsl:value-of select="//userdata/pass/text()" />
										</xsl:attribute>
									</input>
									<input class="clsBtnFlat" id="addBtn2" type="button" value="Add" onclick="addElem(this.parentElement.children[0], 'file');" />
									<input class="clsBtnFlat" id="delBtn2" type="button" value="Remove" onclick="if(window.filetgt)window.filetgt.outerHTML = '';" />
									<input class="clsBtnFlat" id="uploadBtn2" type="submit" value="Upload">
										<xsl:attribute name="onclick">javascript:return fnCheckSSL('<xsl:value-of select="//userdata/filetgt1/text()" />');</xsl:attribute>
									</input>
								</form>
							</td>
						</tr>
					</table>
				</td>
				<td valign="middle">
					<center></center>
				</td>
				<td valign="top" width="250">
					<div style="float:left;height:250pxl" id="FileList2" nowrap="true">
						<span id="TgtFileList2" style="height:250;margin-bottom:5px; width:100%;border:1pxl solid #669999;overflow:auto">
							<script defer="true">fnListFILL(sFileDataset2, 'TgtFileList2');</script>
						</span>
						<br />
						<input class="clsBtnFlat" id="delBtn4" type="button" value="Remove">
							<xsl:attribute name="onclick">fnRemoveTgt(sFileDataset2,'TgtFileList2')</xsl:attribute>
						</input>
					</div>
				</td>
			</tr>
		</table>
	</xsl:template>
	<xsl:template match="install">
		<xsl:variable name="src">
			<xsl:call-template name="validateurl">
				<xsl:with-param name="url">
					<xsl:value-of select="@src" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<table cellpadding="1">
			<xsl:apply-templates />
		</table>
		<br />
		<input class="clsBtnFlat" id="connectBtn" type="submit" value="Connect">
			<xsl:attribute name="onclick">fnAPPDEPLOY('<xsl:value-of select="$src" />', false); event.cancelBubble=true; return false;</xsl:attribute>
		</input>
	</xsl:template>
	<xsl:template match="input">
		<input>
			<xsl:attribute name="type">
				<xsl:value-of select="@type" />
			</xsl:attribute>
			<xsl:attribute name="value">
				<xsl:value-of select="@value" />
			</xsl:attribute>
			<xsl:apply-templates />
		</input>
	</xsl:template>
	<xsl:template match="textfield">
		<tr>
			<td class="homepageinactive"><xsl:value-of select="@name" />:</td>
			<td>
				<input id="vsInstallField" type="text">
					<xsl:attribute name="name">
						<xsl:value-of select="@name" />
					</xsl:attribute>
				</input>
			</td>
		</tr>
	</xsl:template>
	<xsl:template match="securefield">
		<tr>
			<td class="homepageinactive"><xsl:value-of select="@name" />:</td>
			<td>
				<input id="vsInstallField" type="password">
					<xsl:attribute name="name">
						<xsl:value-of select="@name" />
					</xsl:attribute>
				</input>
			</td>
		</tr>
	</xsl:template>
	<xsl:template match="updated">
		<script defer="true">
		window.status = 'Last app update: <xsl:value-of select="current()/text()" />';
	</script>
	</xsl:template>
</xsl:stylesheet>