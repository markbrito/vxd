using System;
using System.Collections.Generic;
using System.Text;

namespace XMLEditor
{
    public class XMLEditorTree:System.Windows.Forms.TreeView,System.Xml.IHasXmlNode
    {
       

      
            
        #region IHasXmlNode Members

        System.Xml.XmlNode System.Xml.IHasXmlNode.GetNode()
        {
            throw new Exception("The method or operation is not implemented.");
        }

        #endregion
    }
}
