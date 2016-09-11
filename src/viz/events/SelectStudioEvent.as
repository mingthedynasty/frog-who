package viz.events {

    import flash.events.Event;


    /***************************************
     **
     ** SelectStudioEvent
     **
     ***************************************/
    public class SelectStudioEvent extends Event {


        /***********************************
         ** VARIABLES
         ***********************************/
        public var studioCode:String;
        public var prevCode:String;


        //-----------
		public static const SELECT_STUDIO:String = "select_studio";
        public static const NO_STUDIO_SELECTED:String = "no_studio_selected";



        /***********************************
         ** CONSTRUCTOR
         ***********************************/
		public function SelectStudioEvent(type:String, 
                                          code:String,
                                          pCode:String)
		{
			super(type, false, false);
            studioCode = code;
            prevCode = pCode;
		}
    }
}
