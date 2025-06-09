package flashx.textLayout.utils
{
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.engine.TextLine;
   import flash.text.engine.TextRotation;
   import flashx.textLayout.compose.IFlowComposer;
   import flashx.textLayout.compose.TextFlowLine;
   import flashx.textLayout.container.ContainerController;
   import flashx.textLayout.container.ScrollPolicy;
   import flashx.textLayout.elements.FlowLeafElement;
   import flashx.textLayout.elements.ParagraphElement;
   import flashx.textLayout.elements.TextFlow;
   import flashx.textLayout.elements.TextRange;
   import flashx.textLayout.formats.BlockProgression;
   import flashx.textLayout.formats.Direction;
   import flashx.textLayout.tlf_internal;
   
   use namespace tlf_internal;
   
   public final class NavigationUtil
   {
      
      public function NavigationUtil()
      {
         super();
      }
      
      private static function validateTextRange(param1:TextRange) : Boolean
      {
         return param1.textFlow != null && param1.anchorPosition != -1 && param1.activePosition != -1;
      }
      
      private static function doIncrement(param1:TextFlow, param2:int, param3:Function) : int
      {
         var _loc4_:ParagraphElement = param1.tlf_internal::findAbsoluteParagraph(param2);
         return param3(param1,_loc4_,param2,_loc4_.getAbsoluteStart());
      }
      
      private static function previousAtomHelper(param1:TextFlow, param2:ParagraphElement, param3:int, param4:int) : int
      {
         if(param3 - param4 == 0)
         {
            return param3 > 0 ? param3 - 1 : 0;
         }
         return param2.findPreviousAtomBoundary(param3 - param4) + param4;
      }
      
      public static function previousAtomPosition(param1:TextFlow, param2:int) : int
      {
         return doIncrement(param1,param2,previousAtomHelper);
      }
      
      private static function nextAtomHelper(param1:TextFlow, param2:ParagraphElement, param3:int, param4:int) : int
      {
         if(param3 - param4 == param2.textLength - 1)
         {
            return Math.min(param1.textLength - 1,param3 + 1);
         }
         return param2.findNextAtomBoundary(param3 - param4) + param4;
      }
      
      public static function nextAtomPosition(param1:TextFlow, param2:int) : int
      {
         return doIncrement(param1,param2,nextAtomHelper);
      }
      
      public static function previousWordPosition(param1:TextFlow, param2:int) : int
      {
         if(isOverset(param1,param2))
         {
            return endOfLastController(param1);
         }
         var _loc3_:ParagraphElement = param1.tlf_internal::findAbsoluteParagraph(param2);
         var _loc4_:int = _loc3_.getAbsoluteStart();
         var _loc5_:int = param2 - _loc4_;
         var _loc6_:int = 0;
         if(param2 - _loc4_ == 0)
         {
            return param2 > 0 ? param2 - 1 : 0;
         }
         do
         {
            _loc6_ = _loc3_.findPreviousWordBoundary(_loc5_);
            if(_loc5_ == _loc6_)
            {
               _loc5_ = _loc3_.findPreviousWordBoundary(_loc5_ - 1);
            }
            else
            {
               _loc5_ = _loc6_;
            }
         }
         while(_loc5_ > 0 && CharacterUtil.isWhitespace(_loc3_.getCharCodeAtPosition(_loc5_)));
         
         return _loc5_ + _loc4_;
      }
      
      public static function nextWordPosition(param1:TextFlow, param2:int) : int
      {
         var _loc3_:ParagraphElement = param1.tlf_internal::findAbsoluteParagraph(param2);
         var _loc4_:int = _loc3_.getAbsoluteStart();
         var _loc5_:int = param2 - _loc4_;
         if(param2 - _loc4_ == _loc3_.textLength - 1)
         {
            return Math.min(param1.textLength - 1,param2 + 1);
         }
         while(true)
         {
            _loc5_ = _loc3_.findNextWordBoundary(_loc5_);
            if(!(_loc5_ < _loc3_.textLength - 1 && CharacterUtil.isWhitespace(_loc3_.getCharCodeAtPosition(_loc5_))))
            {
               break;
            }
         }
         return _loc5_ + _loc4_;
      }
      
      tlf_internal static function updateStartIfInReadOnlyElement(param1:TextFlow, param2:int) : int
      {
         return param2;
      }
      
      tlf_internal static function updateEndIfInReadOnlyElement(param1:TextFlow, param2:int) : int
      {
         return param2;
      }
      
      private static function moveForwardHelper(param1:TextRange, param2:Boolean, param3:Function) : Boolean
      {
         var _loc4_:TextFlow = param1.textFlow;
         var _loc5_:int = param1.anchorPosition;
         var _loc6_:int = param1.activePosition;
         if(param2)
         {
            _loc6_ = param3(_loc4_,_loc6_);
         }
         else if(_loc5_ == _loc6_)
         {
            _loc6_ = _loc5_ = param3(_loc4_,_loc5_);
         }
         else if(_loc6_ > _loc5_)
         {
            _loc5_ = _loc6_;
         }
         else
         {
            _loc6_ = _loc5_;
         }
         if(_loc5_ == _loc6_)
         {
            _loc5_ = tlf_internal::updateStartIfInReadOnlyElement(_loc4_,_loc5_);
            _loc6_ = tlf_internal::updateEndIfInReadOnlyElement(_loc4_,_loc6_);
         }
         else
         {
            _loc6_ = tlf_internal::updateEndIfInReadOnlyElement(_loc4_,_loc6_);
         }
         if(!param2 && param1.anchorPosition == _loc5_ && param1.activePosition == _loc6_)
         {
            if(_loc5_ < _loc6_)
            {
               _loc6_ = _loc5_ = Math.min(_loc6_ + 1,_loc4_.textLength - 1);
            }
            else
            {
               _loc5_ = _loc6_ = Math.min(_loc5_ + 1,_loc4_.textLength - 1);
            }
         }
         return param1.updateRange(_loc5_,_loc6_);
      }
      
      private static function moveBackwardHelper(param1:TextRange, param2:Boolean, param3:Function) : Boolean
      {
         var _loc4_:TextFlow = param1.textFlow;
         var _loc5_:int = param1.anchorPosition;
         var _loc6_:int = param1.activePosition;
         if(param2)
         {
            _loc6_ = param3(_loc4_,_loc6_);
         }
         else if(_loc5_ == _loc6_)
         {
            _loc6_ = _loc5_ = param3(_loc4_,_loc5_);
         }
         else if(_loc6_ > _loc5_)
         {
            _loc6_ = _loc5_;
         }
         else
         {
            _loc5_ = _loc6_;
         }
         if(_loc5_ == _loc6_)
         {
            _loc5_ = tlf_internal::updateEndIfInReadOnlyElement(_loc4_,_loc5_);
            _loc6_ = tlf_internal::updateStartIfInReadOnlyElement(_loc4_,_loc6_);
         }
         else
         {
            _loc6_ = tlf_internal::updateStartIfInReadOnlyElement(_loc4_,_loc6_);
         }
         if(!param2 && param1.anchorPosition == _loc5_ && param1.activePosition == _loc6_)
         {
            if(_loc5_ < _loc6_)
            {
               _loc5_ = _loc6_ = Math.max(_loc5_ - 1,0);
            }
            else
            {
               _loc6_ = _loc5_ = Math.max(_loc6_ - 1,0);
            }
         }
         return param1.updateRange(_loc5_,_loc6_);
      }
      
      public static function nextCharacter(param1:TextRange, param2:Boolean = false) : Boolean
      {
         if(validateTextRange(param1))
         {
            if(!adjustForOversetForward(param1))
            {
               moveForwardHelper(param1,param2,nextAtomPosition);
            }
            return true;
         }
         return false;
      }
      
      public static function previousCharacter(param1:TextRange, param2:Boolean = false) : Boolean
      {
         if(validateTextRange(param1))
         {
            if(!adjustForOversetBack(param1))
            {
               moveBackwardHelper(param1,param2,previousAtomPosition);
            }
            return true;
         }
         return false;
      }
      
      public static function nextWord(param1:TextRange, param2:Boolean = false) : Boolean
      {
         if(validateTextRange(param1))
         {
            if(!adjustForOversetForward(param1))
            {
               moveForwardHelper(param1,param2,nextWordPosition);
            }
            return true;
         }
         return false;
      }
      
      public static function previousWord(param1:TextRange, param2:Boolean = false) : Boolean
      {
         if(validateTextRange(param1))
         {
            if(!adjustForOversetBack(param1))
            {
               moveBackwardHelper(param1,param2,previousWordPosition);
            }
            return true;
         }
         return false;
      }
      
      public static function nextLine(param1:TextRange, param2:Boolean = false) : Boolean
      {
         var _loc9_:TextFlowLine = null;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:TextLine = null;
         var _loc13_:ParagraphElement = null;
         var _loc14_:int = 0;
         var _loc15_:* = false;
         var _loc16_:Rectangle = null;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Point = null;
         var _loc21_:TextFlowLine = null;
         var _loc22_:ContainerController = null;
         var _loc23_:int = 0;
         var _loc24_:int = 0;
         var _loc25_:TextLine = null;
         var _loc26_:Rectangle = null;
         var _loc27_:Point = null;
         var _loc28_:Rectangle = null;
         var _loc29_:* = false;
         var _loc30_:int = 0;
         var _loc31_:Point = null;
         if(!validateTextRange(param1))
         {
            return false;
         }
         if(adjustForOversetForward(param1))
         {
            return true;
         }
         var _loc3_:TextFlow = param1.textFlow;
         var _loc4_:int = param1.anchorPosition;
         var _loc5_:int = param1.activePosition;
         var _loc6_:int = endOfLastController(_loc3_);
         var _loc7_:int = _loc3_.flowComposer.findLineIndexAtPosition(_loc5_);
         var _loc8_:* = _loc3_.computedFormat.direction == Direction.RTL;
         if(_loc7_ < _loc3_.flowComposer.numLines - 1)
         {
            _loc9_ = _loc3_.flowComposer.getLineAt(_loc7_);
            _loc10_ = _loc9_.absoluteStart;
            _loc11_ = _loc5_ - _loc10_;
            _loc12_ = _loc9_.getTextLine(true);
            _loc13_ = _loc9_.paragraph;
            _loc14_ = _loc12_.getAtomIndexAtCharIndex(_loc5_ - _loc13_.getAbsoluteStart());
            _loc15_ = _loc12_.getAtomBidiLevel(_loc14_) % 2 != 0;
            _loc16_ = _loc12_.getAtomBounds(_loc14_);
            _loc17_ = _loc12_.x;
            _loc18_ = _loc16_.left;
            _loc19_ = _loc16_.right;
            if(_loc3_.computedFormat.blockProgression == BlockProgression.RL)
            {
               _loc17_ = _loc12_.y;
               _loc18_ = _loc16_.top;
               _loc19_ = _loc16_.bottom;
            }
            _loc20_ = new Point();
            if(_loc3_.computedFormat.blockProgression != BlockProgression.RL)
            {
               if(!_loc8_)
               {
                  _loc20_.x = _loc16_.left;
               }
               else
               {
                  _loc20_.x = _loc16_.right;
               }
               _loc20_.y = 0;
            }
            else
            {
               _loc20_.x = 0;
               if(!_loc8_)
               {
                  _loc20_.y = _loc16_.top;
               }
               else
               {
                  _loc20_.y = _loc16_.bottom;
               }
            }
            _loc20_ = _loc12_.localToGlobal(_loc20_);
            _loc21_ = _loc3_.flowComposer.getLineAt(_loc7_ + 1);
            if(_loc21_.absoluteStart >= _loc6_)
            {
               if(!param2)
               {
                  param1.anchorPosition = _loc3_.textLength - 1;
               }
               param1.activePosition = _loc3_.textLength - 1;
               return true;
            }
            _loc22_ = _loc3_.flowComposer.getControllerAt(_loc3_.flowComposer.numControllers - 1);
            _loc23_ = _loc22_.absoluteStart;
            _loc24_ = _loc23_ + _loc22_.textLength;
            if(_loc21_.absoluteStart >= _loc23_ && _loc21_.absoluteStart < _loc24_)
            {
               if(_loc21_.tlf_internal::isDamaged())
               {
                  _loc3_.flowComposer.composeToPosition(_loc21_.absoluteStart + 1);
                  _loc21_ = _loc3_.flowComposer.getLineAt(_loc7_ + 1);
               }
               _loc22_.scrollToRange(_loc21_.absoluteStart,_loc21_.absoluteStart + _loc21_.textLength - 1);
            }
            _loc25_ = _loc21_.getTextLine(true);
            if(_loc21_.controller == _loc9_.controller)
            {
               if(_loc3_.computedFormat.blockProgression != BlockProgression.RL)
               {
                  _loc20_.y += _loc21_.y - _loc9_.y;
               }
               else
               {
                  _loc20_.x -= _loc9_.x - _loc21_.x;
               }
            }
            else
            {
               _loc26_ = _loc25_.getAtomBounds(0);
               _loc27_ = new Point();
               _loc27_.x = _loc26_.left;
               _loc27_.y = 0;
               _loc27_ = _loc25_.localToGlobal(_loc27_);
               if(_loc3_.computedFormat.blockProgression != BlockProgression.RL)
               {
                  _loc20_.x += _loc21_.controller.container.x;
                  _loc20_.y = _loc27_.y;
               }
               else
               {
                  _loc20_.x = _loc27_.x;
                  _loc20_.y += _loc21_.controller.container.y;
               }
            }
            _loc14_ = _loc25_.getAtomIndexAtPoint(_loc20_.x,_loc20_.y);
            if(_loc14_ == -1)
            {
               if(_loc3_.computedFormat.blockProgression != BlockProgression.RL)
               {
                  if(!_loc15_)
                  {
                     _loc5_ = _loc20_.x <= _loc25_.x ? _loc21_.absoluteStart : _loc21_.absoluteStart + _loc21_.textLength - 1;
                  }
                  else
                  {
                     _loc5_ = _loc20_.x <= _loc25_.x ? _loc21_.absoluteStart + _loc21_.textLength - 1 : _loc21_.absoluteStart;
                  }
               }
               else if(!_loc15_)
               {
                  _loc5_ = _loc20_.y <= _loc25_.y ? _loc21_.absoluteStart : _loc21_.absoluteStart + _loc21_.textLength - 1;
               }
               else
               {
                  _loc5_ = _loc20_.y <= _loc25_.y ? _loc21_.absoluteStart + _loc21_.textLength - 1 : _loc21_.absoluteStart;
               }
            }
            else
            {
               _loc28_ = _loc25_.getAtomBounds(_loc14_);
               _loc29_ = false;
               if(_loc28_)
               {
                  _loc31_ = new Point();
                  _loc31_.x = _loc28_.x;
                  _loc31_.y = _loc28_.y;
                  _loc31_ = _loc25_.localToGlobal(_loc31_);
                  if(_loc3_.computedFormat.blockProgression == BlockProgression.RL && _loc25_.getAtomTextRotation(_loc14_) != TextRotation.ROTATE_0)
                  {
                     _loc29_ = _loc20_.y > _loc31_.y + _loc28_.height / 2;
                  }
                  else
                  {
                     _loc29_ = _loc20_.x > _loc31_.x + _loc28_.width / 2;
                  }
               }
               if(_loc25_.getAtomBidiLevel(_loc14_) % 2 != 0)
               {
                  _loc30_ = _loc29_ ? _loc25_.getAtomTextBlockBeginIndex(_loc14_) : _loc25_.getAtomTextBlockEndIndex(_loc14_);
               }
               else if(_loc8_)
               {
                  if(_loc29_ == false && _loc14_ > 0)
                  {
                     _loc30_ = _loc25_.getAtomTextBlockBeginIndex(_loc14_ - 1);
                  }
                  else
                  {
                     _loc30_ = _loc25_.getAtomTextBlockBeginIndex(_loc14_);
                  }
               }
               else
               {
                  _loc30_ = _loc29_ ? _loc25_.getAtomTextBlockEndIndex(_loc14_) : _loc25_.getAtomTextBlockBeginIndex(_loc14_);
               }
               _loc5_ = _loc21_.paragraph.getAbsoluteStart() + _loc30_;
               if(_loc5_ >= _loc3_.textLength)
               {
                  _loc5_ = _loc3_.textLength - 1;
               }
            }
         }
         else
         {
            _loc5_ = _loc3_.textLength - 1;
         }
         if(!param2)
         {
            _loc4_ = _loc5_;
         }
         if(_loc4_ == _loc5_)
         {
            _loc4_ = tlf_internal::updateStartIfInReadOnlyElement(_loc3_,_loc4_);
            _loc5_ = tlf_internal::updateEndIfInReadOnlyElement(_loc3_,_loc5_);
         }
         else
         {
            _loc5_ = tlf_internal::updateEndIfInReadOnlyElement(_loc3_,_loc5_);
         }
         return param1.updateRange(_loc4_,_loc5_);
      }
      
      public static function previousLine(param1:TextRange, param2:Boolean = false) : Boolean
      {
         var _loc8_:TextFlowLine = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:TextLine = null;
         var _loc12_:ParagraphElement = null;
         var _loc13_:int = 0;
         var _loc14_:* = false;
         var _loc15_:Rectangle = null;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Point = null;
         var _loc20_:TextFlowLine = null;
         var _loc21_:ContainerController = null;
         var _loc22_:int = 0;
         var _loc23_:int = 0;
         var _loc24_:TextLine = null;
         var _loc25_:Rectangle = null;
         var _loc26_:Point = null;
         var _loc27_:Rectangle = null;
         var _loc28_:* = false;
         var _loc29_:int = 0;
         var _loc30_:Point = null;
         if(!validateTextRange(param1))
         {
            return false;
         }
         if(adjustForOversetBack(param1))
         {
            return true;
         }
         var _loc3_:TextFlow = param1.textFlow;
         var _loc4_:int = param1.anchorPosition;
         var _loc5_:int = param1.activePosition;
         var _loc6_:int = _loc3_.flowComposer.findLineIndexAtPosition(_loc5_);
         var _loc7_:* = _loc3_.computedFormat.direction == Direction.RTL;
         if(_loc6_ > 0)
         {
            _loc8_ = _loc3_.flowComposer.getLineAt(_loc6_);
            _loc9_ = _loc8_.absoluteStart;
            _loc10_ = _loc5_ - _loc9_;
            _loc11_ = _loc8_.getTextLine(true);
            _loc12_ = _loc8_.paragraph;
            _loc13_ = _loc11_.getAtomIndexAtCharIndex(_loc5_ - _loc12_.getAbsoluteStart());
            _loc14_ = _loc11_.getAtomBidiLevel(_loc13_) % 2 != 0;
            _loc15_ = _loc11_.getAtomBounds(_loc13_);
            _loc16_ = _loc11_.x;
            _loc17_ = _loc15_.left;
            _loc18_ = _loc15_.right;
            if(_loc3_.computedFormat.blockProgression == BlockProgression.RL)
            {
               _loc16_ = _loc11_.y;
               _loc17_ = _loc15_.top;
               _loc18_ = _loc15_.bottom;
            }
            _loc19_ = new Point();
            if(_loc3_.computedFormat.blockProgression != BlockProgression.RL)
            {
               if(!_loc7_)
               {
                  _loc19_.x = _loc15_.left;
               }
               else
               {
                  _loc19_.x = _loc15_.right;
               }
               _loc19_.y = 0;
            }
            else
            {
               _loc19_.x = 0;
               if(!_loc7_)
               {
                  _loc19_.y = _loc15_.top;
               }
               else
               {
                  _loc19_.y = _loc15_.bottom;
               }
            }
            _loc19_ = _loc11_.localToGlobal(_loc19_);
            _loc20_ = _loc3_.flowComposer.getLineAt(_loc6_ - 1);
            _loc21_ = _loc3_.flowComposer.getControllerAt(_loc3_.flowComposer.numControllers - 1);
            _loc22_ = _loc21_.absoluteStart;
            _loc23_ = _loc22_ + _loc21_.textLength;
            if(_loc20_.absoluteStart >= _loc22_ && _loc20_.absoluteStart < _loc23_)
            {
               _loc21_.scrollToRange(_loc20_.absoluteStart,_loc20_.absoluteStart + _loc20_.textLength - 1);
            }
            _loc24_ = _loc20_.getTextLine(true);
            if(_loc20_.controller == _loc8_.controller)
            {
               if(_loc3_.computedFormat.blockProgression != BlockProgression.RL)
               {
                  _loc19_.y -= _loc11_.y - _loc24_.y;
               }
               else
               {
                  _loc19_.x += _loc24_.x - _loc11_.x;
               }
            }
            else
            {
               _loc25_ = _loc24_.getAtomBounds(0);
               _loc26_ = new Point();
               _loc26_.x = _loc25_.left;
               _loc26_.y = 0;
               _loc26_ = _loc24_.localToGlobal(_loc26_);
               if(_loc3_.computedFormat.blockProgression != BlockProgression.RL)
               {
                  _loc19_.x -= _loc8_.controller.container.x;
                  _loc19_.y = _loc26_.y;
               }
               else
               {
                  _loc19_.x = _loc26_.x;
                  _loc19_.y -= _loc8_.controller.container.y;
               }
            }
            _loc13_ = _loc24_.getAtomIndexAtPoint(_loc19_.x,_loc19_.y);
            if(_loc13_ == -1)
            {
               if(_loc3_.computedFormat.blockProgression != BlockProgression.RL)
               {
                  if(!_loc14_)
                  {
                     _loc5_ = _loc19_.x <= _loc24_.x ? _loc20_.absoluteStart : _loc20_.absoluteStart + _loc20_.textLength - 1;
                  }
                  else
                  {
                     _loc5_ = _loc19_.x <= _loc24_.x ? _loc20_.absoluteStart + _loc20_.textLength - 1 : _loc20_.absoluteStart;
                  }
               }
               else if(!_loc14_)
               {
                  _loc5_ = _loc19_.y <= _loc24_.y ? _loc20_.absoluteStart : _loc20_.absoluteStart + _loc20_.textLength - 1;
               }
               else
               {
                  _loc5_ = _loc19_.y <= _loc24_.y ? _loc20_.absoluteStart + _loc20_.textLength - 1 : _loc20_.absoluteStart;
               }
            }
            else
            {
               _loc27_ = _loc24_.getAtomBounds(_loc13_);
               _loc28_ = false;
               if(_loc27_)
               {
                  _loc30_ = new Point();
                  _loc30_.x = _loc27_.x;
                  _loc30_.y = _loc27_.y;
                  _loc30_ = _loc24_.localToGlobal(_loc30_);
                  if(_loc3_.computedFormat.blockProgression == BlockProgression.RL && _loc24_.getAtomTextRotation(_loc13_) != TextRotation.ROTATE_0)
                  {
                     _loc28_ = _loc19_.y > _loc30_.y + _loc27_.height / 2;
                  }
                  else
                  {
                     _loc28_ = _loc19_.x > _loc30_.x + _loc27_.width / 2;
                  }
               }
               if(_loc24_.getAtomBidiLevel(_loc13_) % 2 != 0)
               {
                  _loc29_ = _loc28_ ? _loc24_.getAtomTextBlockBeginIndex(_loc13_) : _loc24_.getAtomTextBlockEndIndex(_loc13_);
               }
               else if(_loc7_)
               {
                  if(_loc28_ == false && _loc13_ > 0)
                  {
                     _loc29_ = _loc24_.getAtomTextBlockBeginIndex(_loc13_ - 1);
                  }
                  else
                  {
                     _loc29_ = _loc24_.getAtomTextBlockBeginIndex(_loc13_);
                  }
               }
               else
               {
                  _loc29_ = _loc28_ ? _loc24_.getAtomTextBlockEndIndex(_loc13_) : _loc24_.getAtomTextBlockBeginIndex(_loc13_);
               }
               _loc5_ = _loc20_.paragraph.getAbsoluteStart() + _loc29_;
            }
         }
         else
         {
            _loc5_ = 0;
         }
         if(!param2)
         {
            _loc4_ = _loc5_;
         }
         if(_loc4_ == _loc5_)
         {
            _loc4_ = tlf_internal::updateStartIfInReadOnlyElement(_loc3_,_loc4_);
            _loc5_ = tlf_internal::updateEndIfInReadOnlyElement(_loc3_,_loc5_);
         }
         else
         {
            _loc5_ = tlf_internal::updateEndIfInReadOnlyElement(_loc3_,_loc5_);
         }
         return param1.updateRange(_loc4_,_loc5_);
      }
      
      public static function nextPage(param1:TextRange, param2:Boolean = false) : Boolean
      {
         var _loc3_:ContainerController = null;
         var _loc12_:int = 0;
         var _loc15_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         if(!validateTextRange(param1))
         {
            return false;
         }
         var _loc4_:TextFlow = param1.textFlow;
         var _loc5_:int = _loc4_.flowComposer.findControllerIndexAtPosition(param1.activePosition);
         if(_loc5_ != _loc4_.flowComposer.numControllers - 1)
         {
            param1.activePosition = _loc4_.flowComposer.getControllerAt(_loc5_ + 1).absoluteStart;
            if(!param2)
            {
               param1.anchorPosition = param1.activePosition;
            }
            return true;
         }
         if(!isScrollable(_loc4_,param1.activePosition))
         {
            return false;
         }
         if(adjustForOversetForward(param1))
         {
            return true;
         }
         var _loc6_:int = param1.absoluteStart;
         var _loc7_:int = param1.absoluteEnd;
         var _loc8_:int = _loc4_.flowComposer.findLineIndexAtPosition(_loc7_);
         var _loc9_:TextFlowLine = _loc4_.flowComposer.getLineAt(_loc8_);
         var _loc10_:int = _loc4_.flowComposer.getLineAt(_loc8_).absoluteStart;
         var _loc11_:int = _loc7_ - _loc10_;
         var _loc13_:TextFlowLine = _loc9_;
         var _loc14_:* = _loc4_.computedFormat.blockProgression == BlockProgression.RL;
         _loc3_ = _loc4_.flowComposer.getControllerAt(_loc4_.flowComposer.numControllers - 1);
         if(_loc14_)
         {
            _loc15_ = _loc3_.compositionWidth * _loc4_.configuration.scrollPagePercentage;
         }
         else
         {
            _loc15_ = _loc3_.compositionHeight * _loc4_.configuration.scrollPagePercentage;
         }
         if(_loc14_)
         {
            if(_loc3_.horizontalScrollPosition - _loc15_ < -_loc3_.tlf_internal::contentWidth)
            {
               _loc3_.horizontalScrollPosition = -_loc3_.tlf_internal::contentWidth;
               _loc12_ = _loc4_.flowComposer.numLines - 1;
               _loc13_ = _loc4_.flowComposer.getLineAt(_loc12_);
            }
            else
            {
               _loc17_ = _loc3_.horizontalScrollPosition;
               _loc3_.horizontalScrollPosition -= _loc15_;
               _loc18_ = _loc3_.horizontalScrollPosition;
               if(_loc17_ == _loc18_)
               {
                  _loc12_ = _loc4_.flowComposer.numLines - 1;
                  _loc13_ = _loc4_.flowComposer.getLineAt(_loc12_);
               }
               else
               {
                  _loc12_ = _loc8_;
                  while(_loc12_ < _loc4_.flowComposer.numLines - 1)
                  {
                     _loc12_++;
                     _loc13_ = _loc4_.flowComposer.getLineAt(_loc12_);
                     if(_loc9_.x - _loc13_.x >= _loc17_ - _loc18_)
                     {
                        break;
                     }
                  }
               }
            }
         }
         else if(_loc3_.verticalScrollPosition + _loc15_ > _loc3_.tlf_internal::contentHeight)
         {
            _loc3_.verticalScrollPosition = _loc3_.tlf_internal::contentHeight;
            _loc12_ = _loc4_.flowComposer.numLines - 1;
            _loc13_ = _loc4_.flowComposer.getLineAt(_loc12_);
         }
         else
         {
            _loc19_ = _loc3_.verticalScrollPosition;
            _loc3_.verticalScrollPosition += _loc15_;
            _loc20_ = _loc3_.verticalScrollPosition;
            if(_loc20_ == _loc19_)
            {
               _loc12_ = _loc4_.flowComposer.numLines - 1;
               _loc13_ = _loc4_.flowComposer.getLineAt(_loc12_);
            }
            else
            {
               _loc12_ = _loc8_;
               while(_loc12_ < _loc4_.flowComposer.numLines - 1)
               {
                  _loc12_++;
                  _loc13_ = _loc4_.flowComposer.getLineAt(_loc12_);
                  if(_loc13_.y - _loc9_.y >= _loc20_ - _loc19_)
                  {
                     break;
                  }
               }
            }
         }
         _loc7_ = _loc13_.absoluteStart + _loc11_;
         var _loc16_:int = _loc13_.absoluteStart + _loc13_.textLength - 1;
         if(_loc7_ > _loc16_)
         {
            _loc7_ = _loc16_;
         }
         if(!param2)
         {
            _loc6_ = _loc7_;
         }
         if(_loc6_ == _loc7_)
         {
            _loc6_ = tlf_internal::updateEndIfInReadOnlyElement(_loc4_,_loc6_);
            _loc7_ = tlf_internal::updateStartIfInReadOnlyElement(_loc4_,_loc7_);
         }
         else
         {
            _loc7_ = tlf_internal::updateStartIfInReadOnlyElement(_loc4_,_loc7_);
         }
         return param1.updateRange(_loc6_,_loc7_);
      }
      
      public static function previousPage(param1:TextRange, param2:Boolean = false) : Boolean
      {
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc17_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         if(!validateTextRange(param1))
         {
            return false;
         }
         var _loc3_:TextFlow = param1.textFlow;
         var _loc4_:int = _loc3_.flowComposer.findControllerIndexAtPosition(param1.activePosition);
         var _loc5_:ContainerController = _loc3_.flowComposer.getControllerAt(_loc4_);
         var _loc6_:TextFlowLine = _loc3_.flowComposer.findLineAtPosition(_loc5_.absoluteStart);
         if(param1.activePosition <= _loc5_.absoluteStart + _loc6_.textLength)
         {
            if(_loc4_ == 0)
            {
               return false;
            }
            param1.activePosition = _loc3_.flowComposer.getControllerAt(_loc4_ - 1).absoluteStart;
            if(!param2)
            {
               param1.anchorPosition = param1.activePosition;
            }
            return true;
         }
         if(_loc4_ != _loc3_.flowComposer.numControllers - 1)
         {
            param1.activePosition = _loc5_.absoluteStart;
            if(!param2)
            {
               param1.anchorPosition = param1.activePosition;
            }
            return true;
         }
         if(!isScrollable(_loc3_,param1.activePosition))
         {
            return false;
         }
         if(adjustForOversetBack(param1))
         {
            return true;
         }
         var _loc7_:int = param1.absoluteStart;
         var _loc8_:int = param1.absoluteEnd;
         var _loc9_:int = _loc3_.flowComposer.findLineIndexAtPosition(_loc8_);
         var _loc10_:TextFlowLine = _loc3_.flowComposer.getLineAt(_loc9_);
         var _loc11_:int = _loc3_.flowComposer.getLineAt(_loc9_).absoluteStart;
         var _loc12_:int = _loc8_ - _loc11_;
         var _loc15_:TextFlowLine = _loc10_;
         var _loc16_:* = _loc3_.computedFormat.blockProgression == BlockProgression.RL;
         _loc5_ = _loc3_.flowComposer.getControllerAt(_loc3_.flowComposer.numControllers - 1);
         if(_loc16_)
         {
            _loc17_ = _loc5_.compositionWidth * _loc3_.configuration.scrollPagePercentage;
         }
         else
         {
            _loc17_ = _loc5_.compositionHeight * _loc3_.configuration.scrollPagePercentage;
         }
         if(_loc16_)
         {
            if(_loc5_.horizontalScrollPosition + _loc17_ + _loc5_.compositionWidth > 0)
            {
               _loc5_.horizontalScrollPosition = 0;
               _loc13_ = _loc3_.flowComposer.findLineIndexAtPosition(_loc5_.absoluteStart);
               _loc15_ = _loc3_.flowComposer.getLineAt(_loc13_);
            }
            else
            {
               _loc19_ = _loc5_.horizontalScrollPosition;
               _loc5_.horizontalScrollPosition += _loc17_;
               _loc20_ = _loc5_.horizontalScrollPosition;
               if(_loc19_ == _loc20_)
               {
                  _loc13_ = _loc3_.flowComposer.findLineIndexAtPosition(_loc5_.absoluteStart);
                  _loc15_ = _loc3_.flowComposer.getLineAt(_loc13_);
               }
               else
               {
                  _loc13_ = _loc9_;
                  while(_loc13_ > 0)
                  {
                     _loc13_--;
                     _loc15_ = _loc3_.flowComposer.getLineAt(_loc13_);
                     if(_loc15_.x - _loc10_.x >= _loc20_ - _loc19_ || _loc15_.absoluteStart < _loc5_.absoluteStart)
                     {
                        break;
                     }
                  }
               }
            }
         }
         else if(_loc5_.verticalScrollPosition - _loc17_ + _loc5_.compositionHeight < 0)
         {
            _loc5_.verticalScrollPosition = 0;
            _loc13_ = _loc3_.flowComposer.findLineIndexAtPosition(_loc5_.absoluteStart);
            _loc15_ = _loc3_.flowComposer.getLineAt(_loc13_);
         }
         else
         {
            _loc21_ = _loc5_.verticalScrollPosition;
            _loc5_.verticalScrollPosition -= _loc17_;
            _loc22_ = _loc5_.verticalScrollPosition;
            if(_loc21_ == _loc22_)
            {
               _loc13_ = _loc3_.flowComposer.findLineIndexAtPosition(_loc5_.absoluteStart);
               _loc15_ = _loc3_.flowComposer.getLineAt(_loc13_);
            }
            else
            {
               _loc13_ = _loc9_;
               while(_loc13_ > 0)
               {
                  _loc13_--;
                  _loc15_ = _loc3_.flowComposer.getLineAt(_loc13_);
                  if(_loc10_.y - _loc15_.y >= _loc21_ - _loc22_ || _loc15_.absoluteStart < _loc5_.absoluteStart)
                  {
                     break;
                  }
               }
            }
         }
         _loc8_ = _loc15_.absoluteStart + _loc12_;
         var _loc18_:int = _loc15_.absoluteStart + _loc15_.textLength - 1;
         if(_loc8_ > _loc18_)
         {
            _loc8_ = _loc18_;
         }
         if(!param2)
         {
            _loc7_ = _loc8_;
         }
         if(_loc7_ == _loc8_)
         {
            _loc7_ = tlf_internal::updateEndIfInReadOnlyElement(_loc3_,_loc7_);
            _loc8_ = tlf_internal::updateStartIfInReadOnlyElement(_loc3_,_loc8_);
         }
         else
         {
            _loc8_ = tlf_internal::updateStartIfInReadOnlyElement(_loc3_,_loc8_);
         }
         return param1.updateRange(_loc7_,_loc8_);
      }
      
      public static function endOfLine(param1:TextRange, param2:Boolean = false) : Boolean
      {
         if(!validateTextRange(param1))
         {
            return false;
         }
         var _loc3_:TextFlow = param1.textFlow;
         checkCompose(_loc3_.flowComposer,param1.absoluteEnd);
         var _loc4_:int = param1.anchorPosition;
         var _loc5_:int = param1.activePosition;
         var _loc6_:int = _loc3_.flowComposer.findLineIndexAtPosition(_loc5_);
         var _loc7_:int = _loc3_.flowComposer.getLineAt(_loc6_).absoluteStart;
         var _loc8_:int = _loc7_ + _loc3_.flowComposer.getLineAt(_loc6_).textLength - 1;
         var _loc9_:FlowLeafElement = _loc3_.findLeaf(_loc5_);
         var _loc10_:ParagraphElement = _loc9_.getParagraph();
         if(CharacterUtil.isWhitespace(_loc10_.getCharCodeAtPosition(_loc8_ - _loc10_.getAbsoluteStart())))
         {
            _loc5_ = _loc8_;
         }
         else
         {
            _loc5_ = _loc8_ + 1;
         }
         if(!param2)
         {
            _loc4_ = _loc5_;
         }
         if(_loc4_ == _loc5_)
         {
            _loc4_ = tlf_internal::updateEndIfInReadOnlyElement(_loc3_,_loc4_);
            _loc5_ = tlf_internal::updateStartIfInReadOnlyElement(_loc3_,_loc5_);
         }
         else
         {
            _loc5_ = tlf_internal::updateStartIfInReadOnlyElement(_loc3_,_loc5_);
         }
         return param1.updateRange(_loc4_,_loc5_);
      }
      
      public static function startOfLine(param1:TextRange, param2:Boolean = false) : Boolean
      {
         if(!validateTextRange(param1))
         {
            return false;
         }
         var _loc3_:TextFlow = param1.textFlow;
         checkCompose(_loc3_.flowComposer,param1.absoluteEnd);
         var _loc4_:int = param1.anchorPosition;
         var _loc5_:int = param1.activePosition;
         var _loc6_:int = _loc3_.flowComposer.findLineIndexAtPosition(_loc5_);
         var _loc7_:int;
         _loc5_ = _loc7_ = _loc3_.flowComposer.getLineAt(_loc6_).absoluteStart;
         if(!param2)
         {
            _loc4_ = _loc5_;
         }
         if(_loc4_ == _loc5_)
         {
            _loc4_ = tlf_internal::updateEndIfInReadOnlyElement(_loc3_,_loc4_);
            _loc5_ = tlf_internal::updateStartIfInReadOnlyElement(_loc3_,_loc5_);
         }
         else
         {
            _loc5_ = tlf_internal::updateStartIfInReadOnlyElement(_loc3_,_loc5_);
         }
         return param1.updateRange(_loc4_,_loc5_);
      }
      
      public static function endOfDocument(param1:TextRange, param2:Boolean = false) : Boolean
      {
         if(!validateTextRange(param1))
         {
            return false;
         }
         var _loc3_:TextFlow = param1.textFlow;
         var _loc4_:int = param1.anchorPosition;
         var _loc5_:int = param1.activePosition;
         _loc5_ = _loc3_.textLength - 1;
         if(!param2)
         {
            _loc4_ = _loc5_;
         }
         if(_loc4_ == _loc5_)
         {
            _loc4_ = tlf_internal::updateEndIfInReadOnlyElement(_loc3_,_loc4_);
            _loc5_ = tlf_internal::updateStartIfInReadOnlyElement(_loc3_,_loc5_);
         }
         else
         {
            _loc5_ = tlf_internal::updateStartIfInReadOnlyElement(_loc3_,_loc5_);
         }
         return param1.updateRange(_loc4_,_loc5_);
      }
      
      public static function startOfDocument(param1:TextRange, param2:Boolean = false) : Boolean
      {
         var _loc3_:int = param1.anchorPosition;
         var _loc4_:int = 0;
         if(!param2)
         {
            _loc3_ = _loc4_;
         }
         if(_loc3_ == _loc4_)
         {
            _loc3_ = tlf_internal::updateEndIfInReadOnlyElement(param1.textFlow,_loc3_);
            _loc4_ = tlf_internal::updateStartIfInReadOnlyElement(param1.textFlow,_loc4_);
         }
         else
         {
            _loc4_ = tlf_internal::updateStartIfInReadOnlyElement(param1.textFlow,_loc4_);
         }
         return param1.updateRange(_loc3_,_loc4_);
      }
      
      public static function startOfParagraph(param1:TextRange, param2:Boolean = false) : Boolean
      {
         var _loc3_:int = param1.anchorPosition;
         var _loc4_:int = param1.activePosition;
         var _loc5_:FlowLeafElement = param1.textFlow.findLeaf(_loc4_);
         var _loc6_:ParagraphElement = _loc5_.getParagraph();
         _loc4_ = _loc6_.getAbsoluteStart();
         if(!param2)
         {
            _loc3_ = _loc4_;
         }
         if(_loc3_ == _loc4_)
         {
            _loc3_ = tlf_internal::updateStartIfInReadOnlyElement(param1.textFlow,_loc3_);
            _loc4_ = tlf_internal::updateEndIfInReadOnlyElement(param1.textFlow,_loc4_);
         }
         else
         {
            _loc4_ = tlf_internal::updateEndIfInReadOnlyElement(param1.textFlow,_loc4_);
         }
         return param1.updateRange(_loc3_,_loc4_);
      }
      
      public static function endOfParagraph(param1:TextRange, param2:Boolean = false) : Boolean
      {
         if(!validateTextRange(param1))
         {
            return false;
         }
         var _loc3_:int = param1.anchorPosition;
         var _loc4_:int = param1.activePosition;
         var _loc5_:FlowLeafElement = param1.textFlow.findLeaf(_loc4_);
         var _loc6_:ParagraphElement = _loc5_.getParagraph();
         _loc4_ = _loc6_.getAbsoluteStart() + _loc6_.textLength - 1;
         if(!param2)
         {
            _loc3_ = _loc4_;
         }
         if(_loc3_ == _loc4_)
         {
            _loc3_ = tlf_internal::updateStartIfInReadOnlyElement(param1.textFlow,_loc3_);
            _loc4_ = tlf_internal::updateEndIfInReadOnlyElement(param1.textFlow,_loc4_);
         }
         else
         {
            _loc4_ = tlf_internal::updateEndIfInReadOnlyElement(param1.textFlow,_loc4_);
         }
         return param1.updateRange(_loc3_,_loc4_);
      }
      
      private static function adjustForOversetForward(param1:TextRange) : Boolean
      {
         var _loc4_:int = 0;
         var _loc2_:IFlowComposer = param1.textFlow.flowComposer;
         var _loc3_:ContainerController = null;
         checkCompose(_loc2_,param1.absoluteEnd);
         if(Boolean(_loc2_) && Boolean(_loc2_.numControllers))
         {
            _loc4_ = _loc2_.findControllerIndexAtPosition(param1.absoluteEnd);
            if(_loc4_ >= 0)
            {
               _loc3_ = _loc2_.getControllerAt(_loc4_);
            }
            if(_loc4_ == _loc2_.numControllers - 1)
            {
               if(_loc3_.absoluteStart + _loc3_.textLength <= param1.absoluteEnd && _loc3_.absoluteStart + _loc3_.textLength != param1.textFlow.textLength)
               {
                  _loc3_ = null;
               }
            }
         }
         if(!_loc3_)
         {
            param1.anchorPosition = param1.textFlow.textLength - 1;
            param1.activePosition = param1.anchorPosition;
            return true;
         }
         return false;
      }
      
      private static function adjustForOversetBack(param1:TextRange) : Boolean
      {
         var _loc2_:IFlowComposer = param1.textFlow.flowComposer;
         if(_loc2_)
         {
            checkCompose(_loc2_,param1.absoluteEnd);
            if(_loc2_.findControllerIndexAtPosition(param1.absoluteEnd) == -1)
            {
               param1.anchorPosition = endOfLastController(param1.textFlow);
               param1.activePosition = param1.anchorPosition;
               return true;
            }
         }
         return false;
      }
      
      private static function checkCompose(param1:IFlowComposer, param2:int) : void
      {
         if(param1.damageAbsoluteStart <= param2)
         {
            param1.composeToPosition(param2);
         }
      }
      
      private static function endOfLastController(param1:TextFlow) : int
      {
         var _loc2_:IFlowComposer = param1.flowComposer;
         if(!_loc2_ || _loc2_.numControllers <= 0)
         {
            return 0;
         }
         var _loc3_:ContainerController = _loc2_.getControllerAt(_loc2_.numControllers - 1);
         return _loc3_.absoluteStart + Math.max(_loc3_.textLength - 1,0);
      }
      
      private static function isOverset(param1:TextFlow, param2:int) : Boolean
      {
         var _loc3_:IFlowComposer = param1.flowComposer;
         return !_loc3_ || _loc3_.findControllerIndexAtPosition(param2) == -1;
      }
      
      private static function isScrollable(param1:TextFlow, param2:int) : Boolean
      {
         var _loc5_:ContainerController = null;
         var _loc6_:String = null;
         var _loc3_:IFlowComposer = param1.flowComposer;
         if(!_loc3_)
         {
            return false;
         }
         var _loc4_:int = _loc3_.findControllerIndexAtPosition(param2);
         if(_loc4_ >= 0)
         {
            _loc5_ = _loc3_.getControllerAt(_loc4_);
            _loc6_ = _loc5_.rootElement.computedFormat.blockProgression;
            return _loc6_ == BlockProgression.TB && _loc5_.verticalScrollPolicy != ScrollPolicy.OFF || _loc6_ == BlockProgression.RL && _loc5_.horizontalScrollPolicy != ScrollPolicy.OFF;
         }
         return false;
      }
   }
}

