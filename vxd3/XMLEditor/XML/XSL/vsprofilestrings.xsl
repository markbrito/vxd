<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt">
	<xsl:variable name="RebootNeeded">Changes will not take effect until Visual Studio is restarted</xsl:variable>

	<xsl:variable name="MostRecentSln">Load last loaded Solution</xsl:variable>
	<xsl:variable name="PrjDlg">Show Open Project dialog box</xsl:variable>
	<xsl:variable name="NewPrj">Show New Project dialog box</xsl:variable>
	<xsl:variable name="EmptyIDE">Show empty environment</xsl:variable>

	<xsl:variable name="VSDesignLayout">Visual Studio Default</xsl:variable>
	<xsl:variable name="VBDesignLayout">Visual Basic 6</xsl:variable>
	<xsl:variable name="VCDesignLayout">Visual C++ 6</xsl:variable>
	<xsl:variable name="SimpleWinLayout">Student Window Layout</xsl:variable>
	<xsl:variable name="NoToolWinLayout">No Tool Windows Layout</xsl:variable>

	<xsl:variable name="DefaultKeyScheme">[Default Settings]</xsl:variable>
	<xsl:variable name="VB6KeyScheme">Visual Basic 6</xsl:variable>
	<xsl:variable name="VC6KeyScheme">Visual C++ 6</xsl:variable>
	<xsl:variable name="VC2KeyScheme">Visual C++ 2</xsl:variable>
	<xsl:variable name="VS6KeyScheme">Visual Studio 6</xsl:variable>

	<xsl:variable name="VSDefaultProfile">Visual Studio Developer</xsl:variable>
	<xsl:variable name="VBDefaultProfile">Visual Basic Developer</xsl:variable>
	<xsl:variable name="VCDefaultProfile">Visual C++ Developer</xsl:variable>
	<xsl:variable name="VFDefaultProfile">Visual FoxPro Developer</xsl:variable>
	<xsl:variable name="VMDefaultProfile">VS Macro Developer</xsl:variable>
	<xsl:variable name="VIDefaultProfile">Visual InterDev Developer</xsl:variable>
	<xsl:variable name="CSDefaultProfile">Visual C# Developer</xsl:variable>
	<xsl:variable name="JSDefaultProfile">Visual J# Developer</xsl:variable>
	<xsl:variable name="LearnDfltProfile">Student Developer</xsl:variable>
	<xsl:variable name="CustomProfile">(custom)</xsl:variable>

	<xsl:variable name="VSFilterName">Visual Studio</xsl:variable>
	<xsl:variable name="NoFilterName">(no filter)</xsl:variable>
	<xsl:variable name="VBFilterName">Visual Basic</xsl:variable>
	<xsl:variable name="VCFilterName">Visual C++</xsl:variable>
	<xsl:variable name="VFFilterName">Visual FoxPro</xsl:variable>
	<xsl:variable name="VMFilterName">Visual Studio Macros</xsl:variable>
	<xsl:variable name="CSFilterName">Visual C#</xsl:variable>
	<xsl:variable name="JSFilterName">Visual J#</xsl:variable>
	<xsl:variable name="LearnFltName">Learning Developer</xsl:variable>

	<xsl:variable name="VSHP">Show Start Page</xsl:variable>
	<xsl:variable name="NotInDebugMode">Not available in debug mode</xsl:variable>
	
	<xsl:variable name="Done">Done</xsl:variable>
	<xsl:variable name="NoSamplesMatching">No samples found matching query.</xsl:variable>
	<xsl:variable name="ErrorQueryOnline">Error querying online. If error persists please contact your administrator.</xsl:variable> 
	<xsl:variable name="NoOnlineFeaturesWhenOffline">The online search feature does not work when offline.</xsl:variable>
	<xsl:variable name="SearchingDotDotDot">Searching...</xsl:variable>
	<xsl:variable name="AddReferencesDocs">To add a web reference, a project supporting web references must be open and selected in the Solution Explorer.</xsl:variable>
	<xsl:variable name="ReferencesNotSupported">The selected project does not support references, or the reference could not be found.</xsl:variable>
	<xsl:variable name="NoDataAvail">No Data Available. Please refine query.</xsl:variable>
	<xsl:variable name="LoadingData">Checking for updated information from the web...</xsl:variable>
</xsl:stylesheet>