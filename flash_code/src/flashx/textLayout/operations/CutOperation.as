package flashx.textLayout.operations
{
   import flashx.textLayout.edit.SelectionState;
   import flashx.textLayout.edit.TextFlowEdit;
   import flashx.textLayout.edit.TextScrap;
   
   public class CutOperation extends FlowTextOperation
   {
      
      private var _tScrap:TextScrap;
      
      public function CutOperation(param1:SelectionState, param2:TextScrap)
      {
         super(param1);
         this._tScrap = param2;
      }
      
      override public function doOperation() : Boolean
      {
         var _loc1_:int = textFlow.textLength;
         TextFlowEdit.replaceRange(textFlow,absoluteStart,absoluteEnd,null);
         if(textFlow.interactionManager)
         {
            textFlow.interactionManager.notifyInsertOrDelete(absoluteStart,-(absoluteEnd - absoluteStart));
         }
         if(textFlow.textLength == _loc1_)
         {
            this._tScrap = null;
         }
         return true;
      }
      
      override public function undo() : SelectionState
      {
         if(this._tScrap != null)
         {
            TextFlowEdit.replaceRange(textFlow,absoluteStart,absoluteStart,this._tScrap);
            if(textFlow.interactionManager)
            {
               textFlow.interactionManager.notifyInsertOrDelete(absoluteStart,absoluteEnd - absoluteStart);
            }
         }
         return originalSelectionState;
      }
      
      override public function redo() : SelectionState
      {
         TextFlowEdit.replaceRange(textFlow,absoluteStart,absoluteEnd,null);
         if(textFlow.interactionManager)
         {
            textFlow.interactionManager.notifyInsertOrDelete(absoluteStart,-(absoluteEnd - absoluteStart));
         }
         return new SelectionState(textFlow,absoluteStart,absoluteStart,null);
      }
      
      public function get scrapToCut() : TextScrap
      {
         return this._tScrap;
      }
      
      public function set scrapToCut(param1:TextScrap) : void
      {
         this._tScrap = param1;
      }
   }
}

