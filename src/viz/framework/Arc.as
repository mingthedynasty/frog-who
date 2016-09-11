package viz.framework {

    import flash.display.Sprite;
    import flash.geom.Point;
    
    import caurina.transitions.Tweener;


    /***************************************
     **
     ** Arc
     **
     ***************************************/
    public class Arc extends Sprite {


        /***********************************
         ** VARIABLES
         ***********************************/
        private var _radius:Number = 0;
        private var _angle:Number = 0;
        private var _startAngle:Number = 0;        
        private var _center:Point = new Point();
        
        private var _color:uint = 0x666666;
        

        /***********************************
         ** CONSTRUCTOR
         ***********************************/
        public function Arc(radius:Number = 0, angle:Number = 0, 
                            startAngle:Number = 0, 
                            center:Point = null, color:uint = 0x666666) {

            // Set up variables
            _radius = radius;
            _angle = angle;
            _startAngle = startAngle;
            _center = center;
            _color = color;
            
            drawArc();


            // Set up tween properties
            Tweener.registerSpecialProperty("arcAngle", 
                                            getArcAngle, 
                                            setArcAngle);
            Tweener.registerSpecialProperty("arcRadius", 
                                            getArcRadius, 
                                            setArcRadius);
        }


        /***********************************
         ** GETTERS/SETTERS
         ***********************************/
        public function set radius(r:Number):void {
            _radius = r;
            drawArc();
        }
        public function get radius():Number {
            return _radius;
        }
        
        //-----------
        public function set angle(a:Number):void {
            _angle = a;
            drawArc();
        }
        public function get angle():Number {
            return _angle;
        }
        
        //-----------
        public function set startAngle(a:Number):void {
            _startAngle = a;
            drawArc();
        }
        public function get startAngle():Number {
            return _startAngle;
        }
        
        //-----------
        public function set center(pt:Point):void {
            _center = pt;
            drawArc();
        }
        public function get center():Point {
            return _center;
        }
        
        //-----------
        public function set color(c:uint):void {
            _color = c;
            drawArc();
        }
        public function get color():uint {
            return _color;
        }

        /***********************************
         ** PRIVATE
         ***********************************/
        private function drawArc():void {
            
            if (!(_radius && _angle) ) { 
                graphics.clear();
                return;
            }

            var segAngle:Number;
            var angle:Number;
            var angleMid:Number;
            var numOfSegs:Number;
            var ax:Number;
            var ay:Number;
            var bx:Number;
            var by:Number;
            var cx:Number;
            var cy:Number;
            
            // Wipe the slate clean
            graphics.clear();
            graphics.lineStyle(1, _color);
            
            // No need to draw more than 360
            if (Math.abs(_angle) > 2 * Math.PI) {
                _angle = 2 * Math.PI;
            }
            
            numOfSegs = Math.ceil(Math.abs(_angle)/(Math.PI/4));
            segAngle = _angle/numOfSegs;
            angle = _startAngle;
            
            // Calculate the start point
            ax = _center.x + Math.cos(angle) * _radius;
            ay = _center.y + Math.sin(angle) * _radius;
            
            // Move the pen
            graphics.moveTo(ax, ay);
            
            for(var i:int = 0; i < numOfSegs; i++) {
                // Increment the angle
                angle += segAngle;
                
                // The angle halfway between the last and the new
                angleMid = angle - (segAngle/2);
                
                // Calculate the end point
                bx = Math.cos(angle) * _radius;
                by = Math.sin(angle) * _radius;
                
                // Calculate the control point
                cx = Math.cos(angleMid) * (_radius/Math.cos(segAngle/2));
                cy = Math.sin(angleMid) * (_radius/Math.cos(segAngle/2));
                
                // Draw out the segment
                graphics.curveTo(cx, cy, bx, by);
            }
        }
        
        
        /***********************************
         ** PRIVATE
         ***********************************/
        //------------------------
        // Tween arc angle
        //------------------------
        private function setArcAngle(obj:Object, a:Number, 
                                     params:Array = null, info:Object = null):void {
            obj.angle = a;
        }
        private function getArcAngle(obj:Object, params:Array = null, 
                                     info:Object = null):Number{
            return obj._angle;
        }
        
        //------------------------
        // Tween arc radius
        //------------------------
        private function setArcRadius(obj:Object, r:Number, 
                                      params:Array = null, info:Object = null):void {
            obj.radius = r;
        }
        private function getArcRadius(obj:Object, params:Array = null, 
                                      info:Object = null):Number{
            return obj._radius;
        }
    }
}
