package
{
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.text.TextField;
   import flash.ui.Keyboard;
   import flash.ui.Mouse;
   import flash.ui.MouseCursor;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol93")]
   public class PlayerAdd extends MovieClip
   {
      
      public static const EMPTY:String = "Player not selected";
      
      public static const INIT:String = "Player is initialized";
      
      public static const READY:String = "Player is ready";
      
      public var setKeyRight:MovieClip;
      
      public var setKeyLeft:MovieClip;
      
      public var keyToToggle:TextField;
      
      public var left_txt:TextField;
      
      public var right_txt:TextField;
      
      public var player_txt:TextField;
      
      private var alpha_none:Number = 0.25;
      
      private var alpha_over:Number = 0.625;
      
      private var alpha_full:Number = 1;
      
      private var player:Player;
      
      private var status:String;
      
      private var toggleKey:uint;
      
      private var home:HomeController;
      
      private var settingLeft:Boolean;
      
      private var settingRight:Boolean;
      
      private var controlsSet:Boolean;
      
      public var eventDispatcher:EventDispatcher = new EventDispatcher();
      
      public function PlayerAdd()
      {
         super();
         this.player_txt.alpha = this.alpha_none;
         this.setKeyLeft.visible = false;
         this.settingLeft = false;
         this.setKeyRight.visible = false;
         this.settingRight = false;
         this.controlsSet = false;
         this.status = PlayerAdd.EMPTY;
         this.home = null;
         this.player_txt.addEventListener(MouseEvent.MOUSE_OVER,this.handleMouseOver);
         this.keyToToggle.addEventListener(MouseEvent.MOUSE_OVER,this.handleMouseOver);
         this.player_txt.addEventListener(MouseEvent.MOUSE_OUT,this.handleMouseOut);
         this.keyToToggle.addEventListener(MouseEvent.MOUSE_OUT,this.handleMouseOut);
         this.player_txt.addEventListener(MouseEvent.CLICK,this.handleClick);
         this.keyToToggle.addEventListener(MouseEvent.CLICK,this.handleClick);
         this.left_txt.addEventListener(MouseEvent.MOUSE_OVER,this.handleMouseOverLeft);
         this.left_txt.addEventListener(MouseEvent.MOUSE_OUT,this.handleMouseOutLeft);
         this.left_txt.addEventListener(MouseEvent.CLICK,this.handleClickLeft);
         this.right_txt.addEventListener(MouseEvent.MOUSE_OVER,this.handleMouseOverRight);
         this.right_txt.addEventListener(MouseEvent.MOUSE_OUT,this.handleMouseOutRight);
         this.right_txt.addEventListener(MouseEvent.CLICK,this.handleClickRight);
      }
      
      private function handleMouseOverLeft(param1:MouseEvent) : void
      {
         if(!this.home.isControlLocked(this))
         {
            if(this.status == PlayerAdd.READY)
            {
               this.left_txt.alpha = this.alpha_over;
               Mouse.cursor = MouseCursor.BUTTON;
            }
         }
      }
      
      private function handleMouseOutLeft(param1:MouseEvent) : void
      {
         if(!this.home.isControlLocked(this))
         {
            if(this.status == PlayerAdd.EMPTY)
            {
               this.left_txt.alpha = this.alpha_none;
            }
            else
            {
               this.left_txt.alpha = this.alpha_full;
            }
            Mouse.cursor = MouseCursor.AUTO;
         }
      }
      
      private function handleMouseOverRight(param1:MouseEvent) : void
      {
         if(!this.home.isControlLocked(this))
         {
            if(this.status == PlayerAdd.READY)
            {
               this.right_txt.alpha = this.alpha_over;
               Mouse.cursor = MouseCursor.BUTTON;
            }
         }
      }
      
      private function handleMouseOutRight(param1:MouseEvent) : void
      {
         if(!this.home.isControlLocked(this))
         {
            if(this.status == PlayerAdd.EMPTY)
            {
               this.right_txt.alpha = this.alpha_none;
            }
            else
            {
               this.right_txt.alpha = this.alpha_full;
            }
            Mouse.cursor = MouseCursor.AUTO;
         }
      }
      
      private function handleClickLeft(param1:MouseEvent) : void
      {
         if(!this.home.isControlLocked(this) && !this.settingLeft && !this.settingRight && this.status == PlayerAdd.READY)
         {
            this.setKeyLeft.visible = true;
            this.settingLeft = true;
            this.settingRight = false;
            this.home.lockControl(this);
            this.status = PlayerAdd.INIT;
         }
      }
      
      private function handleClickRight(param1:MouseEvent) : void
      {
         if(!this.home.isControlLocked(this) && !this.settingLeft && !this.settingRight && this.status == PlayerAdd.READY)
         {
            this.setKeyRight.visible = true;
            this.settingLeft = false;
            this.settingRight = true;
            this.home.lockControl(this);
            this.status = PlayerAdd.INIT;
         }
      }
      
      public function silent() : void
      {
         stage.removeEventListener(KeyboardEvent.KEY_UP,this.handleKeyUp);
         this.setKeyLeft.visible = false;
         this.settingLeft = false;
         this.setKeyRight.visible = false;
         this.settingRight = false;
         if(this.status == PlayerAdd.READY)
         {
            this.player_txt.alpha = this.alpha_full;
            this.left_txt.alpha = this.alpha_full;
            this.right_txt.alpha = this.alpha_full;
         }
         else
         {
            this.status = PlayerAdd.EMPTY;
            this.player_txt.alpha = this.alpha_none;
            this.left_txt.alpha = this.alpha_none;
            this.right_txt.alpha = this.alpha_none;
         }
      }
      
      public function listen() : void
      {
         stage.addEventListener(KeyboardEvent.KEY_UP,this.handleKeyUp);
      }
      
      private function handleClick(param1:MouseEvent) : void
      {
         if(!this.home.isControlLocked(this))
         {
            if(this.status == PlayerAdd.EMPTY)
            {
               this.player_txt.alpha = this.alpha_full;
               this.left_txt.alpha = this.alpha_full;
               this.right_txt.alpha = this.alpha_full;
               this.home.lockControl(this);
               this.settingLeft = true;
               this.settingRight = true;
               this.prepareSetLeft();
               this.status = PlayerAdd.INIT;
            }
            else if(this.status == PlayerAdd.READY)
            {
               this.player.setActive(false);
               this.player_txt.alpha = this.alpha_none;
               this.left_txt.alpha = this.alpha_none;
               this.right_txt.alpha = this.alpha_none;
               this.status = PlayerAdd.EMPTY;
               this.home.openControl(this);
               this.left_txt.text = "";
               this.right_txt.text = "";
            }
         }
      }
      
      private function prepareSetLeft() : void
      {
         this.setKeyLeft.visible = true;
         this.setKeyRight.visible = false;
      }
      
      private function prepareSetRight() : void
      {
         this.setKeyLeft.visible = false;
         this.setKeyRight.visible = true;
      }
      
      private function handleKeyUp(param1:KeyboardEvent) : void
      {
         if(!this.home.isControlLocked(this))
         {
            if(param1.keyCode != Keyboard.SPACE && param1.keyCode != Keyboard.ESCAPE && this.status == PlayerAdd.INIT)
            {
               if(this.settingLeft)
               {
                  this.player.setLeftKey(param1.keyCode);
                  this.left_txt.text = this.getKeyFromCharCode(param1.charCode,param1.keyCode);
                  this.settingLeft = false;
                  if(!this.settingRight)
                  {
                     this.status = PlayerAdd.READY;
                     this.setKeyLeft.visible = false;
                     this.home.openControl(this);
                  }
                  else
                  {
                     this.prepareSetRight();
                  }
               }
               else if(this.settingRight)
               {
                  this.player.setRightKey(param1.keyCode);
                  this.right_txt.text = this.getKeyFromCharCode(param1.charCode,param1.keyCode);
                  this.settingRight = false;
                  this.setKeyRight.visible = false;
                  this.status = PlayerAdd.READY;
                  this.player.setActive(true);
                  this.controlsSet = true;
                  this.home.openControl(this);
               }
            }
            else if(this.status == PlayerAdd.EMPTY && param1.keyCode == this.toggleKey)
            {
               this.player_txt.alpha = this.alpha_full;
               this.left_txt.alpha = this.alpha_full;
               this.right_txt.alpha = this.alpha_full;
               this.status = PlayerAdd.INIT;
               this.home.lockControl(this);
               this.settingLeft = true;
               this.settingRight = true;
               this.prepareSetLeft();
               this.home.lockControl(this);
            }
            else if(this.status == PlayerAdd.READY && param1.keyCode == this.toggleKey)
            {
               this.player.setActive(false);
               this.player_txt.alpha = this.alpha_none;
               this.left_txt.alpha = this.alpha_none;
               this.right_txt.alpha = this.alpha_none;
               this.status = PlayerAdd.EMPTY;
               this.left_txt.text = "";
               this.right_txt.text = "";
            }
         }
      }
      
      private function handleMouseOver(param1:MouseEvent) : void
      {
         if(!this.home.isControlLocked(this) && !this.settingLeft && !this.settingRight)
         {
            this.player_txt.alpha = this.alpha_over;
            this.left_txt.alpha = this.alpha_over;
            this.right_txt.alpha = this.alpha_over;
            Mouse.cursor = MouseCursor.BUTTON;
         }
      }
      
      private function handleMouseOut(param1:MouseEvent) : void
      {
         if(!this.home.isControlLocked(this))
         {
            if(this.status == PlayerAdd.EMPTY)
            {
               this.player_txt.alpha = this.alpha_none;
               this.left_txt.alpha = this.alpha_none;
               this.right_txt.alpha = this.alpha_none;
            }
            else
            {
               this.player_txt.alpha = this.alpha_full;
               this.left_txt.alpha = this.alpha_full;
               this.right_txt.alpha = this.alpha_full;
            }
            Mouse.cursor = MouseCursor.AUTO;
         }
      }
      
      public function addPlayer(param1:Player, param2:uint, param3:HomeController) : void
      {
         this.player = param1;
         this.toggleKey = param2;
         this.home = param3;
         this.keyToToggle.text = String.fromCharCode(param2);
         var _loc4_:uint = param1.getColor();
         var _loc5_:Number = _loc4_ % 256 / 256;
         _loc4_ /= 256;
         var _loc6_:Number = _loc4_ % 256 / 256;
         _loc4_ /= 256;
         var _loc7_:Number = _loc4_ % 256 / 256;
         var _loc8_:ColorTransform = new ColorTransform(_loc7_,_loc6_,_loc5_);
         this.player_txt.transform.colorTransform = _loc8_;
         this.left_txt.transform.colorTransform = _loc8_;
         this.right_txt.transform.colorTransform = _loc8_;
         this.keyToToggle.transform.colorTransform = _loc8_;
         this.player_txt.text = this.player.getName();
         this.player_txt.alpha = this.alpha_none;
         stage.addEventListener(KeyboardEvent.KEY_UP,this.handleKeyUp);
      }
      
      private function getKeyFromCharCode(param1:uint, param2:uint) : String
      {
         var _loc3_:String = "";
         _loc3_ = this.getStringFromKeyCode(param2);
         if(_loc3_ == "")
         {
            _loc3_ = String.fromCharCode(param1);
         }
         return _loc3_.toUpperCase();
      }
      
      private function getStringFromKeyCode(param1:uint) : String
      {
         switch(param1)
         {
            case Keyboard.BACKSPACE:
               return "BACKSPACE";
            case Keyboard.CAPS_LOCK:
               return "CAPS LOCK";
            case Keyboard.CONTROL:
               return "CTRL";
            case Keyboard.DELETE:
               return "DELETE";
            case Keyboard.DOWN:
               return "DOWN";
            case Keyboard.ENTER:
               return "ENTER";
            case Keyboard.END:
               return "END";
            case Keyboard.F1:
               return "F1";
            case Keyboard.F2:
               return "F2";
            case Keyboard.F3:
               return "F3";
            case Keyboard.F4:
               return "F4";
            case Keyboard.F5:
               return "F5";
            case Keyboard.F6:
               return "F6";
            case Keyboard.F6:
               return "F6";
            case Keyboard.F7:
               return "F7";
            case Keyboard.F8:
               return "F8";
            case Keyboard.F9:
               return "F9";
            case Keyboard.F10:
               return "F10";
            case Keyboard.F11:
               return "F11";
            case Keyboard.F12:
               return "F12";
            case Keyboard.F13:
               return "F13";
            case Keyboard.F14:
               return "F14";
            case Keyboard.F15:
               return "F15";
            case Keyboard.HOME:
               return "HOME";
            case Keyboard.INSERT:
               return "INSERT";
            case Keyboard.LEFT:
               return "LEFT";
            case Keyboard.NUMPAD_ENTER:
               return "NUM ENTER";
            case Keyboard.PAGE_DOWN:
               return "PAGE DOWN";
            case Keyboard.PAGE_UP:
               return "PAGE UP";
            case Keyboard.RIGHT:
               return "RIGHT";
            case Keyboard.SHIFT:
               return "SHIFT";
            case Keyboard.TAB:
               return "TAB";
            case Keyboard.UP:
               return "UP";
            default:
               return "";
         }
      }
   }
}

