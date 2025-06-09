package flashx.textLayout.operations
{
   import flashx.textLayout.edit.ElementRange;
   import flashx.textLayout.edit.ParaEdit;
   import flashx.textLayout.edit.SelectionState;
   import flashx.textLayout.elements.FlowLeafElement;
   import flashx.textLayout.elements.InlineGraphicElement;
   import flashx.textLayout.elements.ParagraphElement;
   import flashx.textLayout.elements.SpanElement;
   import flashx.textLayout.elements.TCYElement;
   import flashx.textLayout.formats.ITextLayoutFormat;
   import flashx.textLayout.formats.TextLayoutFormat;
   import flashx.textLayout.tlf_internal;
   
   use namespace tlf_internal;
   
   public class InsertTextOperation extends FlowTextOperation
   {
      
      private var _deleteSelectionState:SelectionState;
      
      private var delSelOp:DeleteTextOperation = null;
      
      public var _text:String;
      
      private var adjustedForInsert:Boolean = false;
      
      private var _characterFormat:ITextLayoutFormat;
      
      public function InsertTextOperation(param1:SelectionState, param2:String, param3:SelectionState = null)
      {
         super(param1);
         this._characterFormat = param1.pointFormat;
         this._text = param2;
         this.initialize(param3);
      }
      
      private function initialize(param1:SelectionState) : void
      {
         if(param1 == null)
         {
            param1 = originalSelectionState;
         }
         if(param1.anchorPosition != param1.activePosition)
         {
            this._deleteSelectionState = param1;
            this.delSelOp = new DeleteTextOperation(this._deleteSelectionState);
         }
      }
      
      public function get text() : String
      {
         return this._text;
      }
      
      public function set text(param1:String) : void
      {
         this._text = param1;
      }
      
      public function get deleteSelectionState() : SelectionState
      {
         return this._deleteSelectionState;
      }
      
      public function set deleteSelectionState(param1:SelectionState) : void
      {
         this._deleteSelectionState = param1;
      }
      
      public function get characterFormat() : ITextLayoutFormat
      {
         return this._characterFormat;
      }
      
      public function set characterFormat(param1:ITextLayoutFormat) : void
      {
         this._characterFormat = new TextLayoutFormat(param1);
      }
      
      private function doInternal() : void
      {
         var _loc3_:ElementRange = null;
         var _loc6_:ITextLayoutFormat = null;
         var _loc7_:int = 0;
         var _loc1_:FlowLeafElement = textFlow.findLeaf(absoluteStart);
         var _loc2_:TCYElement = null;
         if(_loc1_ is InlineGraphicElement && _loc1_.parent is TCYElement)
         {
            _loc2_ = _loc1_.parent as TCYElement;
         }
         if(this.delSelOp != null)
         {
            _loc6_ = new TextLayoutFormat(textFlow.findLeaf(absoluteStart).format);
            if(this.delSelOp.doOperation())
            {
               if(this.characterFormat == null && absoluteStart < absoluteEnd)
               {
                  this._characterFormat = _loc6_;
               }
               else if(_loc1_.textLength == 0)
               {
                  _loc7_ = _loc1_.parent.getChildIndex(_loc1_);
                  _loc1_.parent.replaceChildren(_loc7_,_loc7_ + 1,null);
               }
               if(Boolean(_loc2_) && _loc2_.numChildren == 0)
               {
                  _loc1_ = new SpanElement();
                  _loc2_.replaceChildren(0,0,_loc1_);
               }
            }
         }
         var _loc4_:Boolean = false;
         if(absoluteStart >= absoluteEnd || _loc1_.getParagraph() == null || _loc1_.getTextFlow() == null)
         {
            _loc3_ = ElementRange.createElementRange(textFlow,absoluteStart,absoluteStart);
         }
         else
         {
            _loc3_ = new ElementRange();
            _loc3_.firstParagraph = _loc1_.getParagraph();
            _loc3_.firstLeaf = _loc1_;
            _loc4_ = true;
         }
         var _loc5_:int = absoluteStart - _loc3_.firstParagraph.getAbsoluteStart();
         ParaEdit.insertText(_loc3_.firstParagraph,_loc3_.firstLeaf,_loc5_,this._text,_loc4_);
         if(textFlow.interactionManager)
         {
            textFlow.interactionManager.notifyInsertOrDelete(absoluteStart,this._text.length);
         }
         if(Boolean(this._characterFormat) && !TextLayoutFormat.isEqual(this._characterFormat,_loc3_.firstLeaf.format))
         {
            ParaEdit.applyTextStyleChange(textFlow,absoluteStart,absoluteStart + this._text.length,this._characterFormat,null);
         }
      }
      
      override public function doOperation() : Boolean
      {
         var _loc1_:SelectionState = null;
         this.doInternal();
         if(originalSelectionState.tlf_internal::selectionManagerOperationState && Boolean(textFlow.interactionManager))
         {
            _loc1_ = textFlow.interactionManager.getSelectionState();
            if(_loc1_.pointFormat)
            {
               _loc1_.pointFormat = null;
               textFlow.interactionManager.setSelectionState(_loc1_);
            }
         }
         return true;
      }
      
      override public function undo() : SelectionState
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc1_:ParagraphElement = textFlow.tlf_internal::findAbsoluteParagraph(absoluteStart);
         var _loc2_:int = absoluteStart - _loc1_.getAbsoluteStart();
         ParaEdit.deleteText(_loc1_,_loc2_,this._text.length);
         if(textFlow.interactionManager)
         {
            textFlow.interactionManager.notifyInsertOrDelete(absoluteStart,-this._text.length);
         }
         var _loc3_:SelectionState = originalSelectionState;
         if(this.delSelOp != null)
         {
            _loc3_ = this.delSelOp.undo();
         }
         if(this.adjustedForInsert)
         {
            _loc4_ = _loc3_.anchorPosition;
            _loc5_ = _loc3_.activePosition;
            if(_loc5_ > _loc4_)
            {
               _loc5_--;
            }
            else
            {
               _loc4_--;
            }
            if(absoluteStart < absoluteEnd)
            {
               return new SelectionState(textFlow,_loc4_,_loc5_,_loc3_.pointFormat);
            }
            return new SelectionState(textFlow,_loc4_,_loc5_,originalSelectionState.pointFormat);
         }
         return originalSelectionState;
      }
      
      override public function redo() : SelectionState
      {
         this.doInternal();
         return new SelectionState(textFlow,absoluteStart + this._text.length,absoluteStart + this._text.length,null);
      }
      
      override tlf_internal function merge(param1:FlowOperation) : FlowOperation
      {
         if(absoluteStart < absoluteEnd)
         {
            return null;
         }
         if(this.endGeneration != param1.beginGeneration)
         {
            return null;
         }
         var _loc2_:InsertTextOperation = null;
         if(param1 is InsertTextOperation)
         {
            _loc2_ = param1 as InsertTextOperation;
         }
         if(_loc2_)
         {
            if(_loc2_.deleteSelectionState != null || this.deleteSelectionState != null)
            {
               return null;
            }
            if(_loc2_.originalSelectionState.pointFormat == null && originalSelectionState.pointFormat != null)
            {
               return null;
            }
            if(originalSelectionState.pointFormat == null && _loc2_.originalSelectionState.pointFormat != null)
            {
               return null;
            }
            if(originalSelectionState.absoluteStart + this._text.length != _loc2_.originalSelectionState.absoluteStart)
            {
               return null;
            }
            if(originalSelectionState.pointFormat == null && _loc2_.originalSelectionState.pointFormat == null || TextLayoutFormat.isEqual(originalSelectionState.pointFormat,_loc2_.originalSelectionState.pointFormat))
            {
               this._text += _loc2_.text;
               tlf_internal::setGenerations(beginGeneration,_loc2_.endGeneration);
               return this;
            }
            return null;
         }
         if(param1 is SplitParagraphOperation)
         {
            return new CompositeOperation([this,param1]);
         }
         return null;
      }
   }
}

