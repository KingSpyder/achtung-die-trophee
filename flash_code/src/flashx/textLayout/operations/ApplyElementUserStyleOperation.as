package flashx.textLayout.operations
{
   import flashx.textLayout.edit.SelectionState;
   import flashx.textLayout.elements.FlowElement;
   
   public class ApplyElementUserStyleOperation extends FlowElementOperation
   {
      
      private var _styleName:String;
      
      private var _origValue:*;
      
      private var _newValue:*;
      
      public function ApplyElementUserStyleOperation(param1:SelectionState, param2:FlowElement, param3:String, param4:*, param5:int = 0, param6:int = -1)
      {
         this._styleName = param3;
         this._newValue = param4;
         super(param1,param2,param5,param6);
      }
      
      public function get styleName() : String
      {
         return this._styleName;
      }
      
      public function set styleName(param1:String) : void
      {
         this._styleName = param1;
      }
      
      public function get newValue() : *
      {
         return this._newValue;
      }
      
      public function set newValue(param1:*) : void
      {
         this._newValue = param1;
      }
      
      override public function doOperation() : Boolean
      {
         var _loc1_:FlowElement = getTargetElement();
         this._origValue = _loc1_.getStyle(this._styleName);
         adjustForDoOperation(_loc1_);
         _loc1_.setStyle(this._styleName,this._newValue);
         return true;
      }
      
      override public function undo() : SelectionState
      {
         var _loc1_:FlowElement = getTargetElement();
         _loc1_.setStyle(this._styleName,this._origValue);
         adjustForUndoOperation(_loc1_);
         return originalSelectionState;
      }
   }
}

