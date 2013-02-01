package vxd;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;

public class DragConnectorGlassPane extends JComponent
    implements MouseMotionListener,MouseListener
{
    public int xstartpos=0;
    public int ystartpos=0;
    public int xendpos=0;
    public int yendpos=0;
    public vxdDragIcon source;

    public DragConnectorGlassPane(vxdDragIcon source)
    {
	this.source=source;
	Point p=new Point(0,0);
	Dimension d=source.getSize();
	p.x+=d.width/2;
	p.y+=d.height/2;
	Point fp=SwingUtilities.convertPoint(source,p,vxd.frame.getGlassPane());
	xendpos=xstartpos=fp.x;
	yendpos=ystartpos=fp.y;
	setSize(vxd.XSIZE,vxd.YSIZE);
	addMouseMotionListener(this);
	addMouseListener(this);
    }
    
    public synchronized void paint(Graphics g)
    {
	g.drawLine(xstartpos,ystartpos,xendpos,yendpos);
    }
    
    public void update(Graphics g)
    {
	paint(g);
    }

    public void mouseMoved(MouseEvent e)
    {
	xendpos=e.getX();
	yendpos=e.getY();
	repaint();
    }

    public void mouseReleased(MouseEvent e)
    {
                vxd.controller.DEBUG_STACK_TRACE(e);

	DragConnectorGlassPane glass=(DragConnectorGlassPane)vxd.frame.
	    getRootPane().getGlassPane();
	glass.setVisible(false);
	Point fp=SwingUtilities.convertPoint(this,e.getPoint(),vxd.frame);
	Component droptarget=SwingUtilities.
	    getDeepestComponentAt(vxd.frame,fp.x,fp.y);
	if(droptarget!=null && droptarget instanceof vxdDropTarget && 
	   !(droptarget instanceof vxdIconConnectionView) &&
	   droptarget instanceof vxdDragIcon)
	    {
		Runnable r=new Runnable()
		    {
			vxdDragIcon source;
			vxdDropTarget droptarget;
			public void setArgs(vxdDragIcon i,vxdDropTarget d)
			{
			    source=i;
			    droptarget=d;
			} 
			public void run()
			{
			    vxd.controller.addConnectorDrop(source,(vxdDragIcon)droptarget,
							    vxdIconConnector.CONNECTION);
			}
		    };
		try
		    {
			Class[] args=new Class[2];
			args[0]=vxdDragIcon.class;
			args[1]=vxdDropTarget.class;
			Object[] params=new Object[2];
			params[0]=source;
			params[1]=droptarget;
			r.getClass().getMethod("setArgs",args).invoke(r,params);
		    }
		catch(Exception ex)
		    {
			ex.printStackTrace();
		    }
		SwingUtilities.invokeLater(r);
	    }
    }

    public void mouseClicked(MouseEvent e)
    {
    }

    public void mouseDragged(MouseEvent e)
    {
    }

    public void mousePressed(MouseEvent e)
    {
    }

    public void mouseEntered(MouseEvent e)
    {
	;
    }

    public void mouseExited(MouseEvent e)
    {
	;
    }
}
