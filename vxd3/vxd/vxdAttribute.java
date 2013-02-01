package vxd;

import java.util.*;

public class vxdAttribute
{
    public String name;
    public String label;
    public String value;
    public boolean required;
    public boolean fixed;
    public Vector combo;
    
    public vxdAttribute(String name,boolean req,boolean fixed,String value,Vector combo)
    {
	this.name=name;
	this.required=req;
	this.fixed=fixed;
	this.value=value;
	this.combo=combo;
	this.label=name;
    }
}
