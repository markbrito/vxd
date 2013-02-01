using System;
using System.Data;
using System.ComponentModel;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using System.Drawing;
using System.Xml;
using System.Xml.XPath;
using System.IO;
using System.Xml.Schema;
using System.Windows.Forms;
using System.Diagnostics;
using System.Text;
using System.Web.UI.WebControls;
using System.Collections;

namespace XMLEditor
{
    public partial class XMLDocumentController : Component
    {
        protected System.Threading.Mutex repaintSync = new System.Threading.Mutex();

        #region Selected Items
        protected XMLEditorWindow selectedEditor = null;
        protected string selectedDocumentFilename = null;
        #endregion

        #region Document Content Collections
        protected Hashtable xmlFileDocuments = new Hashtable();
        protected Hashtable xmlNSSchemas = new Hashtable();
        protected Hashtable xmlFilenameSchemaXml = new Hashtable();
        protected Hashtable xmlFileNamespaces = new Hashtable();
        protected ImageList imgList = null;
        protected bool xmlValidated = false;
        #endregion

        #region Image Attribute and Filename Mapping
        protected string[] IMAGE_ATTRIBUTE_LIST = {
                "Name", "NAME", "name", "Image", "IMAGE", "image", "IMG", "img", "Img"        };
        protected string[] IMAGE_ATTRIBUTE_VAL_PREFIX_LIST = new string[]{
                       "",
                        "System_Web_UI_WebControls_",
                        "System.Web.UI.WebControls."
        };
        #endregion

        #region Constructors

        private XMLDocumentController()
        {
            InitializeComponent();
        }

        public XMLDocumentController(XMLEditorWindow edtr, string xmlfile, 
            string xsdfile,string xmlns,string xmlnsuri)
        {
            this.SelectedXMLEditor = edtr;
            this.selectedDocumentFilename=xmlfile;

            xmlns = this.GetNamespaceFromSchemaFile(xsdfile);
            XMLEditor.XMLEditorMain.VXDDEFAULTXMLNS = xmlns;

            LoadValidatedXSD(xmlfile, xsdfile, xmlns, xmlnsuri);
            LoadValidatedXML(xmlfile,xsdfile,xmlns,xmlnsuri);
            
            this.imgList = new ImageList();
            Icon treeNodeDefaultTag = (Icon)XMLEditor.Properties.Resources.DefaultTag;
            Icon treeNodeDefaultAttr = (Icon)XMLEditor.Properties.Resources.DefaultAttr;
            Icon vxdIcon = (Icon)XMLEditor.Properties.Resources.vxd;
            this.imgList.Images.Add("DEFAULTTAG", treeNodeDefaultTag);
            this.imgList.Images.Add("DEFAULTATTR",treeNodeDefaultAttr);
            this.imgList.Images.Add("DEFAULTVXD",vxdIcon);
            this.selectedEditor.leftTreeView.ImageList = this.imgList;
            this.selectedEditor.rightTreeView.ImageList = this.imgList;
            this.RefreshEditors();
            XMLEditorMain.mainWindow.Update();
        }

        private XMLDocumentController(IContainer container)
        {
            container.Add(this);
            InitializeComponent();
        }
        #endregion

        #region SelectedEditor
        public XMLEditorWindow SelectedXMLEditor
        {
            get
            {
                return this.selectedEditor;
            }
            set
            {
                this.selectedEditor = value;
            }
        }
        #endregion

        public string GetNamespaceFromSchemaFile(string xsdfile)
        {
            string ns=XMLEditor.XMLEditorMain.VXDDEFAULTXMLNS;
            try
            {
                StreamReader str=new StreamReader(xsdfile);
                XmlReader xrdr = XmlReader.Create(str);
                XmlDocument xd = new XmlDocument();
                xd.Load(xrdr);
                ns = xd.DocumentElement.Attributes["targetNamespace"].Value;
            }
            catch (Exception)
            {
                ;
            }
            return ns;
        }

        #region SelectedDocumentFilename
        public string SelectedDocumentFilename
        {
            get
            {
                return this.selectedDocumentFilename;
            }
            set
            {
                this.selectedDocumentFilename=value;
            }
        }
        #endregion

        #region LoadValidatedXML
        private XmlDocument LoadValidatedXML(string filename, string xsdfilename,
                                                string xmlns,string uri)
        {
            XmlDocument xd = null;
            XmlResolver res=new XmlUrlResolver();
            XmlReaderSettings sett = GetXmlReaderValidationSettings(xmlns, uri, xsdfilename);
            sett.XmlResolver = res;

            XmlTextReader xtxt = new XmlTextReader(filename);
            xtxt.XmlResolver = res;
            XmlReader xrdr = XmlReader.Create(xtxt, sett);
            xd = new XmlDocument();
            xd.Load(xrdr);
            xd.DocumentElement.Normalize();
            if (xsdfilename != null)
                this.xmlValidated = true;
            
            if (this.xmlFileDocuments.Contains(filename))
                this.xmlFileDocuments.Remove(filename);
            this.xmlFileDocuments.Add(filename, xd);

            //Schema Sets
            if (this.xmlNSSchemas.Contains(xmlns))
                this.xmlNSSchemas.Remove(xmlns);
            this.xmlNSSchemas.Add(xmlns, xd.Schemas);
        
            //Namespaces
            if (this.xmlFileNamespaces.Contains(filename))
                this.xmlFileNamespaces.Remove(filename);
            this.xmlFileNamespaces.Add(filename,xmlns);
            return xd;
        }
        #endregion

        #region LoadValidatedXSD
        public string LoadValidatedXSD(string xmlfilename,string filename,
            string xmlns,string uri)
        {
            string targetNS = null;
            try
            {
                XmlResolver res = new XmlUrlResolver();
                string xsdText = LoadXMLorXSDorSchemaText(filename, xmlns);
                XmlReaderSettings sett = GetXmlReaderValidationSettings(
                    XMLEditor.XMLEditorMain.XMLSchemaXSDXMLNS, uri,null);
                sett.XmlResolver = res;
                XmlDocument xd = new XmlDocument();
                xd.XmlResolver = res;
                xd.LoadXml(xsdText);
                xd.DocumentElement.Normalize();
                if (this.xmlFilenameSchemaXml.Contains(xmlfilename))
                    this.xmlFilenameSchemaXml.Remove(xmlfilename);
                this.xmlFilenameSchemaXml.Add(xmlfilename, xd);
            }
            catch (System.Xml.Schema.XmlSchemaValidationException xsve)
            {
                MessageBox.Show("Validation Error, ignoring schema.\n" +
                    xsve.Message + "\nLine: " + xsve.LineNumber);
            }
            return targetNS;
        }

        private static XmlReaderSettings GetXmlReaderValidationSettings(string xmlns, string uri,string xsdfilename)
        {
            XmlReaderSettings sett = new XmlReaderSettings();
            
            try
            {
                sett.Schemas.Add(xmlns, uri);
            }
            catch (Exception) { ;}

            if (File.Exists(xsdfilename))
            {
                StringReader strrdr=null;
                XmlTextReader xmlxsdtxt = null;
                if (xmlns.Equals(XMLEditor.XMLEditorMain.XMLXSDXMLNS))
                {
                    // XML
                    strrdr = new StringReader(
                        XMLEditor.Properties.Resources.xmlschema);
                    xmlxsdtxt = new XmlTextReader(strrdr);
                    sett.Schemas.Add(XMLEditor.XMLEditorMain.XMLXSDXMLNS, xmlxsdtxt);
                }
                if (xmlns.Equals(XMLEditor.XMLEditorMain.XMLSchemaXSDXMLNS))
                {
                    // XML Schema
                    strrdr = new StringReader(XMLEditor.Properties.Resources.xmlschema);
                    xmlxsdtxt = new XmlTextReader(strrdr);
                    sett.Schemas.Add(XMLEditor.XMLEditorMain.XMLSchemaXSDXMLNS, xmlxsdtxt);
                }
                if (xsdfilename != null)
                {
                    // Schema File
                    XmlTextReader xsdtxt = new XmlTextReader(xsdfilename);
                    sett.Schemas.Add(xmlns, xsdtxt);
                }
            }
            sett.ValidationType= ValidationType.Schema;
            sett.ValidationFlags = XmlSchemaValidationFlags.ProcessIdentityConstraints | XmlSchemaValidationFlags.ProcessInlineSchema | XmlSchemaValidationFlags.ProcessSchemaLocation |
                XmlSchemaValidationFlags.AllowXmlAttributes;
            sett.ConformanceLevel = ConformanceLevel.Document;
            sett.IgnoreWhitespace = true;
            sett.IgnoreComments = true;
            sett.ProhibitDtd = false;
            sett.IgnoreProcessingInstructions = false;
            sett.IgnoreComments = true;
            sett.CheckCharacters = false;    
            sett.Schemas.Compile();
            return sett;
        }

        private static string LoadXMLorXSDorSchemaText(string filename, string xmlns)
        {
            string xsdText = XMLEditor.Properties.Resources.xmlschema;
            if (filename == null || !File.Exists(filename))
            {
                if (xmlns.Equals("http://www.w3.org/2001/XMLSchema"))
                    xsdText = XMLEditor.Properties.Resources.xsdschema;
            }
            else
            {
                StreamReader rd = File.OpenText(filename);
                xsdText = rd.ReadToEnd();
            }
            return xsdText;
        }
        #endregion
        
        #region RefreshEditor
        public void RefreshEditors()
        {
            RefreshXMLEditor();
            RefreshXSDEditor();
            RefreshTreeEditor();
        }

        private void RefreshTreeEditor()
        {
            this.selectedEditor.leftTreeView.Nodes.Clear();
            XmlNode root = GetSelectedXMLDocumentElement();
            if (root == null)
                return;
            XMLEditorTreeNode[] children = this.PopulateTree(root);
            XMLEditorTreeNode[] attrroot = this.PopulateAttributes(root);
            XMLEditorTreeNode[] rootchildren = new XMLEditorTreeNode[children.Length + attrroot.Length];
            System.Array.Copy(attrroot, rootchildren, attrroot.Length);
            System.Array.Copy(children, 0, rootchildren, attrroot.Length, children.Length);
            XMLEditorTreeNode rootNode = new XMLEditorTreeNode("<" + root.Name + ">", rootchildren, root);
            this.BuildImageList(root);
            this.SetTreeNodeImageAndToolTip(rootNode, root);
            rootNode.SelectedImageKey = rootNode.StateImageKey = 
                rootNode.ImageKey="DEFAULTVXD";
            this.selectedEditor.leftTreeView.Nodes.Add(rootNode);
            rootNode.Expand();
            this.selectedEditor.leftTreeView.Invalidate();

            this.selectedEditor.rightTreeView.Nodes.Clear();
            if (this.xmlValidated)
            {
                XmlNode rroot = GetSelectedXSDDocumentElement();
                XMLEditorTreeNode[] rchildren = this.PopulateTree(rroot);
                XMLEditorTreeNode[] rattrroot = this.PopulateAttributes(rroot);
                XMLEditorTreeNode[] rrootchildren = new XMLEditorTreeNode[rchildren.Length + rattrroot.Length];
                System.Array.Copy(rattrroot, rrootchildren, rattrroot.Length);
                System.Array.Copy(rchildren, 0, rrootchildren, rattrroot.Length, rchildren.Length);
                XMLEditorTreeNode rrootNode = new XMLEditorTreeNode("<" + rroot.Name + ">", rrootchildren, rroot);
                this.BuildImageList(rroot);
                this.SetTreeNodeImageAndToolTip(rrootNode, rroot);
                rrootNode.SelectedImageKey = rrootNode.StateImageKey =
                    rrootNode.ImageKey = "DEFAULTVXD";
                this.selectedEditor.rightTreeView.Nodes.Add(rrootNode);
                rrootNode.Expand();
                this.selectedEditor.rightTreeView.Invalidate();
            }
            
            this.selectedEditor.Invalidate();
        }

        public XmlNode GetSelectedXMLDocumentElement()
        {

            XmlNode root = ((XmlDocument)this.xmlFileDocuments[this.selectedDocumentFilename]).DocumentElement;
            return root;
        }

        public XmlNode GetSelectedXSDDocumentElement()
        {
            XmlNode root = new XmlDocument().DocumentElement;
            if (this.xmlValidated && this.xmlFilenameSchemaXml.Contains(this.selectedDocumentFilename))
            {
                root=((XmlDocument)this.xmlFilenameSchemaXml[this.selectedDocumentFilename]).DocumentElement;
            }
            return root;
        }

        private void RefreshXMLEditor()
        {
            string xml = ((XmlDocument)xmlFileDocuments[this.selectedDocumentFilename]).OuterXml;
            this.selectedEditor.xmlTextbox.Text = xml;
            this.selectedEditor.xmlTextbox.Invalidate();
        }

        private void RefreshXSDEditor()
        {
            this.selectedEditor.xsdTextbox.Text = string.Empty;
            if (this.xmlValidated)
            {
                string xd = ((XmlDocument)this.xmlFilenameSchemaXml[this.SelectedDocumentFilename]).OuterXml;
                this.selectedEditor.xsdTextbox.Text = xd;
            }
            this.selectedEditor.xsdTextbox.Invalidate();
        }


        #endregion RefreshEditor

        #region BuildImageList
        private void BuildImageList(XmlNode nd)
        {
            if (nd != null && nd.Attributes != null)
            {
                string absolutePathVXD = XMLEditorMain.VXDDEFAULTDIR;
                absolutePathVXD += absolutePathVXD.EndsWith("\\") ? string.Empty : "\\";

                string mainNameAtt = string.Empty;
                string dotprefix = "System.Web.UI.WebControls.";
                string uprefix = dotprefix.Replace(".", "_");
                string[] imageExt ={ ".gif", ".jpg", "" };
                //Attributes to check for filename
                foreach (string attName in new string[] {
                    "Name", "NAME", "name", "Image", "IMAGE", "image", "IMG", "img", "Img" 
                ,nd.Name,string.Empty})
                {
                    mainNameAtt = null;
                    if (nd.Attributes[attName] != null &&
                        nd.Attributes[attName].Value != null)
                        mainNameAtt = nd.Attributes[attName].Value;
                    if (mainNameAtt == null)
                        continue;
                    try
                    {
                        //Get from Resources
                        System.Drawing.Image icon = null;
                        object picon = XMLEditor.Properties.Resources.ResourceManager.GetObject(mainNameAtt);
                        if (picon is System.Drawing.Image)
                            icon = (System.Drawing.Image)picon;
                        if (picon is Icon)
                            icon = ((Icon)picon).ToBitmap();
                        if (icon != null)
                            this.imgList.Images.Add(mainNameAtt, icon);
                        //Directories to check
                        foreach (string pfx in this.IMAGE_ATTRIBUTE_VAL_PREFIX_LIST)
                            foreach (string parentdir in new string[]{
                          absolutePathVXD, 
                            absolutePathVXD+XMLEditorMain.DEFAULTIMGDIR+pfx,
                        absolutePathVXD+XMLEditorMain.DEFAULTIMGDIR+pfx,
                         
                        absolutePathVXD+XMLEditorMain.DEFAULTIMGDIR})
                                //Image Extensions
                                foreach (string extension in imageExt)
                                    //Prefixes
                                    foreach (string imfileiter in
                                        new string[]{
                                        mainNameAtt,
                                        parentdir+mainNameAtt,
parentdir+mainNameAtt+extension,
                                        parentdir+"Images\\"+mainNameAtt
                       
                            })
                                    {
                                        string imfile = imfileiter.Replace('/', '\\');
                                      
                                        if (!this.imgList.Images.ContainsKey(imfile) &&
                                            File.Exists(imfile)
                                            )
                                        {
                                            icon = null;

                                            try { icon = System.Drawing.Image.FromFile(imfile); }
                                            catch { ; }
                                            if (icon != null)
                                            {

                                                if (mainNameAtt != null)
                                                {
                                                    this.imgList.Images.Add(mainNameAtt, icon);
                                                }
                                            }
                                        }
                                        //search for filename with attribute value and 
                                        //image extension
                                        /*
                                                                            if (Directory.Exists(parentdir))
                                                                            {

                                                                                string[] dir = null;
                                                                                for (int j = 0; j < extension.Length; ++j)
                                                                                {
                                                                                    if (Directory.Exists(parentdir))
                                                                                    {
                                                                                        dir = Directory.GetFiles(
                                        parentdir, "*" + mainNameAtt + dir[j], SearchOption.TopDirectoryOnly);

                                                                                        for (int i = 0; i < dir.Length; ++i
                                                                                            )
                                                                                        {

                                                                                            icon = null;

                                                                                            try { icon = System.Drawing.Image.FromFile(parentdir + dirent); }
                                                                                            catch { ; }
                                                                                            if (icon != null)
                                                                                            {


                                                                                                if (mainNameAtt != null)
                                                                                                {
                                                                                                    this.imgList.Images.Add(mainNameAtt, icon);
                                                                                                    this.imgList.Images.Add(uprefix + mainNameAtt.Replace(".", "_"), icon);
                                                                                                    this.imgList.Images.Add(mainNameAtt, icon);
                                                                                                }

                                                                                            }
                                                                                        }
                                                                                    }
                                                                                }
                                                                            */


                                    }
                    }

                    catch (Exception )
                    {
                        ;
                    }
                }
            }
        }
        #endregion

        #region PopulateTree
        protected XMLEditorTreeNode[] PopulateTree(XmlNode parent)
        {
            if (parent == null || parent.ChildNodes == null)
                return new XMLEditorTreeNode[0];
            XMLEditorTreeNode treend = null;
            ArrayList arr = new ArrayList();
            foreach (XmlNode nd in parent.ChildNodes)
            {
                this.BuildImageList(nd);
                if (nd.HasChildNodes)
                {
                    XMLEditorTreeNode[] attrroot = this.PopulateAttributes(nd);
                    XMLEditorTreeNode[] children = this.PopulateTree(nd);
                    XMLEditorTreeNode[] rootchildren = new XMLEditorTreeNode[children.Length + attrroot.Length];
                    System.Array.Copy(attrroot, rootchildren, attrroot.Length);
                    System.Array.Copy(children, 0, rootchildren, attrroot.Length, children.Length);
                    string nameattr = string.Empty;
                    if (nd.Attributes != null)
                    {
                        XmlAttribute id = nd.Attributes["ID"];
                        if (id == null)
                            id = nd.Attributes["id"];
                        if (id != null && id.Value != null)
                            nameattr += " ID=\"" + id.Value.ToString() + "\" ";
                        foreach (string nmatt in new string[] { "Name", "NAME", "name" })
                        {
                            XmlAttribute nm = nd.Attributes[nmatt];
                            if (nm != null && nm.Value != null)
                            {
                                nameattr += " name=\"" + nm.Value.ToString() + "\"";
                                break;
                            }
                        }
                    }
                    treend = new XMLEditorTreeNode("<" + nd.Name + nameattr + ">", rootchildren, nd);
                    this.SetTreeNodeImageAndToolTip(treend, nd);
                    arr.Add(treend);
                    treend.Expand();
                }
                else
                {
                    XMLEditorTreeNode[] att = PopulateAttributes(nd);
                    string nameattr = string.Empty;
                    if (nd.Attributes != null)
                    {
                        XmlAttribute id = nd.Attributes["ID"];
                        if (id == null)
                            id = nd.Attributes["id"];
                        if (id != null && id.Value != null)
                            nameattr += " ID=\"" + id.Value.ToString() + "\" ";
                        foreach (string nmatt in new string[] { "Name", "NAME", "name" })
                        {
                            XmlAttribute nm = nd.Attributes[nmatt];
                            if (nm != null && nm.Value != null)
                            {
                                nameattr += " name=\"" + nm.Value.ToString() + "\"";
                                break;
                            }
                        }
                    }
                    if (att == null)
                        treend = new XMLEditorTreeNode("<" + nd.Name + nameattr + ">", nd);
                    else
                        treend = new XMLEditorTreeNode("<" + nd.Name + nameattr + ">", att, nd);
                    this.SetTreeNodeImageAndToolTip(treend, nd);
                    arr.Add(treend);
                    treend.Collapse();
                    if (treend.Parent != null)
                        treend.Parent.Collapse();
                }
            }
            int i = 0;
            XMLEditorTreeNode[] nds = new XMLEditorTreeNode[arr.Count];
            foreach (XMLEditorTreeNode t in arr)
            {
                nds[i] = t; ++i;
            }
            return nds;
        }
        #endregion

        #region SetTreeNodeImageAndToolTip
        private void SetTreeNodeImageAndToolTip(XMLEditorTreeNode nd, XmlNode xnd)
        {
            if (nd == null || xnd == null)
                return;
            if (xnd.Attributes == null)
            {
                nd.SelectedImageKey=nd.StateImageKey=nd.ImageKey = "DEFAULTTAG";
                return;
            }
 
            System.Xml.Schema.XmlSchemaSet schset = (System.Xml.Schema.XmlSchemaSet)                                     this.xmlNSSchemas[XMLEditor.XMLEditorMain.VXDDEFAULTXMLNS];
            object[] schmSetArray = new object[1];
            schset.GlobalElements.Values.CopyTo(schmSetArray, 0);
            XmlSchemaElement rootSchemaNode = (XmlSchemaElement)schmSetArray[0];

            nd.ToolTipText = xnd.Name + " " + this.GetAttributeList(xnd);
            nd.ContextMenuStrip = new ContextMenuStrip();
            nd.ContextMenuStrip.Items.Add("Delete " + nd.Name);
            nd.ContextMenuStrip.Items.Add("Copy " + nd.Name);
            ToolStripMenuItem paste = new ToolStripMenuItem();
            paste.Text = "Paste";
            paste.Enabled = false;
            nd.ContextMenuStrip.Items.Add(paste);
            nd.ContextMenuStrip.Items.Add(new ToolStripSeparator());
            
            CreateDropDownMenus(nd, xnd, rootSchemaNode);

            foreach (string attName in this.IMAGE_ATTRIBUTE_LIST)
            {
                string mainNameAtt = null;
                if (xnd.Attributes[attName] != null &&
                    xnd.Attributes[attName].Value != null)
                    mainNameAtt = xnd.Attributes[attName].Value;
                if (mainNameAtt == null)
                    continue;


                foreach (string prefix in this.IMAGE_ATTRIBUTE_VAL_PREFIX_LIST)
                    if (this.imgList.Images.ContainsKey(prefix + mainNameAtt))
                    {
                        string prefixedAttVal = prefix + mainNameAtt;
                        try
                        {
                            nd.SelectedImageKey=nd.StateImageKey=nd.ImageKey = prefixedAttVal;                            
                            return;
                        }
                        catch (Exception) { ;}

                    }
            }
        }

        private static void CreateDropDownMenus(XMLEditorTreeNode nd, XmlNode xnd, XmlSchemaElement rootSchemaNode)
        {

            ToolStripDropDownButton elmnu = new ToolStripDropDownButton();
            elmnu.Text = "New Element";
            ToolStripDropDownButton attrmnu = new ToolStripDropDownButton();
            attrmnu.Text = "New Attribute";

            PopulateDropDownMenu(xnd, elmnu, attrmnu, rootSchemaNode);

            nd.ContextMenuStrip.Items.Add(attrmnu);
            nd.ContextMenuStrip.Items.Add(elmnu);

        }

        private static void PopulateDropDownMenu(XmlNode localNode,
            ToolStripDropDownButton elmnu, ToolStripDropDownButton attrmnu
            , XmlSchemaElement schemaNodeIter)
        {
            if (schemaNodeIter!=null &&
                schemaNodeIter.ElementSchemaType!=null &&
                schemaNodeIter.ElementSchemaType is XmlSchemaComplexType)
            {
                XmlSchemaComplexType schmCpx = (XmlSchemaComplexType)
                    schemaNodeIter.ElementSchemaType;

                if (localNode.Name.Equals(schemaNodeIter.Name) &&
                    schmCpx.Particle is XmlSchemaSequence)
                {
                    XmlSchemaSequence scmcpxSeq = (XmlSchemaSequence)schmCpx.Particle;
                    foreach (XmlSchemaElement cpxel in scmcpxSeq.Items)
                    {
                        elmnu.DropDownItems.Add(cpxel.Name);
                    }
                }
                foreach (XmlSchemaAttribute schemaAttributeIter in
                    schmCpx.AttributeUses.Values)
                {
                    if (localNode.Name.Equals(schemaNodeIter.Name))
                    {
                        attrmnu.DropDownItems.Add(schemaAttributeIter.Name);
                    }
                }
                if (schmCpx.Particle is XmlSchemaSequence)
                {
                    XmlSchemaSequence cpxSeq = (XmlSchemaSequence)schmCpx.Particle;
                    foreach (XmlSchemaElement cpxel in cpxSeq.Items)
                    {
                        PopulateDropDownMenu(localNode, elmnu,attrmnu, cpxel);

                    }
                }
                
            }
        }
    
                    
        #endregion

        #region PopulateAttributes
        private XMLEditorTreeNode[] PopulateAttributes(XmlNode parent)
        {
            if (parent == null || parent.Attributes == null)
                return new XMLEditorTreeNode[0];
            XMLEditorTreeNode treend = null;
            ArrayList arr = new ArrayList();
            foreach (XmlAttribute nd in parent.Attributes)
            {
                treend = new XMLEditorTreeNode(nd.Name + "=\"" + nd.Value + "\"", nd);
                treend.SelectedImageKey = treend.StateImageKey = treend.ImageKey = "DEFAULTATTR";
                treend.ToolTipText = nd.Name + "=\"" + nd.Value + "\"";
                arr.Add(treend);
            }
            int i = 0;
            XMLEditorTreeNode[] nds = new XMLEditorTreeNode[arr.Count];
            foreach (XMLEditorTreeNode t in arr)
            {
                nds[i] = t; ++i;
            }
            return nds;
        }
        #endregion

        #region GetAttributeList
        private string GetAttributeList(XmlNode nd)
        {
            if (nd == null || nd.Attributes == null)
                return string.Empty;
            string stratts = "(";
            foreach (XmlAttribute att in nd.Attributes)
                stratts += att.Name + "=\"" + att.Value + "\",";
            stratts.TrimEnd(new char[] { ',' });
            stratts += ")";
            return stratts;
        }
        #endregion

        #region GetXmlDocumentFragment
        public XmlDocumentFragment GetSelectedDocumentXmlFragment(string name, string xpath)
        {
            XmlReaderSettings set = new XmlReaderSettings();
            set.ValidationType = ValidationType.None;
            set.ValidationFlags = XmlSchemaValidationFlags.None;
            XmlDocument xdata = new XmlDocument();
            xdata.LoadXml(((XmlDocument)this.xmlFileDocuments[name]).OuterXml);
            XmlNodeList nl = xdata.SelectNodes(xpath);
            XmlDocumentFragment frag = xdata.CreateDocumentFragment();
            foreach (XmlNode n in nl) frag.AppendChild(n);
            return frag;
        }
        #endregion

        #region Log
        public void Log(string text)
        {
            this.Log(text, null);
        }
        public void Log(string text, string detail)
        {
            string entry=text + "\n" + detail;
            if (XMLEditorMain.LOGGING != XMLEditorMain.LOGLEVEL.none)
            {
                this.SelectedXMLEditor.eventLog.WriteEntry(entry, EventLogEntryType.Information);
                MessageBox.Show(entry);
            }
        }
        #endregion

        #region Update Tree Node
        public bool UpdateTreeNodeXML(object treeNd, string val)
        {
            if (val == null)
                return true;
            XMLEditorTreeNode nd = (XMLEditorTreeNode)treeNd;
            if (nd.XmlNode is XmlAttribute)
            {
                XmlAttribute att = (XmlAttribute)nd.XmlNode;
                string prevval = att.Value;
                try
                {
                    string attrval = val.Substring(val.IndexOf("\"") + 1);
                    att.Value = attrval.Substring(0, attrval.LastIndexOf("\""));
                }
                catch (Exception)
                {
                    att.Value = prevval;
                }
                string labelval = att.Name + "=\"" + att.Value + "\"";
                nd.Text = labelval;
                nd.ToolTipText = labelval;
                nd.SelectedImageKey = nd.StateImageKey = nd.ImageKey;
            }
            this.RefreshXMLEditor();
            return true;
        }
        #endregion
    }
}
