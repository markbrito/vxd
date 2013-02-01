package vxd;

import org.w3c.dom.*;

public class vxdIconConnector
{
    public static final int CONNECTION=1;
    public static final int AGGREGATION=2;
    public static final int ARROWSIZE=7;

    public vxdDragIcon icona;
    public vxdDragIcon iconb;
    public int type;
    public boolean visible;
    Element element;

    public vxdIconConnector(vxdDragIcon a,vxdDragIcon b,int type)
    {
	icona=a;
	iconb=b;
	this.type=type;
	visible=true;
	element=null;
    }

    public vxdIconConnector(vxdDragIcon a,vxdDragIcon b,int type,Element e)
    {
	this(a,b,type);
	element=e;
    }

    public void setVisible(boolean v)
    {
	visible=v;
    }

    public boolean isVisible()
    {
	return visible;
    }

    public void setElement(Element e)
    {
	element=e;
    }
}
