package flashx.textLayout.operations
{
   import flashx.textLayout.edit.SelectionState;
   import flashx.textLayout.elements.TextFlow;
   import flashx.textLayout.tlf_internal;
   
   use namespace tlf_internal;
   
   public class CompositeOperation extends FlowOperation
   {
      
      private var _operations:Array;
      
      public function CompositeOperation(param1:Array = null)
      {
         super(null);
         this.operations = param1;
      }
      
      override public function get textFlow() : TextFlow
      {
         return this._operations.length > 0 ? this._operations[0].textFlow : null;
      }
      
      public function get operations() : Array
      {
         return this._operations;
      }
      
      public function set operations(param1:Array) : void
      {
         this._operations = param1 ? param1.slice() : [];
      }
      
      public function addOperation(param1:FlowOperation) : void
      {
         if(this._operations.length > 0 && param1.textFlow != this.textFlow)
         {
            return;
         }
         this._operations.push(param1);
      }
      
      override public function doOperation() : Boolean
      {
         var _loc1_:Boolean = true;
         var _loc2_:int = 0;
         while(_loc2_ < this._operations.length)
         {
            _loc1_ &&= FlowOperation(this._operations[_loc2_]).doOperation();
            _loc2_++;
         }
         return true;
      }
      
      override public function undo() : SelectionState
      {
         var _loc1_:SelectionState = null;
         var _loc2_:int = int(this._operations.length - 1);
         while(_loc2_ >= 0)
         {
            _loc1_ = FlowOperation(this._operations[_loc2_]).undo();
            _loc2_--;
         }
         return _loc1_;
      }
      
      override public function redo() : SelectionState
      {
         var _loc1_:SelectionState = null;
         var _loc2_:int = 0;
         while(_loc2_ < this._operations.length)
         {
            _loc1_ = FlowOperation(this._operations[_loc2_]).redo();
            _loc2_++;
         }
         return _loc1_;
      }
      
      override public function canUndo() : Boolean
      {
         var _loc5_:FlowOperation = null;
         var _loc1_:Boolean = true;
         var _loc2_:int = int(beginGeneration);
         var _loc3_:int = int(this._operations.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_ && _loc1_)
         {
            _loc5_ = this._operations[_loc4_];
            if(_loc5_.beginGeneration != _loc2_ || !_loc5_.canUndo())
            {
               _loc1_ = false;
            }
            _loc2_ = int(_loc5_.endGeneration);
            _loc4_++;
         }
         if(_loc3_ > 0 && this._operations[_loc3_ - 1].endGeneration != endGeneration)
         {
            _loc1_ = false;
         }
         return _loc1_;
      }
      
      override tlf_internal function merge(param1:FlowOperation) : FlowOperation
      {
         var _loc2_:FlowOperation = null;
         var _loc3_:FlowOperation = null;
         if(param1 is InsertTextOperation || param1 is SplitParagraphOperation || param1 is DeleteTextOperation)
         {
            if(this.endGeneration != param1.beginGeneration)
            {
               return null;
            }
            _loc3_ = Boolean(this._operations) && Boolean(this._operations.length) ? FlowOperation(this._operations[this._operations.length - 1]) : null;
            if(_loc3_)
            {
               _loc2_ = _loc3_.tlf_internal::merge(param1);
            }
            if(Boolean(_loc2_) && !(_loc2_ is CompositeOperation))
            {
               this._operations[this._operations.length - 1] = _loc2_;
            }
            else
            {
               this._operations.push(param1);
            }
            return this;
         }
         return null;
      }
   }
}

