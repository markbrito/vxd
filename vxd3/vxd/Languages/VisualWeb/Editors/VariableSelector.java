package vxd.Languages.VisualWeb.Editors;

import vxd.*;
import javax.swing.*;
import org.w3c.dom.*;
import java.awt.*;
import java.util.*;

public class VariableSelector
    implements vxdPropertyEditDialog
{
    public JPanel editElement(org.w3c.dom.Document root,
			    org.w3c.dom.Element el,
			    org.w3c.dom.Attr attr,
			    Frame parent)
    {
	Vector v=new Vector();
	JList list=new JList();
	NodeList nl=root.getElementsByTagName("Connection");
	if(nl.getLength()==0)
	    {
		list.setEnabled(false);
	    }
	else
	    {
		for(int i=0;i<nl.getLength();++i)
		    {
			Element e=(Element)nl.item(i);
			Element el2=el;
			while(el2!=null && !el2.getTagName().equals("HTML"))
			    el2=(Element)el2.getParentNode();
			if(e.getAttribute("DestID").
			   equals(el2.getAttribute("ID")))
			    {
				el2=e;
				while(el2!=null && !el2.getTagName().equals("HTML"))
				    el2=(Element)el2.getParentNode();
				fillVarVector(el2.getChildNodes(),v);
			    }
		    }
		list.setDragEnabled(true);
	    }
	if(v.size()==0)
	    v.add("No Variables");
	list.setListData(v);
	JPanel p=new JPanel();
	p.add(list);
	return p;
    }

    public void fillVarVector(NodeList nl,Vector v)
    {
	for(int i=0;i<nl.getLength();++i)
	    {
		Element e=(Element)nl.item(i);
		String nm=e.getNodeName();
		if(nm.equals("Textbox") || nm.equals("ListBox") || nm.equals("Href") ||
		   nm.equals("Hidden") || nm.equals("RadioButton") || nm.equals("PasswordField") ||
		   nm.equals("FileUpload") || nm.equals("TextArea") || nm.equals("CheckBox") ||
		   nm.equals("ComboBox"))
		    {
			v.add("{"+e.getAttribute("Name")+"}");
		    }
		if(!e.getTagName().equals("Connection"))
		    fillVarVector(e.getChildNodes(),v);
	    }
    }
}
