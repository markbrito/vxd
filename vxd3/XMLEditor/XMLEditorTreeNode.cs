using System;
using System.Collections.Generic;
using System.Xml;
using System.Text;
using System.Xml.Serialization;
using System.ComponentModel;
using System.Drawing;
using System.Windows.Forms;
using System.Drawing.Design;
using System.Runtime.Serialization;

namespace XMLEditor
{
    public class XMLEditorTreeNode : System.Windows.Forms.TreeNode
    {
        protected XmlNode xmlNode=null;


        #region XmlNode
        public XmlNode XmlNode
        {
            get
            {
                return this.xmlNode;
            }
        }
        #endregion

        private XMLEditorTreeNode() :base()
        {
            ;
        }
        public XMLEditorTreeNode(string text,XmlNode nd):base(text)

        {
            this.xmlNode = nd;
        }

        private XMLEditorTreeNode(SerializationInfo serializationInfo, StreamingContext context):base(serializationInfo,context)
        {
            ;
        }
        public XMLEditorTreeNode(string text, TreeNode[] children,XmlNode nd):base(text,children)
        {
            this.xmlNode = nd;
            
        }
        public XMLEditorTreeNode(string text, TreeNode[] children, XmlAttribute nd)
            : base(text, children)
        {
            this.xmlNode = nd;

        }
        private XMLEditorTreeNode(string text, int imageIndex, int selectedImageIndex, TreeNode[] children)
        {
            ;
        }

    }
}
