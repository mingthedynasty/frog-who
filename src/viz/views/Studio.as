package viz.views {

    import flash.display.Sprite;
    import flash.geom.Point;

    import mx.binding.utils.BindingUtils;    
    import mx.collections.XMLListCollection;
    
    import caurina.transitions.Tweener;
    
    import viz.data.ApplicationDataModel;
    import viz.events.SelectStudioEvent;
    import viz.framework.Arc;


    /***************************************
     **
     ** Studio
     **
     ***************************************/
    public class Studio extends Sprite {


        /***********************************
         ** VARIABLES
         ***********************************/
        private var _arc:Arc = null;
        
        private var _radius:Number = 0;
        private var _frogsSorted:Array = [];
        
        private var _data:XML;


        //-----------
        private static const DEFAULT_FROG_SIZE_FACTOR:Number = 230;
        private static const ZOOM_FROG_SIZE_FACTOR:Number = 140;


        /***********************************
         ** CONSTRUCTOR
         ***********************************/
        public function Studio() {

            // Set up arc
            _arc = new Arc(0, 0, -Math.PI/2, new Point(), 0x222222);
            addChild(_arc);

            BindingUtils.bindProperty(_arc, "radius", this, "radius");

            // Listen for studio select event
            ApplicationDataModel.getInstance().addEventListener(SelectStudioEvent.SELECT_STUDIO,
                                                                onSelectStudio);

            // Special tweening prop
            Tweener.registerSpecialProperty("studioRadius", 
                                            getStudioRadius, 
                                            setStudioRadius);
        }


        /***********************************
         ** GETTERS/SETTERS
         ***********************************/
        public function set data(data:XML):void {
            _data = data;

            var appModel:ApplicationDataModel = ApplicationDataModel.getInstance();
            var code:String = _data.code;
            var frogsData:XMLListCollection = 
                new XMLListCollection(appModel.frogData.source.(studio == code));

            radius = WhoDev.MAX_STUDIO_RADIUS - 
                (2 * (appModel.maxStudioCount - frogsData.length));
            initFrogs(frogsData);
        }

        //-----------
        [Bindable]
        public function set radius(r:Number):void {
            _radius = r;
        }
        public function get radius():Number {
            return _radius;
        }



        /***********************************
         ** PUBLIC
         ***********************************/
        public function show(delay:Number):void {
            Tweener.addTween(_arc, {arcAngle: 2 * Math.PI, 
                                    transition: "easeInOutCubic",
                                    time: 1, delay: delay});
            doLayout(true, delay);
        }
        

        /***********************************
         ** PRIVATE
         ***********************************/
        private function doLayout(animate:Boolean = false, delay:Number = 0, time:Number = 1):void {

            var appModel:ApplicationDataModel = ApplicationDataModel.getInstance();
            var hasSelection:Boolean = 
                appModel.selectedStudio != SelectStudioEvent.NO_STUDIO_SELECTED;

            var code:String = _data.code;
            var angleStep:Number;
            var currAng:Number = -Math.PI/2;
            var i:int;
            var j:int;
            var frog:Frog;
            var frogsData:XMLListCollection = 
                new XMLListCollection(appModel.frogData.source.(studio == code));                
            var studioRadius:Number;
            var frogRadius:Number;
                
            if (hasSelection) {
                studioRadius = (appModel.maxStudioCount * 13)/(2 * Math.PI);
                angleStep = (2 * Math.PI)/frogsData.length;

                if (animate) {
                    Tweener.addTween(this, {studioRadius: studioRadius,
                                                              time: time,//.5,
                                                              transition: "easeInOutQuad",
                                                              delay: delay});
                } else {
                    radius = studioRadius;
                }

                for (i = 0; i < _frogsSorted.length; i++) {
                    for (j = 0; j < _frogsSorted[i].frogs.length; j++) {
                        frog = _frogsSorted[i].frogs[j];
                        frogRadius = Math.round((appModel.maxFrogId - frog.data.id)/ZOOM_FROG_SIZE_FACTOR) + 3;
                        if (animate) {
                            Tweener.addTween(frog, {angle: currAng, 
                                                    radius: frogRadius,
                                                    transition: "easeInOutQuad",
                                                               time: time, //.5, 
                                                    delay: delay});
                        } else {
                            frog.angle = currAng;
                            frog.radius = frogRadius;
                        }
                        currAng += angleStep;
                    }
                }            
            } else {
                angleStep = ApplicationDataModel.getInstance().angleStep;
                var startAng:Number;

                studioRadius = WhoDev.MAX_STUDIO_RADIUS - 
                    (2 * (appModel.maxStudioCount - frogsData.length));
                if (animate) {
                    Tweener.addTween(this, {studioRadius: studioRadius,
                                                              time: time,//.5,
                                                              transition: "easeInOutQuad",
                                                              delay: delay});
                } else {
                    radius = studioRadius;
                }

                for (i = 0; i < _frogsSorted.length; i++) {
                    startAng = currAng;
                    for (j = 0; j < _frogsSorted[i].frogs.length; j++) {
                        frog = _frogsSorted[i].frogs[j];
                        frogRadius = Math.round((appModel.maxFrogId - frog.data.id)/DEFAULT_FROG_SIZE_FACTOR) + 1;
                        if (animate) {
                            Tweener.addTween(frog, {angle: currAng, 
                                                               radius: frogRadius,
                                                               transition: "easeInOutCubic",
                                                               time: time, //1, 
                                                               delay: delay,
                                                               onStart: function():void {this.visible = true}});
                        } else {
                            frog.angle = currAng;
                            frog.radius = frogRadius;
                            frog.visible = true;
                        }
                        currAng += angleStep;
                    }
                    currAng = startAng + _frogsSorted[i].data.max * angleStep;                    
                }            
            }    
        }


        //-----------
        private function initFrogs(frogsData:XMLListCollection):void {
            var deptData:XMLListCollection = 
                ApplicationDataModel.getInstance().departmentData;
            var maxId:Number = ApplicationDataModel.getInstance().maxFrogId;
            for each (var deptXML:XML in deptData) {
                var dept:String = deptXML.code;
                var deptColor:uint = deptXML.color;
                var departmentFrogs:XMLList = frogsData.source.(department == dept);
                var deptInfo:Object = {};
                var frogArray:Array = [];
                deptInfo.data = deptXML;
                    
                for each (var frogXML:XML in departmentFrogs) {
                    var rad:Number = Math.round((maxId - frogXML.id)/DEFAULT_FROG_SIZE_FACTOR) + 1;
                    var frog:Frog = new Frog(rad, -Math.PI/2, _radius, deptColor);
                    BindingUtils.bindProperty(frog, "trackRadius", this, "radius");
                    frog.visible = false;
                    frog.data = frogXML;
                    addChild(frog);
                    frogArray.push(frog);
                }
                deptInfo.frogs = frogArray;
                _frogsSorted.push(deptInfo);
            }
        }

        //-----------
        private function onSelectStudio(e:SelectStudioEvent):void {
            var appModel:ApplicationDataModel = ApplicationDataModel.getInstance();
            if (e.studioCode == _data.code) {
                visible = true;
                Tweener.addTween(this, {alpha: 1, 
                                        time: 1,
                                        onComplete: function():void { appModel.searchAgain(); }});
                if (e.prevCode == SelectStudioEvent.NO_STUDIO_SELECTED) {
                    doLayout(true, .5, .5);
                } else {
                    doLayout(false, 0, .5);
                }
            } else if (e.studioCode == SelectStudioEvent.NO_STUDIO_SELECTED) {
                visible = true;
                if (e.prevCode == _data.code) {
                    doLayout(true, 0, .5);                    
                    Tweener.addTween(this, {x: x, 
                                            time: 1.3,
                                            onComplete: function():void { appModel.searchAgain(); }});

                } else {
                    doLayout(false, 0, .5);
                    Tweener.addTween(this, {alpha: 1, 
                                            time: 1,
                                            delay: .5,
                                            transition: "easeInOutQuad"});  
                }
            } else {
                Tweener.addTween(this, {alpha: 0, 
                                        time: 1,
                                        onComplete: function():void { this.visible = false;}});                
            }
        }

        //------------------------
        // Tweening radius
        //------------------------
        protected function setStudioRadius(obj:Object, r:Number, 
                                           params:Array = null, info:Object = null):void {
            obj.radius = r;
        }
        protected function getStudioRadius(obj:Object, params:Array = null, 
                                           info:Object = null):Number{
            return obj._radius;
        }

    }
}

