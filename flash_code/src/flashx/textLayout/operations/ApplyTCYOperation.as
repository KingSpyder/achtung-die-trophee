package flashx.textLayout.operations
{
   import flashx.textLayout.edit.SelectionState;
   import flashx.textLayout.edit.TextFlowEdit;
   import flashx.textLayout.edit.TextScrap;
   import flashx.textLayout.elements.FlowLeafElement;
   import flashx.textLayout.elements.TCYElement;
   
   public class ApplyTCYOperation extends FlowTextOperation
   {
      
      private var makeBegIdx:int;
      
      private var makeEndIdx:int;
      
      private var removeBegIdx:int;
      
      private var removeEndIdx:int;
      
      private var removeRedoBegIdx:int;
      
      private var removeRedoEndIdx:int;
      
      private var _textScrap:TextScrap;
      
      private var _tcyOn:Boolean;
      
      public function ApplyTCYOperation(param1:SelectionState, param2:Boolean)
      {
         super(param1);
         if(param2)
         {
            this.makeBegIdx = param1.absoluteStart;
            this.makeEndIdx = param1.absoluteEnd;
         }
         else
         {
            this.removeBegIdx = param1.absoluteStart;
            this.removeEndIdx = param1.absoluteEnd;
         }
         this._tcyOn = param2;
      }
      
      public function get tcyOn() : Boolean
      {
         return this._tcyOn;
      }
      
      public function set tcyOn(param1:Boolean) : void
      {
         this._tcyOn = param1;
      }
      
      override public function doOperation() : Boolean
      {
         var _loc1_:FlowLeafElement = null;
         var _loc2_:TCYElement = null;
         if(this._tcyOn && this.makeEndIdx <= this.makeBegIdx)
         {
            return false;
         }
         if(!this._tcyOn && this.removeEndIdx <= this.removeBegIdx)
         {
            return false;
         }
         if(this._tcyOn)
         {
            this._textScrap = TextFlowEdit.createTextScrap(textFlow,this.makeBegIdx,this.makeEndIdx);
            TextFlowEdit.makeTCY(textFlow,this.makeBegIdx,this.makeEndIdx);
         }
         else
         {
            _loc1_ = textFlow.findLeaf(this.removeBegIdx);
            _loc2_ = _loc1_.getParentByType(TCYElement) as TCYElement;
            this.removeRedoBegIdx = this.removeBegIdx;
            this.removeRedoEndIdx = this.removeEndIdx;
            this.removeBegIdx = _loc2_.getAbsoluteStart();
            this.removeEndIdx = this.removeBegIdx + _loc2_.textLength;
            this._textScrap = TextFlowEdit.createTextScrap(textFlow,this.removeBegIdx,this.removeEndIdx);
            TextFlowEdit.removeTCY(textFlow,this.removeRedoBegIdx,this.removeRedoEndIdx);
         }
         return true;
      }
      
      override public function undo() : SelectionState
      {
         if(this._textScrap != null)
         {
            if(this._tcyOn)
            {
               TextFlowEdit.replaceRange(textFlow,this.makeBegIdx,this.makeEndIdx,this._textScrap);
            }
            else
            {
               TextFlowEdit.replaceRange(textFlow,this.removeBegIdx,this.removeEndIdx,this._textScrap);
            }
         }
         return originalSelectionState;
      }
      
      override public function redo() : SelectionState
      {
         if(this._textScrap != null)
         {
            if(this._tcyOn)
            {
               TextFlowEdit.makeTCY(textFlow,this.makeBegIdx,this.makeEndIdx);
            }
            else
            {
               TextFlowEdit.removeTCY(textFlow,this.removeRedoBegIdx,this.removeRedoEndIdx);
            }
         }
         return originalSelectionState;
      }
   }
}

