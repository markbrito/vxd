package vxd;

import org.w3c.dom.*;

public class vxdproject
{
    public String name;
    public String language;
    public String translator;
    public String platform;
    public Document languageElements;
    public Document programXML;
    public String programXSL;
    public String programXSLT;
    public String languageDTD;

    public vxdproject(String name,String l,String t,String p)
    {
	this.name=name;
	this.language=l;
	this.translator=t;
	this.platform=p;
    }

    public void setProgramXML(Document d)
    {
	programXML=d;
    }

    public void setProgramXSL(String d)
    {
	programXSL=d;
    }

    public void setProgramXSLT(String s)
    {
	programXSLT=s;
    }

    public void setLanguageDTD(String s)
    {
	languageDTD=s;
    }

    public void setLanguageElements(Document d)
    {
	languageElements=d;
    }
}
