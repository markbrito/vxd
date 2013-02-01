package vxd;

import javax.swing.*;
import javax.swing.event.*;
import java.awt.*;
import java.awt.event.*;
import org.w3c.dom.*;
import java.util.*;
import javax.swing.tree.*;

public class vxdIconConnectionView extends JComponent
    implements vxdDropTarget,LayoutManager,MouseListener
{
    public String name;
    public Element element;
    public Vector connectors;

    public vxdIconConnectionView(String name)
    {
	this.name=name;
	connectors=new Vector();
	setLayout(this);
	addMouseListener(this);
    }

    public void paint(Graphics g)
    {
	super.paint(g);
	Enumeration e=connectors.elements();
	while(e.hasMoreElements())
	    {
		vxdIconConnector con=(vxdIconConnector)e.nextElement();
		if(!con.isVisible())
		    continue;
		Point p1=con.icona.getLocation();
		Dimension d1=con.icona.getSize();
		p1.x+=d1.width/2;
		p1.y+=d1.height/2;
		Point p2=con.iconb.getLocation();
		Dimension d2=con.iconb.getSize();
		p2.x+=d2.width/2;
		p2.y+=d2.height/2;
		double m=1;
		double ang=0;
		try
		    {
			m=(p2.y-p1.y)/(p2.x-p1.x);
			ang=Math.asin((p2.y-p1.y)/
				      (Math.sqrt(Math.pow(p2.x-p1.x,2)+
						 Math.pow(p2.y-p1.y,2))));
		    }
		catch(Exception ex){;}
		p1.x+=(int)(Math.cos(ang)*(d1.width/2))*(p1.x>p2.x?-1:1);
		p1.y+=(int)(Math.sin(ang)*(d1.height/2));//*(p1.y>p2.y?-1:1);
		p2.x-=(int)(Math.cos(ang)*(d2.width/2))*(p1.x>p2.x?-1:1);
		p2.y-=(int)(Math.sin(ang)*(d2.height/2));//*(p1.y>p2.y?-1:1);
		if(con.type==vxdIconConnector.AGGREGATION)
		    {
			Point pa=new Point(p1);
			Point pc=new Point(p1);
			pa.x+=(int)(Math.cos(ang)*(vxdIconConnector.ARROWSIZE*1.5))*(p1.x>p2.x?-1:1);
			pa.y+=(int)(Math.sin(ang)*(vxdIconConnector.ARROWSIZE*1.5));
			pc.x+=(int)(Math.cos(ang)*(vxdIconConnector.ARROWSIZE*3))*(p1.x>p2.x?-1:1);
			pc.y+=(int)(Math.sin(ang)*(vxdIconConnector.ARROWSIZE*3));
			Point pb=new Point(pa);
			pa.x+=(int)(Math.cos(ang+Math.PI/2)*(vxdIconConnector.ARROWSIZE))*(p1.x>p2.x?-1:1);
			pa.y+=(int)(Math.sin(ang+Math.PI/2)*(vxdIconConnector.ARROWSIZE));
			pb.x+=(int)(Math.cos(ang-Math.PI/2)*(vxdIconConnector.ARROWSIZE))*(p1.x>p2.x?-1:1);
			pb.y+=(int)(Math.sin(ang-Math.PI/2)*(vxdIconConnector.ARROWSIZE));
			g.drawLine(p1.x,p1.y,pa.x,pa.y);
			g.drawLine(p1.x,p1.y,pb.x,pb.y);
			g.drawLine(pc.x,pc.y,pa.x,pa.y);
			g.drawLine(pc.x,pc.y,pb.x,pb.y);
			p1=pc;
		    }
		g.drawLine(p1.x,p1.y,p2.x,p2.y);
		if(con.type==vxdIconConnector.CONNECTION)
		    {
			Point pa=new Point(p2);
			pa.x-=(int)(Math.cos(ang)*(vxdIconConnector.ARROWSIZE))*(p1.x>p2.x?-1:1);
			pa.y-=(int)(Math.sin(ang)*(vxdIconConnector.ARROWSIZE));
			Point pb=new Point(pa);
			pa.x-=(int)(Math.cos(ang+Math.PI/2)*(vxdIconConnector.ARROWSIZE))*(p1.x>p2.x?-1:1);
			pa.y-=(int)(Math.sin(ang+Math.PI/2)*(vxdIconConnector.ARROWSIZE));
			g.drawLine(pa.x,pa.y,p2.x,p2.y);
			pb.x-=(int)(Math.cos(ang-Math.PI/2)*(vxdIconConnector.ARROWSIZE))*(p1.x>p2.x?-1:1);
			pb.y-=(int)(Math.sin(ang-Math.PI/2)*(vxdIconConnector.ARROWSIZE));
			g.drawLine(pb.x,pb.y,p2.x,p2.y);
		    }
	    }
    }

    public void update(Graphics g)
    {
	paint(g);
    }

    public void addConnector(vxdIconConnector c)
    {
	connectors.addElement(c);
    }

    public void removeConnector(vxdIconConnector c)
    {
	connectors.removeElement(c);
    }

    public void setElement(Element e)
    {
	element=e;
    }

    public Element getElement()
    {
	return element;
    }

    public void addLayoutComponent(String n,Component c)
    {
	;
    }

    public void validateIconsAndConnectors()
    {
	Component[] cpts=new Component[getComponentCount()];
	cpts=getComponents();
	for(int i=0;i<getComponentCount();++i)
	    {
		if(cpts[i] instanceof vxdDragIcon)
		    {
			vxdDragIcon icon=(vxdDragIcon)cpts[i];
			if(icon.element!=null)
			    {
				String visible=icon.element.getAttribute("Visible");
				if(visible!=null && visible.equals("FALSE"))
				    icon.setVisible(false);
				else if(visible!=null && visible.equals("TRUE"))
				    icon.setVisible(true);
			    }
		    }
	    }	
	Enumeration e=connectors.elements();
	while(e.hasMoreElements())
	    {
		vxdIconConnector con=(vxdIconConnector)e.nextElement();
		if(!con.icona.isVisible() || !con.iconb.isVisible())
		    con.setVisible(false);
		else if(con.icona.isVisible() && con.iconb.isVisible())
		    con.setVisible(true);
		if(!con.icona.isVisible() && con.iconb.isVisible() &&
		   con.type==vxdIconConnector.AGGREGATION)
		    {
			con.iconb.setVisible(false);
			con.iconb.element.getAttributeNode("Visible").
			    setValue("FALSE");
			e=connectors.elements();
		    }
		if((con.icona.getParent()==null || con.iconb.getParent()==null) &&
		   con.type==vxdIconConnector.CONNECTION)
		    {
			removeConnector(con);
			con.element.getParentNode().removeChild(con.element);
		    }
		else if(con.type==vxdIconConnector.AGGREGATION &&
			con.icona.getParent()==null &&
			con.iconb.getParent()!=null)
		    {
			removeConnector(con);
			remove(con.iconb);
			if(con.iconb.element.getParentNode()!=null)
			    con.iconb.element.getParentNode().
				removeChild(con.iconb.element);
			e=connectors.elements();
		    }
		else if(con.type==vxdIconConnector.AGGREGATION &&
			(con.icona.getParent()==null ||
			 con.iconb.getParent()==null))
		    {
			removeConnector(con);
		    }
	    }
	validate();
	repaint();
    }

    public void layoutContainer(Container c)
    {
	Component[] cpts=new Component[c.getComponentCount()];
	cpts=c.getComponents();
	for(int i=0;i<c.getComponentCount();++i)
	    {
		Component cpt=cpts[i];
		Dimension d=cpt.getPreferredSize();
		Point p=cpt.getLocation();
		cpt.setBounds(p.x,p.y,
			      d.width,d.height);
	    }
    }

    public Dimension minimumLayoutSize(Container c)
    {
	return preferredLayoutSize(c);
    }

    public Dimension preferredLayoutSize(Container c)
    {
	return new Dimension(vxd.XSIZE,vxd.YSIZE);
    }

    public void removeLayoutComponent(Component c)
    {
    }

    public void mousePressed(MouseEvent e)
    {
                vxd.controller.DEBUG_STACK_TRACE(e);

	TreePath path=new TreePath(element);
	vxd.controller.selectedNode=path;
	SwingUtilities.invokeLater(new Runnable(){public void run()
		{vxd.controller.refreshXMLViews();}});
    }

    public void mouseReleased(MouseEvent e)
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
}
