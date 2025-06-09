package flashx.textLayout.operations
{
   import flashx.textLayout.edit.SelectionState;
   import flashx.textLayout.elements.FlowElement;
   import flashx.textLayout.formats.ITextLayoutFormat;
   import flashx.textLayout.formats.TextLayoutFormat;
   import flashx.textLayout.tlf_internal;
   
   use namespace tlf_internal;
   
   public class ApplyFormatToElementOperation extends FlowElementOperation
   {
      
      private var _format:ITextLayoutFormat;
      
      private var undoCoreStyles:Object;
      
      public function ApplyFormatToElementOperation(param1:SelectionState, param2:FlowElement, param3:ITextLayoutFormat, param4:int = 0, param5:int = -1)
      {
         super(param1,param2,param4,param5);
         this._format = param3;
      }
      
      public function get format() : ITextLayoutFormat
      {
         return this._format;
      }
      
      public function set format(param1:ITextLayoutFormat) : void
      {
         this._format = param1;
      }
      
      override public function doOperation() : Boolean
      {
         var _loc2_:TextLayoutFormat = null;
         var _loc1_:FlowElement = getTargetElement();
         adjustForDoOperation(_loc1_);
         this.undoCoreStyles = _loc1_.coreStyles;
         if(this._format)
         {
            _loc2_ = new TextLayoutFormat(_loc1_.format);
            _loc2_.apply(this._format);
            _loc1_.format = _loc2_;
         }
         return true;
      }
      
      override public function undo() : SelectionState
      {
         var _loc1_:FlowElement = getTargetElement();
         _loc1_.tlf_internal::setCoreStylesInternal(this.undoCoreStyles);
         adjustForUndoOperation(_loc1_);
         return originalSelectionState;
      }
   }
}

