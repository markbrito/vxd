package vxd;

import org.w3c.dom.*;
import javax.swing.*;
import javax.swing.event.*;
import javax.swing.tree.*;
import java.util.*;

public class XMLTreeModel implements TreeModel,TreeSelectionListener
{
    public Element root;
    public Vector listeners;

    public XMLTreeModel(Element root)
    {
	this.root=root;
	this.listeners=new Vector();
    }

    public Object getRoot(){return root;}

    public void setRoot(Element r)
    {
	this.root=r;
    }

    public boolean isLeaf(Object node)
    {
	if(((Element)node).getChildNodes().getLength()==0)
	    return true;
	else 
	    return false;
    }

    public int getChildCount(Object node)
    {
    	return ((Element)node).getChildNodes().getLength();
    }

    public Object getChild(Object node,int i)
    {
	return ((Node)node).getChildNodes().item(i);
    }

    public int getIndexOfChild(Object parent,Object child)
    {
	NodeList nl=((Element)parent).getChildNodes();
	for(int i=0;i<nl.getLength();++i)
	    {
		if(nl.item(i)==child)
		    return i;
	    }
	return -1;
    }

    public void valueForPathChanged(TreePath path,Object newvalue)
    {
	Enumeration e=listeners.elements();
	TreeModelEvent evt=new TreeModelEvent(this,
					      new Object[]{root});
	while(e.hasMoreElements())
	    {
		TreeModelListener list=(TreeModelListener)
		    e.nextElement();
		list.treeStructureChanged(evt);
	    }
    }

    public void addTreeModelListener(TreeModelListener l)
    {
	listeners.addElement(l);
    }

    public void removeTreeModelListener(TreeModelListener l)
    {
	listeners.removeElement(l);
    }

    public void valueChanged(TreeSelectionEvent e)
    {
	vxd.controller.selectedNode=e.getPath();
	SwingUtilities.invokeLater(new Runnable(){public void run()
		{vxd.controller.refreshXMLViews();}});
    }
}
