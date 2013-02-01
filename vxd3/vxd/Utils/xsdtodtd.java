package vxd.Utils;

import javax.xml.transform.*;
import javax.xml.transform.stream.*;
import javax.xml.transform.dom.*;
import java.util.*;
import org.w3c.dom.*;
import org.xml.sax.*;
import org.xml.sax.helpers.*;
import java.io.*;
import javax.xml.*;
import javax.xml.parsers.*;
import org.apache.crimson.tree.*;

public class xsdtodtd
{
    public static final boolean DEBUG=false;
    public static void main(String[] args)
    {
	try
	    {
		if(args.length!=1)
		    {
			System.out.println("java xsdtodtd in.xsd");
			System.exit(0);
		    }

		DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
		factory.setValidating(false);
	
		factory.setIgnoringElementContentWhitespace(false);
		factory.setExpandEntityReferences(false);
		factory.setNamespaceAware(true);
		factory.setIgnoringElementContentWhitespace(true);
		
		factory.setExpandEntityReferences(false);
		
		factory.setIgnoringComments(true);
		factory.setCoalescing(false);
		factory.setXIncludeAware(false);
		DocumentBuilder builder = factory.newDocumentBuilder();
		
		File file=(new File(args[0]));
		builder.setErrorHandler(new DefaultHandler(){
			public void error(SAXParseException exception)throws SAXParseException{throw exception;}
			public void fatalError(SAXParseException exception)throws SAXParseException{throw exception;}
			public void warning(SAXParseException exception)throws SAXParseException{throw exception;}
		    });
		FileInputStream rdr=new FileInputStream(file);
		DataInputStream dta=new DataInputStream(rdr);
		byte[] filedata=new byte[(int)file.length()];
		dta.readFully(filedata);
		String serverxml=new String(filedata);
		rdr.close();
		Document xdoc=		builder.parse(new InputSource(new StringReader(serverxml.toString())));
		Element root=xdoc.getDocumentElement();
		if(DEBUG)
		    System.out.print(serverxml);
		NodeList els=root.getElementsByTagName("xs:element");
		for(int i=0;i<els.getLength();i++)
		    {
			Hashtable ht=new Hashtable();
			Hashtable htel=new Hashtable();
			Element el=(Element)els.item(i);
			String name=el.getAttribute("name");
			String type=el.getAttribute("type");
			if(name==null || name=="")
			    name=el.getAttribute("ref");
			String children="";
			String attrchildren="";
			Element curtype=null;
			NodeList types=root.getElementsByTagName("xs:element");
			for(int j=0;j<types.getLength();++j)
			    {
				Element tel=(Element)types.item(j);
				String tname=tel.getAttribute("name");
				if(tname==null || tname=="")
				    tname=tel.getAttribute("ref");
				if(htel.contains(tname))
				    ;
				else
				    {
					htel.put(tname,tname);
					if( tname!="")
					    {
						children+=tname+ "|";
					    }
				    }
				NodeList attrs=tel.getElementsByTagName("xs:attribute");

				if(attrs.getLength()>0)
				    {

					for(int k=0;k<attrs.getLength();++k)
					    {
						Element attr=(Element)attrs.item(k);
						String attrname=attr.getAttribute("name");
						if (attrname!="")
						    {
						    if(ht.contains(attrname))
							;
						    else
							{
							    ht.put(attrname,attrname);
							    attrchildren+=" "+attrname+ " CDATA #IMPLIED\n";
							}
						    }
					    }
				    }
				attrs=tel.getElementsByTagName("xs:attribute");
				if(attrs.getLength()>0)
				    {
					for(int k=0;k<attrs.getLength();++k)
					    {
						Element attr=(Element)attrs.item(k);
						String attrname=attr.getAttribute("name");
						if(attrname!="")
						    {
						    if(ht.contains(attrname))
							;
						    else
							{
							    ht.put(attrname,attrname);
							    attrchildren+=" "+attrname+ " CDATA #IMPLIED";
							}
						    }
					    }
				    }
				attrs=root.getElementsByTagName("xs:attribute");
				if(attrs.getLength()>0)
				    {

					for(int k=0;k<attrs.getLength();++k)
					    {
						Element attr=(Element)attrs.item(k);
						String attrname=attr.getAttribute("name");
						if(attrname!="")
						    {
						    if(ht.contains(attrname))
							;
						    else
							{
							    ht.put(attrname,attrname);
							    attrchildren+=" "+attrname+ " CDATA #IMPLIED";
							}
						    }
					    }
				    }
				NodeList attrgrps=tel.getElementsByTagName("xs:attributeGroup");
				if(attrgrps.getLength()>0)
				    {
					for(int p=0;p<attrgrps.getLength();++p)
					    {
						Element grpdef=null;
						Element attrgrp=(Element)attrgrps.item(p);
						String attrgrpname=attrgrp.getAttribute("ref");
						if(attrgrpname==null || attrgrpname=="")
						    attrgrpname=attrgrp.getAttribute("name");
						NodeList grpdefs=root.getElementsByTagName("xs:attributeGroup");
						for(int q=0;q<grpdefs.getLength();++q)
						    {
							grpdef=(Element)grpdefs.item(q);
							String grpdefname=grpdef.getAttribute("name");
							if(grpdefname==null || grpdefname=="")
							    grpdefname=grpdef.getAttribute("ref");

							if(grpdefname.equals(attrgrpname))
							    {
								if(grpdef!=null)
								    {
									NodeList gattrs=grpdef.getElementsByTagName("xs:attribute");
									if(gattrs.getLength()>0)
									    {
										for(int k=0;k<gattrs.getLength();++k)
										    {
											Element gattr=(Element)gattrs.item(k);
											String gattrname=gattr.getAttribute("name");
												if(gattrname!=null && gattrname!="")
												    {
												    
												    if(ht.contains(gattrname))
													;
												    else
													{
													    ht.put(gattrname,gattrname);
													    attrchildren+=(" "+gattrname+ " CDATA #IMPLIED");
													}
												    }
										    }
									    }
								    }
							    }
						    }
					    }
				    }
			    }
			types=root.getElementsByTagName("xs:group");
			for(int j=0;j<types.getLength();++j)
			    {
				Element tel=(Element)types.item(j);
				String tname=tel.getAttribute("name");
				if(tname==null || tname=="")
				    tname=tel.getAttribute("ref");
				NodeList eltnodes=tel.getElementsByTagName("xs:choice");

				for(int tt=0;tt<eltnodes.getLength();tt++)
				    {
					Element etel=(Element)eltnodes.item(tt);
					String eltname=etel.getAttribute("name");
					if(eltname==null || tname=="")
					    eltname=tel.getAttribute("ref");
					    {
						NodeList choices=etel.getElementsByTagName("xs:element");

						for(int r=0;r<choices.getLength();++r)
						    {
							Element choiceel=(Element)choices.item(r);
							String choiceelname=choiceel.getAttribute("name");
								if(choiceelname!="")
								    {
								    if(htel.contains(choiceelname))
									;
								    else
									{
									    htel.put(choiceelname,choiceelname);
									    children+=choiceelname+"|";
									}
								    }
							NodeList attrs=choiceel.getElementsByTagName("xs:attribute");
							if(attrs.getLength()>0)
							    {
								for(int k=0;k<attrs.getLength();++k)
								    {
									Element attr=(Element)attrs.item(k);
									String attrname=attr.getAttribute("name");
									if(attrname!=null && attrname!="")
									    {
										if(ht.contains(attrname))
										;
									    else
										{
										    ht.put(attrname,attrname);
										    attrchildren+=" "+attrname+ " CDATA #IMPLIED";
										}
									    }
								    }
							    }
						    }
					    }
				    }
			    }
			System.out.println("<!ELEMENT "+name+" ("+
					   children+" Connection)*>\n\n");
			System.out.println("<!ATTLIST "+name+" "+attrchildren+"\n>\n\n");		    
		    }
	    }	    
	catch(Exception e){e.printStackTrace();}
    }
}
