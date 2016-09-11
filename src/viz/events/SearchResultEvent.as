package viz.events {

    import flash.events.Event;

	import mx.collections.XMLListCollection;


    /***************************************
     **
     ** SearchTextEvent
     **
     ***************************************/
    public class SearchResultEvent extends Event {


        /***********************************
         ** VARIABLES
         ***********************************/
        public var searchTerm:String;
        public var results:XMLListCollection;

        //-----------
		public static const RESULT:String = "result";


        /***********************************
         ** CONSTRUCTOR
         ***********************************/
        public function SearchResultEvent(type:String,
                                          term:String,
                                          r:XMLListCollection) {
            super(type);
            searchTerm = term;
            results = r;
        }
    }
}
