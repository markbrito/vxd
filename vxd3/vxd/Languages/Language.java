package vxd.Languages;

public class Language
{
    private static Object mutex=new Object();
    private static Language language=null;
    public static final String NOT_INSTANTIATED="Language is Not Instantiated";
    
    private Language()
    {
        ;
    }
    
    public static Language getLanguage()
    {
        if(language==null)
        {
            synchronized(mutex)
            {
                if(language==null)
                {
                    language=new Language();
                }
            }
        }
        return language;
    }
    
    public boolean createLanguage() throws Exception
    {
        if(language==null)
            throw new Exception(NOT_INSTANTIATED);
        return true;
    }
}