package viz {

    /***************************************
     **
     ** AssetManager
     **
     ***************************************/
    public class AssetManager {


        /***********************************
         ** VARIABLES
         ***********************************/
        [Embed(source='assets/fonts/BentonSansF-Book.otf', 
               fontName='benton', 
               mimeType='application/x-font')] 
        public static const BENTON:Class;

        [Embed(source='assets/fonts/BentonSansFrog-Medium.ttf', 
               fontName='bentonMedium', 
               mimeType='application/x-font')] 
        public static const BENTON_MEDIUM:Class;

        [Embed(source='assets/fonts/BentonSansFrog-ExtraLight.ttf', 
               fontName='bentonLight', 
               mimeType='application/x-font')] 
        public static const BENTON_LIGHT:Class;


        [Embed(source="assets/logo_small.png")]
        public static const FROG_LOGO:Class;  

        [Embed(source="assets/friedolin_small.png")]
        public static const FRIEDOLIN:Class;  

    }

}
