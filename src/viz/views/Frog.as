package viz.views {

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;

    import mx.collections.XMLListCollection;
    import mx.containers.Canvas;
    import mx.managers.SystemManager;

    import caurina.transitions.Tweener;
    
    import viz.data.ApplicationDataModel;
    import viz.events.SearchResultEvent;
    import viz.events.SelectStudioEvent;


    /***************************************
     **
     ** Frog
     **
     ***************************************/
    public class Frog extends Sprite {


        /***********************************
         ** VARIABLES
         ***********************************/
        private var _dot:Sprite;
        private var _hilite:Sprite;
        private var _infoBox:FrogInfoBox;
        private var _hit:Sprite;

        private var _radius:Number = 5;
        private var _angle:Number = Math.PI/2;
        private var _trackRadius:Number = 100;
        private var _color:uint = 0x666666;
        
        private var _data:XML;

        private var _isSearchResult:Boolean = false;
        private var _isNarrowedSearchResult:Boolean = false;


        //-----------
        private static const HILITE_RADIUS_BUFFER:Number = 14;



        /***********************************
         ** CONSTRUCTOR
         ***********************************/
        public function Frog(rad:Number = 5, ang:Number = Math.PI/2, 
                             trackRad:Number = 0, col:uint = 0x666666) {

            // Children
            _hilite = new Sprite();
            _hilite.visible = false;
            addChild(_hilite);

            _dot = new Sprite();
            addChild(_dot);

            _hit = new Sprite();
            _hit.graphics.beginFill(0xFF0000, 0);
            _hit.graphics.drawCircle(0, 0, 10);
            _hit.graphics.endFill();
            addChild(_hit);
            hitArea = _hit;

            // Set up tweener props
            Tweener.registerSpecialProperty("frogAngle", 
                                            getFrogAngle, 
                                            setFrogAngle);
            Tweener.registerSpecialProperty("frogRadius", 
                                            getFrogRadius, 
                                            setFrogRadius);
            Tweener.registerSpecialProperty("frogTrackRadius", 
                                            getFrogTrackRadius, 
                                            setFrogTrackRadius);

            // Mouse listeners
            addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
            addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);

            // Init props
            color = col;
            radius = rad;
            angle = ang;
            trackRadius = trackRad;

            buttonMode = true;
            mouseChildren = false;

            // Application model listeners
            ApplicationDataModel.getInstance().addEventListener(SearchResultEvent.RESULT,
                                                                onSearchResult);
            ApplicationDataModel.getInstance().addEventListener(SelectStudioEvent.SELECT_STUDIO,
                                                                onSelectStudio);
        }


        /***********************************
         ** GETTERS/SETTERS
         ***********************************/
        public function set data(data:XML):void {
            _data = data;
        }
        public function get data():XML {
            return _data;
        }
        
        //-----------
        public function set radius(r:Number):void {
            _radius = r;

            var size:Number = 2 * _radius;
            _dot.width = size;
            _dot.height = size;

            if (_hilite.visible) {
                _hilite.width = size + HILITE_RADIUS_BUFFER;
                _hilite.height = size + HILITE_RADIUS_BUFFER;
            } else {
                _hilite.width = size;
                _hilite.height = size;
            }

            var hitSize:Number = Math.max(size, 10);
            _hit.width = hitSize;
            _hit.height = hitSize;
        }
        public function get radius():Number {
            return _radius;
        }

        //-----------
        public function set angle(a:Number):void {
            _angle = a;
            x = Math.cos(_angle) * _trackRadius; 
            y = Math.sin(_angle) * _trackRadius; 
        }
        public function get angle():Number {
            return _angle;
        }

        //-----------
        public function set trackRadius(r:Number):void {
            _trackRadius = r;
            x = Math.cos(_angle) * _trackRadius; 
            y = Math.sin(_angle) * _trackRadius; 
        }
        public function get trackRadius():Number {
            return _trackRadius;
        }

        //-----------
        public function set color(c:uint):void {
            _color = c;
            draw();
        }
        public function get color():uint {
            return _color;
        }


        /***********************************
         ** PUBLIC
         ***********************************/


        /***********************************
         ** PRIVATE
         ***********************************/
        private function draw():void {
            _hilite.graphics.clear();
            _hilite.graphics.beginFill(_color, .5);
            _hilite.graphics.drawCircle(0, 0, 10);
            _hilite.graphics.beginFill(0x000000, .5);
            _hilite.graphics.drawCircle(0, 0, 10);
            
            _dot.graphics.clear();
            _dot.graphics.beginFill(_color, 1);
            _dot.graphics.drawCircle(0, 0, 10);
        }


        //------------------------
        // Mouse handlers
        //------------------------
        private function onMouseOver(e:MouseEvent):void {
            var application:WhoDev = ((root as SystemManager).application) as WhoDev;
            if (!_infoBox) {
                _infoBox = new FrogInfoBox(_data, _color);
                // Need to add info box at the top level for layering
                application.infoBoxes.rawChildren.addChild(_infoBox);
            }

            _infoBox.x = x;
            _infoBox.y = y - _infoBox.height;

            if (!_infoBox.visible || !_isSearchResult) {
                _infoBox.show();
            }

            hilite();

            // Bring to top of view stack
            parent.setChildIndex(this, parent.numChildren - 1);
            application.infoBoxes.setChildIndex(_infoBox,
                                                application.infoBoxes.numChildren - 1);
        }

        private function onMouseOut(e:MouseEvent):void {
            if (_isNarrowedSearchResult && _infoBox && _infoBox.visible) {
                return; 
            }
            if (_infoBox) {
                _infoBox.hide();
            }
            if (!_isSearchResult) {
                unhilite();
            }
        }

        //------------------------
        // Search handler
        //------------------------
        private function onSearchResult(e:SearchResultEvent):void {
            var appModel:ApplicationDataModel = ApplicationDataModel.getInstance();
            if (_data.name.search(e.searchTerm.toUpperCase()) > -1 && 
                e.searchTerm != "") {

                if (appModel.selectedStudio == _data.studio ||
                    appModel.selectedStudio == SelectStudioEvent.NO_STUDIO_SELECTED) {
                    if (e.results.length > 5) {
                        hilite();
                        if (_infoBox && _infoBox.visible) {
                            _infoBox.hide();
                        }
                        _isNarrowedSearchResult = false;
                    } else {
                        _isNarrowedSearchResult = true;
                        onMouseOver(null);
                    }
                    _isSearchResult = true;
                } else {
                    hilite();
                }
            } else {
                _isSearchResult = false;
                _isNarrowedSearchResult = false;
                onMouseOut(null);
            }
        }

        //------------------------
        // Select studio handler
        //------------------------
        private function onSelectStudio(e:SelectStudioEvent):void {
            if (_infoBox && _infoBox.visible && _isNarrowedSearchResult) {
                _infoBox.hide();
            }
        }

        //------------------------
        // Hilite
        //------------------------
        protected function hilite():void {
            var size:Number = 2 * _radius;
            _hilite.visible = true;
            Tweener.addTween(_hilite, {width: size + HILITE_RADIUS_BUFFER,
                                                  height: size + HILITE_RADIUS_BUFFER,
                                                  time: .3,
                                                  transition: "easeInOutCubic"});
        }

        protected function unhilite():void {       
            var size:Number = 2 * _radius;     
            Tweener.addTween(_hilite, {width: size, 
                                                  height: size,
                                                  time: .3,
                                                  transition: "easeInOutCubic",
                                                  onComplete: function():void {this.visible = false;}});
        }

        //------------------------
        // Tween angle
        //------------------------
        private function setFrogAngle(obj:Object, a:Number, 
                                      params:Array = null, info:Object = null):void {
            obj.angle = a;
        }

        private function getFrogAngle(obj:Object, params:Array = null, 
                                      info:Object = null):Number{
            return obj.angle;
        }

        //------------------------
        // Tween radius
        //------------------------
        private function setFrogRadius(obj:Object, r:Number, 
                                       params:Array = null, info:Object = null):void {
            obj.radius = r;
        }
        private function getFrogRadius(obj:Object, params:Array = null, 
                                       info:Object = null):Number{
            return obj.radius;
        }

        //------------------------
        // Tween track radius
        //------------------------
        private function setFrogTrackRadius(obj:Object, r:Number, 
                                            params:Array = null, info:Object = null):void {
            obj.trackRadius = r;
        }
        private function getFrogTrackRadius(obj:Object, params:Array = null, 
                                            info:Object = null):Number{
            return obj.trackRadius;
        }


    }
}
