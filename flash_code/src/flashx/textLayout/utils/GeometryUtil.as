package flashx.textLayout.utils
{
   import flash.geom.Rectangle;
   import flash.text.engine.TextLine;
   import flashx.textLayout.compose.IFlowComposer;
   import flashx.textLayout.compose.TextFlowLine;
   import flashx.textLayout.elements.TextRange;
   import flashx.textLayout.tlf_internal;
   
   use namespace tlf_internal;
   
   public final class GeometryUtil
   {
      
      public function GeometryUtil()
      {
         super();
      }
      
      public static function getHighlightBounds(param1:TextRange) : Array
      {
         var _loc7_:TextFlowLine = null;
         var _loc10_:Array = null;
         var _loc11_:Array = null;
         var _loc12_:Array = null;
         var _loc13_:TextLine = null;
         var _loc14_:Rectangle = null;
         var _loc15_:TextFlowLine = null;
         var _loc16_:Object = null;
         var _loc2_:IFlowComposer = param1.textFlow.flowComposer;
         if(!_loc2_)
         {
            return null;
         }
         var _loc3_:Array = new Array();
         var _loc4_:int = _loc2_.findLineIndexAtPosition(param1.absoluteStart);
         var _loc5_:int = param1.absoluteStart == param1.absoluteEnd ? _loc4_ : _loc2_.findLineIndexAtPosition(param1.absoluteEnd);
         if(_loc5_ >= _loc2_.numLines)
         {
            _loc5_ = _loc2_.numLines - 1;
         }
         var _loc6_:TextFlowLine = _loc4_ > 0 ? _loc2_.getLineAt(_loc4_ - 1) : null;
         var _loc8_:TextFlowLine = _loc2_.getLineAt(_loc4_);
         var _loc9_:int = _loc4_;
         while(_loc9_ <= _loc5_)
         {
            _loc7_ = _loc9_ != _loc2_.numLines - 1 ? _loc2_.getLineAt(_loc9_ + 1) : null;
            _loc10_ = new Array();
            _loc11_ = new Array();
            _loc12_ = _loc8_.tlf_internal::getRomanSelectionHeightAndVerticalAdjustment(_loc6_,_loc7_);
            _loc13_ = _loc8_.getTextLine();
            _loc8_.tlf_internal::calculateSelectionBounds(_loc13_,_loc10_,param1.absoluteStart < _loc8_.absoluteStart ? _loc8_.absoluteStart - _loc8_.paragraph.getAbsoluteStart() : param1.absoluteStart - _loc8_.paragraph.getAbsoluteStart(),param1.absoluteEnd > _loc8_.absoluteStart + _loc8_.textLength ? _loc8_.absoluteStart + _loc8_.textLength - _loc8_.paragraph.getAbsoluteStart() : param1.absoluteEnd - _loc8_.paragraph.getAbsoluteStart(),param1.textFlow.computedFormat.blockProgression,_loc12_);
            for each(_loc14_ in _loc10_)
            {
               _loc16_ = new Object();
               _loc16_.textLine = _loc13_;
               _loc16_.rect = _loc14_.clone();
               _loc3_.push(_loc16_);
            }
            _loc15_ = _loc8_;
            _loc8_ = _loc7_;
            _loc6_ = _loc15_;
            _loc9_++;
         }
         return _loc3_;
      }
   }
}

