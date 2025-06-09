package fl.text
{
   import fl.text.container.TLFContainerController;
   import flash.display.CapsStyle;
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   import flash.display.JointStyle;
   import flash.display.LineScaleMode;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.AntiAliasType;
   import flash.text.FontStyle;
   import flash.text.GridFitType;
   import flash.text.StyleSheet;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFieldType;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.text.TextLineMetrics;
   import flash.text.engine.CFFHinting;
   import flash.text.engine.FontDescription;
   import flash.text.engine.FontLookup;
   import flash.text.engine.FontPosture;
   import flash.text.engine.FontWeight;
   import flash.text.engine.Kerning;
   import flash.text.engine.RenderingMode;
   import flash.text.engine.TabAlignment;
   import flash.text.engine.TextLine;
   import flash.text.engine.TextLineValidity;
   import flashx.textLayout.compose.IFlowComposer;
   import flashx.textLayout.compose.TextFlowLine;
   import flashx.textLayout.container.*;
   import flashx.textLayout.conversion.ConversionType;
   import flashx.textLayout.conversion.ITextImporter;
   import flashx.textLayout.conversion.TextConverter;
   import flashx.textLayout.edit.EditManager;
   import flashx.textLayout.edit.EditingMode;
   import flashx.textLayout.edit.ElementRange;
   import flashx.textLayout.edit.ISelectionManager;
   import flashx.textLayout.edit.SelectionFormat;
   import flashx.textLayout.edit.SelectionManager;
   import flashx.textLayout.edit.SelectionState;
   import flashx.textLayout.elements.Configuration;
   import flashx.textLayout.elements.ContainerFormattedElement;
   import flashx.textLayout.elements.FlowElement;
   import flashx.textLayout.elements.FlowGroupElement;
   import flashx.textLayout.elements.FlowLeafElement;
   import flashx.textLayout.elements.InlineGraphicElement;
   import flashx.textLayout.elements.LinkElement;
   import flashx.textLayout.elements.TextFlow;
   import flashx.textLayout.events.CompositionCompleteEvent;
   import flashx.textLayout.events.FlowElementMouseEvent;
   import flashx.textLayout.events.FlowOperationEvent;
   import flashx.textLayout.events.TextLayoutEvent;
   import flashx.textLayout.formats.BlockProgression;
   import flashx.textLayout.formats.Direction;
   import flashx.textLayout.formats.FormatValue;
   import flashx.textLayout.formats.ITextLayoutFormat;
   import flashx.textLayout.formats.LeadingModel;
   import flashx.textLayout.formats.LineBreak;
   import flashx.textLayout.formats.TabStopFormat;
   import flashx.textLayout.formats.TextDecoration;
   import flashx.textLayout.formats.TextLayoutFormat;
   import flashx.textLayout.formats.TextLayoutFormatValueHolder;
   import flashx.textLayout.formats.WhiteSpaceCollapse;
   import flashx.textLayout.operations.CutOperation;
   import flashx.textLayout.operations.DeleteTextOperation;
   import flashx.textLayout.operations.FlowOperation;
   import flashx.textLayout.operations.FlowTextOperation;
   import flashx.textLayout.operations.InsertTextOperation;
   import flashx.textLayout.operations.PasteOperation;
   import flashx.textLayout.operations.SplitParagraphOperation;
   import flashx.textLayout.tlf_internal;
   
   use namespace tlf_internal;
   
   public class TLFTextField extends Sprite
   {
      
      private static var noCondenseWhiteConfig:Configuration;
      
      private static var condenseWhiteConfig:Configuration;
      
      protected static var textImporter:ITextImporter;
      
      protected static var htmlNoCondenseWhite:ITextImporter;
      
      protected static var noCondenseWhiteFormat:TextLayoutFormat;
      
      protected static var condenseWhiteFormat:TextLayoutFormat;
      
      protected static var htmlCondenseWhite:ITextImporter;
      
      protected static var xmlNoCondenseWhite:ITextImporter;
      
      protected static var xmlCondenseWhite:ITextImporter;
      
      protected static const INVALID_NONE:uint = 0;
      
      protected static const INVALID_TEXT:uint = 1;
      
      protected static const INVALID_DIMENSIONS:uint = 2;
      
      protected static const INVALID_BORDER:uint = 4;
      
      protected static const INVALID_WORD_WRAP:uint = 8;
      
      protected static const INVALID_SELECTION:uint = 16;
      
      protected static const INVALID_AUTO_SIZE:uint = 32;
      
      protected static const INVALID_TYPE:uint = 64;
      
      protected static const INVALID_ALL:uint = INVALID_TEXT | INVALID_DIMENSIONS | INVALID_BORDER | INVALID_WORD_WRAP | INVALID_SELECTION | INVALID_AUTO_SIZE | INVALID_TYPE;
      
      protected static var alwaysShowSelectionOnFormat:SelectionFormat = new SelectionFormat(14937852,1,"normal",0,0,"normal",0);
      
      protected static var alwaysShowSelectionOffFormat:SelectionFormat = new SelectionFormat(12047870,0,"normal",0,0,"normal",0);
      
      protected static var focusedSelectionFormat:SelectionFormat = new SelectionFormat(12047870,1,"normal",0,1,"normal",500);
      
      protected static var inactiveSelectionFormat:SelectionFormat = new SelectionFormat(12047870,0,"normal",0,0,"normal",0);
      
      private static var genericFonts:Array = ["_sans","_serif","_typewriter","_gothic","_gothicMono","_mincho","_ゴシック","_等幅","_明朝"];
      
      private var _generationID:int;
      
      protected var _text:String;
      
      private var _type:String;
      
      private var _restrict:String;
      
      private var _defaultTextFormat:TextFormat;
      
      private var _mouseWheelEnabled:Boolean;
      
      private var _maxChars:int;
      
      private var _embedFonts:Boolean;
      
      private var _passwordCharacter:String;
      
      private var _maxScrollVFirstLineIndex:int;
      
      private var originalHeight:Number = 0;
      
      private var _maxScrollVFirstLineRect:Rectangle;
      
      protected var _invalidTextLayoutFormat:TextLayoutFormat;
      
      private var _antiAliasType:String;
      
      private var originalWidth:Number = 0;
      
      private var _alwaysShowSelection:Boolean;
      
      private var _inlineInfo:*;
      
      private var _priorSelectionBeginIndex:int = 0;
      
      private var _hasScrollRect:Boolean;
      
      private var _backgroundAlpha:Number;
      
      private var _backgroundColor:uint;
      
      private var objInit:Boolean;
      
      private var _htmlTextGenerationID:int;
      
      private var _contentWidth:Number = 0;
      
      private var _bgShape2:Shape;
      
      private var _maxScrollH:int;
      
      protected var _invalidState:uint;
      
      private var _maxScrollV:int;
      
      private var _background:Boolean;
      
      protected var _displayAsPassword:Boolean;
      
      private var _borderAlpha:Number;
      
      private var _htmlText:String;
      
      private var _borderColor:uint;
      
      private var _contentHeight:Number = 0;
      
      private var _gridFitType:String;
      
      private var _tlfMarkupGenerationID:int;
      
      private var _maxScrollVCached:Boolean;
      
      private var _isPointText:Boolean;
      
      private var _paddingLock:Boolean;
      
      private var _multiline:Boolean;
      
      private var _bgShape:Shape;
      
      private var _tlfMarkup:String;
      
      private var _borderWidth:Number;
      
      private var _textTypeLocation:String;
      
      private var _border:Boolean;
      
      private var _condenseWhite:Boolean;
      
      protected var _controller:TLFContainerController;
      
      protected var _textFlow:TextFlow;
      
      private var _maxScrollHCached:Boolean;
      
      private var _prevAutoSize:String;
      
      private var _useRichTextClipboard:Boolean;
      
      private var _maxScrollVLastLineRect:Rectangle;
      
      protected var _inRepaint:Boolean;
      
      private var _autoSize:String;
      
      protected var _wordWrap:Boolean;
      
      private var _priorSelectionEndIndex:int = 0;
      
      private var _selectable:Boolean;
      
      public function TLFTextField()
      {
         super();
         this._bgShape = new Shape();
         addChild(this._bgShape);
         this.initController();
         this._textTypeLocation = "bottomRight";
         doubleClickEnabled = true;
         tabEnabled = false;
         focusRect = false;
         this._hasScrollRect = false;
         if(condenseWhiteConfig == null)
         {
            condenseWhiteConfig = new Configuration();
            condenseWhiteFormat = new TextLayoutFormat();
            condenseWhiteFormat.whiteSpaceCollapse = WhiteSpaceCollapse.COLLAPSE;
            condenseWhiteConfig.textFlowInitialFormat = condenseWhiteFormat;
            noCondenseWhiteConfig = new Configuration();
            noCondenseWhiteFormat = new TextLayoutFormat();
            noCondenseWhiteFormat.whiteSpaceCollapse = WhiteSpaceCollapse.PRESERVE;
            noCondenseWhiteConfig.textFlowInitialFormat = noCondenseWhiteFormat;
            htmlNoCondenseWhite = TextConverter.getImporter(TextConverter.TEXT_FIELD_HTML_FORMAT,noCondenseWhiteConfig);
            htmlCondenseWhite = TextConverter.getImporter(TextConverter.TEXT_FIELD_HTML_FORMAT,condenseWhiteConfig);
            xmlNoCondenseWhite = TextConverter.getImporter(TextConverter.TEXT_LAYOUT_FORMAT,noCondenseWhiteConfig);
            xmlCondenseWhite = TextConverter.getImporter(TextConverter.TEXT_LAYOUT_FORMAT,condenseWhiteConfig);
            textImporter = TextConverter.getImporter(TextConverter.PLAIN_TEXT_FORMAT);
         }
         this._alwaysShowSelection = false;
         this._antiAliasType = AntiAliasType.NORMAL;
         this._autoSize = TextFieldAutoSize.NONE;
         this._background = false;
         this._backgroundAlpha = 1;
         this._backgroundColor = 16777215;
         this._border = false;
         this._borderAlpha = 1;
         this._borderColor = 0;
         this._borderWidth = 1;
         this._condenseWhite = false;
         this._defaultTextFormat = new TextFormat();
         this._defaultTextFormat.align = TextFormatAlign.LEFT;
         this._defaultTextFormat.blockIndent = 0;
         this._defaultTextFormat.bold = false;
         this._defaultTextFormat.bullet = false;
         this._defaultTextFormat.color = 0;
         this._defaultTextFormat.font = "Times New Roman";
         this._defaultTextFormat.indent = 0;
         this._defaultTextFormat.italic = false;
         this._defaultTextFormat.kerning = false;
         this._defaultTextFormat.leading = null;
         this._defaultTextFormat.leftMargin = 0;
         this._defaultTextFormat.letterSpacing = 0;
         this._defaultTextFormat.rightMargin = 0;
         this._defaultTextFormat.size = 12;
         this._defaultTextFormat.tabStops = [];
         this._defaultTextFormat.target = "";
         this._defaultTextFormat.underline = false;
         this._defaultTextFormat.url = "";
         this._displayAsPassword = false;
         this._embedFonts = false;
         this._gridFitType = GridFitType.PIXEL;
         this._maxChars = 0;
         this._mouseWheelEnabled = true;
         this._multiline = true;
         this._paddingLock = false;
         this._passwordCharacter = "*";
         this._restrict = null;
         this._text = "";
         this._htmlText = "";
         this._tlfMarkup = "";
         this._useRichTextClipboard = false;
         this._selectable = true;
         this._type = TextFieldType.DYNAMIC;
         this._wordWrap = false;
         this._controller.paddingLeft = 2;
         this._controller.paddingRight = 2;
         this._controller.paddingTop = 2;
         this._controller.paddingBottom = 2;
         this._generationID = -1;
         this._htmlTextGenerationID = -1;
         this._tlfMarkupGenerationID = -1;
         this._isPointText = false;
         this._controller.setCompositionSize(100,100);
         this.originalWidth = int.MAX_VALUE;
         this.originalHeight = int.MAX_VALUE;
         this.objInit = true;
         this._invalidState = INVALID_ALL;
      }
      
      private static function repeat(param1:String, param2:String) : String
      {
         var _loc3_:String = "";
         var _loc4_:int = 0;
         while(_loc4_ < param2.length)
         {
            if(param2.substr(_loc4_,1) == String.fromCharCode(10))
            {
               _loc3_ += param2.substr(_loc4_,1);
            }
            else
            {
               _loc3_ += param1;
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      private static function locateNearestColumn(param1:ContainerController, param2:Number, param3:Number, param4:String, param5:String) : int
      {
         var _loc8_:Rectangle = null;
         var _loc9_:Rectangle = null;
         var _loc6_:int = 0;
         var _loc7_:ColumnState = param1.columnState;
         while(_loc6_ < _loc7_.columnCount - 1)
         {
            _loc8_ = _loc7_.getColumnAt(_loc6_);
            _loc9_ = _loc7_.getColumnAt(_loc6_ + 1);
            if(_loc8_.contains(param2,param3))
            {
               break;
            }
            if(_loc9_.contains(param2,param3))
            {
               _loc6_++;
               break;
            }
            if(param4 == BlockProgression.RL)
            {
               if(param3 < _loc8_.top || param3 < _loc9_.top && Math.abs(_loc8_.bottom - param3) <= Math.abs(_loc9_.top - param3))
               {
                  break;
               }
               if(param3 > _loc9_.top)
               {
                  _loc6_++;
                  break;
               }
            }
            else if(param5 == Direction.LTR)
            {
               if(param2 < _loc8_.left || param2 < _loc9_.left && Math.abs(_loc8_.right - param2) <= Math.abs(_loc9_.left - param2))
               {
                  break;
               }
               if(param2 < _loc9_.left)
               {
                  _loc6_++;
                  break;
               }
            }
            else
            {
               if(param2 > _loc8_.right || param2 > _loc9_.right && Math.abs(_loc8_.left - param2) <= Math.abs(_loc9_.right - param2))
               {
                  break;
               }
               if(param2 > _loc9_.right)
               {
                  _loc6_++;
                  break;
               }
            }
            _loc6_++;
         }
         return _loc6_;
      }
      
      private static function testCharacter(param1:uint, param2:String) : Boolean
      {
         var _loc9_:uint = 0;
         var _loc11_:Boolean = false;
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = false;
         var _loc5_:Boolean = false;
         var _loc6_:* = true;
         var _loc7_:uint = 0;
         var _loc8_:int = param2.length;
         if(_loc8_ > 0)
         {
            _loc9_ = uint(param2.charCodeAt(0));
            if(_loc9_ == 94)
            {
               _loc3_ = true;
            }
         }
         var _loc10_:int = 0;
         while(_loc10_ < _loc8_)
         {
            _loc9_ = uint(param2.charCodeAt(_loc10_));
            _loc11_ = false;
            if(!_loc4_)
            {
               if(_loc9_ == 45)
               {
                  _loc5_ = true;
               }
               else if(_loc9_ == 94)
               {
                  _loc6_ = !_loc6_;
               }
               else if(_loc9_ == 92)
               {
                  _loc4_ = true;
               }
               else
               {
                  _loc11_ = true;
               }
            }
            else
            {
               _loc11_ = true;
               _loc4_ = false;
            }
            if(_loc11_)
            {
               if(_loc5_)
               {
                  if(_loc7_ <= param1 && param1 <= _loc9_)
                  {
                     _loc3_ = _loc6_;
                  }
                  _loc5_ = false;
                  _loc7_ = 0;
               }
               else
               {
                  if(param1 == _loc9_)
                  {
                     _loc3_ = _loc6_;
                  }
                  _loc7_ = _loc9_;
               }
            }
            _loc10_++;
         }
         return _loc3_;
      }
      
      private static function restrictChar(param1:String, param2:String) : String
      {
         var _loc6_:uint = 0;
         if(param2 == null)
         {
            return param1;
         }
         if(param2 == "")
         {
            return "";
         }
         var _loc3_:Array = [];
         var _loc4_:int = param1.length;
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            _loc6_ = uint(param1.charCodeAt(_loc5_));
            if(testCharacter(_loc6_,param2))
            {
               _loc3_.push(_loc6_);
            }
            _loc5_++;
         }
         return String.fromCharCode.apply(null,_loc3_);
      }
      
      private static function computeSelectionIndexInLine(param1:TextFlow, param2:TextLine, param3:Number, param4:Number) : int
      {
         var _loc12_:int = 0;
         if(!(param2.userData is TextFlowLine))
         {
            return -1;
         }
         var _loc5_:TextFlowLine = TextFlowLine(param2.userData);
         if(_loc5_.validity == TextLineValidity.INVALID)
         {
            return -1;
         }
         param2 = _loc5_.getTextLine(true);
         var _loc6_:* = param1.computedFormat.blockProgression == BlockProgression.RL;
         var _loc7_:Number = _loc6_ ? param3 : param4;
         var _loc8_:Point = new Point();
         _loc8_.x = param3;
         _loc8_.y = param4;
         _loc8_ = param2.localToGlobal(_loc8_);
         var _loc9_:int = param2.getAtomIndexAtPoint(_loc8_.x,_loc8_.y);
         if(_loc9_ == -1)
         {
            _loc8_.x = param3;
            _loc8_.y = param4;
            if(_loc8_.x < 0 || _loc6_ && _loc7_ > param2.ascent)
            {
               _loc8_.x = 0;
            }
            if(_loc8_.y < 0 || !_loc6_ && _loc7_ > param2.descent)
            {
               _loc8_.y = 0;
            }
            _loc8_ = param2.localToGlobal(_loc8_);
            _loc9_ = param2.getAtomIndexAtPoint(_loc8_.x,_loc8_.y);
         }
         if(_loc9_ == -1)
         {
            _loc8_.x = param3;
            _loc8_.y = param4;
            _loc8_ = param2.localToGlobal(_loc8_);
            if(!_loc6_)
            {
               return _loc8_.x <= param2.x ? _loc5_.absoluteStart : _loc5_.absoluteStart + _loc5_.textLength - 1;
            }
            return _loc8_.y <= param2.y ? _loc5_.absoluteStart : _loc5_.absoluteStart + _loc5_.textLength - 1;
         }
         var _loc10_:Rectangle = param2.getAtomBounds(_loc9_);
         var _loc11_:Boolean = false;
         if(param2.getAtomBidiLevel(_loc9_) % 2 != 0)
         {
            _loc12_ = _loc11_ ? param2.getAtomTextBlockBeginIndex(_loc9_) : param2.getAtomTextBlockEndIndex(_loc9_);
         }
         else
         {
            _loc12_ = _loc11_ ? param2.getAtomTextBlockEndIndex(_loc9_) : param2.getAtomTextBlockBeginIndex(_loc9_);
         }
         return _loc5_.paragraph.getAbsoluteStart() + _loc12_;
      }
      
      private static function splice(param1:String, param2:int, param3:int, param4:String) : String
      {
         return param1.substring(0,param2) + param4 + param1.substring(param3,param1.length);
      }
      
      tlf_internal function set contentHeight(param1:Number) : void
      {
         this._contentHeight = param1;
      }
      
      public function replaceText(param1:int, param2:int, param3:String) : void
      {
         this.repaint();
         if(param1 < 0)
         {
            param1 = 0;
         }
         var _loc4_:String = this.getEditingMode(this.textFlow.interactionManager);
         this.switchToEditingMode(this.textFlow,EditingMode.READ_WRITE);
         var _loc5_:EditManager = EditManager(this.textFlow.interactionManager);
         _loc5_.beginCompositeOperation();
         _loc5_.selectRange(param1,param2);
         this.insertWithParagraphs(_loc5_,param3);
         _loc5_.endCompositeOperation();
         this.textFlow.flowComposer.updateAllControllers();
         this.switchToEditingMode(this.textFlow,_loc4_);
      }
      
      public function get firstBaselineOffset() : Object
      {
         return this._controller.computedFormat.firstBaselineOffset;
      }
      
      protected function repaint(param1:Event = null) : void
      {
         var wmode:String = null;
         var format:TextLayoutFormat = null;
         var e:Event = param1;
         if(this._inRepaint)
         {
            return;
         }
         try
         {
            this._inRepaint = true;
            if(e != null)
            {
               if(e.type == Event.ADDED && e.target != this)
               {
                  return;
               }
               removeEventListener(Event.ADDED,this.repaint);
               removeEventListener(Event.ADDED_TO_STAGE,this.repaint);
               removeEventListener(Event.FRAME_CONSTRUCTED,this.repaint);
               if(stage != null)
               {
                  stage.removeEventListener(Event.RENDER,this.repaint);
               }
               else if(e.type == Event.RENDER)
               {
                  e.target.removeEventListener(Event.RENDER,this.repaint);
               }
            }
            if(this._invalidState == INVALID_NONE)
            {
               return;
            }
            wmode = this.getBlockProgression();
            if(Boolean(this._textFlow) && Boolean(this._textFlow.flowComposer))
            {
               if(this._invalidState & (INVALID_AUTO_SIZE | INVALID_WORD_WRAP))
               {
                  if(this._prevAutoSize != null && this.originalWidth != int.MAX_VALUE)
                  {
                     if(this._prevAutoSize != TextFieldAutoSize.NONE)
                     {
                        if(this._wordWrap)
                        {
                           if(wmode != BlockProgression.RL)
                           {
                              if(isNaN(this._controller.compositionWidth))
                              {
                                 this.originalWidth = this._controller.tlf_internal::contentWidth;
                              }
                              else
                              {
                                 this.originalWidth = this._controller.compositionWidth;
                              }
                              this.originalHeight = this._controller.tlf_internal::contentHeight;
                           }
                           else
                           {
                              this.originalWidth = this._controller.tlf_internal::contentWidth;
                              if(isNaN(this._controller.compositionWidth))
                              {
                                 this.originalHeight = this._controller.tlf_internal::contentHeight;
                              }
                              else
                              {
                                 this.originalHeight = this._controller.compositionHeight;
                              }
                           }
                        }
                        else
                        {
                           this.originalWidth = this._controller.tlf_internal::contentWidth;
                           this.originalHeight = this._controller.tlf_internal::contentHeight;
                        }
                     }
                     else
                     {
                        this.originalWidth = this._controller.compositionWidth;
                        this.originalHeight = this._controller.compositionHeight;
                     }
                  }
                  if(this._invalidState & INVALID_WORD_WRAP)
                  {
                     if(this._prevAutoSize == null)
                     {
                        if(this._autoSize != TextFieldAutoSize.NONE)
                        {
                           if(!this._wordWrap)
                           {
                              if(wmode != BlockProgression.RL)
                              {
                                 if(isNaN(this._controller.compositionWidth))
                                 {
                                    this.originalWidth = this._controller.tlf_internal::contentWidth;
                                 }
                                 else
                                 {
                                    this.originalWidth = this._controller.compositionWidth;
                                 }
                                 this.originalHeight = this._controller.tlf_internal::contentHeight;
                              }
                              else
                              {
                                 this.originalWidth = this._controller.tlf_internal::contentWidth;
                                 if(isNaN(this._controller.compositionHeight))
                                 {
                                    this.originalHeight = this._controller.tlf_internal::contentHeight;
                                 }
                                 else
                                 {
                                    this.originalHeight = this._controller.compositionHeight;
                                 }
                              }
                           }
                           else
                           {
                              this.originalWidth = this._controller.tlf_internal::contentWidth;
                              this.originalHeight = this._controller.tlf_internal::contentHeight;
                           }
                        }
                        else
                        {
                           this.originalWidth = this._controller.compositionWidth;
                           this.originalHeight = this._controller.compositionHeight;
                        }
                     }
                     this._textFlow.lineBreak = this._wordWrap ? LineBreak.TO_FIT : LineBreak.EXPLICIT;
                  }
                  else
                  {
                     this._wordWrap = this._textFlow.computedFormat.lineBreak == LineBreak.TO_FIT;
                  }
                  if(this.originalWidth == int.MAX_VALUE)
                  {
                     this.originalWidth = 0;
                     this.originalHeight = 0;
                  }
                  if(this._autoSize != TextFieldAutoSize.NONE)
                  {
                     if(this._wordWrap)
                     {
                        if(wmode != BlockProgression.RL)
                        {
                           if(isNaN(this._controller.compositionWidth))
                           {
                              this._controller.setCompositionSize(this._controller.tlf_internal::contentWidth,NaN);
                           }
                           else
                           {
                              this._controller.setCompositionSize(this._controller.compositionWidth,NaN);
                           }
                        }
                        else if(isNaN(this._controller.compositionHeight))
                        {
                           this._controller.setCompositionSize(NaN,this._controller.tlf_internal::contentHeight);
                        }
                        else
                        {
                           this._controller.setCompositionSize(NaN,this._controller.compositionHeight);
                        }
                     }
                     else
                     {
                        this._controller.setCompositionSize(NaN,NaN);
                     }
                  }
                  else if(this._invalidState & INVALID_AUTO_SIZE && this._prevAutoSize != null && this._prevAutoSize != this._autoSize)
                  {
                     if(!this.objInit)
                     {
                        if(this._wordWrap)
                        {
                           if(wmode != BlockProgression.RL)
                           {
                              this._controller.setCompositionSize(this._controller.compositionWidth,this._controller.tlf_internal::contentHeight);
                           }
                           else
                           {
                              this._controller.setCompositionSize(this._controller.tlf_internal::contentWidth,this._controller.compositionHeight);
                           }
                        }
                        else
                        {
                           this._controller.setCompositionSize(this._controller.tlf_internal::contentWidth,this._controller.tlf_internal::contentHeight);
                        }
                     }
                  }
                  this.objInit = false;
                  this._prevAutoSize = null;
               }
               else
               {
                  this._wordWrap = this._textFlow.computedFormat.lineBreak == LineBreak.TO_FIT;
               }
               if(Boolean(this._invalidState & INVALID_TEXT) && this._invalidTextLayoutFormat != null)
               {
                  format = this._invalidTextLayoutFormat;
                  this._invalidTextLayoutFormat = null;
                  this.setFormatForAllElements(this.textFlow,format);
               }
               if(this._invalidState & (INVALID_TEXT | INVALID_DIMENSIONS | INVALID_WORD_WRAP | INVALID_AUTO_SIZE))
               {
                  this._textFlow.flowComposer.updateAllControllers();
               }
            }
            if(this._invalidState & (INVALID_TEXT | INVALID_DIMENSIONS | INVALID_BORDER | INVALID_WORD_WRAP | INVALID_AUTO_SIZE))
            {
               this.drawBorder(wmode);
            }
            this._invalidState = INVALID_NONE;
         }
         finally
         {
            this._inRepaint = false;
         }
      }
      
      private function doImport(param1:String, param2:String) : void
      {
         var cacheAutoSize:String;
         var cacheSelectable:Boolean;
         var dataImporter:ITextImporter = null;
         var tmpTextFlow:TextFlow = null;
         var errMsg:String = null;
         var errorString:String = null;
         var cacheDefaultTextFormat:TextFormat = null;
         var importType:String = param1;
         var value:String = param2;
         var txtFormat:ITextLayoutFormat = null;
         var cacheAntiAliasType:String = null;
         var cacheEmbedFonts:Boolean = this._embedFonts;
         var cacheEmbedFontsSet:Boolean = false;
         var cacheGridFitType:String = null;
         if(this._textFlow)
         {
            this.tlf_internal::removeTextFlowEventListeners();
            txtFormat = this._textFlow.hostFormat;
            cacheAntiAliasType = this.antiAliasType;
            cacheEmbedFonts = this.embedFonts;
            cacheEmbedFontsSet = true;
            cacheGridFitType = this.gridFitType;
            this._prevAutoSize = this._autoSize;
         }
         if(importType == TextConverter.TEXT_FIELD_HTML_FORMAT)
         {
            if(this._condenseWhite)
            {
               dataImporter = htmlCondenseWhite;
            }
            else
            {
               dataImporter = htmlNoCondenseWhite;
            }
         }
         else if(importType == TextConverter.TEXT_LAYOUT_FORMAT)
         {
            if(this._condenseWhite)
            {
               dataImporter = xmlCondenseWhite;
            }
            else
            {
               dataImporter = xmlNoCondenseWhite;
            }
         }
         else if(importType == TextConverter.PLAIN_TEXT_FORMAT)
         {
            dataImporter = textImporter;
         }
         dataImporter.throwOnError = false;
         try
         {
            tmpTextFlow = dataImporter.importToFlow(value);
            if(dataImporter.errors)
            {
               for each(errorString in dataImporter.errors)
               {
                  errMsg += "Error: " + errorString + "\n";
               }
            }
            if(tmpTextFlow)
            {
               this._textFlow = tmpTextFlow;
            }
            else
            {
               dataImporter = textImporter;
               this._textFlow = dataImporter.importToFlow("");
            }
         }
         catch(e:Error)
         {
            dataImporter = textImporter;
            _textFlow = dataImporter.importToFlow("");
         }
         this._textFlow.flowComposer.addController(this._controller);
         if(txtFormat)
         {
            this._textFlow.hostFormat = txtFormat;
         }
         else
         {
            cacheDefaultTextFormat = this._defaultTextFormat;
            this._defaultTextFormat = null;
            this.defaultTextFormat = cacheDefaultTextFormat;
         }
         this.tlf_internal::addTextFlowEventListeners();
         if(cacheAntiAliasType != null)
         {
            this.antiAliasType = cacheAntiAliasType;
         }
         else
         {
            this.antiAliasType = this._antiAliasType;
         }
         this.embedFonts = cacheEmbedFonts;
         if(cacheGridFitType != null)
         {
            this.gridFitType = cacheGridFitType;
         }
         else
         {
            this.gridFitType = this._gridFitType;
         }
         this.wordWrap = this._wordWrap;
         cacheAutoSize = this._autoSize;
         this._autoSize = "NA";
         this.autoSize = cacheAutoSize;
         cacheSelectable = this._selectable;
         this._selectable = !this._selectable;
         this.selectable = cacheSelectable;
         this.invalidate(INVALID_ALL);
         this.scrollV = 0;
         this.setDefaultScrollPosition(this.controller);
      }
      
      public function get columnWidth() : Object
      {
         return this._controller.computedFormat.columnWidth;
      }
      
      public function set firstBaselineOffset(param1:Object) : void
      {
         var n:Number = NaN;
         var value:Object = param1;
         try
         {
            this._controller.firstBaselineOffset = value;
         }
         catch(e:Error)
         {
            n = Number(value);
            if(isNaN(n))
            {
               _controller.firstBaselineOffset = "auto";
            }
            else if(n < 0)
            {
               _controller.firstBaselineOffset = 0;
            }
            else if(n > 1000)
            {
               _controller.firstBaselineOffset = 1000;
            }
            else
            {
               _controller.firstBaselineOffset = "auto";
            }
         }
         this.invalidate(INVALID_TEXT);
      }
      
      public function set columnWidth(param1:Object) : void
      {
         var n:Number = NaN;
         var value:Object = param1;
         if(this._controller.columnWidth == value)
         {
            return;
         }
         try
         {
            this._controller.columnWidth = value;
         }
         catch(e:Error)
         {
            n = Number(value);
            if(n < 0 || isNaN(n))
            {
               _controller.columnWidth = 0;
            }
            else if(n > 8000)
            {
               _controller.columnWidth = 8000;
            }
         }
         this.invalidate(INVALID_TEXT);
      }
      
      private function getEditingMode(param1:ISelectionManager) : String
      {
         return param1 ? param1.editingMode : EditingMode.READ_ONLY;
      }
      
      tlf_internal function get firstField() : TLFTextField
      {
         var _loc1_:TLFContainerController = null;
         if(Boolean(this.textFlow) && Boolean(this.textFlow.flowComposer))
         {
            _loc1_ = this.textFlow.flowComposer.getControllerAt(0) as TLFContainerController;
            if(_loc1_)
            {
               return _loc1_.ownerField;
            }
         }
         return null;
      }
      
      public function get border() : Boolean
      {
         return this._border;
      }
      
      public function get styleSheet() : StyleSheet
      {
         return null;
      }
      
      public function getFirstCharInParagraph(param1:int) : int
      {
         var _loc2_:TextFlowLine = this.textFlow.flowComposer.findLineAtPosition(param1);
         if(_loc2_)
         {
            return _loc2_.paragraph.getAbsoluteStart();
         }
         throw new RangeError("The character index specified is out of range.");
      }
      
      public function set scrollH(param1:int) : void
      {
         if(this._textFlow == null)
         {
            return;
         }
         if(this._maxScrollHCached && this._maxScrollH == 0)
         {
            return;
         }
         this.repaint();
         if(!this._maxScrollHCached)
         {
            this.maxScrollH;
            if(!this._maxScrollHCached || this._maxScrollH == 0)
            {
               return;
            }
         }
         if(param1 < 0)
         {
            param1 = 0;
         }
         else if(param1 > this._maxScrollH)
         {
            param1 = this._maxScrollH;
         }
         if(this._textFlow.direction == Direction.RTL)
         {
            param1 = -param1;
         }
         if(this._textFlow.blockProgression == BlockProgression.RL)
         {
            this._controller.verticalScrollPosition = param1;
         }
         else
         {
            this._controller.horizontalScrollPosition = param1;
         }
      }
      
      public function get textColor() : uint
      {
         if(this.textFlow)
         {
            this.repaint();
            return uint(this.textFlow.getFirstLeaf().computedFormat.color);
         }
         return 0;
      }
      
      public function isFontCompatible(param1:String, param2:String) : Boolean
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         if(param2 == FontStyle.REGULAR)
         {
            _loc3_ = FontWeight.NORMAL;
            _loc4_ = FontPosture.NORMAL;
         }
         else if(param2 == FontStyle.BOLD)
         {
            _loc3_ = FontWeight.BOLD;
            _loc4_ = FontPosture.NORMAL;
         }
         else if(param2 == FontStyle.ITALIC)
         {
            _loc3_ = FontWeight.NORMAL;
            _loc4_ = FontPosture.ITALIC;
         }
         else
         {
            if(param2 != FontStyle.BOLD_ITALIC)
            {
               throw new ArgumentError("The fontStyle specified is not a member of flash.text.FontStyle.");
            }
            _loc3_ = FontWeight.BOLD;
            _loc4_ = FontPosture.ITALIC;
         }
         return FontDescription.isFontCompatible(param1,_loc3_,_loc4_);
      }
      
      override public function set height(param1:Number) : void
      {
         if(param1 != this._controller.compositionHeight)
         {
            this._controller.setCompositionSize(this._controller.compositionWidth,param1);
            this.invalidate(INVALID_DIMENSIONS);
         }
      }
      
      public function get autoSize() : String
      {
         return this._autoSize;
      }
      
      public function get selectionBeginIndex() : int
      {
         if(this.textFlow.interactionManager)
         {
            return this.textFlow.interactionManager.absoluteStart < 0 ? 0 : this.textFlow.interactionManager.absoluteStart;
         }
         return this._priorSelectionBeginIndex;
      }
      
      public function get selectable() : Boolean
      {
         var _loc1_:TLFTextField = this.tlf_internal::firstField;
         return _loc1_ ? _loc1_._selectable : this._selectable;
      }
      
      public function set scrollV(param1:int) : void
      {
         if(this._textFlow == null)
         {
            return;
         }
         if(this._maxScrollVCached && this._maxScrollV == 0)
         {
            return;
         }
         this.repaint();
         if(!this._controller.tlf_internal::hasScrollRect)
         {
            return;
         }
         if(!this._maxScrollVCached)
         {
            this.maxScrollV;
            if(!this._maxScrollVCached || this._maxScrollV == 0)
            {
               return;
            }
         }
         if(param1 < 0)
         {
            param1 = 0;
         }
         else if(param1 > this._maxScrollV)
         {
            param1 = this._maxScrollV;
         }
         if(param1 == 0)
         {
            if(this._textFlow.blockProgression == BlockProgression.RL)
            {
               this._controller.horizontalScrollPosition = Math.max(0,this._maxScrollVFirstLineRect.right);
            }
            else
            {
               this._controller.verticalScrollPosition = Math.min(0,this._maxScrollVFirstLineRect.top);
            }
            return;
         }
         if(param1 == this._maxScrollV)
         {
            if(this._textFlow.blockProgression == BlockProgression.RL)
            {
               this._controller.horizontalScrollPosition = Math.min(this._controller.tlf_internal::contentLeft,this._maxScrollVLastLineRect.left);
            }
            else
            {
               this._controller.verticalScrollPosition = Math.max(this._controller.tlf_internal::contentHeight,this._maxScrollVLastLineRect.bottom);
            }
            return;
         }
         var _loc2_:IFlowComposer = this._textFlow.flowComposer;
         var _loc3_:TextFlowLine = this.textFlow.flowComposer.getLineAt(param1 + this._maxScrollVFirstLineIndex - 1);
         var _loc4_:Rectangle = _loc3_.getBounds();
         if(this._textFlow.blockProgression == BlockProgression.RL)
         {
            if(Math.abs(this._controller.tlf_internal::contentLeft - _loc4_.right) < this._controller.compositionWidth)
            {
               this._controller.horizontalScrollPosition = Math.max(this._controller.tlf_internal::contentLeft,this._maxScrollVLastLineRect.left);
            }
            else
            {
               this._controller.horizontalScrollPosition = _loc4_.right;
            }
         }
         else if(this._controller.tlf_internal::contentHeight - _loc4_.top < this._controller.compositionHeight)
         {
            this._controller.verticalScrollPosition = Math.max(this._controller.tlf_internal::contentHeight,this._maxScrollVLastLineRect.bottom);
         }
         else
         {
            this._controller.verticalScrollPosition = _loc4_.top;
         }
      }
      
      public function set text(param1:String) : void
      {
         var _loc2_:FlowLeafElement = null;
         if(param1 == null)
         {
            param1 = "";
         }
         if(!this._textFlow)
         {
            this.doImport(TextConverter.PLAIN_TEXT_FORMAT,param1);
         }
         else
         {
            _loc2_ = this._textFlow.getFirstLeaf();
            if(_loc2_)
            {
               this._textFlow.hostFormat = _loc2_.computedFormat;
            }
            this.replaceText(0,this.length,param1);
         }
         this._text = param1;
         this.scrollH = 0;
         this.scrollV = 0;
         this.setDefaultScrollPosition(this.controller);
      }
      
      public function set verticalAlign(param1:String) : void
      {
         this._controller.verticalAlign = param1;
         this.invalidate(INVALID_TEXT);
      }
      
      private function textFlow_ScrollHandler(param1:TextLayoutEvent) : void
      {
         this.invalidate(INVALID_BORDER);
         this.repaint();
         dispatchEvent(new Event(Event.SCROLL,false,false));
      }
      
      public function set background(param1:Boolean) : void
      {
         if(this._background == param1)
         {
            return;
         }
         this._background = param1;
         this.invalidate(INVALID_BORDER);
      }
      
      public function set border(param1:Boolean) : void
      {
         if(this._border == param1)
         {
            return;
         }
         this._border = param1;
         this.invalidate(INVALID_BORDER);
      }
      
      public function get antiAliasType() : String
      {
         return this.textFlow.renderingMode == RenderingMode.NORMAL ? AntiAliasType.NORMAL : AntiAliasType.ADVANCED;
      }
      
      public function get selectionEndIndex() : int
      {
         if(this.textFlow.interactionManager)
         {
            return this.textFlow.interactionManager.absoluteEnd < 0 ? 0 : this.textFlow.interactionManager.absoluteEnd;
         }
         return this._priorSelectionEndIndex;
      }
      
      public function set styleSheet(param1:StyleSheet) : void
      {
      }
      
      public function set textColor(param1:uint) : void
      {
         param1 &= 16777215;
         this._defaultTextFormat.color = param1;
         if(this._invalidTextLayoutFormat == null)
         {
            this._invalidTextLayoutFormat = new TextLayoutFormat();
         }
         this._invalidTextLayoutFormat.color = param1;
         this.invalidate(INVALID_TEXT);
      }
      
      private function textFlow_flowOperationEndHandler(param1:FlowOperationEvent) : void
      {
         var _loc2_:FlowOperation = param1.operation;
         if(_loc2_ is PasteOperation)
         {
            this.handlePasteOperation(PasteOperation(_loc2_));
         }
         dispatchEvent(new Event(Event.CHANGE,false,false));
      }
      
      public function set type(param1:String) : void
      {
         if(param1 != TextFieldType.INPUT && param1 != TextFieldType.DYNAMIC)
         {
            throw new ArgumentError("The type specified is not a member of flash.text.TextFieldType.");
         }
         if(this.type == param1)
         {
            return;
         }
         var _loc2_:TLFTextField = this.tlf_internal::firstField;
         if(!_loc2_)
         {
            _loc2_ = this;
         }
         _loc2_._type = param1;
         this.doTypeSet(_loc2_);
      }
      
      tlf_internal function get minScrollV() : int
      {
         if(this._textFlow == null)
         {
            return 0;
         }
         if(!this._maxScrollVCached)
         {
            this.maxScrollV;
            if(!this._maxScrollVCached)
            {
               return 0;
            }
         }
         if(this._textFlow.blockProgression == BlockProgression.RL)
         {
            return this._maxScrollVFirstLineRect.right >= 0 ? 1 : 0;
         }
         return this._maxScrollVFirstLineRect.top <= 0 ? 1 : 0;
      }
      
      public function get wordWrap() : Boolean
      {
         this.repaint();
         return this.textFlow.computedFormat.lineBreak == LineBreak.TO_FIT;
      }
      
      private function setDefaultScrollPosition(param1:ContainerController) : void
      {
         if(param1 == null)
         {
            return;
         }
         if(param1.computedFormat.blockProgression == BlockProgression.RL)
         {
            param1.verticalScrollPosition = -param1.paddingLeft;
            param1.horizontalScrollPosition = param1.paddingTop;
         }
         else
         {
            param1.verticalScrollPosition = -param1.paddingTop;
            param1.horizontalScrollPosition = -param1.paddingLeft;
         }
      }
      
      public function get bottomScrollV() : int
      {
         var _loc7_:TextFlowLine = null;
         var _loc8_:Rectangle = null;
         this.repaint();
         var _loc1_:IFlowComposer = this.textFlow.flowComposer;
         var _loc2_:ContainerController = _loc1_.getControllerAt(_loc1_.numControllers - 1);
         var _loc3_:int = _loc1_.findLineIndexAtPosition(this._controller.absoluteStart);
         var _loc4_:int = this.numLines - 1;
         if(_loc4_ < 1)
         {
            return 1;
         }
         if(!_loc2_.tlf_internal::hasScrollRect)
         {
            return _loc4_ + 1;
         }
         var _loc5_:int = 1;
         var _loc6_:int = _loc4_;
         while(_loc6_ >= _loc3_)
         {
            _loc7_ = _loc1_.getLineAt(_loc6_);
            _loc8_ = _loc7_.getBounds();
            if(_loc7_.textLineExists && Boolean(_loc7_.getTextLine().parent))
            {
               if(_loc2_.computedFormat.blockProgression == BlockProgression.RL)
               {
                  if(_loc7_.x > _loc2_.container.scrollRect.x)
                  {
                     _loc5_ = _loc6_ + 1;
                     break;
                  }
               }
               else if(_loc8_.bottom < _loc2_.container.scrollRect.bottom)
               {
                  _loc5_ = _loc6_ + 1;
                  break;
               }
            }
            _loc6_--;
         }
         return _loc5_;
      }
      
      public function set alwaysShowSelection(param1:Boolean) : void
      {
         var _loc4_:SelectionFormat = null;
         if(this.alwaysShowSelection == param1)
         {
            return;
         }
         var _loc2_:TLFTextField = this.tlf_internal::firstField;
         if(!_loc2_)
         {
            _loc2_ = this;
         }
         _loc2_._alwaysShowSelection = param1;
         var _loc3_:ISelectionManager = _loc2_.textFlow.interactionManager;
         if(_loc3_ != null)
         {
            if(_loc3_.focusedSelectionFormat != focusedSelectionFormat)
            {
               _loc3_.focusedSelectionFormat = focusedSelectionFormat;
            }
            if(_loc3_.inactiveSelectionFormat != inactiveSelectionFormat)
            {
               _loc3_.inactiveSelectionFormat = inactiveSelectionFormat;
            }
            _loc4_ = this.alwaysShowSelection ? alwaysShowSelectionOnFormat : alwaysShowSelectionOffFormat;
            if(_loc3_.unfocusedSelectionFormat != _loc4_)
            {
               _loc3_.unfocusedSelectionFormat = _loc4_;
            }
         }
      }
      
      public function set sharpness(param1:Number) : void
      {
      }
      
      public function getLineIndexOfChar(param1:int) : int
      {
         var _loc2_:TextFlowLine = this.textFlow.flowComposer.findLineAtPosition(param1);
         if(_loc2_)
         {
            return this.textFlow.flowComposer.findLineIndexAtPosition(param1);
         }
         throw new RangeError("Character index out of range.");
      }
      
      tlf_internal function get prevField() : TLFTextField
      {
         var _loc1_:int = 0;
         var _loc2_:TLFContainerController = null;
         if(Boolean(this.textFlow) && Boolean(this.textFlow.flowComposer))
         {
            _loc1_ = this.textFlow.flowComposer.getControllerIndex(this.controller);
            if(_loc1_ > 0)
            {
               _loc2_ = this.textFlow.flowComposer.getControllerAt(_loc1_ - 1) as TLFContainerController;
               if(_loc2_)
               {
                  return _loc2_.ownerField;
               }
            }
         }
         return null;
      }
      
      protected function setFormatForAllElements(param1:FlowGroupElement, param2:TextLayoutFormat) : void
      {
         var _loc5_:FlowElement = null;
         var _loc6_:TextLayoutFormatValueHolder = null;
         var _loc3_:int = param1.numChildren;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = param1.getChildAt(_loc4_);
            if(_loc5_ is FlowGroupElement)
            {
               this.setFormatForAllElements(FlowGroupElement(_loc5_),param2);
            }
            else
            {
               _loc6_ = new TextLayoutFormatValueHolder(_loc5_.format);
               _loc6_.apply(param2);
               _loc5_.format = _loc6_;
            }
            _loc4_++;
         }
      }
      
      private function handlePasteOperation(param1:PasteOperation) : void
      {
         if(!this._restrict && !this._maxChars && !this._displayAsPassword)
         {
            return;
         }
         var _loc2_:String = TextConverter.export(param1.textScrap.tlf_internal::textFlow,TextConverter.PLAIN_TEXT_FORMAT,ConversionType.STRING_TYPE) as String;
         if(this._displayAsPassword)
         {
            this._text = splice(this._text,param1.absoluteStart,param1.absoluteStart,_loc2_);
         }
         var _loc3_:EditManager = EditManager(this.textFlow.interactionManager);
         var _loc4_:SelectionState = new SelectionState(param1.textFlow,param1.absoluteStart,param1.absoluteStart + _loc2_.length);
         _loc3_.deleteText(_loc4_);
         this.replaceText(param1.absoluteStart,param1.absoluteStart,_loc2_);
      }
      
      public function get paddingRight() : Object
      {
         return this._controller.computedFormat.paddingRight;
      }
      
      protected function drawBorder(param1:String) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Graphics = this._bgShape.graphics;
         _loc3_.clear();
         if(this._border && this._borderWidth > 0)
         {
            _loc2_ = this._borderWidth / 2 - this._borderWidth;
            if(this._background)
            {
               _loc3_.beginFill(this._backgroundColor,this._backgroundAlpha);
            }
            _loc3_.lineStyle(this._borderWidth,this._borderColor,this._borderAlpha,false,LineScaleMode.NORMAL,CapsStyle.NONE,JointStyle.MITER,10);
            if(this.tlf_internal::isPointText || this._autoSize != TextFieldAutoSize.NONE)
            {
               if(this._wordWrap)
               {
                  if(param1 != BlockProgression.RL)
                  {
                     if(!isNaN(this._controller.compositionWidth))
                     {
                        _loc3_.drawRect(_loc2_,_loc2_,this._controller.compositionWidth + this.borderWidth,this._controller.tlf_internal::contentHeight + this.borderWidth);
                     }
                  }
                  else if(!isNaN(this._controller.compositionHeight))
                  {
                     _loc3_.drawRect(_loc2_,_loc2_,this._controller.tlf_internal::contentWidth + this.borderWidth,this._controller.compositionHeight + this.borderWidth);
                  }
               }
               else
               {
                  _loc3_.drawRect(_loc2_,_loc2_,this._controller.tlf_internal::contentWidth + this.borderWidth,this._controller.tlf_internal::contentHeight + this.borderWidth);
               }
            }
            else if(!isNaN(this._controller.compositionWidth) && !isNaN(this._controller.compositionHeight))
            {
               _loc3_.drawRect(_loc2_,_loc2_,this._controller.compositionWidth + this.borderWidth,this._controller.compositionHeight + this.borderWidth);
            }
            if(this._background)
            {
               _loc3_.endFill();
               if(this._bgShape2 != null)
               {
                  removeChild(this._bgShape2);
                  this._bgShape2 = null;
               }
            }
            else
            {
               if(this._bgShape2 == null)
               {
                  this._bgShape2 = new Shape();
                  this._bgShape2.visible = false;
                  addChildAt(this._bgShape2,0);
               }
               _loc3_ = this._bgShape2.graphics;
               _loc3_.clear();
               _loc3_.beginFill(0);
               _loc3_.drawRect(this._bgShape.x,this._bgShape.y,this._bgShape.width,this._bgShape.height);
               _loc3_.endFill();
            }
            this._bgShape.visible = true;
         }
         else
         {
            if(this._bgShape2 != null)
            {
               removeChild(this._bgShape2);
               this._bgShape2 = null;
            }
            _loc3_.beginFill(this._backgroundColor,this._backgroundAlpha);
            if(this.tlf_internal::isPointText || this._autoSize != TextFieldAutoSize.NONE)
            {
               _loc3_.drawRect(0,0,this._controller.tlf_internal::contentWidth,this._controller.tlf_internal::contentHeight);
            }
            else if(!isNaN(this._controller.compositionWidth) && !isNaN(this._controller.compositionHeight))
            {
               _loc3_.drawRect(0,0,this._controller.compositionWidth,this._controller.compositionHeight);
            }
            _loc3_.endFill();
            this._bgShape.visible = this._background;
         }
      }
      
      public function get borderAlpha() : Number
      {
         return this._borderAlpha;
      }
      
      public function get borderColor() : uint
      {
         return this._borderColor;
      }
      
      public function set condenseWhite(param1:Boolean) : void
      {
         this._condenseWhite = param1;
      }
      
      public function get textWidth() : Number
      {
         this.repaint();
         this.textFlow.flowComposer.composeToPosition();
         return this._controller.tlf_internal::contentWidth - (Number(this.paddingLeft) + Number(this.paddingRight));
      }
      
      public function set autoSize(param1:String) : void
      {
         if(this._autoSize == param1)
         {
            return;
         }
         if(param1 != TextFieldAutoSize.NONE && param1 != TextFieldAutoSize.LEFT && param1 != TextFieldAutoSize.RIGHT && param1 != TextFieldAutoSize.CENTER)
         {
            throw new ArgumentError("The autoSize specified is not a member of flash.text.TextFieldAutoSize.");
         }
         if(this._prevAutoSize == null)
         {
            this._prevAutoSize = this._autoSize;
         }
         this._autoSize = param1;
         this.invalidate(INVALID_AUTO_SIZE);
      }
      
      public function get defaultTextFormat() : TextFormat
      {
         return this._defaultTextFormat;
      }
      
      public function get useRichTextClipboard() : Boolean
      {
         return this._useRichTextClipboard;
      }
      
      public function get embedFonts() : Boolean
      {
         return this.textFlow.fontLookup == FontLookup.EMBEDDED_CFF;
      }
      
      public function get multiline() : Boolean
      {
         return this._multiline;
      }
      
      private function createTextLayoutFormat(param1:TextFormat) : TextLayoutFormat
      {
         var _loc3_:Array = null;
         var _loc4_:String = null;
         var _loc5_:TabStopFormat = null;
         var _loc2_:TextLayoutFormat = new TextLayoutFormat();
         if(param1.align != null)
         {
            if(param1.align == TextFormatAlign.CENTER || param1.align == TextFormatAlign.JUSTIFY || param1.align == TextFormatAlign.LEFT || param1.align == TextFormatAlign.RIGHT)
            {
               _loc2_.textAlign = param1.align;
            }
            else
            {
               _loc2_.textAlign = TextFormatAlign.RIGHT;
            }
         }
         if(param1.blockIndent != null && param1.leftMargin != null)
         {
            _loc2_.paragraphStartIndent = param1.blockIndent + param1.leftMargin;
         }
         else if(param1.blockIndent != null)
         {
            _loc2_.paragraphStartIndent = param1.blockIndent;
         }
         else if(param1.leftMargin != null)
         {
            _loc2_.paragraphStartIndent = param1.leftMargin;
         }
         if(param1.indent != null)
         {
            _loc2_.textIndent = param1.indent;
         }
         if(param1.leading != null)
         {
            _loc2_.lineHeight = param1.leading;
            _loc2_.leadingModel = LeadingModel.APPROXIMATE_TEXT_FIELD;
         }
         if(param1.rightMargin != null)
         {
            _loc2_.paragraphEndIndent = param1.rightMargin;
         }
         if(param1.tabStops != null)
         {
            _loc3_ = new Array();
            param1.tabStops.sort(Array.NUMERIC);
            for each(_loc4_ in param1.tabStops)
            {
               _loc5_ = new TabStopFormat();
               _loc5_.alignment = TabAlignment.DECIMAL;
               _loc5_.position = int(_loc4_);
               _loc3_.push(_loc5_);
            }
            _loc2_.tabStops = _loc3_;
         }
         if(param1.bold != null)
         {
            _loc2_.fontWeight = param1.bold ? FontWeight.BOLD : FontWeight.NORMAL;
         }
         if(param1.color != null)
         {
            _loc2_.color = param1.color;
         }
         if(param1.font != null)
         {
            _loc2_.fontFamily = param1.font;
         }
         if(param1.italic != null)
         {
            _loc2_.fontStyle = param1.italic ? FontPosture.ITALIC : FontPosture.NORMAL;
         }
         if(param1.kerning != null)
         {
            _loc2_.kerning = param1.kerning ? Kerning.ON : Kerning.OFF;
         }
         if(param1.letterSpacing != null)
         {
            _loc2_.trackingRight = param1.letterSpacing;
         }
         if(param1.size != null)
         {
            _loc2_.fontSize = param1.size;
         }
         if(param1.underline != null)
         {
            _loc2_.textDecoration = param1.underline ? TextDecoration.UNDERLINE : TextDecoration.NONE;
         }
         return _loc2_;
      }
      
      public function set columnCount(param1:Object) : void
      {
         var n:Number = NaN;
         var value:Object = param1;
         if(this._controller.columnCount == value)
         {
            return;
         }
         try
         {
            this._controller.columnCount = value;
         }
         catch(e:Error)
         {
            n = Number(value);
            if(n < 1 || isNaN(n))
            {
               _controller.columnCount = 1;
            }
            else if(n > 50)
            {
               _controller.columnCount = 50;
            }
         }
         this.invalidate(INVALID_TEXT);
      }
      
      public function set selectable(param1:Boolean) : void
      {
         if(this.selectable == param1)
         {
            return;
         }
         var _loc2_:TLFTextField = this.tlf_internal::firstField;
         if(!_loc2_)
         {
            _loc2_ = this;
         }
         _loc2_._selectable = param1;
         this.doTypeSet(_loc2_);
      }
      
      public function getLineText(param1:int) : String
      {
         if(param1 < 0 || param1 >= this.numLines)
         {
            throw new RangeError("The line number specified is out of range.");
         }
         var _loc2_:TextFlowLine = this.getValidTextFlowLine(param1);
         var _loc3_:int = _loc2_.absoluteStart - _loc2_.paragraph.getAbsoluteStart();
         return _loc2_.paragraph.getText().substr(_loc3_,_loc2_.textLength);
      }
      
      public function get mouseWheelEnabled() : Boolean
      {
         return this._mouseWheelEnabled;
      }
      
      public function get textHeight() : Number
      {
         this.repaint();
         this.textFlow.flowComposer.composeToPosition();
         return this._controller.tlf_internal::contentHeight - (this.paddingTop + this.paddingBottom);
      }
      
      public function get restrict() : String
      {
         return this._restrict;
      }
      
      public function get tlfMarkup() : String
      {
         if(this.textFlow.generation != this._tlfMarkupGenerationID || this._tlfMarkup == "")
         {
            this._tlfMarkup = TextConverter.export(this.textFlow,TextConverter.TEXT_LAYOUT_FORMAT,ConversionType.STRING_TYPE) as String;
            this._tlfMarkupGenerationID = this.textFlow.generation;
         }
         return this._tlfMarkup;
      }
      
      private function getValidTextFlowLineFromCharIndex(param1:int) : TextFlowLine
      {
         if(param1 >= 0 && param1 < this.textFlow.textLength)
         {
            return this.textFlow.flowComposer.findLineAtPosition(param1);
         }
         throw new RangeError("The character index specified is out of range.");
      }
      
      public function set displayAsPassword(param1:Boolean) : void
      {
         if(this._displayAsPassword == param1)
         {
            return;
         }
         if(param1)
         {
            this._text = this.text;
         }
         this._displayAsPassword = param1;
         this.replaceText(0,this.textFlow.textLength - 1,this._text);
      }
      
      public function get gridFitType() : String
      {
         if(this.textFlow.cffHinting == CFFHinting.NONE)
         {
            this._gridFitType = GridFitType.NONE;
         }
         else if(this._gridFitType != GridFitType.SUBPIXEL)
         {
            this._gridFitType = GridFitType.PIXEL;
         }
         return this._gridFitType;
      }
      
      tlf_internal function get contentWidth() : Number
      {
         return this._contentWidth;
      }
      
      public function get backgroundColor() : uint
      {
         return this._backgroundColor;
      }
      
      public function get maxChars() : int
      {
         var _loc1_:TLFTextField = this.tlf_internal::firstField;
         return _loc1_ ? _loc1_._maxChars : 0;
      }
      
      tlf_internal function get isPointText() : Boolean
      {
         return this.textFlow != null && this._isPointText;
      }
      
      protected function initController() : void
      {
         var _loc1_:Sprite = new Sprite();
         this._controller = new TLFContainerController(_loc1_,this);
         addChild(_loc1_);
         _loc1_.tabEnabled = true;
         _loc1_.focusRect = false;
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
      }
      
      tlf_internal function get textTypeLocation() : String
      {
         return this._textTypeLocation;
      }
      
      public function set antiAliasType(param1:String) : void
      {
         if(this.antiAliasType == param1)
         {
            return;
         }
         if(this._invalidTextLayoutFormat == null)
         {
            this._invalidTextLayoutFormat = new TextLayoutFormat();
         }
         this._invalidTextLayoutFormat.renderingMode = FormatValue.INHERIT;
         this.textFlow.renderingMode = param1 == AntiAliasType.ADVANCED ? RenderingMode.CFF : RenderingMode.NORMAL;
         this.invalidate(INVALID_TEXT);
      }
      
      tlf_internal function get paddingLock() : Boolean
      {
         return this._paddingLock;
      }
      
      public function get length() : int
      {
         return this.text.length;
      }
      
      tlf_internal function get inlineInfo() : *
      {
         return this._inlineInfo;
      }
      
      public function get backgroundAlpha() : Number
      {
         return this._backgroundAlpha;
      }
      
      private function composeComplete(param1:CompositionCompleteEvent) : void
      {
         var _loc2_:ContainerFormattedElement = null;
         var _loc3_:String = null;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         if(param1.target as TextFlow != this.textFlow)
         {
            return;
         }
         this._maxScrollVCached = this._maxScrollHCached = false;
         if(this._autoSize != TextFieldAutoSize.NONE)
         {
            _loc2_ = this._controller.rootElement;
            _loc3_ = _loc2_.computedFormat.blockProgression;
            _loc4_ = 0;
            _loc5_ = 0;
            if(_loc3_ != BlockProgression.RL)
            {
               if(!this._wordWrap)
               {
                  if(this._autoSize == TextFieldAutoSize.RIGHT)
                  {
                     _loc4_ = this.originalWidth - this._controller.tlf_internal::contentWidth;
                  }
                  else if(this._autoSize == TextFieldAutoSize.CENTER)
                  {
                     _loc4_ = (this.originalWidth - this._controller.tlf_internal::contentWidth) / 2;
                  }
               }
            }
            else
            {
               _loc4_ = this.tlf_internal::contentWidth - this.tlf_internal::contentWidth;
               if(!this._wordWrap)
               {
                  if(this._autoSize == TextFieldAutoSize.RIGHT)
                  {
                     _loc5_ = this.originalHeight - this._controller.tlf_internal::contentHeight;
                  }
                  else if(this._autoSize == TextFieldAutoSize.CENTER)
                  {
                     _loc5_ = (this.originalHeight - this._controller.tlf_internal::contentHeight) / 2;
                  }
               }
            }
            this.setDefaultScrollPosition(this.controller);
            this.x += _loc4_;
            this.y += _loc5_;
            this.tlf_internal::contentWidth = this.tlf_internal::contentWidth;
            this.tlf_internal::contentHeight = this.tlf_internal::contentHeight;
         }
         this.originalWidth = this._controller.tlf_internal::contentWidth;
         this.originalHeight = this._controller.tlf_internal::contentHeight;
         if(this.tlf_internal::isPointText || this._autoSize != TextFieldAutoSize.NONE)
         {
            this.invalidate(INVALID_BORDER);
            this.repaint();
         }
      }
      
      public function set thickness(param1:Number) : void
      {
      }
      
      public function set htmlText(param1:String) : void
      {
         var _loc2_:FlowLeafElement = null;
         if(this._textFlow)
         {
            _loc2_ = this._textFlow.getFirstLeaf();
            if(_loc2_)
            {
               this._textFlow.hostFormat = _loc2_.computedFormat;
            }
         }
         this.doImport(TextConverter.TEXT_FIELD_HTML_FORMAT,param1);
         this._htmlText = this.htmlText;
      }
      
      public function getLineMetrics(param1:int) : TextLineMetrics
      {
         var _loc3_:Number = NaN;
         if(param1 < 0 || param1 >= this.numLines)
         {
            throw new RangeError("The line number specified is out of range.");
         }
         var _loc2_:TextFlowLine = this.getValidTextFlowLine(param1);
         if(_loc2_)
         {
            _loc3_ = _loc2_.height;
            if(_loc3_ < _loc2_.ascent + _loc2_.descent)
            {
               _loc3_ = _loc2_.ascent + _loc2_.descent;
            }
            if(param1 == 0)
            {
               return new TextLineMetrics(_loc2_.x,_loc2_.unjustifiedTextWidth,_loc3_,_loc2_.ascent,_loc2_.descent,0);
            }
            return new TextLineMetrics(_loc2_.x,_loc2_.unjustifiedTextWidth,_loc3_,_loc2_.ascent,_loc2_.descent,_loc2_.height - (_loc2_.ascent + _loc2_.descent));
         }
         return null;
      }
      
      public function get borderWidth() : Number
      {
         return this._borderWidth;
      }
      
      public function set direction(param1:String) : void
      {
         this.textFlow.direction = param1;
         this.textFlow.flowComposer.updateAllControllers();
      }
      
      tlf_internal function get contentHeight() : Number
      {
         return this._contentHeight;
      }
      
      public function set paddingTop(param1:Object) : void
      {
         var n:Number = NaN;
         var value:Object = param1;
         if(this._controller.paddingTop == value)
         {
            return;
         }
         try
         {
            this._controller.paddingTop = value;
         }
         catch(e:Error)
         {
            n = Number(value);
            if(isNaN(n))
            {
               _controller.paddingTop = "auto";
            }
            else if(n < 0)
            {
               _controller.paddingTop = value = 0;
            }
            else if(n > 1000)
            {
               _controller.paddingTop = value = 1000;
            }
            else
            {
               _controller.paddingTop = value = "auto";
            }
         }
         this._controller.paddingTop = value;
         if(this._paddingLock)
         {
            this._controller.paddingLeft = value;
            this._controller.paddingRight = value;
            this._controller.paddingBottom = value;
         }
         this.invalidate(INVALID_TEXT);
      }
      
      public function get caretIndex() : int
      {
         if(this.textFlow.interactionManager)
         {
            return this.textFlow.interactionManager.activePosition < 0 ? 0 : this.textFlow.interactionManager.activePosition;
         }
         return this._priorSelectionBeginIndex;
      }
      
      private function switchToEditingMode(param1:TextFlow, param2:String, param3:Boolean = true) : void
      {
         if(param2 == null || this.getEditingMode(param1.interactionManager) == param2)
         {
            return;
         }
         if(param1.interactionManager != null)
         {
            this._priorSelectionBeginIndex = param1.interactionManager.anchorPosition;
            this._priorSelectionEndIndex = param1.interactionManager.activePosition;
         }
         if(param2 == EditingMode.READ_WRITE)
         {
            param1.interactionManager = new EditManager();
         }
         else if(param2 == EditingMode.READ_SELECT)
         {
            param1.interactionManager = new SelectionManager();
         }
         else
         {
            param1.interactionManager = null;
         }
         if(param1.interactionManager)
         {
            this.setSelection(this._priorSelectionBeginIndex,this._priorSelectionEndIndex);
            param1.interactionManager.focusedSelectionFormat = focusedSelectionFormat;
            param1.interactionManager.inactiveSelectionFormat = inactiveSelectionFormat;
            if(this.alwaysShowSelection)
            {
               param1.interactionManager.unfocusedSelectionFormat = alwaysShowSelectionOnFormat;
            }
            else
            {
               param1.interactionManager.unfocusedSelectionFormat = alwaysShowSelectionOffFormat;
            }
         }
         if(param3)
         {
            this.invalidate(INVALID_TEXT);
         }
      }
      
      public function set wordWrap(param1:Boolean) : void
      {
         this._wordWrap = param1;
         this.invalidate(INVALID_WORD_WRAP);
      }
      
      public function set paddingRight(param1:Object) : void
      {
         var n:Number = NaN;
         var value:Object = param1;
         if(this._controller.paddingRight == value)
         {
            return;
         }
         try
         {
            this._controller.paddingRight = value;
         }
         catch(e:Error)
         {
            n = Number(value);
            if(isNaN(n))
            {
               _controller.paddingRight = "auto";
            }
            else if(n < 0)
            {
               _controller.paddingRight = value = 0;
            }
            else if(n > 1000)
            {
               _controller.paddingRight = value = 1000;
            }
            else
            {
               _controller.paddingRight = value = "auto";
            }
         }
         if(this._paddingLock)
         {
            this._controller.paddingLeft = value;
            this._controller.paddingTop = value;
            this._controller.paddingBottom = value;
         }
         this.invalidate(INVALID_TEXT);
      }
      
      public function get maxScrollH() : int
      {
         if(this._textFlow == null)
         {
            return 0;
         }
         if(this._maxScrollHCached)
         {
            return this._maxScrollH;
         }
         this.repaint();
         var _loc1_:IFlowComposer = this._textFlow.flowComposer;
         _loc1_.composeToPosition();
         this._maxScrollH = this._textFlow.blockProgression == BlockProgression.RL ? int(this._controller.tlf_internal::contentHeight - this._controller.compositionHeight) : int(this._controller.tlf_internal::contentWidth - this._controller.compositionWidth);
         if(this._maxScrollH < 0)
         {
            this._maxScrollH = 0;
         }
         this._maxScrollHCached = true;
         return this._maxScrollH;
      }
      
      public function get numLines() : int
      {
         this.repaint();
         var _loc1_:IFlowComposer = this.textFlow.flowComposer;
         return _loc1_.numLines;
      }
      
      public function get maxScrollV() : int
      {
         var _loc7_:Number = NaN;
         if(this._textFlow == null)
         {
            return 0;
         }
         if(this._maxScrollVCached)
         {
            return this._maxScrollV;
         }
         this.repaint();
         var _loc1_:IFlowComposer = this._textFlow.flowComposer;
         _loc1_.composeToPosition();
         if(_loc1_.getControllerIndex(this._controller) < _loc1_.numControllers - 1)
         {
            this._maxScrollVCached = true;
            this._maxScrollV = 0;
            return this._maxScrollV;
         }
         var _loc2_:int = _loc1_.numLines;
         var _loc3_:int = this._controller.columnState.columnCount - 1;
         this._maxScrollVFirstLineIndex = _loc1_.findLineIndexAtPosition(this._controller.absoluteStart);
         var _loc4_:TextFlowLine = _loc1_.getLineAt(this._maxScrollVFirstLineIndex);
         if(_loc4_ == null)
         {
            this._maxScrollVCached = true;
            this._maxScrollV = 0;
            return this._maxScrollV;
         }
         while(_loc4_.columnIndex != _loc3_)
         {
            ++this._maxScrollVFirstLineIndex;
            if(this._maxScrollVFirstLineIndex >= _loc2_)
            {
               this._maxScrollVCached = true;
               this._maxScrollV = 0;
               return this._maxScrollV;
            }
            _loc4_ = _loc1_.getLineAt(this._maxScrollVFirstLineIndex);
         }
         this._maxScrollVFirstLineRect = _loc4_.getBounds();
         var _loc5_:int = _loc2_ - 1;
         var _loc6_:TextFlowLine = _loc1_.getLineAt(_loc5_);
         this._maxScrollVLastLineRect = _loc6_.getBounds();
         var _loc8_:* = this._textFlow.blockProgression == BlockProgression.RL;
         if(_loc8_)
         {
            _loc7_ = Math.round(Math.min(this._maxScrollVLastLineRect.left,this._controller.tlf_internal::contentLeft) + this._controller.compositionWidth);
            if(_loc7_ >= 0)
            {
               this._maxScrollVCached = true;
               this._maxScrollV = 0;
               return this._maxScrollV;
            }
         }
         else
         {
            _loc7_ = Math.round(Math.max(this._maxScrollVLastLineRect.bottom,this._controller.tlf_internal::contentHeight) - this._controller.compositionHeight);
            if(_loc7_ <= 0)
            {
               this._maxScrollVCached = true;
               this._maxScrollV = 0;
               return this._maxScrollV;
            }
         }
         _loc5_--;
         while(_loc5_ > this._maxScrollVFirstLineIndex)
         {
            _loc6_ = _loc1_.getLineAt(_loc5_);
            if(_loc8_)
            {
               if(Math.round(_loc6_.getBounds().right) > _loc7_)
               {
                  break;
               }
            }
            else if(Math.round(_loc6_.getBounds().top) < _loc7_)
            {
               break;
            }
            _loc5_--;
         }
         this._maxScrollV = _loc5_ - this._maxScrollVFirstLineIndex + 2;
         this._maxScrollVCached = true;
         return this._maxScrollV;
      }
      
      public function getImageReference(param1:String) : DisplayObject
      {
         var _loc3_:InlineGraphicElement = null;
         var _loc2_:FlowLeafElement = this.textFlow.getFirstLeaf();
         while(_loc2_)
         {
            if(_loc2_ is InlineGraphicElement)
            {
               _loc3_ = InlineGraphicElement(_loc2_);
               if(String(_loc3_.id).toUpperCase() == param1.toUpperCase())
               {
                  return _loc3_.graphic;
               }
            }
            _loc2_ = _loc2_.getNextLeaf();
         }
         return null;
      }
      
      override public function get height() : Number
      {
         this.repaint();
         return super.height;
      }
      
      override public function set blendMode(param1:String) : void
      {
         this._controller.container.blendMode = param1;
      }
      
      public function get scrollV() : int
      {
         var _loc4_:TextFlowLine = null;
         var _loc5_:Rectangle = null;
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         if(this._textFlow == null)
         {
            return 0;
         }
         if(this._maxScrollVCached && this._maxScrollV == 0)
         {
            return 0;
         }
         this.repaint();
         var _loc1_:IFlowComposer = this._textFlow.flowComposer;
         _loc1_.composeToPosition();
         if(!this._maxScrollVCached)
         {
            this.maxScrollV;
            if(!this._maxScrollVCached || this._maxScrollV == 0)
            {
               return 0;
            }
         }
         var _loc2_:int = _loc1_.numLines;
         var _loc3_:int = this._maxScrollVFirstLineIndex;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = _loc1_.getLineAt(_loc3_);
            _loc5_ = _loc4_.getBounds();
            if(_loc4_.textLineExists && _loc4_.getTextLine().parent != null)
            {
               _loc6_ = _loc3_ - this._maxScrollVFirstLineIndex + 1;
               if(this._textFlow.blockProgression == BlockProgression.RL)
               {
                  _loc7_ = Math.round(this._controller.horizontalScrollPosition);
                  _loc8_ = Math.round(this._maxScrollVFirstLineRect.right);
                  if(Math.round(_loc5_.right) > _loc7_ && _loc7_ < 0)
                  {
                     _loc6_++;
                  }
                  if(_loc7_ > _loc8_ && _loc8_ < 0)
                  {
                     _loc6_--;
                  }
               }
               else
               {
                  _loc9_ = Math.round(this._controller.verticalScrollPosition);
                  _loc10_ = Math.round(this._maxScrollVFirstLineRect.top);
                  if(Math.round(_loc5_.top) < _loc9_ && _loc9_ > 0)
                  {
                     _loc6_++;
                  }
                  if(_loc9_ < _loc10_ && _loc10_ > 0)
                  {
                     _loc6_--;
                  }
               }
               if(_loc6_ > this._maxScrollV)
               {
                  _loc6_ = this._maxScrollV;
               }
               return _loc6_;
            }
            _loc3_++;
         }
         return 0;
      }
      
      public function get scrollH() : int
      {
         if(this._textFlow == null)
         {
            return 0;
         }
         if(this._maxScrollHCached && this._maxScrollH == 0)
         {
            return 0;
         }
         this.repaint();
         return this._textFlow.blockProgression == BlockProgression.RL ? int(Math.abs(this._controller.verticalScrollPosition)) : int(Math.abs(this._controller.horizontalScrollPosition));
      }
      
      public function set borderAlpha(param1:Number) : void
      {
         if(this._borderAlpha == param1)
         {
            return;
         }
         this._borderAlpha = param1;
         if(this._borderAlpha < 0)
         {
            this._borderAlpha = 0;
         }
         else if(this._borderAlpha > 1)
         {
            this._borderAlpha = 1;
         }
         this.invalidate(INVALID_BORDER);
      }
      
      public function get text() : String
      {
         if(!this._textFlow)
         {
            return "";
         }
         if(!this._displayAsPassword && this.textFlow.generation != this._generationID || this._text == "")
         {
            this._text = TextConverter.export(this.textFlow,TextConverter.PLAIN_TEXT_FORMAT,ConversionType.STRING_TYPE) as String;
            this._generationID = this.textFlow.generation;
         }
         return this._text;
      }
      
      public function get verticalAlign() : String
      {
         return this._controller.computedFormat.verticalAlign;
      }
      
      public function getCharBoundaries(param1:int) : Rectangle
      {
         var _loc2_:Rectangle = null;
         var _loc10_:Point = null;
         var _loc11_:Point = null;
         this.repaint();
         var _loc3_:TextFlowLine = this.textFlow.flowComposer.findLineAtPosition(param1);
         var _loc4_:TextLine = _loc3_.getTextLine(true);
         var _loc5_:int = _loc4_.getAtomIndexAtCharIndex(param1 - _loc3_.paragraph.getAbsoluteStart());
         if(_loc5_ > -1)
         {
            _loc2_ = _loc4_.getAtomBounds(_loc5_);
         }
         var _loc6_:TextFlowLine = this.getValidTextFlowLine(this.getLineIndexOfChar(param1));
         var _loc7_:Rectangle = _loc6_.getBounds();
         var _loc8_:String = this.textFlow.computedFormat.blockProgression;
         var _loc9_:* = _loc8_ == BlockProgression.RL;
         if(!_loc9_)
         {
            _loc2_.x += _loc7_.x;
            _loc2_.y = _loc7_.y;
            _loc10_ = this._controller.container.localToGlobal(new Point(_loc2_.x,_loc2_.y));
            _loc11_ = this.globalToLocal(_loc10_);
            _loc2_.x = _loc11_.x;
            _loc2_.y = _loc11_.y;
         }
         else
         {
            _loc2_.x += _loc7_.x;
            _loc2_.y += _loc7_.y;
            _loc10_ = this._controller.container.localToGlobal(new Point(_loc2_.x,_loc2_.y));
            _loc11_ = this.globalToLocal(_loc10_);
            _loc2_.x = _loc11_.x;
            _loc2_.y = _loc11_.y;
         }
         return _loc2_;
      }
      
      public function set paddingBottom(param1:Object) : void
      {
         var n:Number = NaN;
         var value:Object = param1;
         if(this._controller.paddingBottom == value)
         {
            return;
         }
         try
         {
            this._controller.paddingBottom = value;
         }
         catch(e:Error)
         {
            n = Number(value);
            if(isNaN(n))
            {
               _controller.paddingBottom = "auto";
            }
            else if(n < 0)
            {
               _controller.paddingBottom = value = 0;
            }
            else if(n > 1000)
            {
               _controller.paddingBottom = value = 1000;
            }
            else
            {
               _controller.paddingBottom = value = "auto";
            }
         }
         if(this._paddingLock)
         {
            this._controller.paddingLeft = value;
            this._controller.paddingTop = value;
            this._controller.paddingRight = value;
         }
         this.invalidate(INVALID_TEXT);
      }
      
      public function get type() : String
      {
         var _loc1_:TLFTextField = this.tlf_internal::firstField;
         return _loc1_ ? _loc1_._type : this._type;
      }
      
      public function replaceSelectedText(param1:String) : void
      {
         var _loc2_:String = this.getEditingMode(this.textFlow.interactionManager);
         if(_loc2_ != EditingMode.READ_WRITE)
         {
            this.switchToEditingMode(this.textFlow,EditingMode.READ_WRITE);
         }
         var _loc3_:EditManager = EditManager(this.textFlow.interactionManager);
         _loc3_.beginCompositeOperation();
         if(!_loc3_.hasSelection())
         {
            _loc3_.selectRange(int.MAX_VALUE,int.MAX_VALUE);
         }
         var _loc4_:Number = _loc3_.anchorPosition;
         this.insertWithParagraphs(_loc3_,param1);
         this.textFlow.flowComposer.updateAllControllers();
         if(this._defaultTextFormat != null)
         {
            this.setTextFormat(this._defaultTextFormat,_loc4_,_loc4_ + param1.length);
         }
         _loc3_.endCompositeOperation();
         this.invalidate(INVALID_TEXT);
         if(_loc2_ != EditingMode.READ_WRITE)
         {
            this.switchToEditingMode(this.textFlow,_loc2_);
         }
      }
      
      public function get background() : Boolean
      {
         return this._background;
      }
      
      public function get alwaysShowSelection() : Boolean
      {
         var _loc1_:TLFTextField = this.tlf_internal::firstField;
         return _loc1_ ? _loc1_._alwaysShowSelection : this._alwaysShowSelection;
      }
      
      public function get sharpness() : Number
      {
         return 0;
      }
      
      private function insertWithParagraphs(param1:EditManager, param2:String) : void
      {
         var _loc3_:Array = null;
         var _loc4_:Number = NaN;
         var _loc5_:String = null;
         param2 = param2.replace("\r","");
         if(param2 == "")
         {
            param1.insertText("");
         }
         else
         {
            _loc3_ = param2.split("\n");
            _loc4_ = param1.absoluteStart;
            _loc5_ = _loc3_.shift();
            while(_loc5_ != null)
            {
               param1.insertText(_loc5_);
               _loc4_ += _loc5_.length;
               if(_loc3_.length > 0)
               {
                  param1.selectRange(_loc4_,_loc4_);
                  param1.splitParagraph();
                  _loc4_++;
               }
               _loc5_ = _loc3_.shift();
            }
         }
      }
      
      public function set borderColor(param1:uint) : void
      {
         if(this._borderColor == param1)
         {
            return;
         }
         this._borderColor = param1;
         if(this._borderColor > 16777215)
         {
            this._borderColor = 16777215;
         }
         this.invalidate(INVALID_BORDER);
      }
      
      public function set columnGap(param1:Object) : void
      {
         var n:Number = NaN;
         var value:Object = param1;
         if(this._controller.columnGap == value)
         {
            return;
         }
         try
         {
            this._controller.columnGap = value;
         }
         catch(e:Error)
         {
            n = Number(value);
            if(n < 0 || isNaN(n))
            {
               _controller.columnGap = 0;
            }
            else if(n > 1000)
            {
               _controller.columnGap = 1000;
            }
         }
         this.invalidate(INVALID_TEXT);
      }
      
      public function set defaultTextFormat(param1:TextFormat) : void
      {
         var _loc2_:TLFTextField = null;
         if(this.defaultTextFormat == param1)
         {
            return;
         }
         this._defaultTextFormat = param1;
         if(param1)
         {
            if(this._defaultTextFormat.font == null)
            {
               this._defaultTextFormat.font = "Times New Roman";
            }
            _loc2_ = this.tlf_internal::firstField;
            if(!_loc2_)
            {
               _loc2_ = this;
            }
            _loc2_.textFlow.hostFormat = this.createTextLayoutFormat(param1);
         }
      }
      
      public function get condenseWhite() : Boolean
      {
         return this._condenseWhite;
      }
      
      public function get displayAsPassword() : Boolean
      {
         return this._displayAsPassword;
      }
      
      public function setSelection(param1:int, param2:int) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         else if(param1 > this.textFlow.textLength)
         {
            param1 = this.length - 1;
         }
         if(param2 < 0)
         {
            param2 = 0;
         }
         else if(param2 > this.textFlow.textLength)
         {
            param2 = this.length - 1;
         }
         if(this.textFlow.interactionManager)
         {
            this.textFlow.interactionManager.selectRange(param1,param2);
            this.invalidate(INVALID_TEXT);
         }
         else
         {
            this._priorSelectionBeginIndex = param1;
            this._priorSelectionEndIndex = param2;
         }
      }
      
      public function set embedFonts(param1:Boolean) : void
      {
         var _loc2_:FlowLeafElement = null;
         if(this.embedFonts == param1)
         {
            return;
         }
         this.textFlow.fontLookup = param1 ? FontLookup.EMBEDDED_CFF : FontLookup.DEVICE;
         if(param1)
         {
            this.textFlow.fontLookup = FontLookup.EMBEDDED_CFF;
            _loc2_ = this.textFlow.getFirstLeaf();
            while(_loc2_)
            {
               if(String(_loc2_.computedFormat.fontFamily).charAt(0) == "_" && genericFonts.indexOf(_loc2_.computedFormat.fontFamily) >= 0)
               {
                  _loc2_.fontLookup = FontLookup.DEVICE;
               }
               else
               {
                  _loc2_.fontLookup = FormatValue.INHERIT;
               }
               _loc2_ = _loc2_.getNextLeaf();
            }
         }
         this.invalidate(INVALID_TEXT);
      }
      
      public function get columnCount() : Object
      {
         return this._controller.computedFormat.columnCount;
      }
      
      public function set useRichTextClipboard(param1:Boolean) : void
      {
         this._useRichTextClipboard = param1;
      }
      
      tlf_internal function removeTextFlowEventListeners() : void
      {
         this.textFlow.removeEventListener(MouseEvent.CLICK,this.linkClick);
         this.textFlow.removeEventListener(FlowOperationEvent.FLOW_OPERATION_BEGIN,this.textFlow_flowOperationBeginHandler);
         this.textFlow.removeEventListener(FlowOperationEvent.FLOW_OPERATION_END,this.textFlow_flowOperationEndHandler);
         this.textFlow.removeEventListener(TextLayoutEvent.SCROLL,this.textFlow_ScrollHandler);
         this.textFlow.removeEventListener(CompositionCompleteEvent.COMPOSITION_COMPLETE,this.composeComplete);
      }
      
      protected function invalidate(param1:uint) : void
      {
         this._maxScrollVCached = this._maxScrollHCached = false;
         this._invalidState |= param1;
         if(stage != null)
         {
            stage.addEventListener(Event.RENDER,this.repaint,false,0,true);
            stage.invalidate();
         }
         else if(parent == null)
         {
            addEventListener(Event.ADDED,this.repaint,false,0,true);
         }
         else
         {
            addEventListener(Event.ADDED_TO_STAGE,this.repaint,false,0,true);
            addEventListener(Event.FRAME_CONSTRUCTED,this.repaint,false,0,true);
         }
      }
      
      public function set multiline(param1:Boolean) : void
      {
         this._multiline = param1;
      }
      
      protected function getBlockProgression() : String
      {
         var _loc2_:ITextLayoutFormat = null;
         var _loc3_:String = null;
         var _loc1_:ContainerFormattedElement = this._controller.rootElement;
         if(_loc1_ != null)
         {
            _loc2_ = _loc1_.computedFormat;
            if(_loc2_ != null)
            {
               _loc3_ = _loc1_.computedFormat.blockProgression;
               if(_loc3_ != null)
               {
                  return _loc3_;
               }
            }
         }
         return BlockProgression.RL;
      }
      
      public function set mouseWheelEnabled(param1:Boolean) : void
      {
         this._mouseWheelEnabled = param1;
      }
      
      public function appendText(param1:String) : void
      {
         var _loc2_:String = null;
         _loc2_ = this.textFlow.interactionManager.editingMode;
         var _loc3_:SelectionState = null;
         if(_loc2_ != EditingMode.READ_ONLY && _loc2_ != null)
         {
            if(this.textFlow.interactionManager.hasSelection())
            {
               _loc3_ = this.textFlow.interactionManager.getSelectionState();
            }
         }
         if(_loc2_ != EditingMode.READ_WRITE)
         {
            this.switchToEditingMode(this.textFlow,EditingMode.READ_WRITE);
         }
         var _loc4_:EditManager = EditManager(this.textFlow.interactionManager);
         _loc4_.selectRange(int.MAX_VALUE,int.MAX_VALUE);
         _loc4_.beginCompositeOperation();
         this.insertWithParagraphs(_loc4_,param1);
         _loc4_.endCompositeOperation();
         this.textFlow.flowComposer.updateAllControllers();
         if(_loc2_ != EditingMode.READ_WRITE && _loc2_ != null)
         {
            this.switchToEditingMode(this.textFlow,_loc2_);
         }
         if(this.textFlow.interactionManager)
         {
            if(_loc3_)
            {
               this.textFlow.interactionManager.selectRange(_loc3_.anchorPosition,_loc3_.activePosition);
            }
            else
            {
               this.textFlow.interactionManager.selectRange(-1,-1);
            }
         }
      }
      
      public function set paddingLeft(param1:Object) : void
      {
         var n:Number = NaN;
         var value:Object = param1;
         if(this._controller.paddingLeft == value)
         {
            return;
         }
         try
         {
            this._controller.paddingLeft = value;
         }
         catch(e:Error)
         {
            n = Number(value);
            if(isNaN(n))
            {
               _controller.paddingLeft = "auto";
            }
            else if(n < 0)
            {
               _controller.paddingLeft = value = 0;
            }
            else if(n > 1000)
            {
               _controller.paddingLeft = value = 1000;
            }
            else
            {
               _controller.paddingLeft = value = "auto";
            }
         }
         if(this._paddingLock)
         {
            this._controller.paddingTop = value;
            this._controller.paddingRight = value;
            this._controller.paddingBottom = value;
         }
         this.invalidate(INVALID_TEXT);
      }
      
      public function set tlfMarkup(param1:String) : void
      {
         this.doImport(TextConverter.TEXT_LAYOUT_FORMAT,param1);
         this._tlfMarkup = this.tlfMarkup;
      }
      
      public function get thickness() : Number
      {
         return 0;
      }
      
      public function getLineIndexAtPoint(param1:Number, param2:Number) : int
      {
         return this.getLineIndexOfChar(this.getCharIndexAtPoint(param1,param2));
      }
      
      public function getTextFormat(param1:int = -1, param2:int = -1) : TextFormat
      {
         var _loc3_:TextFormat = null;
         var _loc4_:SelectionState = null;
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:TextLayoutFormat = null;
         var _loc9_:TextLayoutFormat = null;
         var _loc10_:String = null;
         var _loc11_:String = null;
         var _loc12_:Array = null;
         var _loc13_:Array = null;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:TabStopFormat = null;
         var _loc17_:ElementRange = null;
         var _loc18_:FlowLeafElement = null;
         var _loc19_:LinkElement = null;
         if(param1 > this.textFlow.textLength - 1 || param1 < -1 || param2 > this.textFlow.textLength - 1 || param2 < -1)
         {
            throw new RangeError("The beginIndex or endIndex specified is out of range.");
         }
         _loc3_ = new TextFormat();
         _loc4_ = null;
         _loc5_ = this.getEditingMode(this.textFlow.interactionManager);
         if(_loc5_ != EditingMode.READ_ONLY && _loc5_ != null)
         {
            if(this.textFlow.interactionManager.hasSelection())
            {
               _loc4_ = this.textFlow.interactionManager.getSelectionState();
            }
         }
         else
         {
            this.switchToEditingMode(this.textFlow,EditingMode.READ_SELECT);
         }
         if(param1 < 0)
         {
            _loc6_ = this.textFlow.getAbsoluteStart();
            _loc7_ = this.textFlow.textLength - 1;
         }
         else if(param1 >= 0 && param2 < 0)
         {
            _loc6_ = param1;
            _loc7_ = param1;
         }
         else
         {
            _loc6_ = param1;
            _loc7_ = param2;
         }
         this.setSelection(_loc6_,_loc7_);
         _loc8_ = TextLayoutFormat(this.textFlow.interactionManager.getCommonCharacterFormat());
         _loc9_ = TextLayoutFormat(this.textFlow.interactionManager.getCommonParagraphFormat());
         if(_loc5_ == EditingMode.READ_ONLY)
         {
            this.switchToEditingMode(this.textFlow,_loc5_);
         }
         if(_loc4_)
         {
            this.textFlow.interactionManager.selectRange(_loc4_.anchorPosition,_loc4_.activePosition);
         }
         else
         {
            this.textFlow.interactionManager.selectRange(-1,-1);
         }
         if(_loc9_.textAlign == TextFormatAlign.LEFT || _loc9_.textAlign == TextFormatAlign.CENTER || _loc9_.textAlign == TextFormatAlign.RIGHT || _loc9_.textAlign == TextFormatAlign.JUSTIFY)
         {
            _loc3_.align = _loc9_.textAlign;
         }
         else
         {
            _loc3_.align = null;
         }
         if(_loc8_.fontWeight == undefined)
         {
            _loc3_.bold = null;
         }
         else
         {
            _loc3_.bold = _loc8_.fontWeight == FontWeight.BOLD;
         }
         _loc3_.color = _loc8_.color;
         if(_loc8_.fontFamily == undefined)
         {
            _loc3_.font = null;
         }
         else
         {
            _loc12_ = String(_loc8_.fontFamily).split(",");
            _loc3_.font = _loc12_[0];
         }
         _loc3_.indent = _loc9_.textIndent;
         if(_loc8_.fontStyle == undefined)
         {
            _loc3_.italic = null;
         }
         else
         {
            _loc3_.italic = _loc8_.fontStyle == FontPosture.ITALIC;
         }
         if(_loc8_.kerning == undefined)
         {
            _loc3_.kerning = null;
         }
         else
         {
            _loc3_.kerning = _loc8_.kerning == Kerning.ON || _loc8_.kerning == Kerning.AUTO;
         }
         if(_loc8_.lineHeight == undefined)
         {
            _loc3_.leading = null;
         }
         else
         {
            _loc3_.leading = _loc8_.lineHeight;
         }
         _loc3_.leftMargin = _loc9_.paragraphStartIndent;
         _loc3_.letterSpacing = _loc8_.trackingRight;
         _loc3_.rightMargin = _loc9_.paragraphEndIndent;
         _loc3_.size = _loc8_.fontSize;
         if(_loc9_.tabStops == undefined)
         {
            _loc3_.tabStops = null;
         }
         else
         {
            _loc13_ = [];
            if(_loc9_.tabStops != null)
            {
               _loc14_ = int(_loc9_.tabStops.length);
               _loc15_ = 0;
               while(_loc15_ < _loc14_)
               {
                  _loc16_ = _loc9_.tabStops[_loc15_];
                  if(_loc16_.alignment == TabAlignment.DECIMAL)
                  {
                     _loc13_.push(_loc16_.position);
                  }
                  _loc15_++;
               }
               _loc13_.sort(Array.NUMERIC);
            }
            _loc3_.tabStops = _loc13_;
         }
         if(_loc8_.textDecoration == undefined)
         {
            _loc3_.underline = null;
         }
         else
         {
            _loc3_.underline = _loc8_.textDecoration == TextDecoration.UNDERLINE;
         }
         _loc10_ = null;
         _loc11_ = null;
         if(_loc6_ <= _loc7_)
         {
            _loc17_ = ElementRange.createElementRange(this.textFlow,_loc6_,_loc7_);
            _loc18_ = _loc17_.firstLeaf;
            while(_loc18_)
            {
               _loc19_ = _loc18_.getParentByType(LinkElement) as LinkElement;
               if(_loc19_ != null)
               {
                  if(_loc10_ == null)
                  {
                     _loc10_ = _loc19_.href;
                  }
                  else if(_loc10_ != _loc19_.href)
                  {
                     _loc10_ = "";
                  }
                  if(_loc11_ == null)
                  {
                     if(_loc19_.target == null)
                     {
                        _loc11_ = "";
                     }
                     else
                     {
                        _loc11_ = _loc19_.target;
                     }
                  }
                  else if(_loc11_ != _loc19_.target)
                  {
                     _loc11_ = "";
                  }
               }
               else
               {
                  _loc10_ = "";
                  _loc11_ = "";
               }
               if(_loc18_ == _loc17_.lastLeaf)
               {
                  break;
               }
               _loc18_ = _loc18_.getNextLeaf();
            }
         }
         _loc3_.url = _loc10_ == "" ? null : _loc10_;
         _loc3_.target = _loc11_ == "" ? null : _loc11_;
         return _loc3_;
      }
      
      public function get direction() : String
      {
         return this.textFlow.direction;
      }
      
      public function get paddingTop() : Object
      {
         return this._controller.computedFormat.paddingTop;
      }
      
      public function setTextFormat(param1:TextFormat, param2:int = -1, param3:int = -1) : void
      {
         var _loc9_:SelectionState = null;
         var _loc10_:Array = null;
         var _loc11_:String = null;
         var _loc12_:TabStopFormat = null;
         if(param2 > this.textFlow.textLength - 1 || param2 < -1 || param3 > this.textFlow.textLength - 1 || param3 < -1)
         {
            throw new RangeError("The beginIndex or endIndex specified is out of range.");
         }
         var _loc4_:SelectionState = null;
         var _loc5_:TextLayoutFormat = new TextLayoutFormat();
         var _loc6_:TextLayoutFormat = new TextLayoutFormat();
         if(param1.align != null)
         {
            if(param1.align == TextFormatAlign.CENTER || param1.align == TextFormatAlign.JUSTIFY || param1.align == TextFormatAlign.LEFT || param1.align == TextFormatAlign.RIGHT)
            {
               _loc6_.textAlign = param1.align;
            }
            else
            {
               _loc6_.textAlign = TextFormatAlign.RIGHT;
            }
         }
         if(param1.blockIndent != null && param1.leftMargin != null)
         {
            _loc6_.paragraphStartIndent = param1.blockIndent + param1.leftMargin;
         }
         else if(param1.blockIndent != null)
         {
            _loc6_.paragraphStartIndent = param1.blockIndent;
         }
         else if(param1.leftMargin != null)
         {
            _loc6_.paragraphStartIndent = param1.leftMargin;
         }
         if(param1.indent != null)
         {
            _loc6_.textIndent = param1.indent;
         }
         if(param1.leading != null)
         {
            _loc6_.leadingModel = LeadingModel.APPROXIMATE_TEXT_FIELD;
            _loc5_.lineHeight = param1.leading;
         }
         if(param1.rightMargin != null)
         {
            _loc6_.paragraphEndIndent = param1.rightMargin;
         }
         if(param1.tabStops != null)
         {
            _loc10_ = new Array();
            param1.tabStops.sort(Array.NUMERIC);
            for each(_loc11_ in param1.tabStops)
            {
               _loc12_ = new TabStopFormat();
               _loc12_.alignment = TabAlignment.DECIMAL;
               _loc12_.position = int(_loc11_);
               _loc10_.push(_loc12_);
            }
            _loc6_.tabStops = _loc10_;
         }
         if(param1.bold != null)
         {
            _loc5_.fontWeight = param1.bold ? FontWeight.BOLD : FontWeight.NORMAL;
         }
         if(param1.color != null)
         {
            _loc5_.color = param1.color;
         }
         if(param1.font != null)
         {
            _loc5_.fontFamily = param1.font;
         }
         if(param1.italic != null)
         {
            _loc5_.fontStyle = param1.italic ? FontPosture.ITALIC : FontPosture.NORMAL;
         }
         if(param1.kerning != null)
         {
            _loc5_.kerning = param1.kerning ? Kerning.ON : Kerning.OFF;
         }
         if(param1.letterSpacing != null)
         {
            _loc5_.trackingRight = param1.letterSpacing;
         }
         if(param1.size != null)
         {
            _loc5_.fontSize = param1.size;
         }
         if(param1.underline != null)
         {
            _loc5_.textDecoration = param1.underline ? TextDecoration.UNDERLINE : TextDecoration.NONE;
         }
         var _loc7_:String = this.getEditingMode(this.textFlow.interactionManager);
         if(_loc7_ != EditingMode.READ_ONLY && _loc7_ != null)
         {
            if(this.textFlow.interactionManager.hasSelection())
            {
               _loc4_ = this.textFlow.interactionManager.getSelectionState();
            }
         }
         if(_loc7_ != EditingMode.READ_WRITE)
         {
            this.switchToEditingMode(this.textFlow,EditingMode.READ_WRITE);
         }
         var _loc8_:EditManager = EditManager(this.textFlow.interactionManager);
         _loc8_.beginCompositeOperation();
         if(param2 < 0 || param3 < 0)
         {
            _loc9_ = new SelectionState(this.textFlow,this.textFlow.getAbsoluteStart(),this.textFlow.textLength - 1);
            _loc8_.applyLeafFormat(_loc5_,_loc9_);
            _loc8_.applyParagraphFormat(_loc6_,_loc9_);
            if(param1.url != null)
            {
               if(param1.url != "")
               {
                  _loc8_.applyLink(param1.url,param1.target,false,_loc9_);
               }
               else
               {
                  _loc8_.applyLink("",param1.target,false,_loc9_);
               }
            }
         }
         else
         {
            _loc9_ = new SelectionState(this.textFlow,param2,param3);
            _loc8_.applyLeafFormat(_loc5_,_loc9_);
            _loc8_.applyParagraphFormat(_loc6_,_loc9_);
            if(param1.url != null)
            {
               if(param1.url != null)
               {
                  _loc8_.applyLink(param1.url,param1.target,false,_loc9_);
               }
               else
               {
                  _loc8_.applyLink("",param1.target,false,_loc9_);
               }
            }
         }
         _loc8_.endCompositeOperation();
         if(_loc7_ != EditingMode.READ_WRITE)
         {
            this.switchToEditingMode(this.textFlow,_loc7_);
         }
         if(this.textFlow.interactionManager)
         {
            if(_loc4_)
            {
               this.textFlow.interactionManager.selectRange(_loc4_.anchorPosition,_loc4_.activePosition);
            }
            else
            {
               this.textFlow.interactionManager.selectRange(-1,-1);
            }
         }
         this.invalidate(INVALID_TEXT);
      }
      
      public function get htmlText() : String
      {
         if(this.textFlow.generation != this._htmlTextGenerationID || this._htmlText == "")
         {
            this._htmlText = TextConverter.export(this.textFlow,TextConverter.TEXT_FIELD_HTML_FORMAT,ConversionType.STRING_TYPE) as String;
            this._htmlTextGenerationID = this.textFlow.generation;
         }
         return this._htmlText;
      }
      
      public function set gridFitType(param1:String) : void
      {
         if(this.gridFitType == param1)
         {
            return;
         }
         if(param1 != GridFitType.NONE && param1 != GridFitType.PIXEL && param1 != GridFitType.SUBPIXEL)
         {
            param1 = GridFitType.PIXEL;
         }
         this._gridFitType = param1;
         if(this._invalidTextLayoutFormat == null)
         {
            this._invalidTextLayoutFormat = new TextLayoutFormat();
         }
         this._invalidTextLayoutFormat.cffHinting = FormatValue.INHERIT;
         this.textFlow.cffHinting = param1 == GridFitType.NONE ? CFFHinting.NONE : CFFHinting.HORIZONTAL_STEM;
         this.invalidate(INVALID_TEXT);
      }
      
      override public function set width(param1:Number) : void
      {
         if(param1 != this._controller.compositionWidth)
         {
            this._controller.setCompositionSize(param1,this._controller.compositionHeight);
            this.invalidate(INVALID_DIMENSIONS);
         }
      }
      
      public function set restrict(param1:String) : void
      {
         this._restrict = param1;
      }
      
      override public function get blendMode() : String
      {
         return this._controller.container.blendMode;
      }
      
      private function textFlow_flowOperationBeginHandler(param1:FlowOperationEvent) : void
      {
         var _loc3_:SelectionState = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:InsertTextOperation = null;
         var _loc8_:String = null;
         var _loc9_:SelectionState = null;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:FlowTextOperation = null;
         var _loc2_:FlowOperation = param1.operation;
         if(_loc2_ is SplitParagraphOperation && !this._multiline)
         {
            param1.preventDefault();
            dispatchEvent(new Event("Enter"));
            return;
         }
         if(_loc2_ is SplitParagraphOperation)
         {
            _loc3_ = (_loc2_ as SplitParagraphOperation).originalSelectionState;
            _loc4_ = _loc3_ == null ? 0 : _loc3_.absoluteEnd - _loc3_.absoluteStart;
            if(this.maxChars != 0)
            {
               _loc5_ = this.textFlow.textLength - 1 - _loc4_;
               _loc6_ = 1;
               if(_loc5_ + _loc6_ > this.maxChars)
               {
                  param1.preventDefault();
                  return;
               }
            }
         }
         if(_loc2_ is InsertTextOperation)
         {
            _loc7_ = InsertTextOperation(_loc2_);
            _loc8_ = _loc7_.text;
            if(this._restrict != null)
            {
               _loc8_ = restrictChar(_loc8_,this.restrict);
               if(_loc8_.length == 0)
               {
                  param1.preventDefault();
                  return;
               }
            }
            _loc9_ = _loc7_.deleteSelectionState;
            _loc10_ = _loc9_ == null ? 0 : _loc9_.absoluteEnd - _loc9_.absoluteStart;
            if(this.maxChars != 0)
            {
               _loc11_ = this.textFlow.textLength - 1 - _loc10_;
               _loc12_ = _loc8_.length;
               if(_loc11_ + _loc12_ > this.maxChars)
               {
                  _loc8_ = _loc8_.substr(0,this.maxChars - _loc11_);
               }
            }
            if(this._displayAsPassword)
            {
               if(_loc10_ > 0)
               {
                  this._text = splice(this._text,_loc9_.absoluteStart,_loc9_.absoluteEnd,"");
               }
               this._text = splice(this._text,_loc7_.absoluteStart,_loc7_.absoluteEnd,_loc8_);
               _loc8_ = repeat(this._passwordCharacter,_loc8_);
            }
            _loc7_.text = _loc8_;
         }
         else if(!(_loc2_ is PasteOperation))
         {
            if(_loc2_ is DeleteTextOperation || _loc2_ is CutOperation)
            {
               _loc13_ = FlowTextOperation(_loc2_);
               if(_loc13_.absoluteStart == _loc13_.absoluteEnd)
               {
                  param1.preventDefault();
                  return;
               }
               if(this._displayAsPassword)
               {
                  this._text = splice(this._text,_loc13_.absoluteStart,_loc13_.absoluteEnd,"");
               }
            }
         }
      }
      
      public function get controller() : TLFContainerController
      {
         return this._controller;
      }
      
      public function getLineOffset(param1:int) : int
      {
         if(param1 < 0 || param1 >= this.numLines)
         {
            throw new RangeError("The line number specified is out of range.");
         }
         var _loc2_:TextFlowLine = this.getValidTextFlowLine(param1);
         return _loc2_.absoluteStart;
      }
      
      tlf_internal function set contentWidth(param1:Number) : void
      {
         this._contentWidth = param1;
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         if(this._textFlow == null)
         {
            return;
         }
         var _loc2_:TLFTextField = this.tlf_internal::firstField;
         if(!_loc2_)
         {
            _loc2_ = this;
         }
         _loc2_.scrollV = 0;
         this.setDefaultScrollPosition(this.controller);
      }
      
      public function get paddingBottom() : Object
      {
         return this._controller.computedFormat.paddingBottom;
      }
      
      tlf_internal function addTextFlowEventListeners() : void
      {
         this.textFlow.addEventListener(MouseEvent.CLICK,this.linkClick);
         this.textFlow.addEventListener(FlowOperationEvent.FLOW_OPERATION_BEGIN,this.textFlow_flowOperationBeginHandler);
         this.textFlow.addEventListener(FlowOperationEvent.FLOW_OPERATION_END,this.textFlow_flowOperationEndHandler);
         this.textFlow.addEventListener(TextLayoutEvent.SCROLL,this.textFlow_ScrollHandler);
         this.textFlow.addEventListener(CompositionCompleteEvent.COMPOSITION_COMPLETE,this.composeComplete,false,0,true);
      }
      
      public function set backgroundColor(param1:uint) : void
      {
         if(this._backgroundColor == param1)
         {
            return;
         }
         if(param1 > 16777215)
         {
            param1 = 16777215;
         }
         this._backgroundColor = param1;
         this.invalidate(INVALID_BORDER);
      }
      
      public function set maxChars(param1:int) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         var _loc2_:TLFTextField = this.tlf_internal::firstField;
         if(!_loc2_)
         {
            _loc2_ = this;
         }
         _loc2_._maxChars = param1;
      }
      
      tlf_internal function set isPointText(param1:Boolean) : void
      {
         if(this._isPointText == param1)
         {
            return;
         }
         this._isPointText = param1;
         this._autoSize = param1 ? TextFieldAutoSize.LEFT : TextFieldAutoSize.NONE;
         this.invalidate(INVALID_AUTO_SIZE);
      }
      
      tlf_internal function set textTypeLocation(param1:String) : void
      {
         this._textTypeLocation = param1;
      }
      
      private function doTypeSet(param1:TLFTextField) : void
      {
         var _loc3_:SelectionFormat = null;
         var _loc2_:ISelectionManager = param1.textFlow.interactionManager;
         if(_loc2_ != null)
         {
            this._priorSelectionBeginIndex = _loc2_.absoluteStart;
            this._priorSelectionEndIndex = _loc2_.absoluteEnd;
         }
         if(this.type == TextFieldType.INPUT)
         {
            if(!(_loc2_ is EditManager))
            {
               this._textFlow.interactionManager = _loc2_ = new EditManager();
            }
         }
         else if(this.selectable)
         {
            if(_loc2_ == null || _loc2_ is EditManager)
            {
               this._textFlow.interactionManager = _loc2_ = new SelectionManager();
            }
         }
         else
         {
            this._textFlow.interactionManager = _loc2_ = null;
         }
         if(_loc2_ != null)
         {
            this.setSelection(this._priorSelectionBeginIndex,this._priorSelectionEndIndex);
            if(_loc2_.focusedSelectionFormat != focusedSelectionFormat)
            {
               _loc2_.focusedSelectionFormat = focusedSelectionFormat;
            }
            if(_loc2_.inactiveSelectionFormat != inactiveSelectionFormat)
            {
               _loc2_.inactiveSelectionFormat = inactiveSelectionFormat;
            }
            _loc3_ = this.alwaysShowSelection ? alwaysShowSelectionOnFormat : alwaysShowSelectionOffFormat;
            if(_loc2_.unfocusedSelectionFormat != _loc3_)
            {
               _loc2_.unfocusedSelectionFormat = _loc3_;
            }
         }
      }
      
      public function getParagraphLength(param1:int) : int
      {
         var _loc2_:int = 0;
         var _loc3_:TextFlowLine = null;
         if(param1 > this._controller.textLength - 1 || param1 < 0)
         {
            throw new RangeError("The character index specified is out of range.");
         }
         _loc2_ = -1;
         _loc3_ = this.getValidTextFlowLineFromCharIndex(param1);
         if(_loc3_)
         {
            _loc2_ = _loc3_.paragraph.textLength;
         }
         return _loc2_;
      }
      
      public function get paddingLeft() : Object
      {
         return this._controller.computedFormat.paddingLeft;
      }
      
      public function set backgroundAlpha(param1:Number) : void
      {
         if(this._backgroundAlpha == param1)
         {
            return;
         }
         this._backgroundAlpha = param1;
         if(this._backgroundAlpha < 0)
         {
            this._backgroundAlpha = 0;
         }
         else if(this._backgroundAlpha > 1)
         {
            this._backgroundAlpha = 1;
         }
         this.invalidate(INVALID_BORDER);
      }
      
      override public function get width() : Number
      {
         this.repaint();
         return super.width;
      }
      
      tlf_internal function get nextField() : TLFTextField
      {
         var _loc1_:int = 0;
         var _loc2_:TLFContainerController = null;
         if(Boolean(this.textFlow) && Boolean(this.textFlow.flowComposer))
         {
            _loc1_ = this.textFlow.flowComposer.getControllerIndex(this.controller);
            if(_loc1_ + 1 < this.textFlow.flowComposer.numControllers)
            {
               _loc2_ = this.textFlow.flowComposer.getControllerAt(_loc1_ + 1) as TLFContainerController;
               if(_loc2_)
               {
                  return _loc2_.ownerField;
               }
            }
         }
         return null;
      }
      
      public function get columnGap() : Object
      {
         return this._controller.computedFormat.columnGap;
      }
      
      tlf_internal function set inlineInfo(param1:*) : void
      {
         this._inlineInfo = param1;
      }
      
      tlf_internal function set paddingLock(param1:Boolean) : void
      {
         this._paddingLock = param1;
         if(this._paddingLock)
         {
            this._controller.paddingTop = this.paddingLeft;
            this._controller.paddingRight = this.paddingLeft;
            this._controller.paddingBottom = this.paddingLeft;
            this.invalidate(INVALID_TEXT);
         }
      }
      
      public function getCharIndexAtPoint(param1:Number, param2:Number) : int
      {
         var _loc19_:TextFlowLine = null;
         var _loc20_:TextLine = null;
         var _loc29_:Rectangle = null;
         var _loc30_:Number = NaN;
         var _loc31_:Number = NaN;
         var _loc32_:Boolean = false;
         var _loc33_:Number = NaN;
         var _loc34_:Boolean = false;
         var _loc35_:int = 0;
         var _loc36_:String = null;
         var _loc3_:Point = this._controller.container.globalToLocal(new Point(param1,param2));
         var _loc4_:Number = _loc3_.x;
         var _loc5_:Number = _loc3_.y;
         var _loc6_:int = -1;
         var _loc7_:int = this._controller.absoluteStart;
         var _loc8_:int = this._controller.textLength;
         var _loc9_:Rectangle = null;
         var _loc10_:String = this.textFlow.computedFormat.blockProgression;
         var _loc11_:* = _loc10_ == BlockProgression.RL;
         var _loc12_:* = this.textFlow.computedFormat.direction == Direction.RTL;
         var _loc13_:Number = _loc11_ ? _loc4_ : _loc5_;
         var _loc14_:Number = 32000;
         var _loc15_:int = locateNearestColumn(this._controller,_loc4_,_loc5_,this.textFlow.computedFormat.blockProgression,this.textFlow.computedFormat.direction);
         var _loc16_:Rectangle = null;
         var _loc17_:int = -1;
         var _loc18_:int = -1;
         var _loc21_:int;
         var _loc22_:int = _loc21_ = this.textFlow.flowComposer.numLines - 1;
         while(_loc22_ >= 0)
         {
            _loc19_ = this.textFlow.flowComposer.getLineAt(_loc22_);
            if(_loc19_.controller != this.controller || _loc19_.columnIndex != _loc15_)
            {
               if(_loc18_ != -1)
               {
                  _loc6_ = _loc22_ + 1;
                  break;
               }
            }
            else if(!(_loc19_.absoluteStart < _loc7_ || _loc19_.absoluteStart >= _loc7_ + _loc8_))
            {
               _loc20_ = _loc19_.getTextLine();
               if(!(_loc20_ == null || _loc20_.parent == null))
               {
                  if(_loc18_ == -1)
                  {
                     _loc18_ = _loc22_;
                  }
                  _loc29_ = _loc20_.getBounds(DisplayObject(this._controller.container));
                  _loc30_ = _loc11_ ? _loc29_.left : _loc29_.bottom;
                  _loc31_ = -1;
                  if(_loc16_)
                  {
                     _loc33_ = _loc11_ ? _loc16_.right : _loc16_.top;
                     _loc31_ = (_loc30_ + _loc33_) / 2;
                  }
                  _loc32_ = _loc11_ ? _loc30_ > _loc13_ : _loc30_ < _loc13_;
                  if((_loc32_) || _loc22_ == 0)
                  {
                     _loc34_ = _loc31_ != -1 && (_loc11_ ? _loc13_ < _loc31_ : _loc13_ > _loc31_);
                     _loc6_ = (_loc34_) && _loc22_ != _loc18_ ? _loc22_ + 1 : _loc22_;
                     break;
                  }
                  _loc16_ = _loc29_;
                  _loc17_ = _loc22_;
               }
            }
            _loc22_--;
         }
         if(_loc6_ == -1)
         {
            _loc6_ = _loc17_;
            if(_loc6_ == -1)
            {
               return -1;
            }
         }
         var _loc23_:TextLine = this.textFlow.flowComposer.getLineAt(_loc6_).getTextLine(true);
         var _loc24_:Point = DisplayObject(this._controller.container).localToGlobal(new Point(_loc4_,_loc5_));
         _loc24_ = _loc23_.globalToLocal(_loc24_);
         _loc4_ = _loc24_.x;
         _loc5_ = _loc24_.y;
         var _loc25_:Rectangle = new Rectangle(0,0,0,0);
         var _loc26_:TextFlowLine = TextFlowLine(_loc23_.userData);
         var _loc27_:Boolean = false;
         if(_loc12_)
         {
            _loc25_ = _loc23_.getAtomBounds(_loc23_.atomCount - 1);
         }
         else if(_loc26_.absoluteStart + _loc26_.textLength >= _loc26_.paragraph.textLength)
         {
            if(_loc23_.atomCount > 1)
            {
               _loc25_ = _loc23_.getAtomBounds(_loc23_.atomCount - 2);
            }
         }
         else
         {
            _loc35_ = _loc26_.absoluteStart + _loc26_.textLength - 1;
            _loc36_ = _loc23_.textBlock.content.rawText.charAt(_loc35_);
            if(_loc36_ == " ")
            {
               if(_loc23_.atomCount > 1)
               {
                  _loc25_ = _loc23_.getAtomBounds(_loc23_.atomCount - 2);
               }
            }
            else
            {
               _loc27_ = true;
               if(_loc23_.atomCount > 0)
               {
                  _loc25_ = _loc23_.getAtomBounds(_loc23_.atomCount - 1);
               }
            }
         }
         if(!_loc11_)
         {
            if(_loc4_ < 0)
            {
               _loc4_ = 0;
            }
            else if(_loc4_ > _loc25_.x + _loc25_.width)
            {
               if(_loc27_)
               {
                  return _loc26_.absoluteStart + _loc26_.textLength;
               }
               _loc4_ = _loc25_.x + _loc25_.width;
            }
         }
         else if(_loc5_ < 0)
         {
            _loc5_ = 0;
         }
         else if(_loc5_ > _loc25_.y + _loc25_.height)
         {
            if(_loc27_)
            {
               return _loc26_.absoluteStart + _loc26_.textLength;
            }
            _loc5_ = _loc25_.y + _loc25_.height;
         }
         var _loc28_:int = computeSelectionIndexInLine(this.textFlow,_loc23_,_loc4_,_loc5_);
         return _loc28_ != -1 ? _loc28_ : _loc7_ + _loc8_;
      }
      
      private function linkClick(param1:FlowElementMouseEvent) : void
      {
         var _loc2_:String = LinkElement(param1.flowElement).href;
         var _loc3_:int = int(_loc2_.search("event:"));
         if(_loc3_ >= 0)
         {
            _loc2_ = _loc2_.substring(_loc3_ + 6,_loc2_.length - _loc3_ + 5);
            dispatchEvent(new TextEvent(TextEvent.LINK,false,false,_loc2_));
         }
      }
      
      public function set blockProgression(param1:Object) : void
      {
         this.textFlow.blockProgression = param1;
         this.invalidate(INVALID_TEXT);
      }
      
      public function get blockProgression() : Object
      {
         return this.textFlow.blockProgression;
      }
      
      public function getLineLength(param1:int) : int
      {
         if(param1 < 0 || param1 >= this.numLines)
         {
            throw new RangeError("The line number specified is out of range.");
         }
         var _loc2_:TextFlowLine = this.getValidTextFlowLine(param1);
         if(_loc2_)
         {
            return _loc2_.textLength - 1;
         }
         return 0;
      }
      
      public function set borderWidth(param1:Number) : void
      {
         if(this._borderWidth == param1)
         {
            return;
         }
         this._borderWidth = param1;
         if(this._borderWidth < 1)
         {
            this._borderWidth = 1;
         }
         else if(this._borderWidth > 100)
         {
            this._borderWidth = 100;
         }
         this.invalidate(INVALID_BORDER);
      }
      
      public function set textFlow(param1:TextFlow) : void
      {
         if(param1 == this._textFlow)
         {
            return;
         }
         this.invalidate(INVALID_ALL);
         if(this._textFlow != null)
         {
            this.tlf_internal::removeTextFlowEventListeners();
         }
         this._textFlow = param1;
         if(this._textFlow != null)
         {
            this._wordWrap = this._textFlow.computedFormat.lineBreak == LineBreak.TO_FIT;
            this.tlf_internal::addTextFlowEventListeners();
         }
      }
      
      public function get textFlow() : TextFlow
      {
         if(!this._textFlow)
         {
            this.text = "";
         }
         return this._textFlow;
      }
      
      private function getValidTextFlowLine(param1:int) : TextFlowLine
      {
         var _loc2_:TextFlowLine = null;
         if(param1 >= 0 && param1 < this.numLines)
         {
            return this.textFlow.flowComposer.getLineAt(param1);
         }
         throw new RangeError("The line number specified is out of range.");
      }
   }
}

import flashx.textLayout.elements.TextFlow;

TextFlow.defaultConfiguration.manageTabKey = false;

