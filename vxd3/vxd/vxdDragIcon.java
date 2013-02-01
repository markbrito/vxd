package vxd;

import javax.swing.*;
import javax.swing.event.*;
import java.awt.*;
import java.awt.event.*;
import org.w3c.dom.*;
import java.util.*;
import javax.swing.tree.*;

public class vxdDragIcon extends JComponent
    implements MouseListener,MouseMotionListener,vxdDropTarget,
	       ActionListener
{
    public vxdJButton button;
    public Image image;
    public Element element;
    public Point dragStart=null;

    public vxdDragIcon(vxdJButton button,int x,int y,Element e)
    {
	this.element=e;
	this.button=button;
	this.image=button.dragimage;
	setToolTipText(button.name);
	Dimension d=new Dimension(image.getWidth(null)+vxd.iconborder*2,
				  image.getHeight(null)+vxd.iconborder*2);
	setPreferredSize(d);
	setLocation(x-d.width/2,y-d.height/2);
	addMouseListener(this);
	addMouseMotionListener(this);
    }

    public Element getElement()
    {
	return element;
    }

    public void setElement(Element e)
    {
	this.element=e;
    }

    public void paint(Graphics g)
    {
	g.drawImage(image,vxd.iconborder,vxd.iconborder,null);
	String name=null;
	if(element!=null)
	    name=element.getAttribute("Name");
	if(name!=null)
	    {
		g.setColor(getBackground());
		for(int i=-1;i<=1;++i)
		    for(int j=-1;j<=1;++j)
			{
			    int xx=getWidth()/2-
				g.getFontMetrics().stringWidth(name)/2+i;
			    g.drawString(name,xx<0?0:xx,getHeight()-5+j);
			}
		g.setColor(getForeground());
		int xx=getWidth()/2-
		    g.getFontMetrics().stringWidth(name)/2;
		g.drawString(name,xx<0?0:xx,
			     getHeight()-5);
	    }
    }

    public void update(Graphics g)
    {
	paint(g);
    }

    public void mousePressed(MouseEvent e)
    {
        vxd.controller.DEBUG_STACK_TRACE(e);
	if(e.getButton()==MouseEvent.BUTTON2 ||
	   e.getButton()==MouseEvent.BUTTON3)
	    return;
	vxd.controller.iconConnectionView.remove(this);
	vxd.controller.iconConnectionView.add(this,0);
	Element root=(Element)vxd.controller.tree.getModel().getRoot();
	Element node=element;
	Vector v=new Vector();
	int i=0;
	do
	    {
		v.insertElementAt(node,i);
		node=(Element)node.getParentNode();
		++i;
	    }
	while(node!=null && node!=root);
	v.insertElementAt(node,i);
	Object[] objs=new Object[i+1];
	int j=0;
	for(;i>=0;--i)
	    objs[j++]=v.elementAt(i);
	TreePath path=new TreePath(objs);
	vxd.controller.selectedNode=path;
	dragStart=e.getPoint();
	SwingUtilities.invokeLater(new Runnable(){public void run()
		{vxd.controller.refreshXMLViews();}});
    }

    public void mouseDragged(MouseEvent e)
    {
	if(e.getButton()==MouseEvent.BUTTON2 ||
	   e.getButton()==MouseEvent.BUTTON3)
	    return;
	if(dragStart==null)
	    return;
	Point pt=SwingUtilities.convertPoint(this,e.getPoint(),getParent());
	setLocation(pt.x-dragStart.x,pt.y-dragStart.y);
	getParent().repaint();
    }

    public void mouseReleased(MouseEvent e)
    {
                vxd.controller.DEBUG_STACK_TRACE(e);

	if(e.getButton()==MouseEvent.BUTTON2 ||
	   e.getButton()==MouseEvent.BUTTON3)
	    {
		mouseReleasedButton2(e);
		return;
	    }
	Point pt=SwingUtilities.convertPoint(this,e.getPoint(),getParent());
	setLocation(pt.x-dragStart.x,pt.y-dragStart.y);
	Point lpt=getLocation();
	element.getAttributeNode("XPos").setValue(Integer.toString(lpt.x));
	element.getAttributeNode("YPos").setValue(Integer.toString(lpt.y));
	SwingUtilities.invokeLater(new Runnable(){public void run()
		{vxd.controller.refreshXMLViews();}});
	dragStart=null;
    }

    public void mouseMoved(MouseEvent e)
    {
	;
    }

    public void mouseEntered(MouseEvent e)
    {
	;
    }

    public void mouseExited(MouseEvent e)
    {
	;
    }

    public void mouseClicked(MouseEvent e)
    {
	;
    }

    public void mouseReleasedButton2(MouseEvent e)
    {
                vxd.controller.DEBUG_STACK_TRACE(e);

	if(e.getButton()==MouseEvent.BUTTON2 ||
	   e.getButton()==MouseEvent.BUTTON3)
	    {
		JPopupMenu popup=new JPopupMenu();
		popup.setLightWeightPopupEnabled(true);
		popup.setBorderPainted(true);
		JMenuItem del=new JMenuItem("Delete");
		del.setActionCommand("DELETE");
		del.addActionListener(this);
		popup.add(del);
		Vector v=vxd.controller.getAttributes(element.getTagName());
		Enumeration en=v.elements();
		while(en.hasMoreElements())
		    {
			vxdAttribute a=(vxdAttribute)en.nextElement();
			if(a.combo!=null &&
			   a.combo.size()==2 && 
			   a.combo.contains("TRUE") &&
			   a.combo.contains("FALSE"))
			    {
				JCheckBoxMenuItem cb=new JCheckBoxMenuItem(a.name);
				cb.setActionCommand(a.name);
				cb.addActionListener(this);
				if(element.getAttribute(a.name).equals("TRUE"))
				    cb.setState(true);
				else
				    cb.setState(false);
				popup.add(cb);
			    }
		    }
		popup.show(this,e.getX(),e.getY());
	    }
    }

    public void actionPerformed(ActionEvent e)
    {
                vxd.controller.DEBUG_STACK_TRACE(e);

	if(e.getActionCommand().equals("DELETE"))
	    {
		element.getParentNode().removeChild(element);
		vxd.controller.iconConnectionView.remove(this);
		vxd.controller.selectedNode=new TreePath(vxd.controller.project.
							 programXML.getDocumentElement());
		SwingUtilities.invokeLater(new Runnable(){public void run()
			{vxd.controller.iconConnectionView.validateIconsAndConnectors();}});
		SwingUtilities.invokeLater(new Runnable(){public void run()
			{vxd.controller.refreshXMLViews();}});
	    }
	else 
	    {
		if(element.getAttribute(e.getActionCommand()).equals("TRUE"))
		    element.getAttributeNode(e.getActionCommand()).
			setValue("FALSE");
		else
		    element.getAttributeNode(e.getActionCommand()).
			setValue("TRUE");
		SwingUtilities.invokeLater(new Runnable(){public void run()
			{vxd.controller.refreshXMLViews();}});
	    }
    }
}
