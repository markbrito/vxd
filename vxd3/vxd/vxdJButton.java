package vxd;

import javax.swing.*;
import javax.swing.event.*;
import java.awt.*;
import java.awt.event.*;
import java.awt.image.*;
import javax.xml.parsers.*;
import org.w3c.dom.*;
import java.io.*;

public class vxdJButton extends JComponent
    implements MouseListener,MouseMotionListener
{
    public String name;
    public ImageIcon icon;
    public Image image;
    public Image dragimage;
    public Element loadedElement;
    
    public vxdJButton(String name,ImageIcon icon,
		      Image image,Image dragimage)
    {
	addMouseListener(this);
	addMouseMotionListener(this);
	this.name=name;
        this.loadedElement=null;
	this.icon=icon;
	this.image=image;
	this.dragimage=dragimage;
	Dimension d=new Dimension(vxd.xiconsize+vxd.iconborder*2,
				  vxd.yiconsize+vxd.iconborder*2);
	setPreferredSize(d);
    }

    public void paint(Graphics g)
    {
	icon.paintIcon(this,g,vxd.iconborder,vxd.iconborder);
    }

    public void update(Graphics g)
    {
	paint(g);
    }

    public void mousePressed(MouseEvent e)
    {
        vxd.controller.DEBUG_STACK_TRACE(e);

	vxd.frame.setGlassPane(new DragGlassPane());
	DragGlassPane glass=(DragGlassPane)vxd.frame.getRootPane().
	    getGlassPane();
	Point p=SwingUtilities.convertPoint(this,e.getPoint(),glass);
	glass.setImage(dragimage);
	glass.setPoint(p);
	glass.setVisible(true);
	e.consume();
	glass.repaint();
    }

    public void mouseDragged(MouseEvent e)
    {

	DragGlassPane glass=(DragGlassPane)vxd.frame.getRootPane().
	    getGlassPane();
	Point p=SwingUtilities.convertPoint(this,e.getPoint(),glass);
	glass.setPoint(p);
	e.consume();
	glass.repaint();
    }

    public void mouseReleased(MouseEvent e)
    {
        vxd.controller.DEBUG_STACK_TRACE(e);

	DragGlassPane glass=(DragGlassPane)vxd.frame.getRootPane().
	    getGlassPane();
	Point p=SwingUtilities.convertPoint(this,e.getPoint(),glass);
	glass.setPoint(p);
	e.consume();
	glass.repaint();
	glass.setVisible(false);
	Point fp=SwingUtilities.convertPoint(this,e.getPoint(),vxd.frame);
        if(vxd.DEBUG2)
        {
            System.out.println("{MouseReleased} vxdJButton Name: "+this.name+" at:  "+fp);
      
            for(int n=0;n<vxd.controller.iconConnectionView.getComponentCount();++n)
                System.out.println("component: "+vxd.controller.iconConnectionView.getComponents()[n].getBounds());
        }
        Component droptarget=SwingUtilities.
	    getDeepestComponentAt(vxd.frame,fp.x,fp.y);
        if(vxd.DEBUG2)
            System.out.println("{Drop Target}: "+droptarget);
	if(droptarget!=null && droptarget instanceof vxdDropTarget)
	    {
		Point pt=SwingUtilities.convertPoint(this,e.getPoint(),
						     vxd.controller.iconConnectionView);
		Runnable r=new Runnable()
		    {
			vxdJButton button;
			Point pt;
			vxdDropTarget droptarget;
			public void setArgs(vxdJButton b,Point p,vxdDropTarget d)
			{
			    button=b;
			    pt=p;
			    droptarget=d;
			} 
			public void run()
			{
			    vxd.controller.addIcon(button,pt.x,pt.y,droptarget);
                            
			}
		    };
		try
		    {
			Class[] args=new Class[3];
			args[0]=vxdJButton.class;
			args[1]=Point.class;
			args[2]=vxdDropTarget.class;
			Object[] params=new Object[3];
			params[0]=this;
			params[1]=pt;
			params[2]=droptarget;
			r.getClass().getMethod("setArgs",args).invoke(r,params);
		    }
		catch(Exception ex)
		    {
			ex.printStackTrace();
		    }
		SwingUtilities.invokeLater(r);
                               
	    }
    }

    public void mouseMoved(MouseEvent e)
    {
	;
    }

    public void mouseEntered(MouseEvent e)
    {
        //TODO: Move this util after all loaded elements
        if(vxd.controller.loadingFile)
            vxd.controller.loadingFile=false;
         if(vxd.DEBUG2)
            {
                System.out.println("View components");
                for(int n=0;n<vxd.controller.iconConnectionView.getComponentCount();++n)
                    System.out.println("component: "+vxd.controller.iconConnectionView.getComponents()[n].getBounds());
            }
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
