package fl.text.container
{
   import fl.text.TLFTextField;
   import flash.desktop.Clipboard;
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.system.IME;
   import flash.text.engine.TextLine;
   import flashx.textLayout.container.ContainerController;
   import flashx.textLayout.container.ScrollPolicy;
   import flashx.textLayout.formats.BlockProgression;
   import flashx.textLayout.tlf_internal;
   
   use namespace tlf_internal;
   
   public class TLFContainerController extends ContainerController
   {
      
      private var _transparentBGButton:SimpleButton = null;
      
      private var _transparentBGButtonX:Number = NaN;
      
      private var _transparentBGButtonY:Number = NaN;
      
      private var _transparentBGButtonHeight:Number = NaN;
      
      private var _owner:TLFTextField;
      
      private var _transparentBGButtonWidth:Number = NaN;
      
      public function TLFContainerController(param1:Sprite, param2:TLFTextField)
      {
         this._owner = param2;
         super(param1);
      }
      
      override public function editHandler(param1:Event) : void
      {
         if((param1.type == Event.COPY || param1.type == Event.CUT) && this._owner.displayAsPassword)
         {
            return;
         }
         super.editHandler(param1);
         if((param1.type == Event.COPY || param1.type == Event.CUT) && !this._owner.useRichTextClipboard)
         {
            Clipboard.generalClipboard.clearData("TEXT_LAYOUT_MARKUP");
         }
      }
      
      override tlf_internal function attachTransparentBackgroundForHit(param1:Boolean) : void
      {
         var _loc2_:Sprite = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Boolean = false;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Graphics = null;
         if(attachTransparentBackground)
         {
            _loc2_ = container;
            if(_loc2_ != null)
            {
               if(param1)
               {
                  if(this._transparentBGButton != null)
                  {
                     Shape(this._transparentBGButton.hitTestState).graphics.clear();
                     this._transparentBGButtonX = this._transparentBGButtonY = this._transparentBGButtonWidth = this._transparentBGButtonHeight = NaN;
                  }
               }
               else
               {
                  if(this._transparentBGButton == null)
                  {
                     this._transparentBGButton = new SimpleButton();
                     this._transparentBGButton.focusRect = false;
                     this._transparentBGButton.tabEnabled = false;
                     this._transparentBGButton.addEventListener(MouseEvent.MOUSE_DOWN,this.abandonComposition,false,0,true);
                     this._transparentBGButton.useHandCursor = false;
                     this._transparentBGButton.hitTestState = new Shape();
                     _loc2_.addChildAt(this._transparentBGButton,0);
                  }
                  _loc3_ = tlf_internal::measureWidth ? Number(tlf_internal::contentWidth) : compositionWidth;
                  _loc4_ = tlf_internal::measureHeight ? Number(tlf_internal::contentHeight) : compositionHeight;
                  _loc5_ = tlf_internal::effectiveBlockProgression == BlockProgression.RL && horizontalScrollPolicy != ScrollPolicy.OFF;
                  _loc6_ = _loc5_ ? horizontalScrollPosition - _loc3_ : horizontalScrollPosition;
                  _loc7_ = verticalScrollPosition;
                  if(_loc6_ != this._transparentBGButtonX || _loc7_ != this._transparentBGButtonY || _loc3_ != this._transparentBGButtonWidth || _loc4_ != this._transparentBGButtonHeight)
                  {
                     _loc8_ = Shape(this._transparentBGButton.hitTestState).graphics;
                     _loc8_.clear();
                     if(_loc3_ != 0 && _loc4_ != 0)
                     {
                        _loc8_.beginFill(0);
                        _loc8_.drawRect(_loc6_,_loc7_,_loc3_,_loc4_);
                        _loc8_.endFill();
                     }
                     this._transparentBGButtonX = _loc6_;
                     this._transparentBGButtonY = _loc7_;
                     this._transparentBGButtonWidth = _loc3_;
                     this._transparentBGButtonHeight = _loc4_;
                  }
               }
            }
         }
      }
      
      public function get ownerField() : TLFTextField
      {
         return this._owner;
      }
      
      override protected function addTextLine(param1:TextLine, param2:int) : void
      {
         var _loc5_:Sprite = null;
         var _loc6_:DisplayObject = null;
         var _loc7_:Rectangle = null;
         super.addTextLine(param1,param2);
         var _loc3_:int = param1.numChildren;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = param1.getChildAt(_loc4_) as Sprite;
            if(!(_loc5_ == null || _loc5_.numChildren < 1))
            {
               _loc6_ = _loc5_.getChildAt(0);
               if(_loc6_.hasOwnProperty("ilg"))
               {
                  _loc7_ = _loc6_.getBounds(_loc5_);
                  _loc6_.x -= _loc7_.x;
                  _loc6_.y -= _loc7_.y;
               }
            }
            _loc4_++;
         }
      }
      
      override public function mouseWheelHandler(param1:MouseEvent) : void
      {
         if(!this._owner.mouseWheelEnabled)
         {
            return;
         }
         super.mouseWheelHandler(param1);
      }
      
      private function abandonComposition(param1:MouseEvent) : void
      {
         var _loc2_:Function = IME["compositionAbandoned"];
         if(IME["compositionAbandoned"] !== undefined)
         {
            _loc2_();
         }
      }
   }
}

