package flashx.textLayout.operations
{
   import flash.utils.getQualifiedClassName;
   import flashx.textLayout.edit.ParaEdit;
   import flashx.textLayout.edit.SelectionState;
   import flashx.textLayout.elements.FlowLeafElement;
   import flashx.textLayout.elements.ParagraphElement;
   import flashx.textLayout.elements.SpanElement;
   import flashx.textLayout.formats.ITextLayoutFormat;
   import flashx.textLayout.formats.TextLayoutFormat;
   import flashx.textLayout.tlf_internal;
   
   use namespace tlf_internal;
   
   public class SplitParagraphOperation extends FlowTextOperation
   {
      
      private var delSelOp:DeleteTextOperation;
      
      private var _characterFormat:ITextLayoutFormat;
      
      public function SplitParagraphOperation(param1:SelectionState)
      {
         super(param1);
         this.characterFormat = param1.pointFormat;
      }
      
      private function get characterFormat() : ITextLayoutFormat
      {
         return this._characterFormat;
      }
      
      private function set characterFormat(param1:ITextLayoutFormat) : void
      {
         this._characterFormat = param1 ? new TextLayoutFormat(param1) : null;
      }
      
      override public function doOperation() : Boolean
      {
         var _loc6_:TextLayoutFormat = null;
         var _loc7_:int = 0;
         var _loc8_:SpanElement = null;
         if(absoluteStart < absoluteEnd)
         {
            this.delSelOp = new DeleteTextOperation(originalSelectionState);
            this.delSelOp.doOperation();
         }
         var _loc1_:ParagraphElement = textFlow.tlf_internal::findAbsoluteParagraph(absoluteStart);
         var _loc2_:int = absoluteStart - _loc1_.getAbsoluteStart();
         var _loc3_:ParagraphElement = ParaEdit.splitParagraph(_loc1_,_loc2_,this._characterFormat);
         if(textFlow.interactionManager)
         {
            textFlow.interactionManager.notifyInsertOrDelete(absoluteStart,1);
         }
         var _loc4_:FlowLeafElement = _loc1_.getLastLeaf();
         if(_loc4_ != null && _loc4_.textLength == 1)
         {
            _loc7_ = _loc4_.parent.getChildIndex(_loc4_);
            if(_loc7_ > 0)
            {
               _loc8_ = _loc4_.parent.getChildAt(_loc7_ - 1) as SpanElement;
               if(_loc8_ != null)
               {
                  _loc4_ = _loc8_;
               }
            }
         }
         var _loc5_:FlowLeafElement = _loc3_.getFirstLeaf();
         if(getQualifiedClassName(_loc4_.parent) != getQualifiedClassName(_loc5_.parent))
         {
            _loc6_ = new TextLayoutFormat();
         }
         else
         {
            _loc6_ = new TextLayoutFormat(this._characterFormat);
            if(_loc3_.textLength == 1)
            {
               if(_loc4_.format != null)
               {
                  _loc6_.concat(_loc4_.format);
               }
            }
            else
            {
               _loc6_.concat(_loc4_.computedFormat);
               _loc6_.removeMatching(_loc5_.computedFormat);
            }
         }
         return true;
      }
      
      override public function undo() : SelectionState
      {
         var _loc1_:ParagraphElement = textFlow.tlf_internal::findAbsoluteParagraph(absoluteStart);
         ParaEdit.mergeParagraphWithNext(_loc1_);
         if(textFlow.interactionManager)
         {
            textFlow.interactionManager.notifyInsertOrDelete(absoluteStart,-1);
         }
         return absoluteStart < absoluteEnd ? this.delSelOp.undo() : originalSelectionState;
      }
      
      override tlf_internal function merge(param1:FlowOperation) : FlowOperation
      {
         if(this.endGeneration != param1.beginGeneration)
         {
            return null;
         }
         if(param1 is SplitParagraphOperation || param1 is InsertTextOperation)
         {
            return new CompositeOperation([this,param1]);
         }
         return null;
      }
   }
}

