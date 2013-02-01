package vxd.Translators.ASPNETCSharpASPX.ExternalTranslators;

import vxd.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.event.*;
import java.io.*;
import java.awt.*;
import java.util.regex.*;

public class TranslationActionEventHandler implements ActionListener
{
    public TranslationActionEventHandler()
    {
	;
    }
	public void actionPerformed(ActionEvent e)
	{
	    if(e.getActionCommand().equals("SAVEXSL"))
		{
		    if(vxd.controller==null || vxd.controller.project==null ||vxd.controller.project.programXSL==null)
			{
			    JOptionPane.showMessageDialog(vxd.frame,"No Project Loaded to Save");
			    return;
			}
		    try
			{
			    File d=new File(vxd.SAVEFILEDIR+
					    vxd.controller.project.name+"/");
			    d.mkdir();
			    File f=new File(vxd.SAVEFILEDIR+
					    vxd.controller.project.name+"/"+
					    vxd.controller.project.name+".xsl");
			    PrintWriter out=new PrintWriter(new FileWriter(f));
			    out.print(vxd.controller.project.programXSL);
			    out.close();
			    JOptionPane.showMessageDialog(vxd.frame,vxd.SAVEFILEDIR+
					    vxd.controller.project.name+"/"+
					    vxd.controller.project.name+".xsl Saved");
			}
		    catch(Exception ex)
			{
			    JOptionPane.showMessageDialog(vxd.frame,"Saving "+vxd.SAVEFILEDIR+
							  vxd.controller.project.name+"/"+
							  vxd.controller.project.name+".xsl Failed");
			    ex.printStackTrace();
			}
		}
	    if(e.getActionCommand().equals("SAVECODE"))
		{
		    if(vxd.controller==null || vxd.controller.project==null || 
		       vxd.controller.project.programXSLT==null || vxd.controller.project.programXSLT.length()==0)
			{
			    JOptionPane.showMessageDialog(vxd.frame,"No Code to Save");
			    return;
			}
		    try
			{
			    File d=new File(vxd.SAVEFILEDIR+
					    vxd.controller.project.name+"/");
			    d.mkdir();
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
				    filename=vxd.SAVEFILEDIR+
					vxd.controller.project.name+"/"+
					m.group(1)+".java";
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
			    JOptionPane.showMessageDialog(vxd.frame,"Files Saved in "+vxd.SAVEFILEDIR+
							  vxd.controller.project.name+"/");

			}
		    catch(Exception ex)
			{
			    JOptionPane.showMessageDialog(vxd.frame,"Saving to "+vxd.SAVEFILEDIR+
							  vxd.controller.project.name+"/ Failed");
			    ex.printStackTrace();
			}
		}
	}
}
