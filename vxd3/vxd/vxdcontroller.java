package vxd;

import javax.swing.*;
import javax.swing.event.*;
import java.awt.*;
import java.awt.event.*;
import java.awt.image.*;
import javax.xml.parsers.*;
import javax.xml.transform.*;
import javax.xml.transform.stream.*;
import javax.xml.transform.dom.*;
import java.util.*;
import org.w3c.dom.*;
import org.xml.sax.*;
import org.xml.sax.helpers.*;
import java.io.*;
import javax.swing.tree.*;
import java.util.regex.*;
import org.apache.crimson.tree.*;
import org.apache.crimson.jaxp.*;
import org.apache.crimson.parser.*;
import org.apache.crimson.util.*;
import javax.swing.event.*;
import javax.swing.tree.*;

public class vxdcontroller {
    public static final boolean DEBUG=vxd.DEBUG;
    public static final String LANGUAGEDIR="Languages/";
    public static final String TRANSLATORDIR="Translators/";
    public static int IDCOUNT=0;
    public boolean loadingFile=false;
    public Object iconLoadedElementSync=new Object();
    public vxdproject project;
    public JSplitPane mainSplitView;
    public JSplitPane projectSplitView;
    public vxdIconConnectionView iconConnectionView;
    public JTabbedPane propertyTabSet;
    public JPanel propertyTabView;
    public JPanel xmlTabView;
    public JPanel xslTabView;
    public JPanel xsltTabView;
    public JPanel treeView;
    public JTree tree;
    public JTextArea xmlTextArea;
    public JTextArea xslTextArea;
    public JTextArea xsltTextArea;
    public JTextArea statusText;
    public TreePath selectedNode;
    public Document loadedDoc;
    public vxdcontroller(vxdproject project,boolean initproj,Element rootElement,Document loadedDoc) {
        initvxdcontroller(project,initproj,rootElement,loadedDoc);
    }
    public vxdcontroller(vxdproject project) {
        initvxdcontroller(project,true,null,null);
    }
    public void initvxdcontroller(vxdproject project,boolean initproj,Element rootElement,Document loadedDoc) {
        this.project=project;
        this.selectedNode=null;
        this.loadedDoc=loadedDoc;
        addToolBar();
        setupSplitView();
        setupStatusBar();
        initDTD();
        initProject(initproj,rootElement);
        initXSL();
        initTreeView();
        initPropertyView();
        SwingUtilities.invokeLater(new Runnable(){public void run() {
            vxd.controller.refreshXMLViews();}});
            if(!initproj) {
                SwingUtilities.invokeLater(new Runnable(){public void run() {
                    initOpenedXML(vxd.controller.loadedDoc);}});
            }
    }
    public void initOpenedXML(Document openedDoc) {
        loadingFile=true;
        NodeList mainEls=openedDoc.getDocumentElement().getChildNodes();
        for(int j=0;j<mainEls.getLength();++j) {
            
            Node nd=mainEls.item(j);
            if(nd instanceof Element) {
                Element el=(Element)nd;
                String elname=el.getTagName();
                if(vxd.DEBUG)
                    System.out.println("Main Parent: "+elname);
                int x=Integer.parseInt(el.getAttribute("XPos"));
                int y=Integer.parseInt(el.getAttribute("YPos"));
                Point parentPoint=new Point(x,y);
                addLoadedElementIcon(el,x,y);
                
                NodeList childEls=nd.getChildNodes();
                initOpenedXMLTree(childEls,parentPoint);
            }
        }
    }
    public void initOpenedXMLTree(NodeList childEls,Point parentPoint) {
        try {
            Runnable r=new Runnable() {
                NodeList childEls;
                Point pt;
                public void setArgs(NodeList childEls,Point p) {
                    this.childEls=childEls;
                    pt=p;
                }
                public void run() {
                    vxd.controller.refreshXMLViews();
                    try {
                        Runnable r=new Runnable() {
                            NodeList childEls;
                            Point grandPoint;
                            public void setArgs(NodeList childEls,Point p) {
                                this.childEls=childEls;
                                grandPoint=p;
                            }
                            public void run() {
                                for(int l=0;l<childEls.getLength();++l) {
                                    Node childNd=childEls.item(l);
                                    if(childNd instanceof Element) {
                                        Element childEl=(Element)childNd;
                                        if(vxd.DEBUG)
                                            System.out.println("Child: "+childEl.getTagName());
                                        vxd.controller.addLoadedElementIcon(childEl, grandPoint.x, grandPoint.y);
                                        try {
                                            Runnable r=new Runnable() {
                                                Element childEl;
                                                
                                                public void setArgs(Element childEl) {
                                                    this.childEl=childEl;
                                                }
                                                public void run() {
                                                    NodeList grandEls=childEl.getChildNodes();
                                                    if(childEl.getAttribute("XPos")!=null && childEl.getAttribute("YPos")!=null) {
                                                        try{
                                                            int x=Integer.parseInt(childEl.getAttribute("XPos"));
                                                            int y=Integer.parseInt(childEl.getAttribute("YPos"));
                                                            Point greatPoint=new Point(x,y);
                                                            initOpenedXMLTree(grandEls,greatPoint);
                                                        } catch(NumberFormatException nfe){;}
                                                    }
                                                }
                                            };
                                            Class[] args=new Class[1];
                                            args[0]=Element.class;
                                            
                                            Object[] prms=new Object[1];
                                            prms[0]=childEl;
                                            
                                            
                                            r.getClass().getMethod("setArgs",args).invoke(r,prms);
                                            SwingUtilities.invokeLater(r);
                                        } catch(Exception grgdex){grgdex.printStackTrace();}
                                    }
                                }
                            }
                        };
                        Class[] args=new Class[2];
                        args[0]=NodeList.class;
                        args[1]=Point.class;
                        
                        Object[] prms=new Object[2];
                        prms[0]=childEls;
                        prms[1]=pt;
                        
                        r.getClass().getMethod("setArgs",args).invoke(r,prms);
                        SwingUtilities.invokeLater(r);
                    } catch(Exception rex){rex.printStackTrace();};
                }
            };
            
            Class[] args=new Class[2];
            args[0]=NodeList.class;
            args[1]=Point.class;
            
            Object[] prms=new Object[2];
            prms[0]=childEls;
            prms[1]=parentPoint;
            
            r.getClass().getMethod("setArgs",args).invoke(r,prms);
            SwingUtilities.invokeLater(r);
        } catch(Exception rex){rex.printStackTrace();}
    }
    
    public void addLoadedElementIcon(Element el,int x,int y) {
        if(vxd.DEBUG)
            System.out.println("In addLoadedElementIcon");
        String iconName=el.getTagName();
        
        Point pt=new Point(x,y);
        
        if(vxd.DEBUG)
            System.out.println(iconName+" "+pt);
        try {
            Runnable r=new Runnable() {
                String name;
                Element element;
                Point pt;
                public void setArgs(String iconName,Point p, Element ele) {
                    name=iconName;
                    pt=p;
                    element=ele;
                }
                public void run() {
                    vxd.controller.DropSourceIconToDropTarget(name,pt,element);
                }
            };
            Class[] args=new Class[3];
            args[0]=String.class;
            args[1]=Point.class;
            args[2]=Element.class;
            Object[] prms=new Object[3];
            prms[0]=iconName;
            prms[1]=pt;
            prms[2]=el;
            r.getClass().getMethod("setArgs",args).invoke(r,prms);
            SwingUtilities.invokeLater(r);
        } catch(Exception rex){if(vxd.DEBUG)rex.printStackTrace();}
    }
    public void DropSourceIconToDropTarget(String sourceName,
            Point pt,
            Element el) {
        synchronized(iconLoadedElementSync) {
            if(vxd.DEBUG2)
                System.out.println("In DropSourceIconToDropTarget Source: "+sourceName);
            vxdJButton source=GetIconButton(sourceName);
            if(source==null)
                return;
            source.loadedElement=el;
            pt=SwingUtilities.convertPoint(iconConnectionView,pt,source);
            pt.x+=vxd.xdragsize/2;
            pt.y+=vxd.ydragsize/2;
            if(vxd.DEBUG2) {
                System.out.println("[DropSourceIconToDropTarget] at "+pt);
                for(int n=0;n<vxd.controller.iconConnectionView.getComponentCount();++n)
                    System.out.println("component: "+vxd.controller.iconConnectionView.getComponents()[n].getBounds());
            }
            MouseEvent evt=new MouseEvent(source,MouseEvent.COMPONENT_SHOWN,0,0,pt.x,pt.y,1,false,1);
            
            
            Runnable r=new Runnable() {
                MouseEvent evt;
                vxdJButton source;
                public void setArgs(MouseEvent evt,vxdJButton source) {
                    this.evt=evt;
                    this.source=source;
                }
                public void run() {
                    source.mouseReleased(evt);
                    if(vxd.DEBUG)
                        System.out.println("End MouseReleased");
                }
            };
            try {
                Class[] args=new Class[2];
                args[0]=MouseEvent.class;
                args[1]=vxdJButton.class;
                Object[] params=new Object[2];
                params[0]=evt;
                params[1]=source;
                
                r.getClass().getMethod("setArgs",args).invoke(r,params);
                source.mousePressed(evt);
                SwingUtilities.invokeLater(r);
                
                if(vxd.DEBUG)
                    System.out.println("End MousePressed");
            } catch(Exception ex) {
                ex.printStackTrace();
            }
        }
    }
    
    public vxdJButton GetIconButton(String name) {
        if(vxd.DEBUG)
            System.out.println("In GetIconButton: "+name);
        vxdJButton toolButton = null;
        try {
            if(vxd.DEBUG)
                System.out.println(((Container)vxd.toolBarPanel.getComponent(1)).getComponentCount());
            for(int j=0;j<((Container)vxd.toolBarPanel.getComponent(1)).getComponentCount();++j) {
                Component buttonSearch=
                        ((Container)vxd.toolBarPanel.getComponent(1)).getComponent(j);
                
                if(buttonSearch instanceof vxdJButton) {
                    if(vxd.DEBUG)
                        System.out.println("In GetIconButton Search: "+((vxdJButton)buttonSearch).name);
                    
                    if(((vxdJButton)buttonSearch).name.trim().compareTo(name)==0) {
                        toolButton = (vxdJButton)buttonSearch;
                        if(vxd.DEBUG)
                            System.out.println("Return GetIconButton");
                        return toolButton;
                    }
                }
            }
        } catch(Exception ex){if(vxd.DEBUG)ex.printStackTrace();}
        
        if(vxd.DEBUG)
            System.out.println("End GetIconButton");
        return toolButton;
    }
    
    public void initPropertyView() {
        layoutPropertyView(project.language,
                iconConnectionView.getElement());
    }
    
    public void layoutPropertyView(String name,Element element) {
        String elementID=element.getAttribute("ID");
        Element root=project.languageElements.getDocumentElement();
        NodeList edtrs=root.getElementsByTagName("Editor");
        boolean hasEditor=false;
        for(int i=0;i<edtrs.getLength();++i) {
            Element node=(Element)edtrs.item(i);
            String elname=node.getAttribute("ElementName");
            if(elname.equals(name))
                hasEditor=true;
        }
        propertyTabView.removeAll();
        Vector vattr=getAttributes(name);
        Enumeration e=vattr.elements();
        JPanel propertypane=new JPanel();
        propertypane.setLayout(new GridLayout(vattr.size(),1));
        Hashtable htattr=new Hashtable();
        Hashtable htcomps=new Hashtable();
        while(e.hasMoreElements()) {
            vxdAttribute a=(vxdAttribute)e.nextElement();
            htattr.put(a.name,a);
            JPanel attrpanel=new JPanel(new GridLayout(1,2));
            JLabel attrlabel=new JLabel(a.label,JLabel.RIGHT);
            JPanel attrlabelpanel=new JPanel(new FlowLayout(FlowLayout.CENTER));
            attrlabelpanel.add(attrlabel);
            attrpanel.add(attrlabelpanel);
            if(a.name.equals("ID") || a.name.equals("XPos") || a.name.equals("YPos") ||
                    ((a.name.equals("SourceID") || a.name.equals("DestID")) &&
                    name.equals("Connection"))) {
                JLabel fixed=new JLabel(element.getAttribute(a.name),JLabel.LEFT);
                JPanel fixedpanel=new JPanel(new FlowLayout(FlowLayout.LEFT));
                fixedpanel.add(fixed);
                attrpanel.add(fixedpanel);
                htcomps.put(a.name,fixed);
            } else if(a.combo!=null) {
                JComboBox cmb=new JComboBox(a.combo);
                cmb.setSelectedItem(element.getAttribute(a.name));
                cmb.addItemListener(new vxdPropertyChangeEventListener(element,a.name,cmb));
                JPanel cmbpanel=new JPanel(new FlowLayout(FlowLayout.LEFT));
                cmbpanel.add(cmb);
                attrpanel.add(cmbpanel);
                htcomps.put(a.name,cmb);
            } else if(a.fixed) {
                JLabel fixed=new JLabel(a.value,JLabel.LEFT);
                JPanel fixedpanel=new JPanel(new FlowLayout(FlowLayout.LEFT));
                fixedpanel.add(fixed);
                attrpanel.add(fixedpanel);
                htcomps.put(a.name,fixed);
            } else {
                JTextField field=new JTextField(8);
                javax.swing.text.Document fielddoc=field.getDocument();
                field.setDocument(fielddoc);
                field.setText(element.getAttribute(a.name));
                field.setHorizontalAlignment(JTextField.LEFT);
                fielddoc.addDocumentListener(new vxdPropertyChangeEventListener(element,a.name,field));
                JPanel fieldpanel=new JPanel(new FlowLayout(FlowLayout.LEFT));
                fieldpanel.add(field);
                attrpanel.add(fieldpanel);
                htcomps.put(a.name,field);
                if(hasEditor) {
                    for(int i=0;i<edtrs.getLength();++i) {
                        Element node=(Element)edtrs.item(i);
                        String attname=node.getAttribute("AttributeName");
                        String elname=node.getAttribute("ElementName");
                        String classname=node.getAttribute("Class");
                        if(attname.equals(a.name) &&
                                elname.equals(name) &&
                                node.getAttribute("Type").equals("PANEL")) {
                            try {
                                Document doc=vxd.controller.project.programXML;
                                Element el=element;
                                Class c=Class.forName(classname);
                                Object cinst=c.newInstance();
                                attrpanel.remove(fieldpanel);
                                attrpanel.add(((vxdPropertyEditDialog)cinst).
                                        editElement(doc,el,
                                        el.getAttributeNode(attname),vxd.frame));
                            } catch(Exception exx){exx.printStackTrace();}
                        }
                        if(attname.equals(a.name) &&
                                elname.equals(name) &&
                                node.getAttribute("Type").equals("DIALOG")) {
                            JButton but=new JButton(node.getAttribute("Name"));
                            ActionListener listener=new ActionListener() {
                                String classname;
                                String id;
                                String nodename;
                                String attrname;
                                public void setArgs(String classname,String id,
                                        String nodename,String attrname) {
                                    this.classname=classname;
                                    this.id=id;
                                    this.nodename=nodename;
                                    this.attrname=attrname;
                                }
                                public void actionPerformed(ActionEvent e) {
                                    try {
                                        Document doc=vxd.controller.project.programXML;
                                        NodeList nl=doc.getDocumentElement().getElementsByTagName("HTML");
                                        Element el=null;
                                        int i;
                                        for(i=0;i<nl.getLength();++i) {
                                            el=(Element)nl.item(i);
                                            if(el.getAttribute("ID").equals(id))
                                                break;
                                        }
                                        if(!(i<nl.getLength()))
                                            return;
                                        Class c=Class.forName(classname);
                                        Object cinst=c.newInstance();
                                        ((vxdPropertyEditDialog)cinst).editElement(doc,
                                                el,
                                                el.getAttributeNode(attrname),
                                                vxd.frame);
                                        SwingUtilities.invokeLater(new Runnable() {
                                            public void run() {
                                                vxd.controller.refreshXMLViews();
                                            }
                                        });
                                    } catch(Exception exx){exx.printStackTrace();}
                                }
                            };
                            try {
                                Class[] args=new Class[4];
                                args[0]=String.class;
                                args[1]=String.class;
                                args[2]=String.class;
                                args[3]=String.class;
                                Object[] params=new Object[4];
                                params[0]=classname;
                                params[1]=elementID;
                                params[2]=name;
                                params[3]=attname;
                                listener.getClass().
                                        getMethod("setArgs",args).invoke(listener,params);
                            } catch(Exception eex){eex.printStackTrace();}
                            but.addActionListener(listener);
                            attrpanel.remove(fieldpanel);
                            attrpanel.add(but);
                        }//DIALOG
                    }//for edtors
                }//if(hasEditor)
            }
            propertypane.add(attrpanel);
        }
        JScrollPane scrollpane=new JScrollPane();
        scrollpane.setViewportView(propertypane);
        propertyTabView.add(scrollpane,BorderLayout.CENTER);
        propertyTabView.validate();
        propertyTabView.repaint();
    }
    
    public void initTreeView() {
        Element root=project.programXML.getDocumentElement();
        XMLTreeModel model=new XMLTreeModel(root);
        tree=new JTree();
        tree.setModel(model);
        tree.addTreeSelectionListener(model);
        DefaultTreeCellRenderer rend=(DefaultTreeCellRenderer)tree.getCellRenderer();
        JScrollPane scroll=new JScrollPane(tree);
        treeView.add(scroll,BorderLayout.CENTER);
        vxd.frame.validate();
    }
    
    public void addIcon(vxdJButton icon,int x,int y,vxdDropTarget target) {
        synchronized(iconLoadedElementSync) {
            if(DEBUG)
                System.out.println("In addIcon");
            if(!(target instanceof vxdIconConnectionView) && target instanceof vxdDragIcon) {
                x+=((vxdDragIcon)target).getWidth();
                y+=((vxdDragIcon)target).getHeight();
            }
            if(vxd.DEBUG2)
                System.out.println("{{Add Icon}} name="+icon.name+" x="+x+" y="+y);
            vxdDragIcon dragicon=new vxdDragIcon(icon,x,y,null);
            iconConnectionView.add(dragicon,0);
            Point pt=dragicon.getLocation();
            
            if(vxd.DEBUG2)
                System.out.println("{{Drag Icon Location}} name="+dragicon.getName()+" x="+pt.x+" y="+pt.y);
            
            Element el=null;
            if(loadingFile) {
                el=project.programXML.createElement(icon.loadedElement.getTagName());
                for(int xi=0;xi<icon.loadedElement.getAttributes().getLength();++xi) {
                    String attrn=icon.loadedElement.getAttributes().item(xi).getNodeName();
                    el.setAttribute(attrn,icon.loadedElement.getAttribute(attrn));
                }
            } else {
                el=showElementPropertyBox(icon.name,project.programXML,pt.x,pt.y);
            }
            if(el==null) {
                iconConnectionView.remove(dragicon);
                SwingUtilities.invokeLater(new Runnable(){public void run() {
                    vxd.controller.iconConnectionView.validateIconsAndConnectors();}});
                    return;
            }
            dragicon.setElement(el);
            target.getElement().appendChild(el);
            if(!(target instanceof vxdIconConnectionView) && target instanceof vxdDragIcon) {
                addConnectorDrop((vxdDragIcon)target,dragicon,vxdIconConnector.AGGREGATION);
            }
            try {
                statusText.setText("");
                DocumentBuilderFactory factory  = DocumentBuilderFactoryImpl.newInstance();
                factory.setValidating(true);
                DocumentBuilder builder = factory.newDocumentBuilder();
                XmlDocument xdoc=(XmlDocument)project.programXML;
                Node dtd=(Node)xdoc.setDoctype(project.language,null,project.languageDTD);
                StringWriter stwr=new StringWriter();
                xdoc.write(stwr);
                builder.setErrorHandler(new DefaultHandler(){
                    public void error(SAXParseException exception)throws SAXParseException{throw exception;}
                    public void fatalError(SAXParseException exception)throws SAXParseException{throw exception;}
                    public void warning(SAXParseException exception)throws SAXParseException{throw exception;}
                });
                builder.parse(new InputSource(new StringReader(stwr.toString())));
            } catch(Exception e) {
                if(e instanceof SAXException)
                    statusText.setText(((SAXException)e).getMessage());
                else
                    statusText.setText(e.toString());
                iconConnectionView.remove(dragicon);
                el.getParentNode().removeChild(el);
                SwingUtilities.invokeLater(new Runnable(){public void run() {
                    vxd.controller.refreshXMLViews();}});
                    return;
            }
            Element root=(Element)vxd.controller.tree.getModel().getRoot();
            Element node=el;
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
            SwingUtilities.invokeLater(new Runnable(){public void run() {
                vxd.controller.refreshXMLViews();}});
        }
        
    }
    
    public void addConnectorStart(vxdJConnectorButton icon,int x,int y,vxdDragIcon target) {
        vxd.frame.setGlassPane(new DragConnectorGlassPane(target));
        vxd.frame.getGlassPane().setVisible(true);
    }
    
    public void addConnectorDrop(vxdDragIcon source,vxdDragIcon target,int type) {
        if(type==vxdIconConnector.CONNECTION) {
            Element el=showElementPropertyBox("Connection",project.programXML,-1,-1);
            if(el!=null) {
                el.getAttributeNode("DestType").setValue(target.element.getTagName());
                el.getAttributeNode("DestID").setValue(target.element.getAttribute("ID"));
                el.getAttributeNode("SourceID").setValue(source.element.getAttribute("ID"));
                source.element.appendChild(el);
                try {
                    statusText.setText("");
                    DocumentBuilderFactory factory  = DocumentBuilderFactoryImpl.newInstance();
                    factory.setValidating(true);
                    DocumentBuilder builder = factory.newDocumentBuilder();
                    XmlDocument xdoc=(XmlDocument)project.programXML;
                    Node dtd=(Node)xdoc.setDoctype(project.language,null,project.languageDTD);
                    StringWriter stwr=new StringWriter();
                    xdoc.write(stwr);
                    builder.setErrorHandler(new DefaultHandler(){
                        public void error(SAXParseException exception)throws SAXParseException{throw exception;}
                        public void fatalError(SAXParseException exception)throws SAXParseException{throw exception;}
                        public void warning(SAXParseException exception)throws SAXParseException{throw exception;}
                    });
                    builder.parse(new InputSource(new StringReader(stwr.toString())));
                } catch(Exception e) {
                    if(e instanceof SAXException)
                        statusText.setText(((SAXException)e).getMessage());
                    else
                        statusText.setText(e.toString());
                    el.getParentNode().removeChild(el);
                    SwingUtilities.invokeLater(new Runnable(){public void run() {
                        vxd.controller.refreshXMLViews();}});
                        return;
                }
                iconConnectionView.addConnector(new vxdIconConnector(source,target,type,el));
            }
        } else if(type==vxdIconConnector.AGGREGATION) {
            iconConnectionView.addConnector(new vxdIconConnector(source,target,type));
        }
        SwingUtilities.invokeLater(new Runnable(){public void run() {
            vxd.controller.refreshXMLViews();}});
    }
    
    public void initDTD() {
        try {
            System.out.println(LANGUAGEDIR+project.language+"/"+project.language+".dtd");
            File file=new File(LANGUAGEDIR+project.language+"/"+project.language+".dtd");
            FileInputStream rdr=new FileInputStream(file);
            DataInputStream dta=new DataInputStream(rdr);
            byte[] filedata=new byte[(int)file.length()];
            dta.readFully(filedata);
            project.setLanguageDTD(new String(filedata));
            rdr.close();
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
    
    public void initXSL() {
        try {
            DocumentBuilderFactory factory =DocumentBuilderFactoryImpl.newInstance();
            factory.setValidating(false);
            factory.setNamespaceAware(true);
            DocumentBuilder builder=factory.newDocumentBuilder();
            builder.setErrorHandler(new DefaultHandler(){
                public void error(SAXParseException exception)throws SAXParseException{throw exception;}
                public void fatalError(SAXParseException exception)throws SAXParseException{throw exception;}
                public void warning(SAXParseException exception)throws SAXParseException{throw exception;}
            });
            File file=new File(TRANSLATORDIR+project.translator+"/"+project.translator+".xsl");
            Reader in = new FileReader(file);
            char[] buff = new char[4096];
            int nch;
            String str="";
            while ((nch = in.read(buff, 0, buff.length)) != -1) {
                str+= new String(buff, 0, nch);
            }
            project.setProgramXSL(str);
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
    
    public void initProject(boolean initproj,Element rootElement) {
        DocumentBuilderFactory factory  = DocumentBuilderFactoryImpl.newInstance();
        try {
            factory.setValidating(true);
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document document = new XmlDocument();
            builder = factory.newDocumentBuilder();
            Element root=null;
            XmlDocument xdoc=null;
            if(initproj) {
                do
                {
                    root=showElementPropertyBox(project.language,document,-1,-1);
                    if(root!=null)
                        break;
                    JOptionPane.showMessageDialog(vxd.frame,"A "+project.language+
                            " Element is Required");
                }
                while(true);
                iconConnectionView.setElement(root);
                document.appendChild(root);
                project.setProgramXML(document);
                xdoc=(XmlDocument)project.programXML;
                Node dtd=(Node)xdoc.setDoctype(project.language,null,project.languageDTD);
            } else {
                root=rootElement;
                Element newroot=document.createElement(root.getTagName());
                for(int xi=0;xi<root.getAttributes().getLength();++xi) {
                    String attrn=root.getAttributes().item(xi).getNodeName();
                    newroot.setAttribute(attrn,root.getAttribute(attrn));
                }
                root=newroot;
                document.appendChild(newroot);
                iconConnectionView.setElement(root);
                project.setProgramXML(document);
                xdoc=(XmlDocument)project.programXML;
                if(vxd.DEBUG) {
                    System.out.println(project==null?"Project Null":project.name);
                    System.out.println(project.language==null?"Language Null":project.language);
                    System.out.println(xdoc==null?"xdoc null":xdoc.getDocumentElement().getNodeName());
                    System.out.println(project.languageDTD==null?"DTD Null":project.languageDTD);
                }
                StringWriter sstwr = new StringWriter();
                xdoc.write(sstwr);
                if(vxd.DEBUG)
                    System.out.print(sstwr.toString());
                
                Node dtd=(Node)xdoc.setDoctype(project.language,null,project.languageDTD);
            }
            
            try {
                StringWriter stwr=new StringWriter();
                xdoc.write(stwr);
                builder.setErrorHandler(new DefaultHandler(){
                    public void error(SAXParseException exception)throws SAXParseException{throw exception;}
                    public void fatalError(SAXParseException exception)throws SAXParseException{throw exception;}
                    public void warning(SAXParseException exception)throws SAXParseException{throw exception;}
                });
                builder.parse(new InputSource(new StringReader(stwr.toString())));
            } catch(Exception e) {
                e.printStackTrace();
            }
        } catch(Exception e) {
            e.printStackTrace();
        }
        
    }
    
    public void refreshXMLViews() {
        try {
            iconConnectionView.validateIconsAndConnectors();
            XmlDocument xdoc=(XmlDocument)project.programXML;
            StringWriter stwr=new StringWriter();
            xdoc.write(stwr);
            xmlTextArea.setText(stwr.toString());
            xslTextArea.setText(project.programXSL);
            TransformerFactory tfactory =TransformerFactory.newInstance();
            Transformer trans=tfactory.
                    newTransformer(new StreamSource(new StringReader(project.programXSL)));
            stwr=new StringWriter();
            DOMSource source = new DOMSource(project.programXML);
            StreamResult result = new StreamResult(stwr);
            trans.transform(source, result);
            stwr.flush();
            project.setProgramXSLT(new String(stwr.getBuffer()));
            xsltTextArea.setText(project.programXSLT);
            if(selectedNode!=null) {
                tree.removeTreeSelectionListener((TreeSelectionListener)tree.getModel());
                tree.getModel().valueForPathChanged(null,null);
                Element el=(Element)selectedNode.getLastPathComponent();
                tree.setSelectionPath(selectedNode);
                if(el!=null)
                    layoutPropertyView(el.getTagName(),el);
                tree.addTreeSelectionListener((TreeSelectionListener)tree.getModel());
            }
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
    
    public Element showElementPropertyBox(String name,Document document,int x,int y) {
        Vector vattr=getAttributes(name);
        Enumeration e=vattr.elements();
        JDialog dlg=new JDialog(vxd.frame,name,true);
        dlg.setSize(350,460);
        dlg.setLocationRelativeTo(null);
        JLabel dlglabel=new JLabel(name+" Attributes");
        dlglabel.setHorizontalAlignment(JLabel.CENTER);
        dlglabel.setVerticalAlignment(JLabel.CENTER);
        dlg.getContentPane().setLayout(new BorderLayout());
        JPanel attrspanel = new JPanel();
        attrspanel.setLayout(new GridLayout(vattr.size()+2,1));
        dlg.getContentPane().add(dlglabel,BorderLayout.NORTH);
        Hashtable htattr=new Hashtable();
        Hashtable htcomps=new Hashtable();
        while(e.hasMoreElements()) {
            vxdAttribute a=(vxdAttribute)e.nextElement();
            htattr.put(a.name,a);
            javax.swing.JPanel attrpanel=new JPanel();
            attrpanel.setLayout( new GridLayout(1,2));
            JLabel attrlabel=new JLabel(a.label,JLabel.RIGHT);
            JPanel attrlabelpanel=new JPanel(new FlowLayout(FlowLayout.CENTER));
            attrlabelpanel.add(attrlabel);
            attrpanel.add(attrlabelpanel);
            if(a.name.equals("ID")) {
                a.value=Integer.toString(IDCOUNT);
                JLabel fixed=new JLabel(a.value,JLabel.LEFT);
                JPanel fixedpanel=new JPanel(new FlowLayout(FlowLayout.LEFT));
                fixedpanel.add(fixed);
                attrpanel.add(fixedpanel);
                htcomps.put(a.name,fixed);
            } else if(a.name.equals("XPos")) {
                a.value=Integer.toString(x);
                JLabel fixed=new JLabel(a.value,JLabel.LEFT);
                JPanel fixedpanel=new JPanel(new FlowLayout(FlowLayout.LEFT));
                fixedpanel.add(fixed);
                attrpanel.add(fixedpanel);
                htcomps.put(a.name,fixed);
            } else if(a.name.equals("YPos")) {
                a.value=Integer.toString(y);
                JLabel fixed=new JLabel(a.value,JLabel.LEFT);
                JPanel fixedpanel=new JPanel(new FlowLayout(FlowLayout.LEFT));
                fixedpanel.add(fixed);
                attrpanel.add(fixedpanel);
                htcomps.put(a.name,fixed);
            } else if((a.name.equals("SourceID") || a.name.equals("DestID")) &&
                    name.equals("Connection")) {
                JLabel fixed=new JLabel(a.value,JLabel.LEFT);
                JPanel fixedpanel=new JPanel(new FlowLayout(FlowLayout.LEFT));
                fixedpanel.add(fixed);
                attrpanel.add(fixedpanel);
                htcomps.put(a.name,fixed);
            } else if((a.name.equals("Title") || a.name.equals("Package") || a.name.equals("URI"))
            && name.equals(project.language)) {
                JTextField field=new JTextField(10);
                field.setText(project.name);
                if(a.name.equals("URI"))
                    field.setText("/"+project.name);
                field.setHorizontalAlignment(JTextField.LEFT);
                JPanel fieldpanel=new JPanel(new FlowLayout(FlowLayout.LEFT));
                fieldpanel.add(field);
                attrpanel.add(fieldpanel);
                htcomps.put(a.name,field);
            } else if(a.combo!=null) {
                JComboBox cmb=new JComboBox(a.combo);
                cmb.setSelectedItem(a.value);
                JPanel cmbpanel=new JPanel(new FlowLayout(FlowLayout.LEFT));
                cmbpanel.add(cmb);
                attrpanel.add(cmbpanel);
                htcomps.put(a.name,cmb);
            } else if(a.fixed) {
                JLabel fixed=new JLabel(a.value,JLabel.LEFT);
                JPanel fixedpanel=new JPanel(new FlowLayout(FlowLayout.LEFT));
                fixedpanel.add(fixed);
                attrpanel.add(fixedpanel);
                htcomps.put(a.name,fixed);
            } else {
                JTextField field=new JTextField(10);
                if(a.value!=null)
                    field.setText(a.value);
                field.setHorizontalAlignment(JTextField.LEFT);
                JPanel fieldpanel=new JPanel(new FlowLayout(FlowLayout.LEFT));
                fieldpanel.add(field);
                attrpanel.add(fieldpanel);
                htcomps.put(a.name,field);
            }
            attrspanel.add(attrpanel);
        }
        JScrollPane scrollpane=new JScrollPane(attrspanel);
        dlg.getContentPane().add(scrollpane,BorderLayout.CENTER);
        JPanel btnpanel=new JPanel(new FlowLayout(FlowLayout.CENTER));
        JButton btnok=new JButton("OK");
        btnok.setActionCommand("NO");
        btnok.requestDefaultFocus();
        btnok.setMnemonic('O');
        btnok.setDefaultCapable(true);
        btnok.addActionListener(new ActionListener(){
            public void actionPerformed(ActionEvent e) {
                ((JButton)e.getSource()).setActionCommand("OK");
                vxd.topDialog.setVisible(false);
            }
        });
        JButton btncancel=new JButton("Cancel");
        btncancel.setMnemonic('C');
        btncancel.addActionListener(new ActionListener(){
            public void actionPerformed(ActionEvent e) {
                vxd.topDialog.setVisible(false);
            }
        });
        btnpanel.add(btnok);
        btnpanel.add(btncancel);
        dlg.getContentPane().add(btnpanel,BorderLayout.SOUTH);
        vxd.topDialog=dlg;
        dlg.show();
        Element node=null;
        node=(Element)document.createElement(name);
        if(!btnok.getActionCommand().equals("OK")) {
            dlg.setVisible(false);
            dlg.dispose();
            vxd.topDialog=null;
            return null;
        } else {
            Enumeration ekeys=htattr.keys();
            while(ekeys.hasMoreElements()) {
                String key=(String)ekeys.nextElement();
                vxdAttribute attr=(vxdAttribute)htattr.get(key);
                if(key.equals("ID")||key.equals("XPos")||key.equals("YPos"))
                    node.setAttribute(key,attr.value);
                else if((key.equals("SourceID") || key.equals("DestID")) &&
                        name.equals("Connection"))
                    node.setAttribute(key,attr.value);
                else if(attr.fixed)
                    node.setAttribute(key,attr.value);
                else if(attr.combo!=null) {
                    JComboBox cmb=(JComboBox)htcomps.get(key);
                    node.setAttribute(key,(String)cmb.getSelectedItem());
                } else {
                    JTextField txt=(JTextField)htcomps.get(key);
                    node.setAttribute(key,txt.getText());
                    if(attr.required &&
                            (txt.getText()==null ||
                            txt.getText().trim().length()==0)) {
                        JOptionPane.showMessageDialog(vxd.frame,
                                attr.label+
                                " is Required");
                        ekeys=htattr.keys();
                        node=(Element)document.createElement(name);
                        btnok.setActionCommand("NO");
                        dlg.show();
                        if(!btnok.getActionCommand().equals("OK")) {
                            dlg.setVisible(false);
                            dlg.dispose();
                            vxd.topDialog=null;
                            return null;
                        }
                    }
                }
            }
        }
        dlg.setVisible(false);
        dlg.dispose();
        vxd.topDialog=null;
        IDCOUNT++;
        return node;
    }
    
    public Vector getAttributes(String element) {
        Vector v=new Vector();
        Pattern p = Pattern.compile(".*<!ATTLIST\\s+"+element+
                "(\\s+[^>]+).*",Pattern.DOTALL|Pattern.MULTILINE);
        Matcher m = p.matcher(project.languageDTD);
        boolean b=m.matches();
        String attrs=m.group(1);
        p=Pattern.compile("\\s*(\\S+)\\s+CDATA\\s+([^\\s>]+)(.*)",Pattern.DOTALL|Pattern.MULTILINE);
        m=p.matcher(attrs);
        b=m.matches();
        int end=m.end(2);
        while(b) {
            boolean fixed=false;
            boolean required=false;
            String name=m.group(1);
            String value=null;
            if(m.group(2).indexOf("#")==-1) {
                required=true;
                p=Pattern.compile(".*\\s"+name+"\\s+CDATA\\s+\"([^\"]*)(\")(.*)",Pattern.DOTALL|Pattern.MULTILINE);
                m=p.matcher(attrs);
                b=m.matches();
                value=m.group(1);
                value=value.replaceAll("&gt;",">").
                        replaceAll("&lt;","<").
                        replaceAll("&amp;","&").
                        replaceAll("&quot;","\"").
                        replaceAll("&apos;","\'");
                end=m.end(2);
                p=Pattern.compile("\\s*(\\S+)\\s+CDATA\\s+([^\\s>]+)(.*)",Pattern.DOTALL|Pattern.MULTILINE);
                m=p.matcher(attrs);
            } else if(m.group(2).equals("#REQUIRED")) {
                required=true;
            } else if(m.group(2).equals("#FIXED")) {
                fixed=true;
                p=Pattern.compile(".*\\s"+name+"\\s+CDATA\\s+\\#FIXED\\s+\"([^\"]+)(\").*",Pattern.DOTALL|Pattern.MULTILINE);
                m=p.matcher(attrs);
                b=m.matches();
                value=m.group(1);
                end=m.end(2);
                p=Pattern.compile("\\s*(\\S+)\\s+CDATA\\s+([^\\s>]+)(.*)",Pattern.DOTALL|Pattern.MULTILINE);
                m=p.matcher(attrs);
            }
            v.addElement(new vxdAttribute(name,required,fixed,value,null));
            b=m.find(end);
            if(b)
                end=m.end(2);
        }
        p=Pattern.compile("[^\\(]*\\s(\\S+)\\s+\\(([^\\)]*)\\)\\s+\"([^\"]+)(\").*",Pattern.DOTALL|Pattern.MULTILINE);
        m=p.matcher(attrs);
        b=m.matches();
        while(b) {
            String opts=m.group(2);
            Vector vopts=new Vector();
            StringTokenizer tok=new StringTokenizer(opts,"|");
            while(tok.hasMoreTokens())
                vopts.addElement(tok.nextToken());
            v.addElement(new vxdAttribute(m.group(1),true,false,m.group(3),vopts));
            b=m.find(m.end(4));
        }
        return v;
    }
    
    public void setupStatusBar() {
        JPanel msgpan=new JPanel(new BorderLayout(4,4));
        statusText=new JTextArea(3,100);
        statusText.setSize(vxd.XSIZE,statusText.getHeight());
        statusText.setLineWrap(true);
        statusText.setEditable(false);
        msgpan.setSize(vxd.XSIZE,statusText.getHeight());
        JLabel statusBar=new JLabel("  Messages:  ");
        msgpan.add(statusBar,BorderLayout.WEST);
        msgpan.add(new JScrollPane(statusText),BorderLayout.CENTER);
        vxd.frame.getContentPane().add(msgpan,"South");
        vxd.frame.getContentPane().validate();
    }
    
    public void setupSplitView() {
        mainSplitView=new JSplitPane(JSplitPane.HORIZONTAL_SPLIT,true,
                new JPanel(),new JPanel());
        mainSplitView.setOneTouchExpandable(true);
        iconConnectionView=new vxdIconConnectionView(project.language);
        JScrollPane iconConnectionViewPanel=new JScrollPane(iconConnectionView);
        treeView=new JPanel(new BorderLayout());
        projectSplitView=new JSplitPane(JSplitPane.HORIZONTAL_SPLIT,true,
                treeView,
                iconConnectionViewPanel);
        projectSplitView.setMinimumSize(new Dimension(0,0));
        treeView.setMinimumSize(new Dimension(0,0));
        iconConnectionViewPanel.setMinimumSize(new Dimension(0,0));
        iconConnectionView.setMinimumSize(new Dimension(0,0));
        projectSplitView.setOneTouchExpandable(true);
        projectSplitView.setSize(vxd.XSIZE,vxd.YSIZE);
        mainSplitView.setLeftComponent(projectSplitView);
        
        propertyTabSet=new JTabbedPane();
        propertyTabView=new JPanel(new BorderLayout());
        xmlTabView=new JPanel(new BorderLayout());
        xslTabView=new JPanel(new BorderLayout());
        xsltTabView=new JPanel(new BorderLayout());
        xmlTabView.add(new JLabel(project.language+" XML Document"),BorderLayout.NORTH);
        xslTabView.add(new JLabel(project.translator+" XSL Stylesheet"),BorderLayout.NORTH);
        xsltTabView.add(new JLabel("XSLT Output"),BorderLayout.NORTH);
        xmlTextArea=new JTextArea();
        xslTextArea=new JTextArea();
        xslTextArea.getDocument().addDocumentListener(new DocumentListener() {
            public void insertUpdate(DocumentEvent e) {
                changedUpdate(e);
            }
            public void removeUpdate(DocumentEvent e) {
                changedUpdate(e);
            }
            public void changedUpdate(DocumentEvent e) {
                try {
                    vxd.controller.project.programXSL=
                            (e.getDocument().
                            getText(0,e.getDocument().
                            getLength()));
                    
                } catch(Exception ex){ex.printStackTrace();}
            }
        });
        xsltTextArea=new JTextArea();
        xmlTextArea.setAutoscrolls(true);
        xmlTextArea.setLineWrap(true);
        xmlTextArea.setEditable(false);
        xmlTextArea.setWrapStyleWord(true);
        xslTextArea.setAutoscrolls(true);
        xslTextArea.setLineWrap(true);
        xslTextArea.setEditable(true);
        xslTextArea.setWrapStyleWord(true);
        xsltTextArea.setAutoscrolls(true);
        xsltTextArea.setLineWrap(true);
        xsltTextArea.setEditable(false);
        xsltTextArea.setWrapStyleWord(true);
        JScrollPane xmlTextAreaScroll=new JScrollPane(xmlTextArea);
        JScrollPane xslTextAreaScroll=new JScrollPane(xslTextArea);
        JScrollPane xsltTextAreaScroll=new JScrollPane(xsltTextArea);
        xmlTabView.add(xmlTextAreaScroll,BorderLayout.CENTER);
        xslTabView.add(xslTextAreaScroll,BorderLayout.CENTER);
        xsltTabView.add(xsltTextAreaScroll,BorderLayout.CENTER);
        propertyTabSet.addTab("Properties",propertyTabView);
        propertyTabSet.addTab("XML",xmlTabView);
        propertyTabSet.addTab("XSL",xslTabView);
        propertyTabSet.addTab("XSLT",xsltTabView);
        
        mainSplitView.setRightComponent(propertyTabSet);
        vxd.frame.getContentPane().remove(vxd.viewPanel);
        vxd.frame.getContentPane().add(mainSplitView,"Center");
        mainSplitView.setSize(vxd.XSIZE,vxd.YSIZE);
        mainSplitView.setDividerLocation((int)(3*vxd.XSIZE/4));
        projectSplitView.setDividerLocation((int)(vxd.XSIZE/4));
        vxd.frame.getContentPane().validate();
    }
    
    public void addToolBar() {
        DocumentBuilderFactory factory =DocumentBuilderFactoryImpl.newInstance();
        factory.setValidating(true);
        try {
            DocumentBuilder builder=factory.newDocumentBuilder();
            project.languageElements=builder.parse(new File(LANGUAGEDIR+project.language+"/"+project.language+".xml"));
            Element root=project.languageElements.getDocumentElement();
            JToolBar toolBar=new JToolBar();
            NodeList icons=root.getElementsByTagName("Icon");
            for(int i=0;i<icons.getLength();++i) {
                Element node=(Element)icons.item(i);
                String name=node.getAttribute("Name");
                Image img=Toolkit.getDefaultToolkit().getImage(node.getAttribute("Image"));
                ImageFilter transparency=new vxd.BlackToTransparentFilter();
                ImageProducer producer=new FilteredImageSource(img.getSource(),transparency);
                Image transparentimg=Toolkit.getDefaultToolkit().createImage(producer);
                Image smallimg=transparentimg.getScaledInstance(vxd.xiconsize,vxd.yiconsize,Image.SCALE_SMOOTH);
                ImageIcon icon=new ImageIcon(smallimg);
                Image dragimage=transparentimg.getScaledInstance(vxd.xdragsize,
                        vxd.ydragsize,Image.SCALE_SMOOTH);
                try {
                    MediaTracker mt=new MediaTracker(vxd.frame);
                    mt.addImage(smallimg,0);
                    mt.addImage(dragimage,1);
                    mt.waitForAll();
                } catch(Exception e){;}
                vxdJButton toolbutton=new vxdJButton(name,icon,img,dragimage);
                toolbutton.setToolTipText(name);
                toolBar.add(toolbutton);
            }
            toolBar.setLayout(new GridLayout((int)(icons.getLength()/vxd.iconsperrow)+1,vxd.iconsperrow));
            icons=root.getElementsByTagName("Connector");
            for(int i=0;i<icons.getLength();++i) {
                Element node=(Element)icons.item(i);
                String name=node.getAttribute("Name");
                Image img=Toolkit.getDefaultToolkit().getImage(node.getAttribute("Image"));
                ImageFilter transparency=new vxd.BlackToTransparentFilter();
                ImageProducer producer=new FilteredImageSource(img.getSource(),transparency);
                Image transparentimg=Toolkit.getDefaultToolkit().createImage(producer);
                Image smallimg=transparentimg.getScaledInstance(vxd.xiconsize,vxd.yiconsize,Image.SCALE_SMOOTH);
                ImageIcon icon=new ImageIcon(smallimg);
                Image dragimage=transparentimg.getScaledInstance(vxd.xdragsize,
                        vxd.ydragsize,Image.SCALE_SMOOTH);
                try {
                    MediaTracker mt=new MediaTracker(vxd.frame);
                    mt.addImage(smallimg,0);
                    mt.addImage(dragimage,1);
                    mt.waitForAll();
                } catch(Exception e){;}
                vxdJConnectorButton toolbutton=new vxdJConnectorButton(name,icon,img,dragimage);
                toolbutton.setToolTipText(name);
                toolBar.add(toolbutton);
            }
            vxd.toolBarPanel.add(toolBar,"South");
            vxd.toolBarPanel.validate();
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
    public void DEBUG_STACK_TRACE(Object e) {
        if(vxd.DEBUG) {
            System.out.println(e);
            try {
                throw new Exception(this.getClass().getName());
            } catch(Exception dbge) {
                dbge.printStackTrace();
            }
        }
    }
}
