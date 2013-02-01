package vxd;

import org.w3c.dom.*;
import java.awt.*;
import javax.swing.*;

public interface vxdPropertyEditDialog
{
    public JPanel editElement(Document root,Element el,Attr a,Frame parent);
}
