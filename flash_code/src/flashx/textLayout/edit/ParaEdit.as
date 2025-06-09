package flashx.textLayout.edit
{
   import flashx.textLayout.container.ContainerController;
   import flashx.textLayout.elements.FlowElement;
   import flashx.textLayout.elements.FlowGroupElement;
   import flashx.textLayout.elements.FlowLeafElement;
   import flashx.textLayout.elements.InlineGraphicElement;
   import flashx.textLayout.elements.ParagraphElement;
   import flashx.textLayout.elements.SpanElement;
   import flashx.textLayout.elements.SubParagraphGroupElement;
   import flashx.textLayout.elements.TextFlow;
   import flashx.textLayout.formats.Float;
   import flashx.textLayout.formats.ITextLayoutFormat;
   import flashx.textLayout.formats.TextLayoutFormat;
   import flashx.textLayout.formats.TextLayoutFormatValueHolder;
   import flashx.textLayout.tlf_internal;
   
   use namespace tlf_internal;
   
   public class ParaEdit
   {
      
      public function ParaEdit()
      {
         super();
      }
      
      public static function insertText(param1:ParagraphElement, param2:FlowLeafElement, param3:int, param4:String, param5:Boolean = false) : void
      {
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:SpanElement = null;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         if(param4.length == 0)
         {
            return;
         }
         var _loc6_:* = false;
         var _loc7_:FlowGroupElement = param2.parent;
         var _loc8_:SubParagraphGroupElement = param2.getParentByType(SubParagraphGroupElement) as SubParagraphGroupElement;
         while(_loc8_ != null)
         {
            _loc11_ = param3 - _loc8_.getElementRelativeStart(param1);
            if(!(_loc11_ == 0 && !_loc8_.tlf_internal::acceptTextBefore() || !_loc8_.tlf_internal::acceptTextAfter() && (_loc11_ == _loc8_.textLength || _loc11_ == _loc8_.textLength - 1 && param2 == param1.getLastLeaf())))
            {
               break;
            }
            _loc6_ = !param5;
            _loc7_ = _loc7_.parent;
            _loc8_ = _loc8_.getParentByType(SubParagraphGroupElement) as SubParagraphGroupElement;
         }
         if(!(param2 is SpanElement) || _loc6_ == true)
         {
            _loc14_ = param2.getElementRelativeStart(param1);
            if(_loc14_ == param3)
            {
               param2 = param2.getPreviousLeaf(param1);
               if(!(param2 is SpanElement))
               {
                  _loc12_ = new SpanElement();
                  if(param2)
                  {
                     _loc12_.format = param2.format;
                     _loc13_ = _loc7_.getChildIndex(param2) + 1;
                  }
                  else
                  {
                     _loc12_.format = param1.getFirstLeaf().format;
                     _loc13_ = 0;
                  }
                  _loc7_.replaceChildren(_loc13_,_loc13_,_loc12_);
                  param2 = _loc12_;
               }
            }
            else
            {
               _loc12_ = new SpanElement();
               _loc12_.format = param2.format;
               if(param2.parent == _loc7_)
               {
                  _loc13_ = _loc7_.getChildIndex(param2) + 1;
               }
               else
               {
                  _loc13_ = _loc7_.getChildIndex(param2.parent) + 1;
               }
               _loc7_.replaceChildren(_loc13_,_loc13_,_loc12_);
               param2 = _loc12_;
            }
         }
         var _loc9_:SpanElement = param2 as SpanElement;
         _loc10_ = param3 - _loc9_.getElementRelativeStart(param1);
         _loc9_.replaceText(_loc10_,_loc10_,param4);
      }
      
      private static function deleteTextInternal(param1:ParagraphElement, param2:int, param3:int) : void
      {
         var _loc4_:FlowElement = null;
         var _loc5_:SpanElement = null;
         var _loc6_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc7_:int = 0;
         while(param3 > 0)
         {
            _loc4_ = param1.findLeaf(param2);
            _loc5_ = _loc4_ as SpanElement;
            _loc8_ = _loc5_.getElementRelativeStart(param1);
            _loc7_ = param2 - _loc8_;
            if(param2 > _loc8_ + _loc5_.textLength)
            {
               _loc6_ = _loc5_.textLength;
            }
            else
            {
               _loc6_ = _loc8_ + _loc5_.textLength - param2;
            }
            if(param3 < _loc6_)
            {
               _loc6_ = param3;
            }
            _loc5_.replaceText(_loc7_,_loc7_ + _loc6_,"");
            if(_loc5_.textLength == 0)
            {
               _loc9_ = _loc5_.parent.getChildIndex(_loc5_);
               _loc5_.parent.replaceChildren(_loc9_,_loc9_ + 1,null);
            }
            param3 -= _loc6_;
         }
      }
      
      public static function deleteText(param1:ParagraphElement, param2:int, param3:int) : void
      {
         var _loc4_:int = param1.textLength - 1;
         if(param2 < 0 || param2 > _loc4_)
         {
            return;
         }
         if(param3 <= 0)
         {
            return;
         }
         var _loc5_:int = param2 + param3 - 1;
         if(_loc5_ > _loc4_)
         {
            _loc5_ = _loc4_;
            param3 = _loc5_ - param2 + 1;
         }
         deleteTextInternal(param1,param2,param3);
      }
      
      public static function createImage(param1:FlowGroupElement, param2:int, param3:Object, param4:Object, param5:Object, param6:Object, param7:ITextLayoutFormat) : InlineGraphicElement
      {
         var _loc16_:String = null;
         var _loc17_:int = 0;
         var _loc18_:TextLayoutFormat = null;
         var _loc8_:FlowElement = param1.findLeaf(param2);
         var _loc9_:int = 0;
         if(_loc8_ != null)
         {
            _loc9_ = param2 - _loc8_.getElementRelativeStart(param1);
         }
         if(_loc8_ != null && _loc9_ > 0 && _loc9_ < _loc8_.textLength)
         {
            (_loc8_ as SpanElement).splitAtPosition(_loc9_);
         }
         var _loc10_:InlineGraphicElement = new InlineGraphicElement();
         _loc10_.height = param5;
         _loc10_.width = param4;
         _loc10_.tlf_internal::float = param6 ? param6.toString() : Float.NONE;
         var _loc11_:Object = param3;
         var _loc12_:String = "@Embed";
         if(_loc11_ is String && _loc11_.length > _loc12_.length && _loc11_.substr(0,_loc12_.length) == _loc12_)
         {
            _loc16_ = "source=";
            _loc17_ = int(_loc11_.indexOf(_loc16_,_loc12_.length));
            if(_loc17_ > 0)
            {
               _loc17_ += _loc16_.length;
               _loc17_ = int(_loc11_.indexOf("\'",_loc17_));
               _loc11_ = _loc11_.substring(_loc17_ + 1,_loc11_.indexOf("\'",_loc17_ + 1));
            }
         }
         _loc10_.source = _loc11_;
         while(Boolean(_loc8_) && _loc8_.parent != param1)
         {
            _loc8_ = _loc8_.parent;
         }
         var _loc13_:int = _loc8_ != null ? param1.getChildIndex(_loc8_) : param1.numChildren;
         if(Boolean(_loc8_) && _loc9_ > 0)
         {
            _loc13_++;
         }
         param1.replaceChildren(_loc13_,_loc13_,_loc10_);
         var _loc14_:ParagraphElement = _loc10_.getParagraph();
         var _loc15_:FlowLeafElement = _loc10_.getPreviousLeaf(_loc14_);
         if(!_loc15_)
         {
            _loc15_ = _loc10_.getNextLeaf(_loc14_);
         }
         if(Boolean(_loc15_.format) || Boolean(param7))
         {
            _loc18_ = new TextLayoutFormat(_loc15_.format);
            if(param7)
            {
               _loc18_.apply(param7);
            }
            _loc10_.format = _loc18_;
         }
         return _loc10_;
      }
      
      private static function splitForChange(param1:SpanElement, param2:int, param3:int) : SpanElement
      {
         var _loc5_:SpanElement = null;
         var _loc4_:int = param1.getAbsoluteStart();
         if(param2 == _loc4_ && param3 == param1.textLength)
         {
            return param1;
         }
         var _loc6_:int = param1.textLength;
         var _loc7_:int = param2 - _loc4_;
         if(_loc7_ > 0)
         {
            _loc5_ = param1.splitAtPosition(_loc7_) as SpanElement;
            if(_loc7_ + param3 < _loc6_)
            {
               _loc5_.splitAtPosition(param3);
            }
         }
         else
         {
            param1.splitAtPosition(param3);
            _loc5_ = param1;
         }
         return _loc5_;
      }
      
      private static function undefineDefinedFormats(param1:TextLayoutFormatValueHolder, param2:ITextLayoutFormat) : void
      {
         var _loc3_:String = null;
         if(param2)
         {
            for(_loc3_ in TextLayoutFormat.tlf_internal::description)
            {
               if(param2[_loc3_] !== undefined)
               {
                  param1[_loc3_] = undefined;
               }
            }
         }
      }
      
      private static function applyCharacterFormat(param1:FlowLeafElement, param2:int, param3:int, param4:ITextLayoutFormat, param5:ITextLayoutFormat) : int
      {
         var _loc6_:TextLayoutFormatValueHolder = new TextLayoutFormatValueHolder(param1.format);
         if(param4)
         {
            _loc6_.apply(param4);
         }
         undefineDefinedFormats(_loc6_,param5);
         return setCharacterFormat(param1,_loc6_,param2,param3);
      }
      
      private static function setCharacterFormat(param1:FlowLeafElement, param2:Object, param3:int, param4:int) : int
      {
         var _loc6_:ParagraphElement = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:FlowLeafElement = null;
         var _loc5_:int = param1.getAbsoluteStart();
         if(!(param2 is ITextLayoutFormat) || !TextLayoutFormat.isEqual(ITextLayoutFormat(param2),param1.format))
         {
            _loc6_ = param1.getParagraph();
            _loc7_ = _loc6_.getAbsoluteStart();
            _loc8_ = param3 - _loc5_;
            if(_loc8_ + param4 > param1.textLength)
            {
               param4 = param1.textLength - _loc8_;
            }
            if(_loc8_ + param4 == param1.textLength - 1 && param1 is SpanElement && SpanElement(param1).tlf_internal::hasParagraphTerminator)
            {
               param4++;
            }
            if(param1 is SpanElement)
            {
               _loc9_ = splitForChange(SpanElement(param1),param3,param4);
            }
            else
            {
               _loc9_ = param1;
            }
            if(param2 is ITextLayoutFormat)
            {
               _loc9_.format = ITextLayoutFormat(param2);
            }
            else
            {
               _loc9_.tlf_internal::setCoreStylesInternal(param2);
            }
            return param3 + param4;
         }
         param4 = param1.textLength;
         return _loc5_ + param4;
      }
      
      public static function applyTextStyleChange(param1:TextFlow, param2:int, param3:int, param4:ITextLayoutFormat, param5:ITextLayoutFormat) : void
      {
         var _loc7_:FlowLeafElement = null;
         var _loc6_:int = param2;
         while(_loc6_ < param3)
         {
            _loc7_ = param1.findLeaf(_loc6_);
            _loc6_ = applyCharacterFormat(_loc7_,_loc6_,param3 - _loc6_,param4,param5);
         }
      }
      
      public static function setTextStyleChange(param1:TextFlow, param2:int, param3:int, param4:Object) : void
      {
         var _loc6_:FlowElement = null;
         var _loc5_:int = param2;
         while(_loc5_ < param3)
         {
            _loc6_ = param1.findLeaf(_loc5_);
            _loc5_ = setCharacterFormat(FlowLeafElement(_loc6_),param4,_loc5_,param3 - _loc5_);
         }
      }
      
      public static function splitParagraph(param1:ParagraphElement, param2:int, param3:ITextLayoutFormat = null) : ParagraphElement
      {
         var _loc4_:ParagraphElement = null;
         var _loc7_:int = 0;
         var _loc8_:FlowLeafElement = null;
         var _loc9_:FlowLeafElement = null;
         var _loc10_:int = 0;
         var _loc11_:SpanElement = null;
         var _loc5_:int = param1.getAbsoluteStart();
         var _loc6_:int = _loc5_ + param2;
         if(param2 == param1.textLength - 1)
         {
            _loc4_ = param1.shallowCopy() as ParagraphElement;
            _loc4_.replaceChildren(0,0,new SpanElement());
            _loc7_ = param1.parent.getChildIndex(param1);
            param1.parent.replaceChildren(_loc7_ + 1,_loc7_ + 1,_loc4_);
            if(_loc4_.textLength == 1)
            {
               _loc8_ = param1.getLastLeaf();
               if(_loc8_ != null && _loc8_.textLength == 1)
               {
                  _loc10_ = _loc8_.parent.getChildIndex(_loc8_);
                  if(_loc10_ > 0)
                  {
                     _loc9_ = _loc8_.parent.getChildAt(_loc10_ - 1) as SpanElement;
                     if(_loc9_ != null)
                     {
                        _loc8_ = _loc9_;
                     }
                  }
               }
               if(_loc8_ != null)
               {
                  ParaEdit.setTextStyleChange(param1.getTextFlow(),_loc6_ + 1,_loc6_ + 2,_loc8_.format);
               }
               if(param3 != null)
               {
                  ParaEdit.applyTextStyleChange(param1.getTextFlow(),_loc6_ + 1,_loc6_ + 2,param3,null);
               }
            }
         }
         else
         {
            _loc4_ = param1.splitAtPosition(param2) as ParagraphElement;
         }
         if(param1.numChildren == 0)
         {
            _loc11_ = new SpanElement();
            _loc11_.tlf_internal::quickCloneTextLayoutFormat(_loc4_.getChildAt(0));
            param1.replaceChildren(0,0,_loc11_);
         }
         return _loc4_;
      }
      
      public static function mergeParagraphWithNext(param1:ParagraphElement) : Boolean
      {
         var _loc4_:FlowElement = null;
         var _loc2_:int = param1.parent.getChildIndex(param1);
         if(_loc2_ == param1.parent.numChildren - 1)
         {
            return false;
         }
         var _loc3_:ParagraphElement = param1.parent.getChildAt(_loc2_ + 1) as ParagraphElement;
         if(_loc3_ == null)
         {
            return false;
         }
         param1.parent.replaceChildren(_loc2_ + 1,_loc2_ + 2,null);
         if(_loc3_.textLength <= 1)
         {
            return true;
         }
         while(_loc3_.numChildren)
         {
            _loc4_ = _loc3_.getChildAt(0);
            _loc3_.replaceChildren(0,1,null);
            param1.replaceChildren(param1.numChildren,param1.numChildren,_loc4_);
            if(param1.numChildren > 1 && param1.getChildAt(param1.numChildren - 2).textLength == 0)
            {
               param1.replaceChildren(param1.numChildren - 2,param1.numChildren - 1,null);
            }
         }
         return true;
      }
      
      public static function cacheParagraphStyleInformation(param1:TextFlow, param2:int, param3:int, param4:Array) : void
      {
         var _loc5_:ParagraphElement = null;
         var _loc6_:Object = null;
         while(param2 <= param3 && param2 >= 0)
         {
            _loc5_ = param1.findLeaf(param2).getParagraph();
            _loc6_ = new Object();
            _loc6_.begIdx = _loc5_.getAbsoluteStart();
            _loc6_.endIdx = _loc6_.begIdx + _loc5_.textLength - 1;
            _loc6_.attributes = _loc5_.coreStyles;
            param4.push(_loc6_);
            param2 = _loc6_.begIdx + _loc5_.textLength;
         }
      }
      
      public static function setParagraphStyleChange(param1:TextFlow, param2:int, param3:int, param4:Object) : void
      {
         var _loc6_:ParagraphElement = null;
         var _loc5_:int = param2;
         while(_loc5_ < param3)
         {
            _loc6_ = param1.findLeaf(_loc5_).getParagraph();
            _loc6_.tlf_internal::setCoreStylesInternal(param4);
            _loc5_ = _loc6_.getAbsoluteStart() + _loc6_.textLength;
         }
      }
      
      public static function applyParagraphStyleChange(param1:TextFlow, param2:int, param3:int, param4:ITextLayoutFormat, param5:ITextLayoutFormat) : void
      {
         var _loc7_:ParagraphElement = null;
         var _loc8_:TextLayoutFormatValueHolder = null;
         var _loc6_:int = param2;
         while(_loc6_ <= param3)
         {
            _loc7_ = param1.findLeaf(_loc6_).getParagraph();
            _loc8_ = new TextLayoutFormatValueHolder(_loc7_.format);
            if(param4)
            {
               _loc8_.apply(param4);
            }
            undefineDefinedFormats(_loc8_,param5);
            _loc7_.format = _loc8_;
            _loc6_ = _loc7_.getAbsoluteStart() + _loc7_.textLength;
         }
      }
      
      public static function cacheStyleInformation(param1:TextFlow, param2:int, param3:int, param4:Array) : void
      {
         var _loc8_:Object = null;
         var _loc9_:int = 0;
         var _loc5_:FlowElement = param1.findLeaf(param2);
         var _loc6_:int = _loc5_.getAbsoluteStart() + _loc5_.textLength - param2;
         var _loc7_:int = param3 - param2;
         while(true)
         {
            _loc8_ = new Object();
            _loc8_.begIdx = param2;
            _loc9_ = Math.min(_loc7_,_loc6_);
            _loc8_.endIdx = param2 + _loc9_;
            _loc8_.style = _loc5_.coreStyles;
            param4.push(_loc8_);
            _loc7_ -= Math.min(_loc7_,_loc6_);
            if(_loc7_ == 0)
            {
               break;
            }
            param2 = int(_loc8_.endIdx);
            _loc5_ = param1.findLeaf(param2);
            _loc6_ = _loc5_.textLength;
         }
      }
      
      public static function cacheContainerStyleInformation(param1:TextFlow, param2:int, param3:int, param4:Array) : void
      {
         var _loc5_:int = 0;
         var _loc6_:ContainerController = null;
         var _loc7_:Object = null;
         if(param1.flowComposer)
         {
            _loc5_ = param1.flowComposer.findControllerIndexAtPosition(param2,false);
            if(_loc5_ >= 0)
            {
               while(_loc5_ < param1.flowComposer.numControllers)
               {
                  _loc6_ = param1.flowComposer.getControllerAt(_loc5_);
                  if(_loc6_.absoluteStart >= param3)
                  {
                     break;
                  }
                  _loc7_ = new Object();
                  _loc7_.container = _loc6_;
                  _loc7_.attributes = _loc6_.coreStyles;
                  param4.push(_loc7_);
                  _loc5_++;
               }
            }
         }
      }
      
      public static function applyContainerStyleChange(param1:TextFlow, param2:int, param3:int, param4:ITextLayoutFormat, param5:ITextLayoutFormat) : void
      {
         var _loc6_:int = 0;
         var _loc7_:ContainerController = null;
         var _loc8_:TextLayoutFormatValueHolder = null;
         if(param1.flowComposer)
         {
            _loc6_ = param1.flowComposer.findControllerIndexAtPosition(param2,false);
            if(_loc6_ >= 0)
            {
               while(_loc6_ < param1.flowComposer.numControllers)
               {
                  _loc7_ = param1.flowComposer.getControllerAt(_loc6_);
                  if(_loc7_.absoluteStart >= param3)
                  {
                     break;
                  }
                  _loc8_ = new TextLayoutFormatValueHolder(_loc7_.format);
                  if(param4)
                  {
                     _loc8_.apply(param4);
                  }
                  undefineDefinedFormats(_loc8_,param5);
                  _loc7_.format = _loc8_;
                  _loc6_++;
               }
            }
         }
      }
      
      public static function setContainerStyleChange(param1:TextFlow, param2:Object) : void
      {
         param2.container.format = param2.attributes as ITextLayoutFormat;
      }
   }
}

