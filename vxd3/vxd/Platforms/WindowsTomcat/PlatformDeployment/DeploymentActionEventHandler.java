package vxd.Platforms.WindowsTomcat.PlatformDeployment;

import vxd.*;
import org.w3c.dom.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.event.*;
import java.io.*;
import java.awt.*;
import java.util.regex.*;

public class DeploymentActionEventHandler implements ActionListener
{
    public static final String DEPLOYMENTCONFIGSDIR="Platforms/WindowsTomcat/PlatformDeployment/ConfigTemplates/";
    public static final String TOMCATDIR="C:/jdk1.2.2/jswdk/";
    public static final String WEBXMLFILE="web.xml";
    public static final String SERVERXMLFILE="webserver.xml";

    public DeploymentActionEventHandler()
    {
	;
    }

    public void actionPerformed(ActionEvent e)
    {
	if(vxd.controller==null || vxd.controller.project==null 
	   ||vxd.controller.project.programXSLT==null||
	   vxd.controller.project.programXSLT.length()==0)
	    {
		JOptionPane.showMessageDialog(vxd.frame,
					      "No Project Loaded to Deploy");
		return;
	    }
	if(e.getActionCommand().equals("STOP"))
	    {
	    }
	if(e.getActionCommand().equals("DEPLOY"))
	    {
		try
		    {
			File file=new File(DEPLOYMENTCONFIGSDIR+SERVERXMLFILE);
			FileInputStream rdr=new FileInputStream(file);
			DataInputStream dta=new DataInputStream(rdr);
			byte[] filedata=new byte[(int)file.length()];
			dta.readFully(filedata);
			String serverxml=new String(filedata);
			rdr.close();
			serverxml=serverxml.replaceAll("@NAME@",
					     vxd.controller.project.name);
			File f=new File(vxd.DEPLOYMENTDIR);
			serverxml=serverxml.replaceAll("@APPSDIR@",
						       f.toURL().toString().
						       substring(6,f.toURL().toString().length()));
			serverxml=serverxml.replaceAll("@PORT@",vxd.controller.project.
					     programXML.getDocumentElement().
					     getAttribute("Port"));
			serverxml=serverxml.replaceAll("@URI@",vxd.controller.project.
						       programXML.getDocumentElement().
						       getAttribute("URI"));
			File newdir=new File(vxd.DEPLOYMENTDIR+vxd.controller.project.name);
			newdir.mkdir();
			newdir=new File(vxd.DEPLOYMENTDIR+vxd.controller.project.name+"/WEB-INF");
			newdir.mkdir();
			newdir=new File(vxd.DEPLOYMENTDIR+vxd.controller.project.name+"/WEB-INF/classes");
			newdir.mkdir();
			newdir=new File(vxd.DEPLOYMENTDIR+vxd.controller.project.name+"/WEB-INF/classes/"+
					vxd.controller.project.
						       programXML.getDocumentElement().
						       getAttribute("Package"));
			newdir.mkdir();
			String webxml="";
			webxml+="<!DOCTYPE web-app PUBLIC \"-//Sun Microsystems, Inc.//DTD Web Application 2.3//EN\"";
			webxml+=" \"http://java.sun.com/dtd/web-app_2_3.dtd\">";
			webxml+="<web-app>";
			NodeList nl=vxd.controller.project.programXML.getDocumentElement().getElementsByTagName("HTML");
			for(int i=0;i<nl.getLength();++i)
			    {
				Element el=(Element)nl.item(i);
				webxml+="<servlet><servlet-name>"+
				    el.getAttribute("Name")+"_"+el.getAttribute("ID")+"</servlet-name>";
				webxml+="<servlet-class>"+ vxd.controller.project.programXML.getDocumentElement().
				    getAttribute("Package")+"."+el.getAttribute("Name")+"_"+
				    el.getAttribute("ID")+"</servlet-class>";
				webxml+="<load-on-startup>0</load-on-startup></servlet>";
			    }
			for(int i=0;i<nl.getLength();++i)
			    {
				Element el=(Element)nl.item(i);
				webxml+="<servlet-mapping><servlet-name>";
				webxml+=el.getAttribute("Name")+"_"+el.getAttribute("ID")+"</servlet-name>";
				webxml+="<url-pattern>/"+el.getAttribute("Name")+"</url-pattern></servlet-mapping>";
			    }
			webxml+="</web-app>";

		       	f=new File(vxd.DEPLOYMENTDIR+vxd.controller.project.name+"/WEB-INF/web.xml");
			PrintWriter out=new PrintWriter(new FileWriter(f));
			out.print(webxml);
			out.close();

			f=new File(DeploymentActionEventHandler.TOMCATDIR+"conf/server.xml");
			out=new PrintWriter(new FileWriter(f));
			out.print(serverxml);
			out.close();

			String compiledir=vxd.DEPLOYMENTDIR+vxd.controller.project.name+"/WEB-INF/classes/"+
			    vxd.controller.project.programXML.getDocumentElement().getAttribute("Package")+"/";

			String code=new String(vxd.controller.project.programXSLT);
			int idx=code.indexOf("package");
			int idx2=code.indexOf("package",idx+1)-1;
			if(idx2<0)
			    idx2=code.length();
			String filecode=code.substring(idx,idx2);
			Pattern p=Pattern.compile(".*public\\s+class\\s+(\\S+).*",Pattern.DOTALL|Pattern.MULTILINE);
			Matcher m=p.matcher(filecode);
			String filename;
			while(m.matches())
			    {
				filename=compiledir+m.group(1)+".java";
				File codefile=new File(filename);
				PrintWriter filewr=new PrintWriter(new FileWriter(codefile));
				filewr.print(filecode);
				filewr.close();
				com.sun.tools.javac.Main.compile(new String[]{filename});
				if(idx2==code.length())
				    break;
				idx=idx2+1;
				idx2=code.indexOf("package",idx+1)-1;
				if(idx2<0)
				    idx2=code.length();
				filecode=code.substring(idx,idx2);
				m=p.matcher(filecode);
			    }
		    }
		catch(Exception ex)
		    {
			ex.printStackTrace();
		    }
	    }
    }
}
