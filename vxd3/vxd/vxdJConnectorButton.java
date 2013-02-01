package vxd;

import javax.swing.*;
import javax.swing.event.*;
import java.awt.*;
import java.awt.event.*;
import java.awt.image.*;
import javax.xml.parsers.*;
import org.w3c.dom.*;
import java.io.*;

public class vxdJConnectorButton extends JComponent
        implements MouseListener,MouseMotionListener {
    public String name;
    public ImageIcon icon;
    public Image image;
    public Image dragimage;
    
    public vxdJConnectorButton(String name,ImageIcon icon,
            Image image,Image dragimage) {
        addMouseListener(this);
        addMouseMotionListener(this);
        this.name=name;
        this.icon=icon;
        this.image=image;
        this.dragimage=dragimage;
        Dimension d=new Dimension(vxd.xiconsize+vxd.iconborder*2,
                vxd.yiconsize+vxd.iconborder*2);
        setPreferredSize(d);
    }
    
    public void paint(Graphics g) {
        icon.paintIcon(this,g,vxd.iconborder,vxd.iconborder);
    }
    
    public void update(Graphics g) {
        paint(g);
    }
    
    public void mousePressed(MouseEvent e) {
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
    
    public void mouseDragged(MouseEvent e) {
        DragGlassPane glass=(DragGlassPane)vxd.frame.getRootPane().
                getGlassPane();
        Point p=SwingUtilities.convertPoint(this,e.getPoint(),glass);
        glass.setPoint(p);
        e.consume();
        glass.repaint();
    }
    
    public void mouseReleased(MouseEvent e) {
        vxd.controller.DEBUG_STACK_TRACE(e);
        
        DragGlassPane glass=(DragGlassPane)vxd.frame.
                getRootPane().getGlassPane();
        Point p=SwingUtilities.convertPoint(this,e.getPoint(),glass);
        glass.setPoint(p);
        e.consume();
        glass.repaint();
        glass.setVisible(false);
        Point fp=SwingUtilities.convertPoint(this,e.getPoint(),vxd.frame);
        Component droptarget=SwingUtilities.
                getDeepestComponentAt(vxd.frame,fp.x,fp.y);
        if(droptarget!=null && droptarget instanceof vxdDropTarget &&
                !(droptarget instanceof vxdIconConnectionView) &&
                droptarget instanceof vxdDragIcon) {
            Point pt=SwingUtilities.convertPoint(this,e.getPoint(),droptarget);
            vxd.controller.addConnectorStart(this,pt.x,pt.y,(vxdDragIcon)droptarget);
        }
    }
    
    public void mouseMoved(MouseEvent e) {
        ;
    }
    
    public void mouseEntered(MouseEvent e) {
        ;
    }
    
    public void mouseExited(MouseEvent e) {
        ;
    }
    
    public void mouseClicked(MouseEvent e) {
        ;
    }
}
