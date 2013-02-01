package vxd.Languages.VisualWeb.Editors;

import vxd.*;
import org.w3c.dom.*;
import org.apache.crimson.tree.*;
import org.xml.sax.*;
import org.xml.sax.helpers.*;
import java.awt.*;
import java.awt.event.*;
import java.io.*;
import javax.xml.parsers.*;
import javax.swing.*;
import javax.swing.event.*;
import javax.swing.text.*;
import javax.swing.text.html.*;
import java.util.regex.*;

public class HtmlEditor 
    implements vxdPropertyEditDialog,DocumentListener,CaretListener
{
    public static JDialog topDialog;
    public JDialog dlg;
    public JTextPane html;
    public JTextPane text;
    public static JFrame frame;

    public static void main(String[] a)
    {
	frame=new JFrame();
	JButton but=new JButton("Edit");
	but.addActionListener(new ActionListener(){
		public void actionPerformed(ActionEvent ev) 
	    {
		try
		{
		DocumentBuilderFactory factory=DocumentBuilderFactory.newInstance();
		DocumentBuilder builder=factory.newDocumentBuilder();
		org.w3c.dom.Document doc=builder.parse(new File("test.xml"));
		(new HtmlEditor()).editElement(doc,(org.w3c.dom.Element)doc.getDocumentElement().
					       getElementsByTagName("HTML").item(0),
					       null,HtmlEditor.frame);
		XmlDocument xdoc=(XmlDocument)doc;
		StringWriter stwr=new StringWriter();
		xdoc.write(stwr);
		System.out.println(stwr.toString());
		}
		catch(Exception e){e.printStackTrace();}
	    }});
	frame.getContentPane().add(but);
	frame.pack();
	frame.setSize(400,400);
	frame.setLocationRelativeTo(null);
	frame.setDefaultCloseOperation(frame.EXIT_ON_CLOSE);
	frame.show();
    }

    public String domString(NodeList nl)
    {
	int max=0;
	String str="";
	for(int i=0;i<nl.getLength();++i)
	    {
		if(!(nl.item(i) instanceof org.w3c.dom.Element))
		    continue;
		org.w3c.dom.Element el=(org.w3c.dom.Element)nl.item(i);
		String order=el.getAttribute("Order");
		try
		    {
			if(order!=null && order.length()>0)
			    {
				int iord=Integer.parseInt(order);
				if(iord>max) max=iord;
			    }
		    }
		catch(NumberFormatException nfe){;}
	    }
	for(int j=0;j<=max;++j)
	    {
	for(int i=0;i<nl.getLength();++i)
	    {
		if(!(nl.item(i) instanceof org.w3c.dom.Element))
		    {
			if(nl.item(i).getNodeValue()!=null)
			    {
				str+=nl.item(i).getNodeValue();
			    }
			continue;
		    }
		org.w3c.dom.Element el=(org.w3c.dom.Element)nl.item(i);
		String order=el.getAttribute("Order");
		try
		    {
			if(order!=null && order.length()>0)
			    {
				int iord=Integer.parseInt(order);
				if(iord==j)
				    {
					String txid=el.getAttribute("ID");
					String ht=el.getAttribute("BeforeHtml");
					if(ht!=null && ht.length()>0)
					    {
						str+="<!-- \"Before_"+el.getTagName()+"_"+txid+"\" -->";
						str+=ht;
						str+="<!-- \"Before_"+el.getTagName()+"_"+txid+"_End\" -->";
					    }
					str+=domString(el.getChildNodes());
					ht=el.getAttribute("AfterHtml");
					if(ht!=null && ht.length()>0)
					    {
						str+="<!-- \"After_"+el.getTagName()+"_"+txid+"\" -->";
						str+=ht;
						str+="<!-- \"After_"+el.getTagName()+"_"+txid+"_End\" -->";
					    }
				    }
			    }
		    }
		catch(NumberFormatException nfe){;}
	    }
	    }
	return str;
    }

    public JPanel editElement(org.w3c.dom.Document root,
			    org.w3c.dom.Element el,
			    org.w3c.dom.Attr attr,
			    Frame parent)
    {
	String htext="";
	String txid=el.getAttribute("ID");

	String ht=el.getAttribute("BeforeHtml");
	if(ht!=null)
	    htext+=ht;
	htext+="<!-- \"Before_"+el.getTagName()+"_"+txid+"\" -->";
	htext+=domString(el.getChildNodes());
	htext+="<!-- \"After_"+el.getTagName()+"_"+txid+"\" -->";
	ht=el.getAttribute("AfterHtml");
	if(ht!=null)
	    htext+=ht;

	html = new JTextPane();
	html.setEditorKit(new vxdHTMLEditorKit());
	html.setDragEnabled(true);
	html.setContentType("text/html");
	html.setText(htext);
	html.setEditable(true);
	((HTMLDocument)html.getDocument()).setPreservesUnknownTags(true);
	html.getDocument().addDocumentListener(this);
	text = new JTextPane();
	text.setContentType("text/plain");
	text.setText(htext);
	text.setEditable(true);
	text.getDocument().addDocumentListener(this);

	dlg=new JDialog(parent,el.getTagName(),true);
	JTabbedPane tabpane=new JTabbedPane(JTabbedPane.TOP);
	tabpane.addTab("HTML Visual Editor",new JScrollPane(html));
	tabpane.addTab("HTML Text Source",new JScrollPane(text));
	dlg.getContentPane().setLayout(new BorderLayout());
	dlg.getContentPane().add(tabpane,BorderLayout.CENTER);
	JPanel buttonpane=new JPanel(new FlowLayout(FlowLayout.CENTER,10,10));
	JButton okbtn=new JButton("OK");
	okbtn.setActionCommand("NO");
	okbtn.addActionListener(new ActionListener(){
		public void actionPerformed(ActionEvent e)
		{
		    ((JButton)e.getSource()).setActionCommand("OK");
		    HtmlEditor.topDialog.setVisible(false);
		}
	    });
	JButton cancelbtn=new JButton("Cancel");
	cancelbtn.addActionListener(new ActionListener(){
		public void actionPerformed(ActionEvent e)
		{
		    HtmlEditor.topDialog.setVisible(false);
		}
	    });
	buttonpane.add(okbtn);
	buttonpane.add(cancelbtn);
	dlg.getContentPane().add(buttonpane,BorderLayout.SOUTH);
	dlg.pack();
	dlg.setSize(500,400);
	dlg.setLocationRelativeTo(null);
	HtmlEditor.topDialog=dlg;
	dlg.setDefaultCloseOperation(JDialog.DISPOSE_ON_CLOSE);
	dlg.show();
	dlg.dispose();
	if(!okbtn.getActionCommand().equals("OK"))
	    {
		return null;
	    }
	try
	    {
		String htmltext=text.getDocument().getText(0,text.getDocument().getLength());
		txid=el.getAttribute("ID");
		el.setAttribute("BeforeHtml",htmltext.
				substring(0,htmltext.indexOf("<!-- \"Before_"+el.getTagName()+"_"+txid+"\" -->")));
		String tailstr="<!-- \"After_"+el.getTagName()+"_"+txid+"\" -->";
		el.setAttribute("AfterHtml",htmltext.
				substring(htmltext.indexOf(tailstr)+tailstr.length(),
					  htmltext.length()));
		setNodeHtml(el.getChildNodes(),htmltext);
	    }
	catch(Exception e){e.printStackTrace();}
	return null;
    }

    public void setNodeHtml(NodeList nl,String html)
    {
	try
	    {
		for(int i=0;i<nl.getLength();++i)
		    {
			setNodeHtml(nl.item(i).getChildNodes(),html);
			if(!(nl.item(i) instanceof org.w3c.dom.Element))
			    continue;
			org.w3c.dom.Element el=(org.w3c.dom.Element)nl.item(i);
			String elid=el.getAttribute("ID");
			if(el.getAttribute("BeforeHtml")!=null && el.getAttribute("BeforeHtml").length()>0)
			    {
				Pattern p = Pattern.compile(".*<!--\\s\"Before_"+el.getTagName()+"_"+elid+"\"\\s-->"+
							    "(.*)<!--\\s\"Before_"+el.getTagName()+"_"+elid+"_End\"\\s-->.*",
							    Pattern.DOTALL|Pattern.MULTILINE);
				Matcher m = p.matcher(html);
				boolean b=m.matches();
				if(b)
				    {
					String txt=m.group(1);
					el.setAttribute("BeforeHtml",txt);
				    }
			    }
			if(el.getAttribute("AfterHtml")!=null && el.getAttribute("AfterHtml").length()>0)
			    {
				Pattern p = Pattern.compile(".*<!--\\s\"After_"+el.getTagName()+"_"+elid+"\"\\s-->"+
						    "(.*)<!--\\s\"After_"+el.getTagName()+"_"+elid+"_End\"\\s-->.*",
						    Pattern.DOTALL|Pattern.MULTILINE);
				Matcher m = p.matcher(html);
				boolean b=m.matches();
				if(b)
				    {
					String txt=m.group(1);
					el.setAttribute("AfterHtml",txt);
				    }
			    }
		    }
	    }
	catch(Exception e){e.printStackTrace();}
    }

    public void insertUpdate(DocumentEvent e)
    {
	changedUpdate(e);
    }

    public void removeUpdate(DocumentEvent e)
    {
	changedUpdate(e);
    }

    public void changedUpdate(DocumentEvent e)
    {
	try
	    {
		if(!(e.getDocument() instanceof HTMLDocument))
		    {
			html.getDocument().removeDocumentListener(this);
			html.setText(e.getDocument().
				     getText(0,e.getDocument().getLength()));
			html.getDocument().addDocumentListener(this);
		    }
		else
		    {
			javax.swing.text.Element ell=((HTMLDocument)e.getDocument()).
			    getCharacterElement(e.getOffset()).getParentElement();
			Object o = ell.getAttributes().getAttribute(StyleConstants.NameAttribute);
			if(o instanceof HTML.Tag && ((HTML.Tag)o) == HTML.Tag.IMPLIED)
			    {
				;
			    }
			StringWriter stwr=new StringWriter();
			HTMLWriter htmlwr=new HTMLWriter(stwr,(HTMLDocument)e.getDocument());
			htmlwr.write();
			text.getDocument().removeDocumentListener(this);
			text.setText(stwr.toString());
			text.getDocument().addDocumentListener(this);
		    }
	    }
	catch(Exception ex){ex.printStackTrace();}
    }

    public void caretUpdate(CaretEvent e)
    {
	;
    }

    public class vxdHTMLEditorKit extends HTMLEditorKit
    {
	public vxdHTMLFactory defaultFactory2=new vxdHTMLFactory();
	public ViewFactory getViewFactory() 
	{
	    return defaultFactory2;
	}
    }

    public class vxdCommentView extends View
    {
	public Icon c=null;

	public vxdCommentView(javax.swing.text.Element el)
	{
	    super(el);
	    c=javax.swing.plaf.metal.MetalIconFactory.getFileChooserHomeFolderIcon();
	}

	public void paint(Graphics g, Shape a) {
	    Rectangle alloc = a.getBounds();
	    c.paintIcon(getContainer(), g, alloc.x, alloc.y);
	}

	public float getPreferredSpan(int axis) 
	{
	    switch (axis) 
		{
		case View.X_AXIS:
		    return c.getIconWidth();
		case View.Y_AXIS:
		    return c.getIconHeight();
		default:
		    throw new IllegalArgumentException("Invalid axis: " + axis);
		}
	}

	public float getAlignment(int axis) 
	{
	    switch (axis) 
		{
		case View.Y_AXIS:
		    return 1;
		default:
		    return super.getAlignment(axis);
		}
	}

	public Shape modelToView(int pos, Shape a, Position.Bias b) throws BadLocationException 
	{
	    int p0 = getStartOffset();
	    int p1 = getEndOffset();
	    if ((pos >= p0) && (pos <= p1)) 
		{
		Rectangle r = a.getBounds();
		if (pos == p1) 
		    {
			r.x += r.width;
		    }
		r.width = 0;
		return r;
	    }
	    throw new BadLocationException(pos + " not in range " + p0 + "," + p1, pos);
	}

	public int viewToModel(float x, float y, Shape a, Position.Bias[] bias) 
	{
	    Rectangle alloc = (Rectangle) a;
	    if (x < alloc.x + (alloc.width / 2)) {
		bias[0] = Position.Bias.Forward;
		return getStartOffset();
	    }
	    bias[0] = Position.Bias.Backward;
	    return getEndOffset();
	}
    }

    public class vxdHTMLFactory extends HTMLEditorKit.HTMLFactory
    {
	public View create(javax.swing.text.Element elem) 
	{
	    Object o = elem.getAttributes().getAttribute(StyleConstants.NameAttribute);
	    if (o instanceof HTML.Tag) 
		{
		    HTML.Tag kind = (HTML.Tag) o;
		    if (kind == HTML.Tag.COMMENT) 
			{
			    return new vxdCommentView(elem);
			}
		}
	    return super.create(elem);
	}
    }
}
