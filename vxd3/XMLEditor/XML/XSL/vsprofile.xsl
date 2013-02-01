<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"	xmlns:msxsl="urn:schemas-microsoft-com:xslt">
<xsl:include href="vsprofileStrings.xsl" />

<xsl:template match="/">
    <br/>
    <br/>
	<TABLE id="profileTable" cellspacing="0" cellpadding="5" border="0">
		<TR>
			<TD colspan="2">
				<label id="blurbattop" class="homePageStatic">Verify that the following settings are personalized for you:</label>
			</TD>
		</TR>
		
		<TR>
			<TD colspan="2">
				<label id="inptProfileProfileSelectLabel" for="inptProfileProfileSelect" class="homePageStatic" accessKey="R"><b>P<u>r</u>ofile:</b></label>
			</TD>
		</TR>

		<TR>
			<TD colspan="2">
				<select id="inptProfileProfileSelect" style="width: 100%" onchange="fnSetProfile(this.options(this.selectedIndex).value);"></select>
			</TD>
		</TR>

		<TR>
			<TD>
				<label id="inptProfileKeySchemeSelectLabel" for="inptProfileKeySchemeSelect" class="homePageInactive" accessKey="K"><u>K</u>eyboard Scheme:</label>
			</TD>
			<TD>
				<select id="inptProfileKeySchemeSelect" style="width: 100%" onchange="fnSetKeyScheme(this.options(this.selectedIndex).value);"></select>
			</TD>
		</TR>

		<TR>
			<TD>
				<label id="inptProfileLayoutSelectLabel" for="inptProfileLayoutSelect" class="homePageInactive" accessKey="W"><u>W</u>indow Layout:</label>
			</TD>
			<TD>
				<select id="inptProfileLayoutSelect" style="width: 100%" onfocus="this.oldIdx = this.selectedIndex;" onchange="if(!fnSetWinLayout(this.options(this.selectedIndex).value))this.selectedIndex = this.oldIdx;"></select>
			</TD>
		</TR>

		<TR>
			<TD>
				<label id="inptProfileFilterSelectLabel" for="inptProfileFilterSelect" class="homePageInactive" accessKey="I">Help F<u>i</u>lter:</label>
			</TD>
			<TD>
				<select id="inptProfileFilterSelect" style="width: 100%" onchange="fnSetHelpFilter(this.options(this.selectedIndex).value);"></select>
			</TD>
		</TR>

		<TR>
			<TD colspan="2">
				<hr class="homepagerule"/>
			</TD>
		</TR>

		<TR>
			<TD>
				<label id="showHelpLabel" class="homePageStatic"><b>Show Help:</b></label>
			</TD>
			<TD>
				<input type="radio" onclick="if(!window.bToldEm)alert(L_RebootNeeded_HTMLText); window.bToldEm = true; window.external.Properties('Environment', 'Help').Item('External').Value=false;" name="inptShowHelp" id="inptHelpIntegrated">
				<label id="inptHelpIntegratedLabel" for="inptHelpIntegrated" accessKey="N">I<u>n</u>ternal Help</label></input>
				<input type="radio" onclick="if(!window.bToldEm)alert(L_RebootNeeded_HTMLText); window.bToldEm = true;window.external.Properties('Environment', 'Help').Item('External').Value=true;" name="inptShowHelp" id="inptHelpExternal">
				<label id="inptHelpExternalLabel" for="inptHelpExternal" accessKey="X">E<u>x</u>ternal Help</label></input>
			</TD>
		</TR>

		<TR>
			<TD>
				<label id="inptProfileStartupSelectLabel" for="inptProfileStartupSelect" class="homePageStatic" accessKey="S"><b>At <u>S</u>tartup:</b></label>
			</TD>
			<TD>
				<select id="inptProfileStartupSelect" style="width: 100%" onchange="fnSetStartupItem(this.options(this.selectedIndex).value);"></select>
			</TD>
		</TR>
	</TABLE>
<script>
var L_RebootNeeded_HTMLText = "<xsl:value-of select="$RebootNeeded"/>"; //Changes will not take effect untill Visual Studio is restarted";
var L_VSHP_HTMLText = "<xsl:value-of select="$VSHP"/>";

var L_MostRecentSln_HTMLText = "<xsl:value-of select="$MostRecentSln"/>";
var L_PrjDlg_HTMLText = "<xsl:value-of select="$PrjDlg"/>";
var L_NewPrj_HTMLText = "<xsl:value-of select="$NewPrj"/>";
var L_EmptyIDE_HTMLText = "<xsl:value-of select="$EmptyIDE"/>";

var L_VSDesignLayout_HTMLText = "<xsl:value-of select="$VSDesignLayout"/>";
var L_VBDesignLayout_HTMLText = "<xsl:value-of select="$VBDesignLayout"/>";
var L_VCDesignLayout_HTMLText = "<xsl:value-of select="$VCDesignLayout"/>";
var L_SimpleWinLayout_HTMLText = "<xsl:value-of select="$SimpleWinLayout"/>";
var L_NoToolWinLayout_HTMLText = "<xsl:value-of select="$NoToolWinLayout"/>";

var L_DefaultKeyScheme_HTMLText = "<xsl:value-of select="$DefaultKeyScheme"/>";
var L_VB6KeyScheme_HTMLText = "<xsl:value-of select="$VB6KeyScheme"/>";
var L_VC6KeyScheme_HTMLText = "<xsl:value-of select="$VC6KeyScheme"/>";
var L_VC2KeyScheme_HTMLText = "<xsl:value-of select="$VC2KeyScheme"/>";
var L_VS6KeyScheme_HTMLText = "<xsl:value-of select="$VS6KeyScheme"/>";

var L_VSDefaultProfile_HTMLText = "<xsl:value-of select="$VSDefaultProfile"/>";
var L_VBDefaultProfile_HTMLText = "<xsl:value-of select="$VBDefaultProfile"/>";
var L_VCDefaultProfile_HTMLText = "<xsl:value-of select="$VCDefaultProfile"/>";
//var L_VFDefaultProfile_HTMLText = "<xsl:value-of select="$VFDefaultProfile"/>";
var L_VMDefaultProfile_HTMLText = "<xsl:value-of select="$VMDefaultProfile"/>";
var L_VIDefaultProfile_HTMLText = "<xsl:value-of select="$VIDefaultProfile"/>";
var L_CSDefaultProfile_HTMLText = "<xsl:value-of select="$CSDefaultProfile"/>";
var L_LearnDfltProfile_HTMLText = "<xsl:value-of select="$LearnDfltProfile"/>";
var L_JSDefaultProfile_HTMLText = "<xsl:value-of select="$JSDefaultProfile"/>";
var L_CustomProfile_HTMLText = "<xsl:value-of select="$CustomProfile"/>";

var L_VSFilterName_HTMLText = "<xsl:value-of select="$VSFilterName"/>";
var L_NoFilterName_HTMLText = "<xsl:value-of select="$NoFilterName"/>";
var L_VBFilterName_HTMLText = "<xsl:value-of select="$VBFilterName"/>";
var L_VCFilterName_HTMLText = "<xsl:value-of select="$VCFilterName"/>";
var L_VMFilterName_HTMLText = "<xsl:value-of select="$VMFilterName"/>";
var L_CSFilterName_HTMLText = "<xsl:value-of select="$CSFilterName"/>";
var L_JSFilterName_HTMLText = "<xsl:value-of select="$JSFilterName"/>";
var L_LearnFltName_HTMLText = "<xsl:value-of select="$LearnFltName"/>";

var L_NotInDebugMode_HTMLText = "<xsl:value-of select="$NotInDebugMode"/>";

var oarrStartupStrings = new Array( L_VSHP_HTMLText, L_MostRecentSln_HTMLText, L_PrjDlg_HTMLText, L_NewPrj_HTMLText, L_EmptyIDE_HTMLText);
var oarrWinLayouts = new Array("VSDesign","VBDesign","VCDesign","Simple","NoToolWin");
var oarrWinLayoutNames = new Array(L_VSDesignLayout_HTMLText, L_VBDesignLayout_HTMLText, L_VCDesignLayout_HTMLText, L_SimpleWinLayout_HTMLText, L_NoToolWinLayout_HTMLText);

var oarrWinLayoutMap = new Array();
var oarrKeySchemae = new Array();
var oarrKeySchemaeDisp = new Array();

var oarrProfileNames = new Array(L_VSDefaultProfile_HTMLText, L_VBDefaultProfile_HTMLText, L_VCDefaultProfile_HTMLText, L_VIDefaultProfile_HTMLText, L_VMDefaultProfile_HTMLText, L_LearnDfltProfile_HTMLText, L_CSDefaultProfile_HTMLText,L_JSDefaultProfile_HTMLText,L_CustomProfile_HTMLText); 

// global helper values
var g_sCurrProfileName = "";

// map name tokens to loc strings
oarrWinLayoutMap["Design"] = L_VSDesignLayout_HTMLText;
oarrWinLayoutMap["VSDesign"] = L_VSDesignLayout_HTMLText;
oarrWinLayoutMap["VBDesign"] = L_VBDesignLayout_HTMLText;
oarrWinLayoutMap["VCDesign"] = L_VCDesignLayout_HTMLText;
oarrWinLayoutMap["Simple"] = L_SimpleWinLayout_HTMLText;
oarrWinLayoutMap["NoToolWin"] = L_NoToolWinLayout_HTMLText;

function fnProfileInit(){
	//document.all("checkStateFrame").style.visibility = "hidden";
	
	if(inptProfileLayoutSelect.options.length == 0){
		fnEnumStartupItems(oarrStartupStrings);
		fnFillHelpList(inptProfileFilterSelect);
		fnEnumKeySchemae(oarrKeySchemae,oarrKeySchemaeDisp);
		fnEnumWinLayouts(oarrWinLayoutNames, oarrWinLayouts);
		fnEnumProfile(oarrProfileNames, oarrProfileNames);
	}
	var bHelpIntegrated = window.external.Properties("Environment", "Help").Item("External").Value;
	
	try{
		inptHelpIntegrated.checked = !bHelpIntegrated;
		inptHelpExternal.checked = !inptHelpIntegrated.checked;

		setTimeout("fnDetProfile();", 0200, "javascript");
	}catch(e){
//		alert(e.description);
	}
}

function fnEnumStartupItems(oArrItems){
	var iStartupItem = window.external.Properties("Environment", "General").Item("OnStartUp").Value;
	for(var i = 0; oArrItems.length!=i;i++){
		fnAddOption(inptProfileStartupSelect, i,oArrItems[i], i == iStartupItem);
	}
}
function fnSetStartupItem(iPreset){
	try{
		window.external.Properties("Environment", "General").Item("OnStartUp").Value = iPreset;
		fnSetBoxen();
	}catch(e){

	}
}

function fnEnumWinLayouts(oarrNames, oarrVals){
	var sCurrWinLayout = oarrWinLayoutMap[window.external.WindowConfigurations.ActiveConfigurationName];
	for(var i = 0; oarrNames.length!=i;i++){
		fnAddOption(inptProfileLayoutSelect, oarrVals[i],oarrNames[i], sCurrWinLayout == oarrNames[i]);
	}	
}
function fnSetWinLayout(sLayout,bNoDet){
	if(window.external.Mode != 1){
		alert(L_NotInDebugMode_HTMLText);
		return false;
	}
	try{
		window.external.WindowConfigurations.Item(sLayout).Apply(false);
		if(sLayout != inptProfileLayoutSelect.options(inptProfileLayoutSelect.selectedIndex).value){
			for(var i = 0; i!=inptProfileLayoutSelect.options.length;i++){
				if(sLayout == inptProfileLayoutSelect.options(i).value)inptProfileLayoutSelect.selectedIndex=i;
			}
		}
		if(!bNoDet)fnDetProfile();
	}catch(e){

	}
	return true;
}

function fnEnumKeySchemae(oarr,oarrDisp){
	try{
		var objFiles = new Enumerator(g_oFSO.getFolder(fnvsGetShellPath()).files);
		var sCurrentScheme = window.external.Properties('Environment', 'Keyboard').Item('Scheme').Value;

		fnAddOption(inptProfileKeySchemeSelect, L_DefaultKeyScheme_HTMLText, L_DefaultKeyScheme_HTMLText, sCurrentScheme == L_DefaultKeyScheme_HTMLText);
		for ( ; !objFiles.atEnd() ; objFiles.moveNext()){
    			var name = objFiles.item().Name;
    			if(name.substr(name.length-3,name.length).toLowerCase() == "vsk"){
				fnAddOption(inptProfileKeySchemeSelect, objFiles.item().path, name.substr(0,name.length-4), sCurrentScheme == objFiles.item().path);
    			}
  		}
		var sCustLoc = g_wshShell.SpecialFolders("appdata") + "\\Microsoft\\VisualStudio\\7.0";
		objFiles = new Enumerator(g_oFSO.getFolder(sCustLoc).files);
		for ( ; !objFiles.atEnd() ; objFiles.moveNext()){
    			var name = objFiles.item().Name;
    			if(name.substr(name.length-3,name.length).toLowerCase() == "vsk"){
				fnAddOption(inptProfileKeySchemeSelect, objFiles.item().path, name.substr(0,name.length-4), sCurrentScheme == objFiles.item().path);
    			}
  		}
	}catch(e){

	}
}
function fnSetKeyScheme(sVSKPath,bNoDet){
	try{
		window.external.Properties('Environment', 'Keyboard').Item('Scheme').Value = sVSKPath;
		if(sVSKPath != inptProfileKeySchemeSelect.options(inptProfileKeySchemeSelect.selectedIndex).value){
			for(var i = 0; i!=inptProfileKeySchemeSelect.options.length;i++){
				if(sVSKPath == inptProfileKeySchemeSelect.options(i).value)inptProfileKeySchemeSelect.selectedIndex=i;
			}
		}
		if(!bNoDet)fnDetProfile();
	}catch(e){

	}
}

function fnEnumProfile(oArrNames, oArrVals)
{
	for(var i = 0; oArrNames.length!=i;i++)
	{
		if(oArrNames[i] == L_JSDefaultProfile_HTMLText)
		{
			var k = 0;
			var fFound = false;
			var count = document.oaFiltList.length;
			
			for(var k = 0 ; k != count ; k++)
			{
				if(document.oaFiltList[k] == L_JSFilterName_HTMLText)
					fFound = true;
			}
			if(fFound == true)
				fnAddOption(inptProfileProfileSelect, oArrVals[i],oArrNames[i], false);
		}
		else
		{
			fnAddOption(inptProfileProfileSelect, oArrVals[i],oArrNames[i], false);
		}
	}
}
function fnSetProfile(sProfile){
	g_wshShell.regwrite(g_strRegistryHiveRoot+"SamplesProfile", "vs");
	if(window.external.Mode != 1)return false;
	switch(sProfile){
		case L_VSDefaultProfile_HTMLText:
			window.external.Properties("Environment", "ProjectsAndSolution").Item("ShowOutputWindowBeforeBuild").Value = true;
			window.external.Properties("Environment", "ProjectsAndSolution").Item("ShowTaskListAfterBuild").Value = true;
			sKeyPath = L_DefaultKeyScheme_HTMLText;
			sWinLayout = "VSDesign";
			sFilterName = L_NoFilterName_HTMLText;
			break;
		case L_VCDefaultProfile_HTMLText:
			window.external.Properties("Environment", "ProjectsAndSolution").Item("ShowOutputWindowBeforeBuild").Value = true;
			window.external.Properties("Environment", "ProjectsAndSolution").Item("ShowTaskListAfterBuild").Value = false;
			sKeyPath = L_VC6KeyScheme_HTMLText;
			sWinLayout = "VCDesign";
			sFilterName = L_VCFilterName_HTMLText;
			g_wshShell.regwrite(g_strRegistryHiveRoot+"SamplesProfile", "vc");
			break;
		case L_VBDefaultProfile_HTMLText:
			window.external.Properties("Environment", "ProjectsAndSolution").Item("ShowOutputWindowBeforeBuild").Value = false;
			window.external.Properties("Environment", "ProjectsAndSolution").Item("ShowTaskListAfterBuild").Value = true;
			sKeyPath = L_VB6KeyScheme_HTMLText;
			sWinLayout = "VBDesign";
			sFilterName = L_VBFilterName_HTMLText;
			g_wshShell.regwrite(g_strRegistryHiveRoot+"SamplesProfile", "vb");
			break;
		case L_VIDefaultProfile_HTMLText:
			window.external.Properties("Environment", "ProjectsAndSolution").Item("ShowOutputWindowBeforeBuild").Value = true;
			window.external.Properties("Environment", "ProjectsAndSolution").Item("ShowTaskListAfterBuild").Value = true;
			sKeyPath = L_VS6KeyScheme_HTMLText;
			sWinLayout = "VSDesign";
			sFilterName = L_NoFilterName_HTMLText;
			break;
		/*
		case L_VFDefaultProfile_HTMLText:
			sKeyPath = L_DefaultKeyScheme_HTMLText;
			sWinLayout = "VSDesign";
			sFilterName = L_VMFilterName_HTMLText;
			break;
		*/
		case L_VMDefaultProfile_HTMLText:
			window.external.Properties("Environment", "ProjectsAndSolution").Item("ShowOutputWindowBeforeBuild").Value = true;
			window.external.Properties("Environment", "ProjectsAndSolution").Item("ShowTaskListAfterBuild").Value = true;
			sKeyPath = L_DefaultKeyScheme_HTMLText;
			sWinLayout = "VSDesign";
			sFilterName = L_VMFilterName_HTMLText;
			break;
		case L_CSDefaultProfile_HTMLText:
			window.external.Properties("Environment", "ProjectsAndSolution").Item("ShowOutputWindowBeforeBuild").Value = true;
			window.external.Properties("Environment", "ProjectsAndSolution").Item("ShowTaskListAfterBuild").Value = true;
			sKeyPath = L_DefaultKeyScheme_HTMLText;
			sWinLayout = "VSDesign";
			sFilterName = L_CSFilterName_HTMLText;
			g_wshShell.regwrite(g_strRegistryHiveRoot+"SamplesProfile", "cs");
			break;
		case L_JSDefaultProfile_HTMLText:
			window.external.Properties("Environment", "ProjectsAndSolution").Item("ShowOutputWindowBeforeBuild").Value = true;
			window.external.Properties("Environment", "ProjectsAndSolution").Item("ShowTaskListAfterBuild").Value = true;
			sKeyPath = L_DefaultKeyScheme_HTMLText;
			sWinLayout = "VSDesign";
			sFilterName = L_JSFilterName_HTMLText;
			g_wshShell.regwrite(g_strRegistryHiveRoot+"SamplesProfile", "js");
			break;
		case L_LearnDfltProfile_HTMLText:
			window.external.Properties("Environment", "ProjectsAndSolution").Item("ShowOutputWindowBeforeBuild").Value = true;
			window.external.Properties("Environment", "ProjectsAndSolution").Item("ShowTaskListAfterBuild").Value = true;
			sKeyPath = L_DefaultKeyScheme_HTMLText;
			sWinLayout = "Simple";
			sFilterName = L_NoFilterName_HTMLText;
			break;
		default:
			return false;
	}

	try{
		for(var i=0;i!=inptProfileKeySchemeSelect.options.length;i++){
			if(inptProfileKeySchemeSelect.options(i).innerText == sKeyPath){
				sKeyPath = inptProfileKeySchemeSelect.options(i).value;
				break;
			}
		}
		for(var j=0;j!=oarrWinLayoutNames.length;j++){
			if(oarrWinLayoutNames[j] == sWinLayout){
				sWinLayout = oarrWinLayouts[j];
				break;
			}
		}
		fnSetKeyScheme(sKeyPath,true);
		fnSetHelpFilter(sFilterName,true);
		fnSetWinLayout(sWinLayout,true);
		setTimeout("fnDetProfile();",0500,"javascript");
	}catch(e){

	}
}
function fnDetProfile(){
  try{
	var bHelpInt = inptHelpIntegrated.checked;
	var sStartupItem = inptProfileStartupSelect.options(inptProfileStartupSelect.selectedIndex).value;
	var sCurrWinLayout = inptProfileLayoutSelect.options(inptProfileLayoutSelect.selectedIndex).innerText;
	var sCurrKeyScheme = inptProfileKeySchemeSelect.options(inptProfileKeySchemeSelect.selectedIndex).innerText;
	var sCurrFilter = g_sFilterName;
	var sProfileName = "";
	
	switch(sCurrKeyScheme){
		case L_DefaultKeyScheme_HTMLText:
			if(sCurrWinLayout==oarrWinLayoutMap["VSDesign"]||sCurrWinLayout==oarrWinLayoutMap["Design"]){
				if(sCurrFilter==L_VSFilterName_HTMLText||sCurrFilter==L_NoFilterName_HTMLText){
					sProfileName = L_VSDefaultProfile_HTMLText;
				}
			}
			if(sCurrWinLayout==oarrWinLayoutMap["VSDesign"]||sCurrWinLayout==oarrWinLayoutMap["Design"]){
				if(sCurrFilter==L_VMFilterName_HTMLText){
					sProfileName = L_VMDefaultProfile_HTMLText;
				}
			}
			if(sCurrWinLayout==oarrWinLayoutMap["VBDesign"]||sCurrWinLayout==oarrWinLayoutMap["Design"]){
				if(sCurrFilter==L_CSFilterName_HTMLText){
					sProfileName = L_CSDefaultProfile_HTMLText;
				}
			}
			if(sCurrWinLayout==oarrWinLayoutMap["VBDesign"]||sCurrWinLayout==oarrWinLayoutMap["Design"]){
				if(sCurrFilter==L_JSFilterName_HTMLText){
					sProfileName = L_JSDefaultProfile_HTMLText;
				}
			}
			if(sCurrWinLayout==oarrWinLayoutMap["Simple"]){
				if(sCurrFilter==L_VSFilterName_HTMLText||sCurrFilter==L_NoFilterName_HTMLText){
					sProfileName = L_LearnDfltProfile_HTMLText;
				}
			}
			break;
		case L_VB6KeyScheme_HTMLText:
			if((sCurrFilter==L_VBFilterName_HTMLText||sCurrFilter==L_NoFilterName_HTMLText)){
				if(sCurrWinLayout==oarrWinLayoutMap["VBDesign"]||sCurrWinLayout==oarrWinLayoutMap["Design"]){
					sProfileName = L_VBDefaultProfile_HTMLText;
				}
			}
			break;
		case L_VC6KeyScheme_HTMLText:
			if((sCurrFilter==L_VCFilterName_HTMLText||sCurrFilter==L_NoFilterName_HTMLText)){
				if(sCurrWinLayout==oarrWinLayoutMap["VCDesign"]||sCurrWinLayout==oarrWinLayoutMap["Design"]){
					sProfileName = L_VCDefaultProfile_HTMLText;
				}
			}
			break;
		case L_VC2KeyScheme_HTMLText:
			break;
		case L_VS6KeyScheme_HTMLText:
			if(sCurrWinLayout==oarrWinLayoutMap["VSDesign"]||sCurrWinLayout==oarrWinLayoutMap["Design"]){
				if(sCurrFilter==L_VSFilterName_HTMLText||sCurrFilter==L_NoFilterName_HTMLText){
					sProfileName = L_VIDefaultProfile_HTMLText;
				}
			}
			break;
		default:
			// shouldn't hit
	}
	if(sProfileName == "")sProfileName = L_CustomProfile_HTMLText;
	
	if(sProfileName != inptProfileProfileSelect.options(inptProfileProfileSelect.selectedIndex).value){
		for(var i = 0; i!=inptProfileProfileSelect.options.length;i++){
			if(sProfileName == inptProfileProfileSelect.options(i).value)inptProfileProfileSelect.selectedIndex=i;
		}
	}

  }catch(oErr){
	//alert(oErr.description);
  }
}

</script>
</xsl:template>
</xsl:stylesheet>











