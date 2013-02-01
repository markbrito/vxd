using System;
using System.IO;
using System.Collections.Generic;
using System.Configuration;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.Xml;
using System.Web.UI.WebControls;
using System.Threading;

namespace XMLEditor
{
    public partial class XMLEditorWindow : Form
    {
        #region Constructor
        public XMLEditorWindow()
        {
            InitializeComponent();
        }
        #endregion

        #region XMLEditor_Load
        private void XMLEditor_Load(object sender, EventArgs e)
        {
            string filename = null;
            string[] args = System.Environment.GetCommandLineArgs();
            if (args.Length > 1)
            {
                filename = args[1];
                this.OpenFile(filename);
            }
        }
        #endregion

        #region TreeView
        private void treeView1_AfterLabelEdit(object sender, NodeLabelEditEventArgs e)
        {
            e.CancelEdit = XMLEditorMain.mainController.UpdateTreeNodeXML(e.Node, e.Label);
        }
        #endregion
        
        #region toolStripButtons
        private void toolStripButton1_Click(object sender, EventArgs e)
        {
        }

        private void toolStripButton2_Click(object sender, EventArgs e)
        {


        }

        private void toolStripButton3_Click(object sender, EventArgs e)
        {
            ;
        }

        private void toolStripMenuItem2_Click(object sender, EventArgs e)
        {

        }

        private void toolStripButton4_Click(object sender, EventArgs e)
        {
            this.OpenFile(null);
        }
        #endregion

        #region RefreshControllerAndEditor

        private void RefreshControllerAndEditor(string xmlfile,
            string xsdfile, string xmlns, string uri)
        {
            if (XMLEditorMain.mainController != null)
                XMLEditorMain.mainController.Dispose();
            XMLEditorMain.mainController = null;
            XMLEditorMain.mainController = new XMLDocumentController(
                XMLEditorMain.mainWindow, xmlfile, xsdfile, xmlns, uri);
            XMLEditorMain.mainWindow.Update();
        }
        #endregion

        #region OpenFile
        public void OpenFile(string filename)
        {
            DialogResult result = DialogResult.No;
            if (filename != null && File.Exists(filename))
            {
                result = DialogResult.OK;
            }
            else
            {
                result = this.openFileDialog1.ShowDialog();
            }
            if (result == DialogResult.OK)
            {
                string uri = XMLEditorMain.VXDDEFAULTXMLNSURI;
                string xmlns = XMLEditorMain.VXDDEFAULTXMLNS;
                string xmlfile = filename;
                if (filename == null || !File.Exists(xmlfile))
                {
                    xmlfile = this.openFileDialog1.FileName.ToString();
                }
                string xsdfile = xmlfile.Substring(0, xmlfile.LastIndexOf("."));
                xsdfile += ".xsd";
                if (!xmlfile.ToUpper().EndsWith(".XSD") && File.Exists(xsdfile))
                {
                    result = MessageBox.Show("Load " + xsdfile + " ?", "Load " + xsdfile.Substring(xsdfile.LastIndexOf("\\") + 1) + " ?", MessageBoxButtons.OKCancel);
                }
                else
                {
                    result = DialogResult.No;
                }
                if(result!=DialogResult.OK)
                {
                    this.openFileDialog2.InitialDirectory = xmlfile.Substring(0, xmlfile.LastIndexOf("\\"));
                    result = this.openFileDialog2.ShowDialog();
                    xsdfile = this.openFileDialog2.FileName;
                }
                if (result == DialogResult.OK)
                {                    
                    uri = xsdfile.Substring(xsdfile.LastIndexOf("\\") + 1);
                    xmlns = XMLEditor.XMLEditorMain.VXDDEFAULTXMLNS;
                }
                else
                {
                    //load default xsd
                    xsdfile = null;
                    uri = "xs";
                    if (xmlfile.ToLower().EndsWith(".xsd"))
                    {
                        xmlns = XMLEditor.XMLEditorMain.XMLSchemaXSDXMLNS;
                    }
                    else
                    {
                        xmlns = XMLEditor.XMLEditorMain.XMLXSDXMLNS;
                    }
                }  
                RefreshControllerAndEditor(xmlfile, xsdfile,xmlns, uri);
            }
        }
        #endregion
    }
}