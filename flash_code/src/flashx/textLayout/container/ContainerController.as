package flashx.textLayout.container
{
   import flash.display.BlendMode;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.InteractiveObject;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.ContextMenuEvent;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.IMEEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.engine.TextLine;
   import flash.text.engine.TextLineValidity;
   import flash.ui.ContextMenu;
   import flash.ui.ContextMenuClipboardItems;
   import flash.utils.Timer;
   import flashx.textLayout.compose.FlowDamageType;
   import flashx.textLayout.compose.IFlowComposer;
   import flashx.textLayout.compose.TextFlowLine;
   import flashx.textLayout.compose.TextLineRecycler;
   import flashx.textLayout.edit.EditingMode;
   import flashx.textLayout.edit.IInteractionEventHandler;
   import flashx.textLayout.edit.ISelectionManager;
   import flashx.textLayout.edit.SelectionFormat;
   import flashx.textLayout.elements.BackgroundManager;
   import flashx.textLayout.elements.ContainerFormattedElement;
   import flashx.textLayout.elements.FlowElement;
   import flashx.textLayout.elements.FlowLeafElement;
   import flashx.textLayout.elements.FlowValueHolder;
   import flashx.textLayout.elements.ParagraphElement;
   import flashx.textLayout.elements.TCYElement;
   import flashx.textLayout.elements.TextFlow;
   import flashx.textLayout.events.TextLayoutEvent;
   import flashx.textLayout.events.UpdateCompleteEvent;
   import flashx.textLayout.formats.BlockProgression;
   import flashx.textLayout.formats.FormatValue;
   import flashx.textLayout.formats.ITextLayoutFormat;
   import flashx.textLayout.formats.TextLayoutFormat;
   import flashx.textLayout.formats.TextLayoutFormatValueHolder;
   import flashx.textLayout.property.Property;
   import flashx.textLayout.tlf_internal;
   
   use namespace tlf_internal;
   
   public class ContainerController implements IInteractionEventHandler, ITextLayoutFormat, ISandboxSupport
   {
      
      private static var _containerControllerInitialFormat:ITextLayoutFormat = createContainerControllerInitialFormat();
      
      private static var tempLineHolder:Sprite = new Sprite();
      
      private var _textFlowCache:TextFlow;
      
      private var _rootElement:ContainerFormattedElement;
      
      private var _absoluteStart:int;
      
      private var _textLength:int;
      
      private var _container:Sprite;
      
      protected var _computedFormat:ITextLayoutFormat;
      
      private var _columnState:ColumnState;
      
      private var _compositionWidth:Number = 0;
      
      private var _compositionHeight:Number = 0;
      
      private var _measureWidth:Boolean;
      
      private var _measureHeight:Boolean;
      
      private var _contentLeft:Number;
      
      private var _contentTop:Number;
      
      private var _contentWidth:Number;
      
      private var _contentHeight:Number;
      
      private var _composeCompleteRatio:Number;
      
      private var _horizontalScrollPolicy:String;
      
      private var _verticalScrollPolicy:String;
      
      private var _xScroll:Number;
      
      private var _yScroll:Number;
      
      private var _minListenersAttached:Boolean = false;
      
      private var _allListenersAttached:Boolean = false;
      
      private var _selectListenersAttached:Boolean = false;
      
      private var _shapesInvalid:Boolean = false;
      
      private var _backgroundShape:Shape;
      
      private var _scrollTimer:Timer = null;
      
      protected var _hasScrollRect:Boolean;
      
      private var _shapeChildren:Array;
      
      private var _formatValueHolder:FlowValueHolder;
      
      private var _containerRoot:DisplayObject;
      
      private var _transparentBGX:Number;
      
      private var _transparentBGY:Number;
      
      private var _transparentBGWidth:Number;
      
      private var _transparentBGHeight:Number;
      
      private var blinkTimer:Timer;
      
      private var blinkObject:DisplayObject;
      
      private var _selectionSprite:Sprite;
      
      public function ContainerController(param1:Sprite, param2:Number = 100, param3:Number = 100)
      {
         super();
         this.initialize(param1,param2,param3);
      }
      
      private static function pinValue(param1:Number, param2:Number, param3:Number) : Number
      {
         return Math.min(Math.max(param1,param2),param3);
      }
      
      tlf_internal static function createDefaultContextMenu() : ContextMenu
      {
         var _loc1_:ContextMenu = new ContextMenu();
         _loc1_.clipboardMenu = true;
         _loc1_.clipboardItems.clear = true;
         _loc1_.clipboardItems.copy = true;
         _loc1_.clipboardItems.cut = true;
         _loc1_.clipboardItems.paste = true;
         _loc1_.clipboardItems.selectAll = true;
         return _loc1_;
      }
      
      private static function createContainerControllerInitialFormat() : ITextLayoutFormat
      {
         var _loc1_:TextLayoutFormatValueHolder = new TextLayoutFormatValueHolder();
         _loc1_.columnCount = FormatValue.INHERIT;
         _loc1_.columnGap = FormatValue.INHERIT;
         _loc1_.columnWidth = FormatValue.INHERIT;
         _loc1_.verticalAlign = FormatValue.INHERIT;
         return _loc1_;
      }
      
      public static function get containerControllerInitialFormat() : ITextLayoutFormat
      {
         return _containerControllerInitialFormat;
      }
      
      public static function set containerControllerInitialFormat(param1:ITextLayoutFormat) : void
      {
         _containerControllerInitialFormat = param1;
      }
      
      tlf_internal function get allListenersAttached() : Boolean
      {
         return this._allListenersAttached;
      }
      
      tlf_internal function get hasScrollRect() : Boolean
      {
         return this._hasScrollRect;
      }
      
      private function initialize(param1:Sprite, param2:Number, param3:Number) : void
      {
         this._container = param1;
         this._containerRoot = null;
         this._textLength = 0;
         this._absoluteStart = -1;
         this._columnState = new ColumnState(null,null,null,0,0);
         this._xScroll = this._yScroll = 0;
         this._contentWidth = this._contentHeight = 0;
         this._composeCompleteRatio = 1;
         if(this._container is InteractiveObject)
         {
            InteractiveObject(this._container).doubleClickEnabled = true;
         }
         this._horizontalScrollPolicy = this._verticalScrollPolicy = String(ScrollPolicy.tlf_internal::scrollPolicyPropertyDefinition.defaultValue);
         this._hasScrollRect = false;
         this._shapeChildren = [];
         this.setCompositionSize(param2,param3);
         this.format = _containerControllerInitialFormat;
      }
      
      tlf_internal function get effectiveBlockProgression() : String
      {
         return this._rootElement ? this._rootElement.computedFormat.blockProgression : BlockProgression.TB;
      }
      
      tlf_internal function getContainerRoot() : DisplayObject
      {
         var x:int = 0;
         if(this._containerRoot == null && this._container && Boolean(this._container.stage))
         {
            try
            {
               x = this._container.stage.numChildren;
               this._containerRoot = this._container.stage;
            }
            catch(e:Error)
            {
               _containerRoot = _container.root;
            }
         }
         return this._containerRoot;
      }
      
      public function get flowComposer() : IFlowComposer
      {
         return this.textFlow ? this.textFlow.flowComposer : null;
      }
      
      tlf_internal function get shapesInvalid() : Boolean
      {
         return this._shapesInvalid;
      }
      
      tlf_internal function set shapesInvalid(param1:Boolean) : void
      {
         this._shapesInvalid = param1;
      }
      
      public function get columnState() : ColumnState
      {
         if(this._rootElement == null)
         {
            return null;
         }
         if(this._computedFormat == null)
         {
            this.computedFormat;
         }
         this._columnState.tlf_internal::computeColumns();
         return this._columnState;
      }
      
      public function get container() : Sprite
      {
         return this._container;
      }
      
      public function get compositionWidth() : Number
      {
         return this._compositionWidth;
      }
      
      public function get compositionHeight() : Number
      {
         return this._compositionHeight;
      }
      
      tlf_internal function get measureWidth() : Boolean
      {
         return this._measureWidth;
      }
      
      tlf_internal function get measureHeight() : Boolean
      {
         return this._measureHeight;
      }
      
      public function setCompositionSize(param1:Number, param2:Number) : void
      {
         var _loc3_:* = !(this._compositionWidth == param1 || isNaN(this._compositionWidth) && isNaN(param1));
         var _loc4_:* = !(this._compositionHeight == param2 || isNaN(this._compositionHeight) && isNaN(param2));
         if(_loc3_ || _loc4_)
         {
            this._compositionHeight = param2;
            this._measureHeight = isNaN(this._compositionHeight);
            this._compositionWidth = param1;
            this._measureWidth = isNaN(this._compositionWidth);
            if(this._computedFormat)
            {
               this.tlf_internal::resetColumnState();
            }
            this.invalidateContents();
            this.tlf_internal::attachTransparentBackgroundForHit(false);
         }
      }
      
      public function get textFlow() : TextFlow
      {
         if(!this._textFlowCache && Boolean(this._rootElement))
         {
            this._textFlowCache = this._rootElement.getTextFlow();
         }
         return this._textFlowCache;
      }
      
      public function get rootElement() : ContainerFormattedElement
      {
         return this._rootElement;
      }
      
      tlf_internal function setRootElement(param1:ContainerFormattedElement) : void
      {
         if(this._rootElement != param1)
         {
            this.tlf_internal::clearCompositionResults();
            this.tlf_internal::detachContainer();
            this._rootElement = param1;
            this._textFlowCache = null;
            this._textLength = 0;
            this._absoluteStart = -1;
            this.tlf_internal::attachContainer();
            if(this._rootElement)
            {
               this.tlf_internal::formatChanged();
            }
         }
      }
      
      public function get interactionManager() : ISelectionManager
      {
         return this.textFlow ? this.textFlow.interactionManager : null;
      }
      
      public function get absoluteStart() : int
      {
         var _loc3_:int = 0;
         var _loc4_:ContainerController = null;
         if(this._absoluteStart != -1)
         {
            return this._absoluteStart;
         }
         var _loc1_:int = 0;
         var _loc2_:IFlowComposer = this.flowComposer;
         if(_loc2_)
         {
            _loc3_ = _loc2_.getControllerIndex(this);
            if(_loc3_ != 0)
            {
               _loc4_ = _loc2_.getControllerAt(_loc3_ - 1);
               _loc1_ = _loc4_.absoluteStart + _loc4_.textLength;
            }
         }
         this._absoluteStart = _loc1_;
         return _loc1_;
      }
      
      public function get textLength() : int
      {
         return this._textLength;
      }
      
      tlf_internal function setTextLengthOnly(param1:int) : void
      {
         var _loc2_:IFlowComposer = null;
         var _loc3_:int = 0;
         var _loc4_:ContainerController = null;
         if(this._textLength != param1)
         {
            this._textLength = param1;
            if(this._absoluteStart != -1)
            {
               _loc2_ = this.flowComposer;
               if(_loc2_)
               {
                  _loc3_ = _loc2_.getControllerIndex(this) + 1;
                  while(_loc3_ < this.flowComposer.numControllers)
                  {
                     _loc4_ = _loc2_.getControllerAt(_loc3_++);
                     if(_loc4_._absoluteStart == -1)
                     {
                        break;
                     }
                     _loc4_._absoluteStart = -1;
                  }
               }
            }
         }
      }
      
      tlf_internal function setTextLength(param1:int) : void
      {
         var _loc2_:* = false;
         var _loc3_:IFlowComposer = null;
         var _loc4_:int = 0;
         this._composeCompleteRatio = 1;
         if(this.textFlow)
         {
            _loc2_ = this.tlf_internal::effectiveBlockProgression == BlockProgression.RL;
            _loc3_ = this.textFlow.flowComposer;
            if(param1 != 0 && _loc3_.getControllerIndex(this) == _loc3_.numControllers - 1 && (!_loc2_ && this._verticalScrollPolicy != ScrollPolicy.OFF || _loc2_ && this._horizontalScrollPolicy != ScrollPolicy.OFF))
            {
               _loc4_ = this.absoluteStart;
               this._composeCompleteRatio = (this.textFlow.textLength - _loc4_) / param1;
               param1 = this.textFlow.textLength - _loc4_;
            }
         }
         this.tlf_internal::setTextLengthOnly(param1);
      }
      
      tlf_internal function updateLength(param1:int, param2:int) : void
      {
         this.tlf_internal::setTextLengthOnly(this._textLength + param2);
      }
      
      public function isDamaged() : Boolean
      {
         return this.flowComposer.isDamaged(this.absoluteStart + this._textLength);
      }
      
      tlf_internal function formatChanged() : void
      {
         this._computedFormat = null;
         this.invalidateContents();
      }
      
      tlf_internal function updateInlineChildren() : void
      {
      }
      
      protected function fillShapeChildren(param1:Array, param2:Sprite) : void
      {
         var _loc6_:Rectangle = null;
         var _loc11_:TextFlowLine = null;
         var _loc12_:TextLine = null;
         var _loc13_:Rectangle = null;
         if(this._textLength == 0)
         {
            return;
         }
         var _loc3_:String = this.tlf_internal::effectiveBlockProgression;
         var _loc4_:Number = this._measureWidth ? this._contentWidth : this._compositionWidth;
         var _loc5_:Number = this._measureHeight ? this._contentHeight : this._compositionHeight;
         if(_loc3_ == BlockProgression.RL)
         {
            _loc6_ = new Rectangle(this._xScroll - _loc4_,this._yScroll,_loc4_,_loc5_);
         }
         else
         {
            _loc6_ = new Rectangle(this._xScroll,this._yScroll,_loc4_,_loc5_);
         }
         var _loc7_:Boolean = _loc3_ == BlockProgression.RL && (this._horizontalScrollPolicy == ScrollPolicy.OFF && this._verticalScrollPolicy == ScrollPolicy.OFF);
         var _loc8_:int = this.flowComposer.findLineIndexAtPosition(this.absoluteStart);
         var _loc9_:int = this.flowComposer.findLineIndexAtPosition(this.absoluteStart + this._textLength - 1);
         var _loc10_:int = _loc8_;
         while(_loc10_ <= _loc9_)
         {
            _loc11_ = this.flowComposer.getLineAt(_loc10_);
            if(!(_loc11_ == null || _loc11_.controller != this))
            {
               _loc12_ = _loc11_.tlf_internal::createShape(_loc3_);
               if(_loc12_)
               {
                  _loc13_ = this.tlf_internal::getPlacedTextLineBounds(_loc12_);
                  if(_loc3_ == BlockProgression.RL ? _loc13_.x + _loc13_.width >= _loc6_.left && _loc13_.x < _loc6_.x + _loc6_.width : _loc13_.y + _loc13_.height >= _loc6_.top && _loc13_.y < _loc6_.y + _loc6_.height)
                  {
                     if(_loc7_)
                     {
                        _loc12_.x -= _loc6_.x;
                        _loc12_.y -= _loc6_.y;
                     }
                     param1.push(_loc12_);
                     if(_loc12_.parent == null)
                     {
                        param2.addChild(_loc12_);
                     }
                  }
               }
            }
            _loc10_++;
         }
         if(_loc7_)
         {
            this._contentLeft -= _loc6_.x;
            this._contentTop -= _loc6_.y;
         }
      }
      
      public function get horizontalScrollPolicy() : String
      {
         return this._horizontalScrollPolicy;
      }
      
      public function set horizontalScrollPolicy(param1:String) : void
      {
         var _loc2_:String = ScrollPolicy.tlf_internal::scrollPolicyPropertyDefinition.setHelper(this._horizontalScrollPolicy,param1) as String;
         if(_loc2_ != this._horizontalScrollPolicy)
         {
            this._horizontalScrollPolicy = _loc2_;
            if(this._horizontalScrollPolicy == ScrollPolicy.OFF)
            {
               this.horizontalScrollPosition = 0;
            }
            this.tlf_internal::formatChanged();
         }
      }
      
      public function get verticalScrollPolicy() : String
      {
         return this._verticalScrollPolicy;
      }
      
      public function set verticalScrollPolicy(param1:String) : void
      {
         var _loc2_:String = ScrollPolicy.tlf_internal::scrollPolicyPropertyDefinition.setHelper(this._verticalScrollPolicy,param1) as String;
         if(_loc2_ != this._verticalScrollPolicy)
         {
            this._verticalScrollPolicy = _loc2_;
            if(this._verticalScrollPolicy == ScrollPolicy.OFF)
            {
               this.verticalScrollPosition = 0;
            }
            this.tlf_internal::formatChanged();
         }
      }
      
      public function get horizontalScrollPosition() : Number
      {
         return this._xScroll;
      }
      
      public function set horizontalScrollPosition(param1:Number) : void
      {
         if(!this._rootElement)
         {
            return;
         }
         if(this._horizontalScrollPolicy == ScrollPolicy.OFF)
         {
            this._xScroll = 0;
            return;
         }
         var _loc2_:Number = this._xScroll;
         var _loc3_:Number = this.computeHorizontalScrollPosition(param1,true);
         if(_loc3_ != _loc2_)
         {
            this._shapesInvalid = true;
            this._xScroll = _loc3_;
            this.updateForScroll();
         }
      }
      
      private function computeHorizontalScrollPosition(param1:Number, param2:Boolean) : Number
      {
         var _loc3_:String = this.tlf_internal::effectiveBlockProgression;
         var _loc4_:Number = this.tlf_internal::contentWidth;
         var _loc5_:Number = 0;
         if(_loc4_ > this._compositionWidth && !this._measureWidth)
         {
            if(_loc3_ == BlockProgression.RL)
            {
               _loc5_ = pinValue(param1,this._contentLeft + this._compositionWidth,this._contentLeft + _loc4_);
               if(param2 && this._composeCompleteRatio != 1 && _loc5_ != this._xScroll)
               {
                  this._xScroll = param1;
                  if(this._xScroll > this._contentLeft + this._contentWidth)
                  {
                     this._xScroll = this._contentLeft + this._contentWidth;
                  }
                  this.flowComposer.composeToController(this.flowComposer.getControllerIndex(this));
                  _loc5_ = pinValue(param1,this._contentLeft + this._compositionWidth,this._contentLeft + this._contentWidth);
               }
            }
            else
            {
               _loc5_ = pinValue(param1,this._contentLeft,this._contentLeft + _loc4_ - this._compositionWidth);
            }
         }
         return _loc5_;
      }
      
      public function get verticalScrollPosition() : Number
      {
         return this._yScroll;
      }
      
      public function set verticalScrollPosition(param1:Number) : void
      {
         if(!this._rootElement)
         {
            return;
         }
         if(this._verticalScrollPolicy == ScrollPolicy.OFF)
         {
            this._yScroll = 0;
            return;
         }
         var _loc2_:Number = this._yScroll;
         var _loc3_:Number = this.computeVerticalScrollPosition(param1,true);
         if(_loc3_ != _loc2_)
         {
            this._shapesInvalid = true;
            this._yScroll = _loc3_;
            this.updateForScroll();
         }
      }
      
      private function computeVerticalScrollPosition(param1:Number, param2:Boolean) : Number
      {
         var _loc3_:Number = 0;
         var _loc4_:Number = this.tlf_internal::contentHeight;
         var _loc5_:String = this.tlf_internal::effectiveBlockProgression;
         if(_loc4_ > this._compositionHeight)
         {
            _loc3_ = pinValue(param1,this._contentTop,this._contentTop + (_loc4_ - this._compositionHeight));
            if(param2 && this._composeCompleteRatio != 1 && _loc5_ == BlockProgression.TB)
            {
               this._yScroll = param1;
               if(this._yScroll < this._contentTop)
               {
                  this._yScroll = this._contentTop;
               }
               this.flowComposer.composeToController(this.flowComposer.getControllerIndex(this));
               _loc3_ = pinValue(param1,this._contentTop,this._contentTop + (_loc4_ - this._compositionHeight));
            }
         }
         return _loc3_;
      }
      
      public function getContentBounds() : Rectangle
      {
         return new Rectangle(this._contentLeft,this._contentTop,this.tlf_internal::contentWidth,this.tlf_internal::contentHeight);
      }
      
      tlf_internal function get contentLeft() : Number
      {
         return this._contentLeft;
      }
      
      tlf_internal function get contentTop() : Number
      {
         return this._contentTop;
      }
      
      tlf_internal function get contentHeight() : Number
      {
         return this.tlf_internal::effectiveBlockProgression == BlockProgression.TB ? this._contentHeight * this._composeCompleteRatio : this._contentHeight;
      }
      
      tlf_internal function get contentWidth() : Number
      {
         return this.tlf_internal::effectiveBlockProgression == BlockProgression.RL ? this._contentWidth * this._composeCompleteRatio : this._contentWidth;
      }
      
      tlf_internal function setContentBounds(param1:Number, param2:Number, param3:Number, param4:Number) : void
      {
         this._contentWidth = param3;
         this._contentHeight = param4;
         this._contentLeft = param1;
         this._contentTop = param2;
      }
      
      private function updateForScroll() : void
      {
         var _loc1_:IFlowComposer = this.textFlow.flowComposer;
         _loc1_.updateToController(_loc1_.getControllerIndex(this));
         this.tlf_internal::attachTransparentBackgroundForHit(false);
         this.textFlow.dispatchEvent(new TextLayoutEvent(TextLayoutEvent.SCROLL));
      }
      
      private function get containerScrollRectLeft() : Number
      {
         var _loc1_:Number = NaN;
         if(this.horizontalScrollPolicy == ScrollPolicy.OFF && this.verticalScrollPolicy == ScrollPolicy.OFF)
         {
            _loc1_ = 0;
         }
         else
         {
            _loc1_ = this.tlf_internal::effectiveBlockProgression == BlockProgression.RL ? this.horizontalScrollPosition - this.compositionWidth : this.horizontalScrollPosition;
         }
         return _loc1_;
      }
      
      private function get containerScrollRectRight() : Number
      {
         return this.containerScrollRectLeft + this.compositionWidth;
      }
      
      private function get containerScrollRectTop() : Number
      {
         var _loc1_:Number = NaN;
         if(this.horizontalScrollPolicy == ScrollPolicy.OFF && this.verticalScrollPolicy == ScrollPolicy.OFF)
         {
            _loc1_ = 0;
         }
         else
         {
            _loc1_ = this.verticalScrollPosition;
         }
         return _loc1_;
      }
      
      private function get containerScrollRectBottom() : Number
      {
         return this.containerScrollRectTop + this.compositionHeight;
      }
      
      public function scrollToRange(param1:int, param2:int) : void
      {
         var _loc20_:TextFlowLine = null;
         var _loc21_:int = 0;
         var _loc22_:TextFlowLine = null;
         var _loc23_:TextFlowLine = null;
         var _loc24_:Array = null;
         var _loc25_:Array = null;
         if(!this._hasScrollRect || !this.flowComposer || this.flowComposer.getControllerAt(this.flowComposer.numControllers - 1) != this)
         {
            return;
         }
         var _loc3_:int = this.absoluteStart;
         var _loc4_:int = Math.min(_loc3_ + this._textLength,this.textFlow.textLength - 1);
         param1 = Math.max(_loc3_,Math.min(param1,_loc4_));
         param2 = Math.max(_loc3_,Math.min(param2,_loc4_));
         var _loc5_:* = this.tlf_internal::effectiveBlockProgression == BlockProgression.RL;
         var _loc6_:int = Math.min(param1,param2);
         var _loc7_:int = Math.max(param1,param2);
         var _loc8_:int = this.flowComposer.findLineIndexAtPosition(_loc6_,_loc6_ == this.textFlow.textLength);
         var _loc9_:int = this.flowComposer.findLineIndexAtPosition(_loc7_,_loc7_ == this.textFlow.textLength);
         var _loc10_:TextFlowLine = _loc8_ == 0 ? null : this.flowComposer.getLineAt(_loc8_ - 1);
         var _loc11_:TextFlowLine = this.flowComposer.getLineAt(_loc8_);
         var _loc12_:int = 0;
         var _loc13_:Number = this.containerScrollRectLeft;
         var _loc14_:Number = this.containerScrollRectTop;
         var _loc15_:Number = this.containerScrollRectRight;
         var _loc16_:Number = this.containerScrollRectBottom;
         var _loc17_:Rectangle = new Rectangle(_loc13_,_loc14_,_loc15_ - _loc13_,_loc16_ - _loc14_);
         var _loc18_:int = _loc8_;
         while(_loc18_ <= _loc9_)
         {
            _loc20_ = _loc18_ + 1 == this.flowComposer.numLines ? null : this.flowComposer.getLineAt(_loc18_ + 1);
            _loc21_ = _loc11_.absoluteStart + _loc11_.textLength;
            if(_loc11_.controller == this)
            {
               _loc12_ += _loc11_.tlf_internal::selectionWillIntersectScrollRect(_loc17_,_loc6_,Math.min(_loc21_,_loc7_),_loc10_,_loc20_);
               if(_loc12_ >= 2)
               {
                  return;
               }
            }
            if(_loc18_ == _loc9_)
            {
               break;
            }
            _loc10_ = _loc11_;
            _loc11_ = _loc20_;
            _loc6_ = _loc21_;
            _loc18_++;
         }
         var _loc19_:Rectangle = this.posToRectangle(param1);
         if(!_loc19_)
         {
            this.flowComposer.composeToPosition(param1);
            _loc19_ = this.posToRectangle(param1);
         }
         if(_loc19_)
         {
            if(_loc19_.top < _loc14_)
            {
               this.verticalScrollPosition = _loc19_.top;
            }
            if(_loc5_)
            {
               if(_loc19_.left < _loc13_)
               {
                  this.horizontalScrollPosition = _loc19_.left + this._compositionWidth;
               }
               if(_loc19_.right > _loc15_)
               {
                  this.horizontalScrollPosition = _loc19_.right;
               }
               if(this.flowComposer.findLineAtPosition(param1).absoluteStart != param1)
               {
                  _loc19_ = this.posToRectangle(param1 - 1);
               }
               if(param1 == param2)
               {
                  _loc19_.bottom += 2;
               }
               if(Boolean(_loc19_) && _loc19_.bottom > _loc16_)
               {
                  this.verticalScrollPosition = _loc19_.bottom - this._compositionHeight;
               }
               _loc24_ = this.tlf_internal::findFirstAndLastVisibleLine();
               _loc22_ = _loc24_[0];
               _loc23_ = _loc24_[1];
               if((Boolean(_loc23_)) && _loc23_.x - _loc23_.descent - _loc23_.spaceAfter > _loc13_)
               {
                  this.horizontalScrollPosition = _loc23_.x - _loc23_.descent + this._compositionWidth;
               }
            }
            else
            {
               if(_loc19_.bottom > _loc16_)
               {
                  this.verticalScrollPosition = _loc19_.bottom - this._compositionHeight;
               }
               if(_loc19_.left < _loc13_)
               {
                  this.horizontalScrollPosition = _loc19_.left;
               }
               if(this.flowComposer.findLineAtPosition(param1).absoluteStart != param1)
               {
                  _loc19_ = this.posToRectangle(param1 - 1);
               }
               if(param1 == param2)
               {
                  _loc19_.right += 2;
               }
               if(Boolean(_loc19_) && _loc19_.right > _loc15_)
               {
                  this.horizontalScrollPosition = _loc19_.right - this._compositionWidth;
               }
               _loc25_ = this.tlf_internal::findFirstAndLastVisibleLine();
               _loc22_ = _loc25_[0];
               _loc23_ = _loc25_[1];
               if(_loc19_.top > _loc14_ && _loc23_ && _loc23_.y + _loc23_.height + _loc23_.spaceAfter < _loc16_)
               {
                  this.verticalScrollPosition = _loc23_.y + _loc23_.height;
               }
            }
         }
      }
      
      private function posToRectangle(param1:int) : Rectangle
      {
         var _loc4_:Rectangle = null;
         var _loc6_:FlowLeafElement = null;
         var _loc2_:TextFlowLine = this.flowComposer.findLineAtPosition(param1);
         if(!_loc2_.textLineExists || _loc2_.tlf_internal::isDamaged())
         {
            return null;
         }
         var _loc3_:TextLine = _loc2_.getTextLine(true);
         var _loc5_:int = _loc3_.getAtomIndexAtCharIndex(param1 - _loc2_.paragraph.getAbsoluteStart());
         if(_loc5_ > -1)
         {
            _loc4_ = _loc3_.getAtomBounds(_loc5_);
         }
         if(this.tlf_internal::effectiveBlockProgression == BlockProgression.RL)
         {
            _loc6_ = this._rootElement.getTextFlow().findLeaf(param1);
            if(_loc6_.getParentByType(TCYElement) != null)
            {
               return new Rectangle(_loc2_.x + _loc4_.x + _loc2_.y + _loc4_.y + _loc4_.width,_loc4_.height);
            }
         }
         return this.tlf_internal::effectiveBlockProgression == BlockProgression.RL ? new Rectangle(_loc2_.x,_loc2_.y + _loc4_.y,_loc2_.height,_loc4_.height) : new Rectangle(_loc2_.x + _loc4_.x,_loc2_.y - _loc2_.height + _loc2_.ascent,_loc4_.width,_loc2_.height + _loc3_.descent);
      }
      
      tlf_internal function resetColumnState() : void
      {
         if(this._rootElement)
         {
            this._columnState.tlf_internal::updateInputs(this.tlf_internal::effectiveBlockProgression,this._rootElement.computedFormat.direction,this,this._compositionWidth,this._compositionHeight);
         }
      }
      
      public function invalidateContents() : void
      {
         if(Boolean(this.textFlow) && Boolean(this._textLength))
         {
            this.textFlow.tlf_internal::damage(this.absoluteStart,this._textLength,FlowDamageType.GEOMETRY,false);
         }
      }
      
      tlf_internal function attachTransparentBackgroundForHit(param1:Boolean) : void
      {
         var _loc2_:Sprite = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Boolean = false;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         if(this._minListenersAttached && this.attachTransparentBackground)
         {
            _loc2_ = this._container as Sprite;
            if(_loc2_)
            {
               if(param1)
               {
                  _loc2_.graphics.clear();
                  this._transparentBGX = this._transparentBGY = this._transparentBGWidth = this._transparentBGHeight = NaN;
               }
               else
               {
                  _loc3_ = this._measureWidth ? this._contentWidth : this._compositionWidth;
                  _loc4_ = this._measureHeight ? this._contentHeight : this._compositionHeight;
                  _loc5_ = this.tlf_internal::effectiveBlockProgression == BlockProgression.RL && this._horizontalScrollPolicy != ScrollPolicy.OFF;
                  _loc6_ = _loc5_ ? this._xScroll - _loc3_ : this._xScroll;
                  _loc7_ = this._yScroll;
                  if(_loc6_ != this._transparentBGX || _loc7_ != this._transparentBGY || _loc3_ != this._transparentBGWidth || _loc4_ != this._transparentBGHeight)
                  {
                     _loc2_.graphics.clear();
                     if(_loc3_ != 0 && _loc4_ != 0)
                     {
                        _loc2_.graphics.beginFill(0,0);
                        _loc2_.graphics.drawRect(_loc6_,_loc7_,_loc3_,_loc4_);
                        _loc2_.graphics.endFill();
                     }
                     this._transparentBGX = _loc6_;
                     this._transparentBGY = _loc7_;
                     this._transparentBGWidth = _loc3_;
                     this._transparentBGHeight = _loc4_;
                  }
               }
            }
         }
      }
      
      tlf_internal function interactionManagerChanged(param1:ISelectionManager) : void
      {
         if(param1)
         {
            this.tlf_internal::attachContainer();
         }
         else
         {
            this.tlf_internal::detachContainer();
         }
      }
      
      tlf_internal function attachContainer() : void
      {
         if(!this._minListenersAttached && this.textFlow && Boolean(this.textFlow.interactionManager))
         {
            this._minListenersAttached = true;
            if(this._container)
            {
               this._container.addEventListener(FocusEvent.FOCUS_IN,this.tlf_internal::requiredFocusInHandler);
               this._container.addEventListener(MouseEvent.MOUSE_OVER,this.tlf_internal::requiredMouseOverHandler);
               this.tlf_internal::attachTransparentBackgroundForHit(false);
               if(Boolean(this._container.stage) && this._container.stage.focus == this._container)
               {
                  this.attachAllListeners();
               }
            }
         }
      }
      
      tlf_internal function attachInteractionHandlers() : void
      {
         var _loc1_:IInteractionEventHandler = this.tlf_internal::getInteractionHandler();
         this._container.addEventListener(MouseEvent.MOUSE_DOWN,this.tlf_internal::requiredMouseDownHandler);
         this._container.addEventListener(FocusEvent.FOCUS_OUT,this.tlf_internal::requiredFocusOutHandler);
         this._container.addEventListener(MouseEvent.DOUBLE_CLICK,_loc1_.mouseDoubleClickHandler);
         this._container.addEventListener(Event.ACTIVATE,_loc1_.activateHandler);
         this._container.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE,_loc1_.focusChangeHandler);
         this._container.addEventListener(FocusEvent.KEY_FOCUS_CHANGE,_loc1_.focusChangeHandler);
         this._container.addEventListener(TextEvent.TEXT_INPUT,_loc1_.textInputHandler);
         this._container.addEventListener(MouseEvent.MOUSE_OUT,_loc1_.mouseOutHandler);
         this._container.addEventListener(MouseEvent.MOUSE_WHEEL,_loc1_.mouseWheelHandler);
         this._container.addEventListener(Event.DEACTIVATE,_loc1_.deactivateHandler);
         this._container.addEventListener("imeStartComposition",_loc1_.imeStartCompositionHandler);
         if(this._container.contextMenu)
         {
            this._container.contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT,_loc1_.menuSelectHandler);
         }
         this._container.addEventListener(Event.COPY,_loc1_.editHandler);
         this._container.addEventListener(Event.SELECT_ALL,_loc1_.editHandler);
         this._container.addEventListener(Event.CUT,_loc1_.editHandler);
         this._container.addEventListener(Event.PASTE,_loc1_.editHandler);
         this._container.addEventListener(Event.CLEAR,_loc1_.editHandler);
      }
      
      tlf_internal function removeInteractionHandlers() : void
      {
         var _loc1_:IInteractionEventHandler = this.tlf_internal::getInteractionHandler();
         this._container.removeEventListener(MouseEvent.MOUSE_DOWN,this.tlf_internal::requiredMouseDownHandler);
         this._container.removeEventListener(FocusEvent.FOCUS_OUT,this.tlf_internal::requiredFocusOutHandler);
         this._container.removeEventListener(MouseEvent.DOUBLE_CLICK,_loc1_.mouseDoubleClickHandler);
         this._container.removeEventListener(Event.ACTIVATE,_loc1_.activateHandler);
         this._container.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE,_loc1_.focusChangeHandler);
         this._container.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE,_loc1_.focusChangeHandler);
         this._container.removeEventListener(TextEvent.TEXT_INPUT,_loc1_.textInputHandler);
         this._container.removeEventListener(MouseEvent.MOUSE_OUT,_loc1_.mouseOutHandler);
         this._container.removeEventListener(MouseEvent.MOUSE_WHEEL,_loc1_.mouseWheelHandler);
         this._container.removeEventListener(Event.DEACTIVATE,_loc1_.deactivateHandler);
         this._container.removeEventListener("imeStartComposition",_loc1_.imeStartCompositionHandler);
         if(this._container.contextMenu)
         {
            this._container.contextMenu.removeEventListener(ContextMenuEvent.MENU_SELECT,_loc1_.menuSelectHandler);
         }
         this._container.removeEventListener(Event.COPY,_loc1_.editHandler);
         this._container.removeEventListener(Event.SELECT_ALL,_loc1_.editHandler);
         this._container.removeEventListener(Event.CUT,_loc1_.editHandler);
         this._container.removeEventListener(Event.PASTE,_loc1_.editHandler);
         this._container.removeEventListener(Event.CLEAR,_loc1_.editHandler);
         this.clearSelectHandlers();
      }
      
      tlf_internal function detachContainer() : void
      {
         if(this._minListenersAttached)
         {
            if(this._container)
            {
               this._container.removeEventListener(FocusEvent.FOCUS_IN,this.tlf_internal::requiredFocusInHandler);
               this._container.removeEventListener(MouseEvent.MOUSE_OVER,this.tlf_internal::requiredMouseOverHandler);
               if(this._allListenersAttached)
               {
                  this.tlf_internal::removeInteractionHandlers();
                  this._container.contextMenu = null;
                  this.tlf_internal::attachTransparentBackgroundForHit(true);
                  this._allListenersAttached = false;
               }
            }
            this._minListenersAttached = false;
         }
      }
      
      private function attachAllListeners() : void
      {
         if(!this._allListenersAttached && this.textFlow && Boolean(this.textFlow.interactionManager))
         {
            this._allListenersAttached = true;
            if(this._container)
            {
               this._container.contextMenu = this.createContextMenu();
               this.tlf_internal::attachInteractionHandlers();
            }
         }
      }
      
      protected function createContextMenu() : ContextMenu
      {
         return tlf_internal::createDefaultContextMenu();
      }
      
      tlf_internal function scrollTimerHandler(param1:Event) : void
      {
         var containerPoint:Point = null;
         var scrollChange:int = 0;
         var mouseEvent:MouseEvent = null;
         var stashedScrollTimer:Timer = null;
         var event:Event = param1;
         if(!this._scrollTimer)
         {
            return;
         }
         if(this.textFlow.interactionManager == null || this.textFlow.interactionManager.activePosition < this.absoluteStart || this.textFlow.interactionManager.activePosition > this.absoluteStart + this.textLength)
         {
            event = null;
         }
         if(event is MouseEvent)
         {
            this._scrollTimer.stop();
            this._scrollTimer.removeEventListener(TimerEvent.TIMER,this.tlf_internal::scrollTimerHandler);
            event.currentTarget.removeEventListener(MouseEvent.MOUSE_UP,this.tlf_internal::scrollTimerHandler);
            this._scrollTimer = null;
         }
         else if(!event)
         {
            this._scrollTimer.stop();
            this._scrollTimer.removeEventListener(TimerEvent.TIMER,this.tlf_internal::scrollTimerHandler);
            if(this.tlf_internal::getContainerRoot())
            {
               this.tlf_internal::getContainerRoot().removeEventListener(MouseEvent.MOUSE_UP,this.tlf_internal::scrollTimerHandler);
            }
            this._scrollTimer = null;
         }
         else if(this._container.stage)
         {
            containerPoint = new Point(this._container.stage.mouseX,this._container.stage.mouseY);
            containerPoint = this._container.globalToLocal(containerPoint);
            scrollChange = this.autoScrollIfNecessaryInternal(containerPoint);
            if(scrollChange != 0 && Boolean(this.interactionManager))
            {
               mouseEvent = new PsuedoMouseEvent(MouseEvent.MOUSE_MOVE,false,false,this._container.stage.mouseX,this._container.stage.mouseY,this._container.stage,false,false,false,true);
               stashedScrollTimer = this._scrollTimer;
               try
               {
                  this._scrollTimer = null;
                  this.interactionManager.mouseMoveHandler(mouseEvent);
               }
               catch(e:Error)
               {
                  throw e;
               }
               finally
               {
                  this._scrollTimer = stashedScrollTimer;
               }
            }
         }
      }
      
      public function autoScrollIfNecessary(param1:int, param2:int) : void
      {
         var _loc4_:* = false;
         var _loc5_:ContainerController = null;
         var _loc6_:Rectangle = null;
         if(this.flowComposer.getControllerAt(this.flowComposer.numControllers - 1) != this)
         {
            _loc4_ = this.tlf_internal::effectiveBlockProgression == BlockProgression.RL;
            _loc5_ = this.flowComposer.getControllerAt(this.flowComposer.numControllers - 1);
            if(_loc4_ && this._horizontalScrollPolicy == ScrollPolicy.OFF || !_loc4_ && this._verticalScrollPolicy == ScrollPolicy.OFF)
            {
               return;
            }
            _loc6_ = _loc5_.container.getBounds(this._container.stage);
            if(_loc4_)
            {
               if(param2 >= _loc6_.top && param2 <= _loc6_.bottom)
               {
                  _loc5_.autoScrollIfNecessary(param1,param2);
               }
            }
            else if(param1 >= _loc6_.left && param1 <= _loc6_.right)
            {
               _loc5_.autoScrollIfNecessary(param1,param2);
            }
         }
         if(!this._hasScrollRect)
         {
            return;
         }
         var _loc3_:Point = new Point(param1,param2);
         _loc3_ = this._container.globalToLocal(_loc3_);
         this.autoScrollIfNecessaryInternal(_loc3_);
      }
      
      private function autoScrollIfNecessaryInternal(param1:Point) : int
      {
         var _loc2_:int = 0;
         if(param1.y - this.containerScrollRectBottom > 0)
         {
            this.verticalScrollPosition += this.textFlow.configuration.scrollDragPixels;
            _loc2_ = 1;
         }
         else if(param1.y - this.containerScrollRectTop < 0)
         {
            this.verticalScrollPosition -= this.textFlow.configuration.scrollDragPixels;
            _loc2_ = -1;
         }
         if(param1.x - this.containerScrollRectRight > 0)
         {
            this.horizontalScrollPosition += this.textFlow.configuration.scrollDragPixels;
            _loc2_ = -1;
         }
         else if(param1.x - this.containerScrollRectLeft < 0)
         {
            this.horizontalScrollPosition -= this.textFlow.configuration.scrollDragPixels;
            _loc2_ = 1;
         }
         if(_loc2_ != 0 && !this._scrollTimer)
         {
            this._scrollTimer = new Timer(this.textFlow.configuration.scrollDragDelay);
            this._scrollTimer.addEventListener(TimerEvent.TIMER,this.tlf_internal::scrollTimerHandler,false,0,true);
            if(this.tlf_internal::getContainerRoot())
            {
               this.tlf_internal::getContainerRoot().addEventListener(MouseEvent.MOUSE_UP,this.tlf_internal::scrollTimerHandler,false,0,true);
               this.beginMouseCapture();
            }
            this._scrollTimer.start();
         }
         return _loc2_;
      }
      
      tlf_internal function findFirstAndLastVisibleLine() : Array
      {
         var _loc4_:TextFlowLine = null;
         var _loc5_:TextFlowLine = null;
         var _loc7_:TextFlowLine = null;
         var _loc8_:TextLine = null;
         var _loc1_:int = this.flowComposer.findLineIndexAtPosition(this.absoluteStart);
         var _loc2_:int = this.flowComposer.findLineIndexAtPosition(this.absoluteStart + this._textLength - 1);
         var _loc3_:int = this._columnState.columnCount - 1;
         if(_loc1_ == this.flowComposer.numLines)
         {
            return [null,null];
         }
         var _loc6_:int = _loc1_;
         while(_loc6_ <= _loc2_)
         {
            _loc7_ = this.flowComposer.getLineAt(_loc6_);
            if(_loc7_.controller == this)
            {
               if(_loc7_.columnIndex == _loc3_)
               {
                  if(_loc7_.textLineExists)
                  {
                     _loc8_ = _loc7_.getTextLine();
                     if((Boolean(_loc8_)) && Boolean(_loc8_.parent))
                     {
                        if(!_loc4_)
                        {
                           _loc4_ = _loc7_;
                        }
                        _loc5_ = _loc7_;
                     }
                  }
               }
            }
            _loc6_++;
         }
         return [_loc4_,_loc5_];
      }
      
      public function getScrollDelta(param1:int) : Number
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc9_:Number = NaN;
         var _loc10_:TextLine = null;
         var _loc11_:FlowLeafElement = null;
         var _loc12_:ParagraphElement = null;
         if(this.flowComposer.numLines == 0)
         {
            return 0;
         }
         var _loc2_:Array = this.tlf_internal::findFirstAndLastVisibleLine();
         var _loc3_:TextFlowLine = _loc2_[0];
         var _loc4_:TextFlowLine = _loc2_[1];
         if(param1 > 0)
         {
            _loc6_ = this.flowComposer.findLineIndexAtPosition(_loc4_.absoluteStart);
            if(_loc4_)
            {
               _loc10_ = _loc4_.getTextLine(true);
               if(this.tlf_internal::effectiveBlockProgression == BlockProgression.TB)
               {
                  if(_loc10_.y + _loc10_.descent - this.containerScrollRectBottom > 2)
                  {
                     _loc6_--;
                  }
               }
               else if(this.containerScrollRectLeft - (_loc10_.x - _loc10_.descent) > 2)
               {
                  _loc6_--;
               }
            }
            while(_loc6_ + param1 > this.flowComposer.numLines - 1 && this.flowComposer.damageAbsoluteStart < this.textFlow.textLength)
            {
               this.flowComposer.composeToPosition(this.flowComposer.damageAbsoluteStart + 1000);
            }
            _loc5_ = Math.min(this.flowComposer.numLines - 1,_loc6_ + param1);
         }
         if(param1 < 0)
         {
            _loc6_ = this.flowComposer.findLineIndexAtPosition(_loc3_.absoluteStart);
            if(_loc3_)
            {
               if(this.tlf_internal::effectiveBlockProgression == BlockProgression.TB)
               {
                  if(_loc3_.y + 2 < this.containerScrollRectTop)
                  {
                     _loc6_++;
                  }
               }
               else if(_loc3_.x + _loc3_.ascent > this.containerScrollRectRight + 2)
               {
                  _loc6_++;
               }
            }
            _loc5_ = Math.max(0,_loc6_ + param1);
         }
         var _loc7_:TextFlowLine = this.flowComposer.getLineAt(_loc5_);
         if(_loc7_.absoluteStart < this.absoluteStart)
         {
            return 0;
         }
         if(_loc7_.validity != TextLineValidity.VALID)
         {
            _loc11_ = this.textFlow.findLeaf(_loc7_.absoluteStart);
            _loc12_ = _loc11_.getParagraph();
            this.textFlow.flowComposer.composeToPosition(_loc12_.getAbsoluteStart() + _loc12_.textLength);
            _loc7_ = this.flowComposer.getLineAt(_loc5_);
         }
         var _loc8_:* = this.tlf_internal::effectiveBlockProgression == BlockProgression.RL;
         if(_loc8_)
         {
            _loc9_ = param1 < 0 ? _loc7_.x + _loc7_.textHeight : _loc7_.x - _loc7_.descent + this._compositionWidth;
            return _loc9_ - this.horizontalScrollPosition;
         }
         _loc9_ = param1 < 0 ? _loc7_.y : _loc7_.y + _loc7_.textHeight - this._compositionHeight;
         return _loc9_ - this.verticalScrollPosition;
      }
      
      public function mouseOverHandler(param1:MouseEvent) : void
      {
         if(this.interactionManager)
         {
            this.interactionManager.mouseOverHandler(param1);
         }
      }
      
      tlf_internal function requiredMouseOverHandler(param1:MouseEvent) : void
      {
         this.attachAllListeners();
         this.tlf_internal::getInteractionHandler().mouseOverHandler(param1);
      }
      
      public function mouseOutHandler(param1:MouseEvent) : void
      {
         if(this.interactionManager)
         {
            this.interactionManager.mouseOutHandler(param1);
         }
      }
      
      public function mouseWheelHandler(param1:MouseEvent) : void
      {
         var _loc2_:* = this.tlf_internal::effectiveBlockProgression == BlockProgression.RL;
         if(_loc2_)
         {
            if(this.tlf_internal::contentWidth > this._compositionWidth && !this._measureWidth)
            {
               this.horizontalScrollPosition += param1.delta * this.textFlow.configuration.scrollMouseWheelMultiplier;
               param1.preventDefault();
            }
         }
         else if(this.tlf_internal::contentHeight > this._compositionHeight && !this._measureHeight)
         {
            this.verticalScrollPosition -= param1.delta * this.textFlow.configuration.scrollMouseWheelMultiplier;
            param1.preventDefault();
         }
      }
      
      public function mouseDownHandler(param1:MouseEvent) : void
      {
         if(this.interactionManager)
         {
            this.interactionManager.mouseDownHandler(param1);
            if(this.interactionManager.hasSelection())
            {
               this.tlf_internal::setFocus();
            }
         }
      }
      
      tlf_internal function requiredMouseDownHandler(param1:MouseEvent) : void
      {
         var _loc2_:DisplayObject = null;
         if(!this._selectListenersAttached)
         {
            _loc2_ = this.tlf_internal::getContainerRoot();
            if(_loc2_)
            {
               _loc2_.addEventListener(MouseEvent.MOUSE_MOVE,this.tlf_internal::rootMouseMoveHandler,false,0,true);
               _loc2_.addEventListener(MouseEvent.MOUSE_UP,this.tlf_internal::rootMouseUpHandler,false,0,true);
               this.beginMouseCapture();
               this._selectListenersAttached = true;
            }
         }
         this.tlf_internal::getInteractionHandler().mouseDownHandler(param1);
      }
      
      public function mouseUpHandler(param1:MouseEvent) : void
      {
         if(this.interactionManager)
         {
            this.interactionManager.mouseUpHandler(param1);
         }
      }
      
      tlf_internal function rootMouseUpHandler(param1:MouseEvent) : void
      {
         this.clearSelectHandlers();
         this.tlf_internal::getInteractionHandler().mouseUpHandler(param1);
      }
      
      private function clearSelectHandlers() : void
      {
         if(this._selectListenersAttached)
         {
            this.tlf_internal::getContainerRoot().removeEventListener(MouseEvent.MOUSE_MOVE,this.tlf_internal::rootMouseMoveHandler);
            this.tlf_internal::getContainerRoot().removeEventListener(MouseEvent.MOUSE_UP,this.tlf_internal::rootMouseUpHandler);
            this.endMouseCapture();
            this._selectListenersAttached = false;
         }
      }
      
      public function beginMouseCapture() : void
      {
         var _loc1_:ISandboxSupport = this.tlf_internal::getInteractionHandler() as ISandboxSupport;
         if(Boolean(_loc1_) && _loc1_ != this)
         {
            _loc1_.beginMouseCapture();
         }
      }
      
      public function endMouseCapture() : void
      {
         var _loc1_:ISandboxSupport = this.tlf_internal::getInteractionHandler() as ISandboxSupport;
         if(Boolean(_loc1_) && _loc1_ != this)
         {
            _loc1_.endMouseCapture();
         }
      }
      
      public function mouseUpSomewhere(param1:Event) : void
      {
         this.tlf_internal::rootMouseUpHandler(null);
         this.tlf_internal::scrollTimerHandler(null);
      }
      
      public function mouseMoveSomewhere(param1:Event) : void
      {
      }
      
      private function hitOnMyFlowExceptLastContainer(param1:MouseEvent) : Boolean
      {
         var _loc2_:TextFlowLine = null;
         var _loc3_:ParagraphElement = null;
         var _loc4_:int = 0;
         if(param1.target is TextLine)
         {
            _loc2_ = TextLine(param1.target).userData as TextFlowLine;
            if(_loc2_)
            {
               _loc3_ = _loc2_.paragraph;
               if(_loc3_.getTextFlow() == this.textFlow)
               {
                  return true;
               }
            }
         }
         else if(param1.target is Sprite)
         {
            _loc4_ = 0;
            while(_loc4_ < this.textFlow.flowComposer.numControllers - 1)
            {
               if(this.textFlow.flowComposer.getControllerAt(_loc4_).container == param1.target)
               {
                  return true;
               }
               _loc4_++;
            }
         }
         return false;
      }
      
      public function mouseMoveHandler(param1:MouseEvent) : void
      {
         if(this.interactionManager)
         {
            if(param1.buttonDown && !this.hitOnMyFlowExceptLastContainer(param1))
            {
               this.autoScrollIfNecessary(param1.stageX,param1.stageY);
            }
            this.interactionManager.mouseMoveHandler(param1);
         }
      }
      
      tlf_internal function rootMouseMoveHandler(param1:MouseEvent) : void
      {
         this.tlf_internal::getInteractionHandler().mouseMoveHandler(param1);
      }
      
      public function mouseDoubleClickHandler(param1:MouseEvent) : void
      {
         if(this.interactionManager)
         {
            this.interactionManager.mouseDoubleClickHandler(param1);
            if(this.interactionManager.hasSelection())
            {
               this.tlf_internal::setFocus();
            }
         }
      }
      
      tlf_internal function setFocus() : void
      {
         if(this._container.stage)
         {
            this._container.stage.focus = this._container;
         }
      }
      
      private function getContainerController(param1:DisplayObject) : ContainerController
      {
         var _loc2_:IFlowComposer = null;
         var _loc3_:int = 0;
         var _loc4_:ContainerController = null;
         while(param1)
         {
            _loc2_ = this.flowComposer;
            _loc3_ = 0;
            while(_loc3_ < _loc2_.numControllers)
            {
               _loc4_ = _loc2_.getControllerAt(_loc3_);
               if(_loc4_.container == param1)
               {
                  return _loc4_;
               }
               _loc3_++;
            }
            param1 = param1.parent;
         }
         return null;
      }
      
      public function focusChangeHandler(param1:FocusEvent) : void
      {
         var _loc2_:ContainerController = this.getContainerController(DisplayObject(param1.target));
         var _loc3_:ContainerController = this.getContainerController(param1.relatedObject);
         if(_loc3_ == _loc2_)
         {
            param1.preventDefault();
         }
      }
      
      public function focusInHandler(param1:FocusEvent) : void
      {
         var _loc2_:int = 0;
         if(this.interactionManager)
         {
            this.interactionManager.focusInHandler(param1);
            if(this.interactionManager.editingMode == EditingMode.READ_WRITE)
            {
               _loc2_ = this.interactionManager.focusedSelectionFormat.pointBlinkRate;
            }
         }
         this.setBlinkInterval(_loc2_);
      }
      
      tlf_internal function requiredFocusInHandler(param1:FocusEvent) : void
      {
         this.attachAllListeners();
         this._container.addEventListener(KeyboardEvent.KEY_DOWN,this.tlf_internal::getInteractionHandler().keyDownHandler);
         this._container.addEventListener(KeyboardEvent.KEY_UP,this.tlf_internal::getInteractionHandler().keyUpHandler);
         this._container.addEventListener(FocusEvent.KEY_FOCUS_CHANGE,this.tlf_internal::getInteractionHandler().keyFocusChangeHandler);
         this.tlf_internal::getInteractionHandler().focusInHandler(param1);
      }
      
      public function focusOutHandler(param1:FocusEvent) : void
      {
         if(this.interactionManager)
         {
            this.interactionManager.focusOutHandler(param1);
            this.setBlinkInterval(this.interactionManager.unfocusedSelectionFormat.pointBlinkRate);
         }
         else
         {
            this.setBlinkInterval(0);
         }
      }
      
      tlf_internal function requiredFocusOutHandler(param1:FocusEvent) : void
      {
         this._container.removeEventListener(KeyboardEvent.KEY_DOWN,this.tlf_internal::getInteractionHandler().keyDownHandler);
         this._container.removeEventListener(KeyboardEvent.KEY_UP,this.tlf_internal::getInteractionHandler().keyUpHandler);
         this._container.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE,this.tlf_internal::getInteractionHandler().keyFocusChangeHandler);
         this.tlf_internal::getInteractionHandler().focusOutHandler(param1);
      }
      
      public function activateHandler(param1:Event) : void
      {
         if(this.interactionManager)
         {
            this.interactionManager.activateHandler(param1);
         }
      }
      
      public function deactivateHandler(param1:Event) : void
      {
         if(this.interactionManager)
         {
            this.interactionManager.deactivateHandler(param1);
         }
      }
      
      public function keyDownHandler(param1:KeyboardEvent) : void
      {
         if(this.interactionManager)
         {
            this.interactionManager.keyDownHandler(param1);
         }
      }
      
      public function keyUpHandler(param1:KeyboardEvent) : void
      {
         if(this.interactionManager)
         {
            this.interactionManager.keyUpHandler(param1);
         }
      }
      
      public function keyFocusChangeHandler(param1:FocusEvent) : void
      {
         if(this.interactionManager)
         {
            this.interactionManager.keyFocusChangeHandler(param1);
         }
      }
      
      public function textInputHandler(param1:TextEvent) : void
      {
         if(this.interactionManager)
         {
            this.interactionManager.textInputHandler(param1);
         }
      }
      
      public function imeStartCompositionHandler(param1:IMEEvent) : void
      {
         if(this.interactionManager)
         {
            this.interactionManager.imeStartCompositionHandler(param1);
         }
      }
      
      public function menuSelectHandler(param1:ContextMenuEvent) : void
      {
         var _loc3_:ContextMenuClipboardItems = null;
         var _loc2_:DisplayObjectContainer = this._container as DisplayObjectContainer;
         if(this.interactionManager)
         {
            this.interactionManager.menuSelectHandler(param1);
         }
         else
         {
            _loc3_ = _loc2_.contextMenu.clipboardItems;
            _loc3_.copy = false;
            _loc3_.cut = false;
            _loc3_.paste = false;
            _loc3_.selectAll = false;
            _loc3_.clear = false;
         }
      }
      
      public function editHandler(param1:Event) : void
      {
         if(this.interactionManager)
         {
            this.interactionManager.editHandler(param1);
         }
         var _loc2_:ContextMenu = this._container.contextMenu;
         if(_loc2_)
         {
            _loc2_.clipboardItems.clear = true;
            _loc2_.clipboardItems.copy = true;
            _loc2_.clipboardItems.cut = true;
            _loc2_.clipboardItems.paste = true;
            _loc2_.clipboardItems.selectAll = true;
         }
      }
      
      public function selectRange(param1:int, param2:int) : void
      {
         if(Boolean(this.interactionManager) && this.interactionManager.editingMode != EditingMode.READ_ONLY)
         {
            this.interactionManager.selectRange(param1,param2);
         }
      }
      
      private function startBlinkingCursor(param1:DisplayObject, param2:int) : void
      {
         if(!this.blinkTimer)
         {
            this.blinkTimer = new Timer(param2,0);
         }
         this.blinkObject = param1;
         this.blinkTimer.addEventListener(TimerEvent.TIMER,this.blinkTimerHandler,false,0,true);
         this.blinkTimer.start();
      }
      
      protected function stopBlinkingCursor() : void
      {
         if(this.blinkTimer)
         {
            this.blinkTimer.stop();
         }
         this.blinkObject = null;
      }
      
      private function blinkTimerHandler(param1:TimerEvent) : void
      {
         this.blinkObject.alpha = this.blinkObject.alpha == 1 ? 0 : 1;
      }
      
      protected function setBlinkInterval(param1:int) : void
      {
         var _loc2_:int = param1;
         if(_loc2_ == 0)
         {
            if(this.blinkTimer)
            {
               this.blinkTimer.stop();
            }
            if(this.blinkObject)
            {
               this.blinkObject.alpha = 1;
            }
         }
         else if(this.blinkTimer)
         {
            this.blinkTimer.delay = _loc2_;
            if(this.blinkObject)
            {
               this.blinkTimer.start();
            }
         }
      }
      
      tlf_internal function drawPointSelection(param1:SelectionFormat, param2:Number, param3:Number, param4:Number, param5:Number) : void
      {
         var _loc6_:Shape = new Shape();
         if(this.interactionManager.activePosition == this.interactionManager.anchorPosition)
         {
            _loc6_.graphics.beginFill(param1.pointColor);
         }
         else
         {
            _loc6_.graphics.beginFill(param1.rangeColor);
         }
         if(this._hasScrollRect)
         {
            if(this.tlf_internal::effectiveBlockProgression == BlockProgression.TB)
            {
               if(param2 >= this.containerScrollRectRight)
               {
                  param2 -= param4;
               }
            }
            else if(param3 >= this.containerScrollRectBottom)
            {
               param3 -= param5;
            }
         }
         _loc6_.graphics.drawRect(int(param2),int(param3),param4,param5);
         _loc6_.graphics.endFill();
         if(param1.pointBlinkRate != 0 && this.interactionManager.editingMode == EditingMode.READ_WRITE)
         {
            this.startBlinkingCursor(_loc6_,param1.pointBlinkRate);
         }
         this.tlf_internal::addSelectionChild(_loc6_);
      }
      
      tlf_internal function addSelectionShapes(param1:SelectionFormat, param2:int, param3:int) : void
      {
         var _loc4_:TextFlowLine = null;
         var _loc5_:TextFlowLine = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:Shape = null;
         var _loc11_:TextFlowLine = null;
         var _loc12_:int = 0;
         var _loc13_:TextFlowLine = null;
         var _loc14_:int = 0;
         if(!this.interactionManager || this._textLength == 0 || param2 == -1 || param3 == -1)
         {
            return;
         }
         if(param2 != param3)
         {
            _loc6_ = this.absoluteStart;
            _loc7_ = this.absoluteStart + this._textLength;
            if(param2 < _loc6_)
            {
               param2 = _loc6_;
            }
            else if(param2 >= _loc7_)
            {
               return;
            }
            if(param3 > _loc7_)
            {
               param3 = _loc7_;
            }
            else if(param3 < _loc6_)
            {
               return;
            }
            _loc8_ = this.flowComposer.findLineIndexAtPosition(param2);
            _loc9_ = param2 == param3 ? _loc8_ : this.flowComposer.findLineIndexAtPosition(param3);
            if(_loc9_ >= this.flowComposer.numLines)
            {
               _loc9_ = this.flowComposer.numLines - 1;
            }
            _loc10_ = new Shape();
            _loc4_ = _loc8_ ? this.flowComposer.getLineAt(_loc8_ - 1) : null;
            _loc11_ = this.flowComposer.getLineAt(_loc8_);
            _loc12_ = _loc8_;
            while(_loc12_ <= _loc9_)
            {
               _loc5_ = _loc12_ != this.flowComposer.numLines - 1 ? this.flowComposer.getLineAt(_loc12_ + 1) : null;
               _loc11_.tlf_internal::hiliteBlockSelection(_loc10_,param1,DisplayObject(this._container),param2 < _loc11_.absoluteStart ? _loc11_.absoluteStart : param2,param3 > _loc11_.absoluteStart + _loc11_.textLength ? _loc11_.absoluteStart + _loc11_.textLength : param3,_loc4_,_loc5_);
               _loc13_ = _loc11_;
               _loc11_ = _loc5_;
               _loc4_ = _loc13_;
               _loc12_++;
            }
            this.tlf_internal::addSelectionChild(_loc10_);
         }
         else
         {
            _loc14_ = this.flowComposer.findLineIndexAtPosition(param2);
            if(_loc14_ == this.flowComposer.numLines)
            {
               _loc14_--;
            }
            if(this.flowComposer.getLineAt(_loc14_).controller == this)
            {
               _loc4_ = _loc14_ != 0 ? this.flowComposer.getLineAt(_loc14_ - 1) : null;
               _loc5_ = _loc14_ != this.flowComposer.numLines - 1 ? this.flowComposer.getLineAt(_loc14_ + 1) : null;
               this.flowComposer.getLineAt(_loc14_).tlf_internal::hilitePointSelection(param1,param2,DisplayObject(this._container),_loc4_,_loc5_);
            }
         }
      }
      
      tlf_internal function clearSelectionShapes() : void
      {
         this.stopBlinkingCursor();
         var _loc1_:DisplayObjectContainer = this.tlf_internal::getSelectionSprite(false);
         if(_loc1_ != null)
         {
            if(_loc1_.parent)
            {
               this.removeSelectionContainer(_loc1_);
            }
            while(_loc1_.numChildren > 0)
            {
               _loc1_.removeChildAt(0);
            }
            return;
         }
      }
      
      tlf_internal function addSelectionChild(param1:DisplayObject) : void
      {
         var _loc2_:DisplayObjectContainer = this.tlf_internal::getSelectionSprite(true);
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:SelectionFormat = this.interactionManager.currentSelectionFormat;
         var _loc4_:String = this.interactionManager.activePosition == this.interactionManager.anchorPosition ? _loc3_.pointBlendMode : _loc3_.rangeBlendMode;
         var _loc5_:Number = this.interactionManager.activePosition == this.interactionManager.anchorPosition ? _loc3_.pointAlpha : _loc3_.rangeAlpha;
         if(_loc2_.blendMode != _loc4_)
         {
            _loc2_.blendMode = _loc4_;
         }
         if(_loc2_.alpha != _loc5_)
         {
            _loc2_.alpha = _loc5_;
         }
         if(_loc2_.numChildren == 0)
         {
            this.addSelectionContainer(_loc2_);
         }
         _loc2_.addChild(param1);
      }
      
      tlf_internal function containsSelectionChild(param1:DisplayObject) : Boolean
      {
         var _loc2_:DisplayObjectContainer = this.tlf_internal::getSelectionSprite(false);
         if(_loc2_ == null)
         {
            return false;
         }
         return _loc2_.contains(param1);
      }
      
      tlf_internal function getBackgroundShape() : Shape
      {
         if(!this._backgroundShape)
         {
            this._backgroundShape = new Shape();
            this.addBackgroundShape(this._backgroundShape);
         }
         return this._backgroundShape;
      }
      
      tlf_internal function get effectivePaddingLeft() : Number
      {
         return this.computedFormat.paddingLeft + (this._rootElement ? this._rootElement.computedFormat.paddingLeft : 0);
      }
      
      tlf_internal function get effectivePaddingRight() : Number
      {
         return this.computedFormat.paddingRight + (this._rootElement ? this._rootElement.computedFormat.paddingRight : 0);
      }
      
      tlf_internal function get effectivePaddingTop() : Number
      {
         return this.computedFormat.paddingTop + (this._rootElement ? this._rootElement.computedFormat.paddingTop : 0);
      }
      
      tlf_internal function get effectivePaddingBottom() : Number
      {
         return this.computedFormat.paddingBottom + (this._rootElement ? this._rootElement.computedFormat.paddingBottom : 0);
      }
      
      tlf_internal function getSelectionSprite(param1:Boolean) : DisplayObjectContainer
      {
         if(this._selectionSprite == null && param1)
         {
            this._selectionSprite = new Sprite();
            this._selectionSprite.mouseEnabled = false;
            this._selectionSprite.mouseChildren = false;
         }
         return this._selectionSprite;
      }
      
      protected function get attachTransparentBackground() : Boolean
      {
         return true;
      }
      
      tlf_internal function clearCompositionResults() : void
      {
         var _loc1_:TextLine = null;
         this.tlf_internal::setTextLength(0);
         for each(_loc1_ in this._shapeChildren)
         {
            this.removeTextLine(_loc1_);
         }
         this._shapeChildren.length = 0;
      }
      
      tlf_internal function updateCompositionShapes() : void
      {
         var _loc8_:TextLine = null;
         var _loc9_:int = 0;
         if(!this.tlf_internal::shapesInvalid)
         {
            return;
         }
         var _loc1_:* = false;
         var _loc2_:Number = this._yScroll;
         if(this.verticalScrollPolicy != ScrollPolicy.OFF && !this._measureHeight)
         {
            this._yScroll = this.computeVerticalScrollPosition(this._yScroll,false);
         }
         _loc1_ = _loc2_ != this._yScroll;
         _loc2_ = this._xScroll;
         if(this.horizontalScrollPolicy != ScrollPolicy.OFF && !this._measureWidth)
         {
            this._xScroll = this.computeHorizontalScrollPosition(this._xScroll,false);
         }
         _loc1_ ||= _loc2_ != this._xScroll;
         var _loc3_:Array = [];
         this.fillShapeChildren(_loc3_,tempLineHolder);
         var _loc4_:int = this.getFirstTextLineChildIndex();
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         while(_loc6_ != _loc3_.length)
         {
            _loc8_ = _loc3_[_loc6_];
            if(_loc8_ == this._shapeChildren[_loc5_])
            {
               _loc4_++;
               _loc6_++;
               _loc5_++;
            }
            else
            {
               _loc9_ = int(this._shapeChildren.indexOf(_loc8_));
               if(_loc9_ == -1)
               {
                  this.addTextLine(_loc8_,_loc4_++);
                  _loc6_++;
               }
               else
               {
                  this.removeAndRecycleTextLines(_loc5_,_loc9_);
                  _loc5_ = _loc9_;
               }
            }
         }
         this.removeAndRecycleTextLines(_loc5_,this._shapeChildren.length);
         this._shapeChildren = _loc3_;
         this.tlf_internal::shapesInvalid = false;
         this.tlf_internal::updateInlineChildren();
         this.updateVisibleRectangle();
         if(this._measureWidth || this._measureHeight)
         {
            this.tlf_internal::attachTransparentBackgroundForHit(false);
         }
         var _loc7_:TextFlow = this.textFlow;
         if(_loc7_.tlf_internal::backgroundManager)
         {
            _loc7_.tlf_internal::backgroundManager.onUpdateComplete(this);
         }
         if(_loc1_ && _loc7_.hasEventListener(TextLayoutEvent.SCROLL))
         {
            _loc7_.dispatchEvent(new TextLayoutEvent(TextLayoutEvent.SCROLL));
         }
         if(_loc7_.hasEventListener(UpdateCompleteEvent.UPDATE_COMPLETE))
         {
            _loc7_.dispatchEvent(new UpdateCompleteEvent(UpdateCompleteEvent.UPDATE_COMPLETE,false,false,_loc7_,this));
         }
         while(tempLineHolder.numChildren)
         {
            tempLineHolder.removeChildAt(0);
         }
      }
      
      private function removeAndRecycleTextLines(param1:int, param2:int) : void
      {
         var _loc4_:TextLine = null;
         var _loc3_:BackgroundManager = this.textFlow.tlf_internal::backgroundManager;
         while(param1 < param2)
         {
            _loc4_ = this._shapeChildren[param1++];
            this.removeTextLine(_loc4_);
            if(TextLineRecycler.textLineRecyclerEnabled && !_loc4_.parent)
            {
               if(_loc4_.userData == null)
               {
                  TextLineRecycler.addLineForReuse(_loc4_);
                  if(_loc3_)
                  {
                     _loc3_.removeLineFromCache(_loc4_);
                  }
               }
               else if(_loc4_.validity == TextLineValidity.INVALID)
               {
                  if(_loc4_.nextLine == null && _loc4_.previousLine == null && (!_loc4_.textBlock || _loc4_.textBlock.firstLine != _loc4_))
                  {
                     _loc4_.userData.releaseTextLine();
                     _loc4_.userData = null;
                     TextLineRecycler.addLineForReuse(_loc4_);
                     if(_loc3_)
                     {
                        _loc3_.removeLineFromCache(_loc4_);
                     }
                  }
               }
            }
         }
      }
      
      protected function getFirstTextLineChildIndex() : int
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < this._container.numChildren)
         {
            if(this._container.getChildAt(_loc1_) is TextLine)
            {
               break;
            }
            _loc1_++;
         }
         return _loc1_;
      }
      
      protected function addTextLine(param1:TextLine, param2:int) : void
      {
         this._container.addChildAt(param1,param2);
      }
      
      protected function removeTextLine(param1:TextLine) : void
      {
         if(this._container.contains(param1))
         {
            this._container.removeChild(param1);
         }
      }
      
      protected function addBackgroundShape(param1:Shape) : void
      {
         this._container.addChildAt(this._backgroundShape,this.getFirstTextLineChildIndex());
      }
      
      protected function addSelectionContainer(param1:DisplayObjectContainer) : void
      {
         if(param1.blendMode == BlendMode.NORMAL && param1.alpha == 1)
         {
            this._container.addChildAt(param1,this.getFirstTextLineChildIndex());
         }
         else
         {
            this._container.addChild(param1);
         }
      }
      
      protected function removeSelectionContainer(param1:DisplayObjectContainer) : void
      {
         param1.parent.removeChild(param1);
      }
      
      tlf_internal function get textLines() : Array
      {
         return this._shapeChildren;
      }
      
      protected function updateVisibleRectangle() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:Rectangle = null;
         if(this.horizontalScrollPolicy == ScrollPolicy.OFF && this.verticalScrollPolicy == ScrollPolicy.OFF)
         {
            if(this._hasScrollRect)
            {
               this._container.scrollRect = null;
               this._hasScrollRect = false;
            }
         }
         else
         {
            _loc1_ = this._contentLeft + this.tlf_internal::contentWidth;
            _loc2_ = this._contentTop + this.tlf_internal::contentHeight;
            if(this._measureWidth)
            {
               _loc3_ = this.tlf_internal::contentWidth;
               _loc4_ = this._contentLeft + _loc3_;
            }
            else
            {
               _loc3_ = this._compositionWidth;
               _loc4_ = _loc3_;
            }
            if(this._measureHeight)
            {
               _loc5_ = this.tlf_internal::contentHeight;
               _loc6_ = this._contentTop + _loc5_;
            }
            else
            {
               _loc6_ = _loc5_ = this._compositionHeight;
            }
            _loc7_ = this.tlf_internal::effectiveBlockProgression == BlockProgression.RL ? -_loc3_ : 0;
            _loc8_ = this.horizontalScrollPosition + _loc7_;
            _loc9_ = this.verticalScrollPosition;
            if(this.textLength == 0 || _loc8_ == 0 && _loc9_ == 0 && this._contentLeft >= _loc7_ && this._contentTop >= 0 && _loc1_ <= _loc4_ && _loc2_ <= _loc6_)
            {
               if(this._hasScrollRect)
               {
                  this._container.scrollRect = null;
                  this._hasScrollRect = false;
               }
            }
            else
            {
               _loc10_ = this._container.scrollRect;
               if(!_loc10_ || _loc10_.x != _loc8_ || _loc10_.y != _loc9_ || _loc10_.width != _loc3_ || _loc10_.height != _loc5_)
               {
                  this._container.scrollRect = new Rectangle(_loc8_,_loc9_,_loc3_,_loc5_);
                  this._hasScrollRect = true;
               }
            }
         }
         this.tlf_internal::attachTransparentBackgroundForHit(false);
      }
      
      public function get color() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.color : undefined;
      }
      
      public function set color(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().color = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get backgroundColor() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.backgroundColor : undefined;
      }
      
      public function set backgroundColor(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().backgroundColor = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get lineThrough() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.lineThrough : undefined;
      }
      
      public function set lineThrough(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().lineThrough = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get textAlpha() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.textAlpha : undefined;
      }
      
      public function set textAlpha(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().textAlpha = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get backgroundAlpha() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.backgroundAlpha : undefined;
      }
      
      public function set backgroundAlpha(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().backgroundAlpha = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get fontSize() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.fontSize : undefined;
      }
      
      public function set fontSize(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().fontSize = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get baselineShift() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.baselineShift : undefined;
      }
      
      public function set baselineShift(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().baselineShift = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get trackingLeft() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.trackingLeft : undefined;
      }
      
      public function set trackingLeft(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().trackingLeft = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get trackingRight() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.trackingRight : undefined;
      }
      
      public function set trackingRight(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().trackingRight = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get lineHeight() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.lineHeight : undefined;
      }
      
      public function set lineHeight(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().lineHeight = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get breakOpportunity() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.breakOpportunity : undefined;
      }
      
      public function set breakOpportunity(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().breakOpportunity = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get digitCase() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.digitCase : undefined;
      }
      
      public function set digitCase(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().digitCase = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get digitWidth() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.digitWidth : undefined;
      }
      
      public function set digitWidth(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().digitWidth = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get dominantBaseline() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.dominantBaseline : undefined;
      }
      
      public function set dominantBaseline(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().dominantBaseline = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get kerning() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.kerning : undefined;
      }
      
      public function set kerning(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().kerning = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get ligatureLevel() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.ligatureLevel : undefined;
      }
      
      public function set ligatureLevel(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().ligatureLevel = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get alignmentBaseline() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.alignmentBaseline : undefined;
      }
      
      public function set alignmentBaseline(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().alignmentBaseline = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get locale() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.locale : undefined;
      }
      
      public function set locale(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().locale = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get typographicCase() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.typographicCase : undefined;
      }
      
      public function set typographicCase(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().typographicCase = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get fontFamily() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.fontFamily : undefined;
      }
      
      public function set fontFamily(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().fontFamily = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get textDecoration() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.textDecoration : undefined;
      }
      
      public function set textDecoration(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().textDecoration = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get fontWeight() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.fontWeight : undefined;
      }
      
      public function set fontWeight(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().fontWeight = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get fontStyle() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.fontStyle : undefined;
      }
      
      public function set fontStyle(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().fontStyle = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get whiteSpaceCollapse() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.whiteSpaceCollapse : undefined;
      }
      
      public function set whiteSpaceCollapse(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().whiteSpaceCollapse = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get renderingMode() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.renderingMode : undefined;
      }
      
      public function set renderingMode(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().renderingMode = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get cffHinting() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.cffHinting : undefined;
      }
      
      public function set cffHinting(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().cffHinting = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get fontLookup() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.fontLookup : undefined;
      }
      
      public function set fontLookup(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().fontLookup = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get textRotation() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.textRotation : undefined;
      }
      
      public function set textRotation(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().textRotation = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get textIndent() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.textIndent : undefined;
      }
      
      public function set textIndent(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().textIndent = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get paragraphStartIndent() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.paragraphStartIndent : undefined;
      }
      
      public function set paragraphStartIndent(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().paragraphStartIndent = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get paragraphEndIndent() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.paragraphEndIndent : undefined;
      }
      
      public function set paragraphEndIndent(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().paragraphEndIndent = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get paragraphSpaceBefore() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.paragraphSpaceBefore : undefined;
      }
      
      public function set paragraphSpaceBefore(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().paragraphSpaceBefore = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get paragraphSpaceAfter() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.paragraphSpaceAfter : undefined;
      }
      
      public function set paragraphSpaceAfter(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().paragraphSpaceAfter = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get textAlign() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.textAlign : undefined;
      }
      
      public function set textAlign(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().textAlign = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get textAlignLast() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.textAlignLast : undefined;
      }
      
      public function set textAlignLast(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().textAlignLast = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get textJustify() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.textJustify : undefined;
      }
      
      public function set textJustify(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().textJustify = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get justificationRule() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.justificationRule : undefined;
      }
      
      public function set justificationRule(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().justificationRule = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get justificationStyle() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.justificationStyle : undefined;
      }
      
      public function set justificationStyle(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().justificationStyle = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get direction() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.direction : undefined;
      }
      
      public function set direction(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().direction = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get tabStops() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.tabStops : undefined;
      }
      
      public function set tabStops(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().tabStops = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get leadingModel() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.leadingModel : undefined;
      }
      
      public function set leadingModel(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().leadingModel = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get columnGap() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.columnGap : undefined;
      }
      
      public function set columnGap(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().columnGap = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get paddingLeft() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.paddingLeft : undefined;
      }
      
      public function set paddingLeft(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().paddingLeft = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get paddingTop() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.paddingTop : undefined;
      }
      
      public function set paddingTop(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().paddingTop = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get paddingRight() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.paddingRight : undefined;
      }
      
      public function set paddingRight(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().paddingRight = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get paddingBottom() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.paddingBottom : undefined;
      }
      
      public function set paddingBottom(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().paddingBottom = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get columnCount() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.columnCount : undefined;
      }
      
      public function set columnCount(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().columnCount = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get columnWidth() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.columnWidth : undefined;
      }
      
      public function set columnWidth(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().columnWidth = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get firstBaselineOffset() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.firstBaselineOffset : undefined;
      }
      
      public function set firstBaselineOffset(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().firstBaselineOffset = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get verticalAlign() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.verticalAlign : undefined;
      }
      
      public function set verticalAlign(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().verticalAlign = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get blockProgression() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.blockProgression : undefined;
      }
      
      public function set blockProgression(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().blockProgression = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get lineBreak() : *
      {
         return this._formatValueHolder ? this._formatValueHolder.lineBreak : undefined;
      }
      
      public function set lineBreak(param1:*) : void
      {
         this.writableTextLayoutFormatValueHolder().lineBreak = param1;
         this.tlf_internal::formatChanged();
      }
      
      public function get userStyles() : Object
      {
         var _loc1_:Object = this._formatValueHolder == null ? null : this._formatValueHolder.userStyles;
         return _loc1_ ? Property.shallowCopy(_loc1_) : null;
      }
      
      public function set userStyles(param1:Object) : void
      {
         var _loc3_:Object = null;
         var _loc2_:Object = new Object();
         for(_loc3_ in param1)
         {
            _loc2_[_loc3_] = param1[_loc3_];
         }
         this.writableTextLayoutFormatValueHolder().userStyles = _loc2_;
         this.tlf_internal::formatChanged();
      }
      
      public function get coreStyles() : Object
      {
         var _loc1_:Object = this._formatValueHolder == null ? null : this._formatValueHolder.coreStyles;
         return _loc1_ ? Property.shallowCopy(_loc1_) : null;
      }
      
      public function get format() : ITextLayoutFormat
      {
         return this._formatValueHolder;
      }
      
      public function set format(param1:ITextLayoutFormat) : void
      {
         this.tlf_internal::formatInternal = param1;
         this.tlf_internal::formatChanged();
      }
      
      private function writableTextLayoutFormatValueHolder() : FlowValueHolder
      {
         if(this._formatValueHolder == null)
         {
            this._formatValueHolder = new FlowValueHolder();
         }
         return this._formatValueHolder;
      }
      
      tlf_internal function set formatInternal(param1:ITextLayoutFormat) : void
      {
         if(param1 == null)
         {
            if(this._formatValueHolder == null || this._formatValueHolder.coreStyles == null)
            {
               return;
            }
            this._formatValueHolder.coreStyles = null;
         }
         else
         {
            this.writableTextLayoutFormatValueHolder().format = param1;
         }
      }
      
      public function getStyle(param1:String) : *
      {
         if(TextLayoutFormat.tlf_internal::description.hasOwnProperty(param1))
         {
            return this.computedFormat[param1];
         }
         return this.tlf_internal::getUserStyleWorker(param1);
      }
      
      public function setStyle(param1:String, param2:*) : void
      {
         if(TextLayoutFormat.tlf_internal::description[param1] !== undefined)
         {
            this[param1] = param2;
         }
         else
         {
            this._formatValueHolder.setUserStyle(param1,param2);
            this.tlf_internal::formatChanged();
         }
      }
      
      public function clearStyle(param1:String) : void
      {
         this.setStyle(param1,undefined);
      }
      
      tlf_internal function getUserStyleWorker(param1:String) : *
      {
         var _loc2_:* = this._formatValueHolder.getUserStyle(param1);
         if(_loc2_ !== undefined)
         {
            return _loc2_;
         }
         var _loc3_:TextFlow = this._rootElement ? this._rootElement.getTextFlow() : null;
         if(Boolean(_loc3_) && Boolean(_loc3_.formatResolver))
         {
            _loc2_ = _loc3_.formatResolver.resolveUserFormat(this,param1);
            if(_loc2_ !== undefined)
            {
               return _loc2_;
            }
         }
         return this._rootElement ? this._rootElement.tlf_internal::getUserStyleWorker(param1) : undefined;
      }
      
      public function get computedFormat() : ITextLayoutFormat
      {
         var _loc1_:FlowElement = null;
         var _loc2_:ITextLayoutFormat = null;
         var _loc3_:uint = 0;
         var _loc4_:TextFlow = null;
         var _loc5_:ITextLayoutFormat = null;
         if(!this._computedFormat)
         {
            FlowElement.tlf_internal::_scratchTextLayoutFormat.format = this.tlf_internal::formatForCascade;
            _loc1_ = this._rootElement;
            if(_loc1_)
            {
               while(1)
               {
                  _loc5_ = ContainerFormattedElement(_loc1_).tlf_internal::formatForCascade;
                  if(_loc5_)
                  {
                     FlowElement.tlf_internal::_scratchTextLayoutFormat.concatInheritOnly(_loc5_);
                  }
                  if(_loc1_.parent == null)
                  {
                     break;
                  }
                  _loc1_ = _loc1_.parent;
               }
            }
            _loc4_ = _loc1_ as TextFlow;
            if(_loc4_)
            {
               _loc2_ = _loc4_.tlf_internal::getDefaultFormat();
               _loc3_ = _loc4_.tlf_internal::getDefaultFormatHash();
            }
            this._computedFormat = TextFlow.tlf_internal::getCanonical(FlowElement.tlf_internal::_scratchTextLayoutFormat,_loc2_,_loc3_);
            this.tlf_internal::resetColumnState();
         }
         return this._computedFormat;
      }
      
      tlf_internal function get formatForCascade() : ITextLayoutFormat
      {
         var _loc1_:TextFlow = null;
         var _loc2_:ITextLayoutFormat = null;
         var _loc3_:ITextLayoutFormat = null;
         var _loc4_:TextLayoutFormat = null;
         if(this._rootElement)
         {
            _loc1_ = this._rootElement.getTextFlow();
            if(_loc1_)
            {
               _loc2_ = _loc1_.tlf_internal::getTextLayoutFormatStyle(this);
               if(_loc2_)
               {
                  _loc3_ = this.format;
                  if(_loc3_ == null)
                  {
                     return _loc2_;
                  }
                  _loc4_ = new TextLayoutFormat(_loc2_);
                  _loc4_.apply(_loc3_);
                  return _loc4_;
               }
            }
         }
         return this.format;
      }
      
      tlf_internal function getPlacedTextLineBounds(param1:TextLine) : Rectangle
      {
         var _loc2_:Rectangle = null;
         if(!param1.parent)
         {
            this.addTextLine(param1,0);
            _loc2_ = param1.getBounds(this._container);
            this.removeTextLine(param1);
         }
         else
         {
            _loc2_ = param1.getBounds(param1.parent);
         }
         return _loc2_;
      }
      
      tlf_internal function getInteractionHandler() : IInteractionEventHandler
      {
         return this;
      }
   }
}

import flash.display.InteractiveObject;
import flash.events.MouseEvent;

class PsuedoMouseEvent extends MouseEvent
{
   
   public function PsuedoMouseEvent(param1:String, param2:Boolean = true, param3:Boolean = false, param4:Number = NaN, param5:Number = NaN, param6:InteractiveObject = null, param7:Boolean = false, param8:Boolean = false, param9:Boolean = false, param10:Boolean = false)
   {
      super(param1,param2,param3,param4,param5,param6,param7,param8,param9,param10);
   }
   
   override public function get currentTarget() : Object
   {
      return relatedObject;
   }
   
   override public function get target() : Object
   {
      return relatedObject;
   }
}
