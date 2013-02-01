package vxd.Translators;

public class Translator
{
    private static Object mutex=new Object();
    private static Translator translator=null;
    public static final String NOT_INSTANTIATED="Translator is Not Instantiated";
    
    private Translator()
    {
        ;
    }
    
    public static Translator getTranslator()
    {
        if(translator==null)
        {
            synchronized(mutex)
            {
                if(translator==null)
                {
                    translator=new Translator();
                }
            }
        }
        return translator;
    }
    
    public boolean createTranslator() throws Exception
    {
        if(translator==null)
            throw new Exception(NOT_INSTANTIATED);
        return true;
    }
}
