package flashx.undo
{
   public class UndoManager implements IUndoManager
   {
      
      private var undoStack:Array;
      
      private var redoStack:Array;
      
      private var _undoAndRedoItemLimit:int = 25;
      
      public function UndoManager()
      {
         super();
         this.undoStack = new Array();
         this.redoStack = new Array();
      }
      
      public function clearAll() : void
      {
         this.undoStack.length = 0;
         this.redoStack.length = 0;
      }
      
      public function canUndo() : Boolean
      {
         return this.undoStack.length > 0;
      }
      
      public function peekUndo() : IOperation
      {
         return this.undoStack.length > 0 ? this.undoStack[this.undoStack.length - 1] : null;
      }
      
      public function popUndo() : IOperation
      {
         return IOperation(this.undoStack.pop());
      }
      
      public function pushUndo(param1:IOperation) : void
      {
         this.undoStack.push(param1);
         this.trimUndoRedoStacks();
      }
      
      public function canRedo() : Boolean
      {
         return this.redoStack.length > 0;
      }
      
      public function clearRedo() : void
      {
         this.redoStack.length = 0;
      }
      
      public function peekRedo() : IOperation
      {
         return this.redoStack.length > 0 ? this.redoStack[this.redoStack.length - 1] : null;
      }
      
      public function popRedo() : IOperation
      {
         return IOperation(this.redoStack.pop());
      }
      
      public function pushRedo(param1:IOperation) : void
      {
         this.redoStack.push(param1);
         this.trimUndoRedoStacks();
      }
      
      public function get undoAndRedoItemLimit() : int
      {
         return this._undoAndRedoItemLimit;
      }
      
      public function set undoAndRedoItemLimit(param1:int) : void
      {
         this._undoAndRedoItemLimit = param1;
         this.trimUndoRedoStacks();
      }
      
      public function undo() : void
      {
         var _loc1_:IOperation = null;
         if(this.canUndo())
         {
            _loc1_ = this.popUndo();
            _loc1_.performUndo();
         }
      }
      
      public function redo() : void
      {
         var _loc1_:IOperation = null;
         if(this.canRedo())
         {
            _loc1_ = this.popRedo();
            _loc1_.performRedo();
         }
      }
      
      private function trimUndoRedoStacks() : void
      {
         var _loc2_:int = 0;
         var _loc1_:int = int(this.undoStack.length + this.redoStack.length);
         if(_loc1_ > this._undoAndRedoItemLimit)
         {
            _loc2_ = Math.min(_loc1_ - this._undoAndRedoItemLimit,this.redoStack.length);
            if(_loc2_)
            {
               this.redoStack.splice(0,_loc2_);
               _loc1_ = int(this.undoStack.length + this.redoStack.length);
            }
            if(_loc1_ > this._undoAndRedoItemLimit)
            {
               _loc2_ = Math.min(_loc1_ - this._undoAndRedoItemLimit,this.undoStack.length);
               this.undoStack.splice(0,_loc2_);
            }
         }
      }
   }
}

