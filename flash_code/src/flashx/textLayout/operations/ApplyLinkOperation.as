package flashx.textLayout.operations
{
   import flashx.textLayout.edit.SelectionState;
   import flashx.textLayout.edit.TextFlowEdit;
   import flashx.textLayout.edit.TextScrap;
   import flashx.textLayout.elements.FlowLeafElement;
   import flashx.textLayout.elements.LinkElement;
   
   public class ApplyLinkOperation extends FlowTextOperation
   {
      
      private var _textScrap:TextScrap;
      
      private var _hrefString:String;
      
      private var _target:String;
      
      private var _extendToLinkBoundary:Boolean;
      
      public function ApplyLinkOperation(param1:SelectionState, param2:String, param3:String, param4:Boolean)
      {
         super(param1);
         this._hrefString = param2;
         this._target = param3;
         this._extendToLinkBoundary = param4;
      }
      
      public function get href() : String
      {
         return this._hrefString;
      }
      
      public function set href(param1:String) : void
      {
         this._hrefString = param1;
      }
      
      public function get target() : String
      {
         return this._target;
      }
      
      public function set target(param1:String) : void
      {
         this._target = param1;
      }
      
      public function get extendToLinkBoundary() : Boolean
      {
         return this._extendToLinkBoundary;
      }
      
      public function set extendToLinkBoundary(param1:Boolean) : void
      {
         this._extendToLinkBoundary = param1;
      }
      
      override public function doOperation() : Boolean
      {
         var _loc1_:FlowLeafElement = null;
         var _loc2_:LinkElement = null;
         var _loc3_:Boolean = false;
         if(absoluteStart == absoluteEnd)
         {
            return false;
         }
         if(this._extendToLinkBoundary)
         {
            _loc1_ = textFlow.findLeaf(absoluteStart);
            _loc2_ = _loc1_.getParentByType(LinkElement) as LinkElement;
            if(_loc2_)
            {
               absoluteStart = _loc2_.getAbsoluteStart();
            }
            _loc1_ = textFlow.findLeaf(absoluteEnd - 1);
            _loc2_ = _loc1_.getParentByType(LinkElement) as LinkElement;
            if(_loc2_)
            {
               absoluteEnd = _loc2_.getAbsoluteStart() + _loc2_.textLength;
            }
         }
         this._textScrap = TextFlowEdit.createTextScrap(textFlow,absoluteStart,absoluteEnd);
         if(this._hrefString != "")
         {
            _loc3_ = TextFlowEdit.makeLink(textFlow,absoluteStart,absoluteEnd,this._hrefString,this._target);
            if(!_loc3_)
            {
               return false;
            }
         }
         else
         {
            TextFlowEdit.removeLink(textFlow,absoluteStart,absoluteEnd);
         }
         return true;
      }
      
      override public function undo() : SelectionState
      {
         if(absoluteStart != absoluteEnd && this._textScrap != null)
         {
            TextFlowEdit.replaceRange(textFlow,absoluteStart,absoluteEnd,this._textScrap);
         }
         return originalSelectionState;
      }
      
      override public function redo() : SelectionState
      {
         if(absoluteStart != absoluteEnd)
         {
            if(this._hrefString != "")
            {
               TextFlowEdit.makeLink(textFlow,absoluteStart,absoluteEnd,this._hrefString,this._target);
            }
            else
            {
               TextFlowEdit.removeLink(textFlow,absoluteStart,absoluteEnd);
            }
         }
         return originalSelectionState;
      }
   }
}

