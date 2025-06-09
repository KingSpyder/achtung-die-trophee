package flashx.textLayout.operations
{
   import flashx.textLayout.edit.SelectionState;
   import flashx.textLayout.edit.TextFlowEdit;
   import flashx.textLayout.edit.TextScrap;
   import flashx.textLayout.elements.FlowLeafElement;
   import flashx.textLayout.elements.ParagraphElement;
   import flashx.textLayout.formats.TextLayoutFormatValueHolder;
   import flashx.textLayout.tlf_internal;
   
   use namespace tlf_internal;
   
   public class DeleteTextOperation extends FlowTextOperation
   {
      
      private var _textScrap:TextScrap;
      
      private var _allowMerge:Boolean;
      
      private var _undoParaFormat:TextLayoutFormatValueHolder;
      
      private var _undoCharacterFormat:TextLayoutFormatValueHolder;
      
      private var _needsOldFormat:Boolean = false;
      
      private var _pendingFormat:TextLayoutFormatValueHolder;
      
      private var _deleteSelectionState:SelectionState = null;
      
      public function DeleteTextOperation(param1:SelectionState, param2:SelectionState = null, param3:Boolean = false)
      {
         this._deleteSelectionState = param2 ? param2 : param1;
         super(this._deleteSelectionState);
         originalSelectionState = param1;
         this._allowMerge = param3;
      }
      
      public function get allowMerge() : Boolean
      {
         return this._allowMerge;
      }
      
      public function set allowMerge(param1:Boolean) : void
      {
         this._allowMerge = param1;
      }
      
      public function get deleteSelectionState() : SelectionState
      {
         return this._deleteSelectionState;
      }
      
      public function set deleteSelectionState(param1:SelectionState) : void
      {
         this._deleteSelectionState = param1;
      }
      
      override public function doOperation() : Boolean
      {
         var _loc5_:SelectionState = null;
         if(absoluteStart == absoluteEnd)
         {
            return false;
         }
         this._textScrap = TextFlowEdit.createTextScrap(textFlow,absoluteStart,absoluteEnd);
         var _loc1_:FlowLeafElement = textFlow.findLeaf(absoluteStart);
         var _loc2_:ParagraphElement = _loc1_.getParagraph();
         var _loc3_:int = _loc2_.getAbsoluteStart();
         this._pendingFormat = new TextLayoutFormatValueHolder(_loc1_.format);
         if(this._textScrap)
         {
            if(this._textScrap.tlf_internal::textFlow.textLength == 1 && (absoluteEnd == textFlow.textLength - 1 || absoluteEnd == _loc3_ + _loc2_.textLength))
            {
               this._textScrap.tlf_internal::beginMissingArray = new Array();
               this._textScrap.tlf_internal::endMissingArray = new Array();
            }
            if(this._textScrap.tlf_internal::textFlow.textLength >= 1)
            {
               _loc1_ = textFlow.findLeaf(absoluteEnd);
               _loc2_ = _loc1_.getParagraph();
               if(absoluteEnd == _loc2_.getAbsoluteStart())
               {
                  this._undoParaFormat = new TextLayoutFormatValueHolder(_loc2_.format);
                  this._undoCharacterFormat = new TextLayoutFormatValueHolder(_loc1_.format);
                  this._needsOldFormat = true;
               }
            }
         }
         var _loc4_:int = textFlow.textLength;
         TextFlowEdit.replaceRange(textFlow,absoluteStart,absoluteEnd,null);
         if(textFlow.interactionManager)
         {
            textFlow.interactionManager.notifyInsertOrDelete(absoluteStart,-(absoluteEnd - absoluteStart));
         }
         if(originalSelectionState.tlf_internal::selectionManagerOperationState && Boolean(textFlow.interactionManager))
         {
            _loc5_ = textFlow.interactionManager.getSelectionState();
            if(_loc5_.anchorPosition == _loc5_.activePosition)
            {
               _loc5_.pointFormat = new TextLayoutFormatValueHolder(this._pendingFormat);
               textFlow.interactionManager.setSelectionState(_loc5_);
            }
         }
         if(_loc4_ == textFlow.textLength)
         {
            this._textScrap = null;
         }
         return true;
      }
      
      override public function undo() : SelectionState
      {
         var _loc1_:FlowLeafElement = null;
         var _loc2_:ParagraphElement = null;
         if(this._textScrap != null)
         {
            TextFlowEdit.replaceRange(textFlow,absoluteStart,absoluteStart,this._textScrap);
            if(this._needsOldFormat)
            {
               textFlow.tlf_internal::normalize();
               _loc1_ = textFlow.findLeaf(absoluteEnd);
               if(_loc1_)
               {
                  _loc2_ = _loc1_.getParagraph();
                  _loc2_.format = this._undoParaFormat;
                  _loc1_.format = this._undoCharacterFormat;
               }
            }
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
         return new SelectionState(textFlow,absoluteStart,absoluteStart,this._pendingFormat);
      }
      
      override tlf_internal function merge(param1:FlowOperation) : FlowOperation
      {
         if(this.endGeneration != param1.beginGeneration)
         {
            return null;
         }
         var _loc2_:DeleteTextOperation = param1 as DeleteTextOperation;
         if(_loc2_ == null || !_loc2_.allowMerge || !this._allowMerge)
         {
            return null;
         }
         return new CompositeOperation([this,param1]);
      }
   }
}

