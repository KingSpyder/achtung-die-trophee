package flashx.textLayout.operations
{
   import flashx.textLayout.edit.SelectionState;
   import flashx.textLayout.elements.FlowElement;
   
   public class ApplyElementStyleNameOperation extends FlowElementOperation
   {
      
      private var _origStyleName:String;
      
      private var _newStyleName:String;
      
      public function ApplyElementStyleNameOperation(param1:SelectionState, param2:FlowElement, param3:String, param4:int = 0, param5:int = -1)
      {
         this._newStyleName = param3;
         super(param1,param2,param4,param5);
      }
      
      public function get newStyleName() : String
      {
         return this._newStyleName;
      }
      
      public function set newStyleName(param1:String) : void
      {
         this._newStyleName = param1;
      }
      
      override public function doOperation() : Boolean
      {
         var _loc1_:FlowElement = getTargetElement();
         this._origStyleName = _loc1_.styleName;
         adjustForDoOperation(_loc1_);
         _loc1_.styleName = this._newStyleName;
         return true;
      }
      
      override public function undo() : SelectionState
      {
         var _loc1_:FlowElement = getTargetElement();
         _loc1_.styleName = this._origStyleName;
         adjustForUndoOperation(_loc1_);
         return originalSelectionState;
      }
   }
}

