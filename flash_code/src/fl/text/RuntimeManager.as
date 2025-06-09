package fl.text
{
   import fl.timeline.TimelineManager;
   import fl.timeline.timelineManager.InstanceInfo;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.text.TextFieldType;
   import flash.text.engine.FontDescription;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import flashx.textLayout.container.ContainerController;
   import flashx.textLayout.conversion.TextConverter;
   import flashx.textLayout.edit.EditingMode;
   import flashx.textLayout.elements.Configuration;
   import flashx.textLayout.elements.FlowLeafElement;
   import flashx.textLayout.elements.GlobalSettings;
   import flashx.textLayout.elements.InlineGraphicElement;
   import flashx.textLayout.elements.InlineGraphicElementStatus;
   import flashx.textLayout.elements.TextFlow;
   import flashx.textLayout.events.StatusChangeEvent;
   import flashx.textLayout.tlf_internal;
   
   use namespace tlf_internal;
   
   public class RuntimeManager extends TimelineManager
   {
      
      private static var singleton:RuntimeManager = new RuntimeManager();
      
      private var fontSymbolMap:Dictionary;
      
      public function RuntimeManager()
      {
         super();
         _supportNextPrevAcrossFrames = true;
      }
      
      public static function ColorStringToUint(param1:String) : uint
      {
         if(param1.substr(0,1) == "#")
         {
            param1 = "0x" + param1.substr(1);
         }
         return uint(param1);
      }
      
      public static function getSingleton() : RuntimeManager
      {
         return singleton;
      }
      
      private function fontMapper(param1:FontDescription) : void
      {
         var _loc2_:* = "[\'" + param1.fontName + "\',\'" + param1.fontWeight + "\',\'" + param1.fontPosture + "\']";
         var _loc3_:Array = this.fontSymbolMap[_loc2_];
         if(_loc3_ != null)
         {
            param1.fontName = _loc3_[0];
            param1.fontWeight = _loc3_[1];
            param1.fontPosture = _loc3_[2];
         }
      }
      
      public function addFontMapEntry(param1:String, param2:Array) : void
      {
         if(this.fontSymbolMap == null)
         {
            this.fontSymbolMap = new Dictionary();
         }
         this.fontSymbolMap[param1] = param2;
      }
      
      private function getInstanceForInfoInternal(param1:InstanceInfo) : DisplayObject
      {
         var _loc6_:TextFlow = null;
         var _loc13_:Object = null;
         var _loc14_:Object = null;
         var _loc15_:InstanceInfo = null;
         var _loc16_:Boolean = false;
         if(this.fontSymbolMap != null)
         {
            GlobalSettings.fontMapperFunction = this.fontMapper;
         }
         var _loc2_:TLFTextField = new TLFTextField();
         _loc2_.tlf_internal::contentWidth = 0;
         _loc2_.tlf_internal::contentHeight = 0;
         var _loc3_:XML = param1.data;
         var _loc4_:String = _loc3_.@type;
         var _loc5_:String = _loc3_.@editPolicy;
         if(_loc5_ == null || _loc5_.length == 0)
         {
            _loc5_ = EditingMode.READ_WRITE;
         }
         var _loc7_:int = 0;
         var _loc8_:Boolean = false;
         var _loc9_:InstanceInfo = param1;
         while(_loc9_.prev != null)
         {
            _loc7_++;
            _loc9_ = _loc9_.prev;
         }
         if(param1.prev != null)
         {
            _loc6_ = TextFlow(TLFTextField(_loc9_.content).textFlow);
         }
         else
         {
            _loc6_ = TextConverter.importToFlow(param1.data,TextConverter.TEXT_LAYOUT_FORMAT);
            _loc8_ = true;
         }
         _loc2_.textFlow = _loc6_;
         var _loc10_:FlowLeafElement = _loc6_.getFirstLeaf();
         while(_loc10_)
         {
            if(_loc10_ as InlineGraphicElement)
            {
               _loc13_ = _loc10_.userStyles;
               _loc14_ = _loc13_["customSource"];
               _loc15_ = _loc9_;
               _loc16_ = false;
               while(Boolean(_loc15_) && !_loc16_)
               {
                  if(_loc15_.extraInfo != undefined && _loc15_.extraInfo[_loc14_] != null)
                  {
                     _loc16_ = true;
                     _loc13_["extraInfo"] = _loc15_.extraInfo;
                     _loc10_.userStyles = _loc13_;
                  }
                  _loc15_ = _loc15_.next;
               }
            }
            _loc10_ = _loc10_.getNextLeaf();
         }
         Configuration(_loc6_.configuration).inlineGraphicResolverFunction = this.resolveInlines;
         var _loc11_:ContainerController = ContainerController(_loc2_.controller);
         _loc6_.flowComposer.addControllerAt(_loc11_,_loc7_);
         if(_loc8_)
         {
            _loc2_.type = TextFieldType.DYNAMIC;
            _loc2_.selectable = false;
            switch(_loc5_)
            {
               case EditingMode.READ_WRITE:
                  _loc2_.type = TextFieldType.INPUT;
                  _loc2_.selectable = true;
                  break;
               case EditingMode.READ_SELECT:
                  _loc2_.type = TextFieldType.DYNAMIC;
                  _loc2_.selectable = true;
            }
         }
         if(_loc4_ == "Paragraph")
         {
            _loc2_.tlf_internal::isPointText = false;
            _loc2_.width = param1.bounds.width;
            _loc2_.height = param1.bounds.height;
            _loc11_.setCompositionSize(param1.bounds.width,param1.bounds.height);
         }
         else
         {
            _loc2_.tlf_internal::isPointText = true;
            _loc11_.setCompositionSize(NaN,NaN);
         }
         var _loc12_:String = _loc3_.@columnCount;
         if(_loc12_ != null && _loc12_.length > 0)
         {
            _loc2_.columnCount = _loc12_;
         }
         _loc12_ = _loc3_.@columnGap;
         if(_loc12_ != null && _loc12_.length > 0)
         {
            _loc2_.columnGap = Number(_loc12_);
         }
         _loc12_ = _loc3_.@verticalAlign;
         if(_loc12_ != null && _loc12_.length > 0)
         {
            _loc2_.verticalAlign = _loc12_;
         }
         _loc12_ = _loc3_.@background;
         if(_loc12_ != null && _loc12_.length > 0)
         {
            _loc2_.background = _loc12_.toLowerCase() == "true";
         }
         _loc12_ = _loc3_.@backgroundColor;
         if(_loc12_ != null && _loc12_.length > 0)
         {
            _loc2_.backgroundColor = ColorStringToUint(_loc12_);
         }
         _loc12_ = _loc3_.@backgroundAlpha;
         if(_loc12_ != null && _loc12_.length > 0)
         {
            _loc2_.backgroundAlpha = Number(_loc12_);
         }
         _loc12_ = _loc3_.@border;
         if(_loc12_ != null && _loc12_.length > 0)
         {
            _loc2_.border = _loc12_.toLowerCase() == "true";
         }
         _loc12_ = _loc3_.@borderColor;
         if(_loc12_ != null && _loc12_.length > 0)
         {
            _loc2_.borderColor = ColorStringToUint(_loc12_);
         }
         _loc12_ = _loc3_.@borderAlpha;
         if(_loc12_ != null && _loc12_.length > 0)
         {
            _loc2_.borderAlpha = Number(_loc12_);
         }
         _loc12_ = _loc3_.@borderWidth;
         if(_loc12_ != null && _loc12_.length > 0)
         {
            _loc2_.borderWidth = Number(_loc12_);
         }
         _loc12_ = _loc3_.@paddingLock;
         if(_loc12_ != null && _loc12_.length > 0)
         {
            _loc2_.tlf_internal::paddingLock = _loc12_.toLowerCase() == "true";
         }
         _loc12_ = _loc3_.@paddingLeft;
         if(_loc12_ != null && _loc12_.length > 0)
         {
            _loc2_.paddingLeft = Number(_loc12_);
         }
         _loc12_ = _loc3_.@paddingTop;
         if(_loc12_ != null && _loc12_.length > 0)
         {
            _loc2_.paddingTop = Number(_loc12_);
         }
         _loc12_ = _loc3_.@paddingRight;
         if(_loc12_ != null && _loc12_.length > 0)
         {
            _loc2_.paddingRight = Number(_loc12_);
         }
         _loc12_ = _loc3_.@paddingBottom;
         if(_loc12_ != null && _loc12_.length > 0)
         {
            _loc2_.paddingBottom = Number(_loc12_);
         }
         _loc12_ = _loc3_.@firstBaselineOffset;
         if(_loc12_ != null && _loc12_.length > 0)
         {
            _loc2_.firstBaselineOffset = _loc12_;
         }
         _loc12_ = _loc3_.@multiline;
         if(_loc12_ != null && _loc12_.length > 0)
         {
            _loc2_.multiline = _loc12_.toLowerCase() == "true";
         }
         _loc12_ = _loc3_.@antiAliasType;
         if(_loc12_ != null && _loc12_.length > 0)
         {
            _loc2_.antiAliasType = _loc12_;
         }
         _loc12_ = _loc3_.@embedFonts;
         if(_loc12_ != null && _loc12_.length > 0)
         {
            _loc2_.embedFonts = _loc12_.toLowerCase() == "true";
         }
         _loc12_ = _loc3_.@maxChars;
         if(_loc12_ != null && _loc12_.length > 0)
         {
            _loc2_.maxChars = int(_loc12_);
         }
         _loc12_ = _loc3_.@displayAsPassword;
         if(_loc12_ != null && _loc12_.length > 0)
         {
            _loc2_.displayAsPassword = _loc12_.toLowerCase() == "true";
         }
         _loc12_ = _loc3_.@text;
         if(_loc12_ != null && _loc12_.length > 0)
         {
            _loc2_.text = _loc12_;
         }
         _loc2_.alwaysShowSelection = false;
         return _loc2_;
      }
      
      override protected function getInstanceForInfo(param1:InstanceInfo) : DisplayObject
      {
         var ii:InstanceInfo = param1;
         try
         {
            if(getDefinitionByName("flashx.textLayout.elements.TextFlow") == null || getDefinitionByName("fl.text.container.TLFContainerController") == null)
            {
               return null;
            }
         }
         catch(re:ReferenceError)
         {
            return null;
         }
         return this.getInstanceForInfoInternal(ii);
      }
      
      private function recomposeOnLoadComplete(param1:Event) : void
      {
         var _loc2_:StatusChangeEvent = param1 as StatusChangeEvent;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:TextFlow = _loc2_.element.getTextFlow();
         if(Boolean(_loc3_) && (_loc2_.status == InlineGraphicElementStatus.SIZE_PENDING || _loc2_.status == InlineGraphicElementStatus.READY))
         {
            _loc3_.flowComposer.updateAllControllers();
            _loc3_.removeEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,this.recomposeOnLoadComplete);
         }
      }
      
      private function resolveInlines(param1:Object) : DisplayObject
      {
         var _loc5_:Object = null;
         var _loc6_:* = undefined;
         var _loc7_:TextFlow = null;
         var _loc8_:Class = null;
         var _loc9_:Bitmap = null;
         var _loc2_:InlineGraphicElement = param1 as InlineGraphicElement;
         if(_loc2_ == null)
         {
            return null;
         }
         var _loc3_:Object = _loc2_.userStyles;
         var _loc4_:* = null;
         if(_loc3_ != null)
         {
            _loc5_ = _loc3_["customSource"];
            _loc6_ = _loc3_["extraInfo"];
            _loc7_ = _loc2_.getTextFlow();
            if(_loc6_ != undefined)
            {
               _loc8_ = _loc6_[_loc5_];
               _loc4_ = new _loc8_();
               if(_loc4_ is BitmapData)
               {
                  _loc9_ = new Bitmap(_loc4_);
                  _loc4_ = new DynamicSprite();
                  _loc4_.addChild(_loc9_);
               }
            }
            if(_loc4_)
            {
               _loc4_["ilg"] = _loc2_;
               _loc7_.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,this.recomposeOnLoadComplete,false,0,true);
            }
         }
         return _loc4_ as DisplayObject;
      }
   }
}

