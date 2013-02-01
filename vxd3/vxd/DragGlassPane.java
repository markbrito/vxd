package vxd;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;

public class DragGlassPane extends JComponent
{
    public Image image=null;
    public int xpos=0;
    public int ypos=0;

    public DragGlassPane()
    {
	setSize(vxd.XSIZE,vxd.YSIZE);
    }
    
    public void setImage(Image i)
    {
	image=i;
    }
    
    public synchronized void paint(Graphics g)
    {
	if(image!=null)
	    g.drawImage(image,xpos-image.getWidth(null)/2,
			ypos-image.getHeight(null)/2,null);
    }
    
    public void update(Graphics g)
    {
	paint(g);
    }

    public void setPoint(Point p)
    {
	xpos=p.x;
	ypos=p.y;
    }
}
