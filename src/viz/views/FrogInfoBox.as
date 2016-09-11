package viz.views {

    import flash.display.Bitmap;
    import flash.display.DisplayObjectContainer;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.MouseEvent;
    import flash.events.TextEvent;
    import flash.net.URLRequest;
    import flash.text.*;

    import caurina.transitions.Tweener;

    import viz.AssetManager;

    
    /***************************************
     **
     ** FrogInfoBox
     **
     ***************************************/
    public class FrogInfoBox extends Sprite {


        /***********************************
         ** VARIABLES
         ***********************************/
        private var _displayName:String = "";
        private var _fileName:String = "";
        private var _image:Sprite;
        private var _info:Sprite;

        private var _data:XML;
        
        //-----------
        private static const INFO_BOX_WIDTH:Number = 175;
        private static const INFO_BOX_HEIGHT:Number = 70;
        private static const INFO_BOX_IMAGE_SIZE:Number = 45;


        private static const BASE_URL:String = 
            "http://frogpond.frogdesign.com/pond_profile/photos/";



        /***********************************
         ** CONSTRUCTOR
         ***********************************/
        public function FrogInfoBox(data:XML, color:uint) {
            _data = data;

            mouseEnabled = false;
            mouseChildren = false;

            // Initialize
            initNames();
            initImage();
            initInfo();

            // Draw Background
            var w:Number = Math.max(INFO_BOX_WIDTH, _info.width + _info.x + 10);
            graphics.beginFill(0x000000, .9);
            graphics.lineStyle(1, color);
            graphics.drawRoundRect(0, 0, w, INFO_BOX_HEIGHT, 10);

            visible = false;
        }


        /***********************************
         ** GETTERS/SETTERS
         ***********************************/


        /***********************************
         ** PUBLIC
         ***********************************/
        public function show():void {
            alpha = 0;
            _image.alpha = 0;
            visible = true;

            Tweener.addTween(this, {alpha: 1, time: .3,transition: "easeInOutCubic"});
            Tweener.addTween(_image, {alpha: 1, time: .5, transition: "easeInOutCubic"});
        }

        public function hide():void {
            Tweener.addTween(this, {alpha: 0, time: .3, transition: "easeInOutCubic",
                                               onComplete: function():void { this.visible = false}});
        }



        /***********************************
         ** PRIVATE
         ***********************************/
        //------------------------
        // Initialization
        //------------------------
        private function initNames():void {
            _displayName = "";
            _fileName = "";
            var names:Array = (_data.name.toLowerCase()).split(" ");
            var n:String = "";
            for (var i:int = 0; i < names.length; i++) {
                var c:String = names[i].charAt(0).toUpperCase();
                n += c + names[i].substring(1, names[i].length) + " ";
                _displayName += c + names[i].substring(1, names[i].length) + " ";
                _fileName += c + names[i].substring(1, names[i].length);
            }
        }


        //-----------
        private function initInfo():void {
            _info = new Sprite();
            initTextField(_displayName, 
                          "bentonMedium", 11, 0xBABABA,
                          _info, 0, 0);
            initTextField(_data.department,
                          "benton", 10, 0xBABABA,
                          _info, 0, 14);
            initTextField(_data.id,
                          "benton", 10, 0xBABABA,
                          _info, 0, 28);

            _info.x = _image.x * 2 + INFO_BOX_IMAGE_SIZE;
            _info.y = Math.round((INFO_BOX_HEIGHT - _info.height)/2) - 3;
            
            addChild(_info);
        }


        //-----------
        private function initImage():void {
            _image = new Sprite();
            _image.y = Math.round((INFO_BOX_HEIGHT - INFO_BOX_IMAGE_SIZE - 1)/2);
            _image.x = _image.y;
            _image.alpha = 0;

            // Loader
            var loader:Loader = new Loader();
            var request:URLRequest = new URLRequest(BASE_URL + _fileName + ".jpg");
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadImage);
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, 
                                                      onLoadImageError);
            loader.load(request);
            loader.alpha = 0;
            _image.addChild(loader);


            // Mask
            var imageMask:Sprite = new Sprite();
            imageMask.graphics.beginFill(0xFF0000, 1);
            imageMask.graphics.drawRoundRect(0, 0, 
                                             INFO_BOX_IMAGE_SIZE, INFO_BOX_IMAGE_SIZE, 
                                             8);
            _image.addChild(imageMask);
            _image.mask = imageMask;


            addChild(_image);
        }

        //------------------------
        // Handlers
        //------------------------
        private function onLoadImage(e:Event):void {
            var loaderInfo:LoaderInfo = e.target as LoaderInfo;
            var ratio:Number = loaderInfo.width/loaderInfo.height;
            var loader:Loader = loaderInfo.loader;

            if (ratio > 1) {
                loader.height = INFO_BOX_IMAGE_SIZE;
                loader.scaleX = loader.scaleY;
                loader.x = Math.round((INFO_BOX_IMAGE_SIZE - loader.width)/2);
            } else {
                loader.width = INFO_BOX_IMAGE_SIZE;
                loader.scaleY = loader.scaleX;
                loader.y = Math.round((INFO_BOX_IMAGE_SIZE - loader.height)/2);
            }
            Tweener.addTween(loader, {alpha: 1, time: .5, transition: "easeInOutCubic"});
        }


        private function onLoadImageError(e:Event):void {
            var bitmap:Bitmap = (new AssetManager.FRIEDOLIN() as Bitmap);
            bitmap.y = Math.round((INFO_BOX_IMAGE_SIZE - bitmap.height)/2);
            _image.addChild(bitmap);
        }            


        //------------------------
        // Utils
        //------------------------
        private function initTextField(text:String, font:String, fontSize:Number, 
                                       fontColor:uint, owner:DisplayObjectContainer,
                                       nx:Number, ny:Number):TextField {
                                       
            var field:TextField = new TextField();
            field.autoSize = TextFieldAutoSize.LEFT;
            field.embedFonts = true;
            field.antiAliasType = AntiAliasType.ADVANCED;
            field.selectable = false;

            var format:TextFormat = new TextFormat();
            format.font = font;
            format.color = fontColor;
            format.size = fontSize;

            field.defaultTextFormat = format;
            field.text = text;
            field.x = nx;
            field.y = ny;

            owner.addChild(field);

            return field;
        }

    }
}
