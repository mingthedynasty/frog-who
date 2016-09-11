package viz.data {

    import mx.rpc.events.ResultEvent;
    import mx.rpc.http.HTTPService;

            
    /***************************************
     **
     ** DataService
     **
     ***************************************/
    public class DataService {


        /***********************************
         ** VARIABLES
         ***********************************/
        private static var _instance:DataService = null;


        /***********************************
         ** CONSTRUCTOR
         ***********************************/
        public function DataService() {
        }


        /***********************************
         ** PUBLIC
         ***********************************/
        public static function getInstance():DataService {
            if (_instance ==  null) {
                _instance = new DataService();
            }
            return _instance;
        }

        //-----------
        public function doRequest(url:String, callBack:Function):void {
            var service:HTTPService = new HTTPService();
            service.resultFormat = "e4x";
            service.addEventListener(ResultEvent.RESULT, callBack);
            service.url = url;
            service.send();
        }

    }
}
