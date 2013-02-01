using System;
using System.Collections.Generic;
using System.Windows.Forms;

namespace XMLEditor
{
    public static class XMLEditorMain
    {
        public enum LOGLEVEL { none, messages, stacktrace };
        public const LOGLEVEL LOGGING = LOGLEVEL.messages;
        public static string VXDDEFAULTDIR =
            @"C:\Documents and Settings\c0d3r\Desktop\VXD\vxdWorkspace\vxdProject\vxd\";
        public static string VXDDEFAULTCONFIGFILE = @"Config\vxd.xml";
        public static string VXDDEFAULTCONFIGFILEXSD = @"Config\vxd.xsd";
        public static string VXDDEFAULTXMLNS = @"http://tempuri.org/";
        public static string VXDDEFAULTXMLNSURI = @"xmlns";
        public static string DEFAULTIMGDIR = @"Images\";
        public static string XMLXSDXMLNS="http://www.w3.org/XML/1998";
        public static string XMLSchemaXSDXMLNS="http://www.w3.org/2001/XMLSchema";

        public static XMLEditorWindow mainWindow = null;
        public static XMLDocumentController mainController=null;
  
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            mainWindow = new   XMLEditorWindow();            
            Application.Run(mainWindow);
        }

    }
}