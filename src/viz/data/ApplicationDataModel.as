package viz.data {

    import flash.events.Event;
    import flash.events.EventDispatcher;

	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.collections.XMLListCollection;
    import mx.events.PropertyChangeEvent;
    import mx.events.PropertyChangeEventKind;

    import viz.events.SelectStudioEvent;
    import viz.events.SearchResultEvent;

    
    /***************************************
     **
     ** ApplicationDataModel
     **
     ***************************************/
    public class ApplicationDataModel extends EventDispatcher {


        /***********************************
         ** VARIABLES
         ***********************************/
        private var _frogData:XMLListCollection;
        private var _studioData:XMLListCollection;
        private var _departmentData:XMLListCollection;
        private var _selectedStudio:String;

        private var _maxStudioCount:Number = 0;
        private var _angleStep:Number = 0;

        private var _searchTerm:String = "";

        //-----------
        public static const DATA_READY:String = "data_ready";


        private static var _instance:ApplicationDataModel = null;



        /***********************************
         ** CONSTRUCTOR
         ***********************************/
        public function ApplicationDataModel() {
            _selectedStudio = SelectStudioEvent.NO_STUDIO_SELECTED;
        }


        /***********************************
         ** GETTERS/SETTERS
         ***********************************/
        [Bindable]
        public function set frogData(data:XMLListCollection):void {
            _frogData = data;
            if (isReady) {
                processData();
            }
        }
        public function get frogData():XMLListCollection {
            return _frogData;
        }

        [Bindable]
        public function set studioData(data:XMLListCollection):void {
            _studioData = data;
            if (isReady) {
                processData();
            }
        }
        public function get studioData():XMLListCollection {
            return _studioData;
        }

        public function set departmentData(data:XMLListCollection):void {
            _departmentData = data;
            if (isReady) {
                processData();
            }
        }
        public function get departmentData():XMLListCollection {
            return _departmentData;
        }
        
        //-----------
        public function set searchTerm(term:String):void {
            _searchTerm = term;
            var found:XMLList = new XMLList();
            var dataSet:XMLListCollection = _frogData;
            if (_selectedStudio != SelectStudioEvent.NO_STUDIO_SELECTED) {
                dataSet = new XMLListCollection(_frogData.source.(studio == _selectedStudio));
            }
            if (term != "") {
                for each (var frog:XML in dataSet) {
                    if (frog.name.search(term) > -1) {
                        found += frog;
                    }
                }
            }
            
            var searchResults:XMLListCollection = 
                new XMLListCollection(found);
            dispatchEvent(new SearchResultEvent(SearchResultEvent.RESULT,
                                                term,
                                                searchResults));
        }
        public function get searchTerm():String {
            return _searchTerm;
        }

        //-----------
        public function set selectedStudio(id:String):void {
            var prev:String = _selectedStudio;
            _selectedStudio = id;
            dispatchEvent(new SelectStudioEvent(SelectStudioEvent.SELECT_STUDIO,
                                                id,
                                                prev));
        }
        public function get selectedStudio():String {
            return _selectedStudio;
        }

        //-----------
        public function get maxStudioCount():Number {
            return _maxStudioCount;
        }

        //-----------
        public function get maxFrogId():Number {
            return _frogData.getItemAt(0).id;
        }

        //-----------
        public function get angleStep():Number {
            return _angleStep;
        }
        

        /***********************************
         ** PUBLIC
         ***********************************/
        public static function getInstance():ApplicationDataModel {
            if (_instance == null) {
                _instance = new ApplicationDataModel();
            }
            return _instance;
        }

        //-----------
        public function searchAgain():void {
            searchTerm = searchTerm;
        }

        /***********************************
         ** PRIVATE
         ***********************************/
        private function get isReady():Boolean {
            return _frogData && _studioData && _departmentData;
        }


        //-----------
		[Bindable(event=DATA_READY)]
        private function processData():void {

            // Calc max studio count
            var maxStudioCount:Number = 0;
            var studioCode:String;
            var studioCount:Number;
            for each (var studioXML:XML in _studioData) {
                studioCode = studioXML.code;
                studioCount = _frogData.source.(studio == studioCode).length();
                studioXML.appendChild("<count>" + studioCount + "</count>");
                if (studioCount > maxStudioCount) {
                    maxStudioCount = studioCount;
                }
            }
            _maxStudioCount = maxStudioCount;


            // Calc department counts and set colors
            var totalMaxDptCount:Number = 0;
            var dptCode:String;
            var dptCount:Number;
            for each (var dptXML:XML in _departmentData) {
                dptCode = dptXML.code;
                var maxDptCount:Number = 0;
                for each (var studioData:XML in _studioData) {
                    studioCode = studioData.code;
                    dptCount = frogData.source.(studio == studioCode).(department == dptCode).length();
                    if (dptCount > maxDptCount) {
                        maxDptCount = dptCount;
                    }
                }
                totalMaxDptCount += maxDptCount;
                dptXML.appendChild("<max>" + maxDptCount + "</max>");
                dptXML.appendChild("<color>" + Math.random() * 0xFFFFFF + "</color>");
            }

            // Sort data
            sortDepartments(); 
            sortFrogs();
            sortStudios();

            // Angle step
            _angleStep = (2 * Math.PI)/totalMaxDptCount;

            dispatchEvent(new Event(DATA_READY));
        }

        private function sortDepartments():void {
            var sort:Sort = new Sort();
            sort.fields = [new SortField("max", true, true, true)];

            _departmentData.sort = sort;
            _departmentData.refresh();
        } 

        private function sortFrogs():void {
            var sort:Sort = new Sort();
            sort.fields = [new SortField("id", true, true, true)];

            _frogData.sort = sort;
            _frogData.refresh();
        } 

        private function sortStudios():void {
            var sort:Sort = new Sort();
            sort.fields = [new SortField("count", true, true, true)];

            _studioData.sort = sort;
            _studioData.refresh();

        } 
    }
}
