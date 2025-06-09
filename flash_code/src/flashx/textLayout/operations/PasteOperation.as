package flashx.textLayout.operations
{
   import flashx.textLayout.edit.SelectionState;
   import flashx.textLayout.edit.TextFlowEdit;
   import flashx.textLayout.edit.TextScrap;
   
   public class PasteOperation extends FlowTextOperation
   {
      
      private var _textScrap:TextScrap;
      
      private var _tScrapUnderSelection:TextScrap;
      
      private var _numCharsAdded:int = 0;
      
      public function PasteOperation(param1:SelectionState, param2:TextScrap)
      {
         super(param1);
         this._textScrap = param2;
      }
      
      override public function doOperation() : Boolean
      {
         if(this._textScrap != null)
         {
            this._tScrapUnderSelection = TextFlowEdit.createTextScrap(originalSelectionState.textFlow,originalSelectionState.absoluteStart,originalSelectionState.absoluteEnd);
            this.internalDoOperation();
         }
         return true;
      }
      
      private function internalDoOperation() : void
      {
         if(absoluteStart != absoluteEnd)
         {
            TextFlowEdit.replaceRange(textFlow,absoluteStart,absoluteEnd,null);
            if(textFlow.interactionManager)
            {
               textFlow.interactionManager.notifyInsertOrDelete(absoluteStart,absoluteStart - absoluteEnd);
            }
         }
         var _loc1_:int = TextFlowEdit.replaceRange(textFlow,absoluteStart,absoluteStart,this._textScrap);
         if(textFlow.interactionManager)
         {
            textFlow.interactionManager.notifyInsertOrDelete(absoluteStart,_loc1_ - absoluteStart);
         }
         this._numCharsAdded = _loc1_ - absoluteStart;
      }
      
      override public function undo() : SelectionState
      {
         if(this._textScrap != null)
         {
            TextFlowEdit.replaceRange(textFlow,absoluteStart,absoluteStart + this._numCharsAdded,this._tScrapUnderSelection);
            if(textFlow.interactionManager)
            {
               textFlow.interactionManager.notifyInsertOrDelete(absoluteStart,-this._numCharsAdded);
            }
         }
         return originalSelectionState;
      }
      
      override public function redo() : SelectionState
      {
         if(this._textScrap != null)
         {
            this.internalDoOperation();
         }
         return new SelectionState(textFlow,absoluteStart + this._numCharsAdded,absoluteStart + this._numCharsAdded,null);
      }
      
      public function get textScrap() : TextScrap
      {
         return this._textScrap;
      }
      
      public function set textScrap(param1:TextScrap) : void
      {
         this._textScrap = param1;
      }
   }
}

