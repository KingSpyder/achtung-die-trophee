package flashx.textLayout.edit
{
   import flash.display.DisplayObjectContainer;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.IMEEvent;
   import flash.events.KeyboardEvent;
   import flash.events.TextEvent;
   import flash.system.Capabilities;
   import flash.ui.Keyboard;
   import flash.utils.getQualifiedClassName;
   import flashx.textLayout.compose.IFlowComposer;
   import flashx.textLayout.container.ContainerController;
   import flashx.textLayout.elements.Configuration;
   import flashx.textLayout.elements.FlowElement;
   import flashx.textLayout.elements.FlowLeafElement;
   import flashx.textLayout.elements.GlobalSettings;
   import flashx.textLayout.elements.ParagraphElement;
   import flashx.textLayout.events.FlowOperationEvent;
   import flashx.textLayout.formats.ITextLayoutFormat;
   import flashx.textLayout.formats.TextLayoutFormat;
   import flashx.textLayout.operations.ApplyElementIDOperation;
   import flashx.textLayout.operations.ApplyElementStyleNameOperation;
   import flashx.textLayout.operations.ApplyFormatOperation;
   import flashx.textLayout.operations.ApplyFormatToElementOperation;
   import flashx.textLayout.operations.ApplyLinkOperation;
   import flashx.textLayout.operations.ApplyTCYOperation;
   import flashx.textLayout.operations.ClearFormatOnElementOperation;
   import flashx.textLayout.operations.ClearFormatOperation;
   import flashx.textLayout.operations.CompositeOperation;
   import flashx.textLayout.operations.CutOperation;
   import flashx.textLayout.operations.DeleteTextOperation;
   import flashx.textLayout.operations.FlowOperation;
   import flashx.textLayout.operations.InsertInlineGraphicOperation;
   import flashx.textLayout.operations.InsertTextOperation;
   import flashx.textLayout.operations.ModifyInlineGraphicOperation;
   import flashx.textLayout.operations.PasteOperation;
   import flashx.textLayout.operations.RedoOperation;
   import flashx.textLayout.operations.SplitParagraphOperation;
   import flashx.textLayout.operations.UndoOperation;
   import flashx.textLayout.tlf_internal;
   import flashx.textLayout.utils.CharacterUtil;
   import flashx.textLayout.utils.NavigationUtil;
   import flashx.undo.IOperation;
   import flashx.undo.IUndoManager;
   
   use namespace tlf_internal;
   
   public class EditManager extends SelectionManager implements IEditManager
   {
      
      public static var overwriteMode:Boolean = false;
      
      private var pendingInsert:InsertTextOperation;
      
      private var enterFrameListener:DisplayObjectContainer;
      
      private var _undoManager:IUndoManager;
      
      private var _imeSession:IMEClient;
      
      private var _imeOperationInProgress:Boolean;
      
      tlf_internal var captureLevel:int = 0;
      
      private var captureOperations:Array = [];
      
      private var parentStack:Array;
      
      public function EditManager(param1:IUndoManager = null)
      {
         super();
         this._undoManager = param1;
      }
      
      public function get undoManager() : IUndoManager
      {
         return this._undoManager;
      }
      
      tlf_internal function setUndoManager(param1:IUndoManager) : void
      {
         this._undoManager = param1;
      }
      
      override public function editHandler(param1:Event) : void
      {
         super.editHandler(param1);
         switch(param1.type)
         {
            case Event.CUT:
               if(activePosition != anchorPosition)
               {
                  TextClipboard.setContents(this.cutTextScrap());
               }
               break;
            case Event.CLEAR:
               if(activePosition != anchorPosition)
               {
                  this.deleteText(null);
               }
               break;
            case Event.PASTE:
               this.pasteTextScrap(TextClipboard.getContents());
         }
      }
      
      override public function keyDownHandler(param1:KeyboardEvent) : void
      {
         var _loc2_:String = null;
         if(!hasSelection() || param1.isDefaultPrevented())
         {
            return;
         }
         super.keyDownHandler(param1);
         if(param1.ctrlKey)
         {
            if(!param1.altKey)
            {
               switch(param1.charCode)
               {
                  case 122:
                     if(!Configuration.tlf_internal::versionIsAtLeast(10,1) && Capabilities.os.search("Mac OS") > -1)
                     {
                        ignoreNextTextEvent = true;
                     }
                     this.undo();
                     param1.preventDefault();
                     break;
                  case 121:
                     ignoreNextTextEvent = true;
                     this.redo();
                     param1.preventDefault();
                     break;
                  case Keyboard.BACKSPACE:
                     if(this._imeSession)
                     {
                        this._imeSession.compositionAbandoned();
                     }
                     this.deletePreviousWord();
                     param1.preventDefault();
               }
               if(param1.keyCode == Keyboard.DELETE)
               {
                  if(this._imeSession)
                  {
                     this._imeSession.compositionAbandoned();
                  }
                  this.deleteNextWord();
                  param1.preventDefault();
               }
               if(param1.shiftKey)
               {
                  if(param1.charCode == 95)
                  {
                     if(this._imeSession)
                     {
                        this._imeSession.compositionAbandoned();
                     }
                     _loc2_ = String.fromCharCode(173);
                     if(overwriteMode)
                     {
                        this.overwriteText(_loc2_);
                     }
                     else
                     {
                        this.insertText(_loc2_);
                     }
                     param1.preventDefault();
                  }
               }
            }
         }
         else if(param1.altKey)
         {
            if(param1.charCode == Keyboard.BACKSPACE)
            {
               this.deletePreviousWord();
               param1.preventDefault();
            }
            else if(param1.keyCode == Keyboard.DELETE)
            {
               this.deleteNextWord();
               param1.preventDefault();
            }
         }
         else if(param1.keyCode == Keyboard.DELETE)
         {
            this.deleteNextCharacter();
            param1.preventDefault();
         }
         else if(param1.keyCode == Keyboard.INSERT)
         {
            overwriteMode = !overwriteMode;
            param1.preventDefault();
         }
         else
         {
            switch(param1.charCode)
            {
               case Keyboard.BACKSPACE:
                  this.deletePreviousCharacter();
                  param1.preventDefault();
                  break;
               case Keyboard.ENTER:
                  if(textFlow.configuration.manageEnterKey)
                  {
                     this.splitParagraph();
                     param1.preventDefault();
                     param1.stopImmediatePropagation();
                  }
                  break;
               case Keyboard.TAB:
                  if(textFlow.configuration.manageTabKey)
                  {
                     if(overwriteMode)
                     {
                        this.overwriteText(String.fromCharCode(param1.charCode));
                     }
                     else
                     {
                        this.insertText(String.fromCharCode(param1.charCode));
                     }
                     param1.preventDefault();
                  }
            }
         }
      }
      
      override public function keyUpHandler(param1:KeyboardEvent) : void
      {
         if(!hasSelection() || param1.isDefaultPrevented())
         {
            return;
         }
         super.keyUpHandler(param1);
         if(textFlow.configuration.manageEnterKey && param1.charCode == Keyboard.ENTER || textFlow.configuration.manageTabKey && param1.charCode == Keyboard.TAB)
         {
            param1.stopImmediatePropagation();
         }
      }
      
      override public function keyFocusChangeHandler(param1:FocusEvent) : void
      {
         if(textFlow.configuration.manageTabKey)
         {
            param1.preventDefault();
         }
      }
      
      override public function textInputHandler(param1:TextEvent) : void
      {
         var _loc2_:int = 0;
         if(!ignoreNextTextEvent)
         {
            _loc2_ = int(param1.text.charCodeAt(0));
            if(_loc2_ >= 32)
            {
               if(overwriteMode)
               {
                  this.overwriteText(param1.text);
               }
               else
               {
                  this.insertText(param1.text);
               }
            }
         }
         ignoreNextTextEvent = false;
      }
      
      override public function focusOutHandler(param1:FocusEvent) : void
      {
         super.focusOutHandler(param1);
         if(Boolean(this._imeSession) && tlf_internal::selectionFormatState != SelectionFormatState.FOCUSED)
         {
            this._imeSession.compositionAbandoned();
         }
      }
      
      override public function deactivateHandler(param1:Event) : void
      {
         super.deactivateHandler(param1);
         if(this._imeSession)
         {
            this._imeSession.compositionAbandoned();
         }
      }
      
      override public function imeStartCompositionHandler(param1:IMEEvent) : void
      {
         this.flushPendingOperations();
         if(!param1["imeClient"])
         {
            this._imeSession = new IMEClient(this);
            this._imeOperationInProgress = false;
            param1["imeClient"] = this._imeSession;
         }
      }
      
      override public function setFocus() : void
      {
         var _loc1_:IFlowComposer = textFlow ? textFlow.flowComposer : null;
         if(this._imeSession && _loc1_ && _loc1_.numControllers > 1)
         {
            this._imeSession.setFocus();
            tlf_internal::setSelectionFormatState(SelectionFormatState.FOCUSED);
         }
         else
         {
            super.setFocus();
         }
      }
      
      tlf_internal function endIMESession() : void
      {
         this._imeSession = null;
         var _loc1_:IFlowComposer = textFlow ? textFlow.flowComposer : null;
         if(Boolean(_loc1_) && _loc1_.numControllers > 1)
         {
            this.setFocus();
         }
      }
      
      tlf_internal function beginIMEOperation() : void
      {
         this._imeOperationInProgress = true;
         this.beginCompositeOperation();
      }
      
      tlf_internal function endIMEOperation() : void
      {
         this.endCompositeOperation();
         this._imeOperationInProgress = false;
      }
      
      override public function doOperation(param1:FlowOperation) : void
      {
         var operation:FlowOperation = param1;
         if(Boolean(this._imeSession) && !this._imeOperationInProgress)
         {
            this._imeSession.compositionAbandoned();
         }
         this.flushPendingOperations();
         try
         {
            ++this.tlf_internal::captureLevel;
            operation = this.doInternal(operation);
         }
         catch(e:Error)
         {
            --tlf_internal::captureLevel;
            throw e;
         }
         --this.tlf_internal::captureLevel;
         if(operation)
         {
            this.finalizeDo(operation);
         }
      }
      
      private function finalizeDo(param1:FlowOperation) : void
      {
         var _loc2_:CompositeOperation = null;
         var _loc3_:Object = null;
         var _loc4_:FlowOperation = null;
         var _loc5_:FlowOperation = null;
         var _loc6_:int = 0;
         var _loc7_:FlowOperationEvent = null;
         if(Boolean(this.parentStack) && this.parentStack.length > 0)
         {
            _loc3_ = this.parentStack[this.parentStack.length - 1];
            if(_loc3_.captureLevel == this.tlf_internal::captureLevel)
            {
               _loc2_ = _loc3_.operation as CompositeOperation;
            }
         }
         if(_loc2_)
         {
            _loc2_.addOperation(param1);
         }
         else if(this.tlf_internal::captureLevel == 0)
         {
            this.captureOperations.length = 0;
            if(this._undoManager)
            {
               if(this._undoManager.canUndo() && allowOperationMerge)
               {
                  _loc4_ = this._undoManager.peekUndo() as FlowOperation;
                  if(_loc4_)
                  {
                     _loc5_ = _loc4_.tlf_internal::merge(param1);
                     if(_loc5_)
                     {
                        _loc5_.tlf_internal::setGenerations(_loc4_.beginGeneration,textFlow.generation);
                        this._undoManager.popUndo();
                        param1 = _loc5_;
                     }
                  }
               }
               if(param1.canUndo())
               {
                  this._undoManager.pushUndo(param1);
               }
               allowOperationMerge = true;
               this._undoManager.clearRedo();
            }
            this.updateAllControllers();
            if(hasSelection())
            {
               _loc6_ = textFlow.flowComposer.findControllerIndexAtPosition(activePosition);
               if(_loc6_ >= 0)
               {
                  textFlow.flowComposer.getControllerAt(_loc6_).scrollToRange(activePosition,anchorPosition);
               }
            }
            if(!this._imeSession)
            {
               _loc7_ = new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_COMPLETE,false,false,param1,0,null);
               textFlow.dispatchEvent(_loc7_);
            }
         }
      }
      
      private function doInternal(param1:FlowOperation) : FlowOperation
      {
         var opError:Error;
         var opEvent:FlowOperationEvent = null;
         var beforeGeneration:uint = 0;
         var index:int = 0;
         var op:FlowOperation = param1;
         var captureStart:int = int(this.captureOperations.length);
         var success:Boolean = false;
         if(!this._imeSession)
         {
            opEvent = new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_BEGIN,false,true,op,this.tlf_internal::captureLevel - 1,null);
            textFlow.dispatchEvent(opEvent);
            if(opEvent.isDefaultPrevented())
            {
               return null;
            }
            op = opEvent.operation;
            if(op is UndoOperation || op is RedoOperation)
            {
               throw new IllegalOperationError(GlobalSettings.resourceStringFunction("illegalOperation",[getQualifiedClassName(op)]));
            }
         }
         opError = null;
         try
         {
            beforeGeneration = textFlow.generation;
            op.tlf_internal::setGenerations(beforeGeneration,0);
            this.captureOperations.push(op);
            success = op.doOperation();
            if(success)
            {
               textFlow.tlf_internal::normalize();
               op.tlf_internal::setGenerations(beforeGeneration,textFlow.generation);
            }
            else
            {
               index = int(this.captureOperations.indexOf(op));
               if(index >= 0)
               {
                  this.captureOperations.splice(index,1);
               }
            }
         }
         catch(e:Error)
         {
            opError = e;
         }
         if(!this._imeSession)
         {
            opEvent = new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_END,false,true,op,this.tlf_internal::captureLevel - 1,opError);
            textFlow.dispatchEvent(opEvent);
            opError = opEvent.isDefaultPrevented() ? null : opEvent.error;
         }
         if(opError)
         {
            throw opError;
         }
         if(this.captureOperations.length - captureStart > 1)
         {
            op = new CompositeOperation(this.captureOperations.slice(captureStart));
            op.tlf_internal::setGenerations(FlowOperation(CompositeOperation(op).operations[0]).beginGeneration,textFlow.generation);
            allowOperationMerge = false;
            this.captureOperations.length = captureStart;
         }
         return success ? op : null;
      }
      
      protected function updateAllControllers() : void
      {
         if(textFlow.flowComposer)
         {
            textFlow.flowComposer.updateAllControllers();
         }
         this.tlf_internal::selectionChanged(true,false);
      }
      
      override public function flushPendingOperations() : void
      {
         var _loc1_:InsertTextOperation = null;
         super.flushPendingOperations();
         if(this.pendingInsert)
         {
            _loc1_ = this.pendingInsert;
            this.pendingInsert = null;
            if(this.enterFrameListener)
            {
               this.enterFrameListener.removeEventListener(Event.ENTER_FRAME,enterFrameHandler);
               this.enterFrameListener = null;
            }
            this.doOperation(_loc1_);
         }
      }
      
      public function undo() : void
      {
         if(this._imeSession)
         {
            this._imeSession.compositionAbandoned();
         }
         if(this.undoManager)
         {
            this.undoManager.undo();
         }
      }
      
      public function performUndo(param1:IOperation) : void
      {
         var opError:Error;
         var undoPsuedoOp:UndoOperation = null;
         var opEvent:FlowOperationEvent = null;
         var rslt:SelectionState = null;
         var controllerIndex:int = 0;
         var theop:IOperation = param1;
         var operation:FlowOperation = theop as FlowOperation;
         if(!operation || operation.textFlow != textFlow)
         {
            return;
         }
         if(!this._imeSession)
         {
            undoPsuedoOp = new UndoOperation(operation);
            opEvent = new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_BEGIN,false,true,undoPsuedoOp,0,null);
            textFlow.dispatchEvent(opEvent);
            if(opEvent.isDefaultPrevented())
            {
               this.undoManager.pushUndo(operation);
               return;
            }
            undoPsuedoOp = opEvent.operation as UndoOperation;
            if(!undoPsuedoOp)
            {
               throw new IllegalOperationError(GlobalSettings.resourceStringFunction("illegalOperation",[getQualifiedClassName(opEvent.operation)]));
            }
            operation = undoPsuedoOp.operation;
         }
         if(operation.endGeneration != textFlow.generation)
         {
            return;
         }
         opError = null;
         try
         {
            rslt = operation.undo();
            setSelectionState(rslt);
            if(this._undoManager)
            {
               this._undoManager.pushRedo(operation);
            }
         }
         catch(e:Error)
         {
            opError = e;
         }
         if(!this._imeSession)
         {
            opEvent = new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_END,false,true,undoPsuedoOp,0,opError);
            textFlow.dispatchEvent(opEvent);
            opError = opEvent.isDefaultPrevented() ? null : opEvent.error;
         }
         if(opError)
         {
            throw opError;
         }
         this.updateAllControllers();
         textFlow.tlf_internal::setGeneration(operation.beginGeneration);
         if(hasSelection())
         {
            controllerIndex = textFlow.flowComposer.findControllerIndexAtPosition(activePosition);
            if(controllerIndex >= 0)
            {
               textFlow.flowComposer.getControllerAt(controllerIndex).scrollToRange(activePosition,anchorPosition);
            }
         }
         opEvent = new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_COMPLETE,false,false,undoPsuedoOp,0,null);
         textFlow.dispatchEvent(opEvent);
      }
      
      public function redo() : void
      {
         if(this._imeSession)
         {
            this._imeSession.compositionAbandoned();
         }
         if(this.undoManager)
         {
            this.undoManager.redo();
         }
      }
      
      public function performRedo(param1:IOperation) : void
      {
         var opError:Error;
         var opEvent:FlowOperationEvent = null;
         var redoPsuedoOp:RedoOperation = null;
         var rslt:SelectionState = null;
         var controllerIndex:int = 0;
         var theop:IOperation = param1;
         var op:FlowOperation = theop as FlowOperation;
         if(!op || op.textFlow != textFlow)
         {
            return;
         }
         if(!this._imeSession)
         {
            redoPsuedoOp = new RedoOperation(op);
            opEvent = new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_BEGIN,false,true,redoPsuedoOp,0,null);
            textFlow.dispatchEvent(opEvent);
            if(opEvent.isDefaultPrevented() && Boolean(this._undoManager))
            {
               this._undoManager.pushRedo(op);
               return;
            }
            redoPsuedoOp = opEvent.operation as RedoOperation;
            if(!redoPsuedoOp)
            {
               throw new IllegalOperationError(GlobalSettings.resourceStringFunction("illegalOperation",[getQualifiedClassName(opEvent.operation)]));
            }
            op = redoPsuedoOp.operation;
         }
         if(op.beginGeneration != textFlow.generation)
         {
            return;
         }
         opError = null;
         try
         {
            rslt = op.redo();
            setSelectionState(rslt);
            if(this._undoManager)
            {
               this._undoManager.pushUndo(op);
            }
         }
         catch(e:Error)
         {
            opError = e;
         }
         if(!this._imeSession)
         {
            opEvent = new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_END,false,true,redoPsuedoOp,0,opError);
            textFlow.dispatchEvent(opEvent);
            opError = opEvent.isDefaultPrevented() ? null : opEvent.error;
         }
         if(opError)
         {
            throw opError;
         }
         this.updateAllControllers();
         textFlow.tlf_internal::setGeneration(op.endGeneration);
         if(hasSelection())
         {
            controllerIndex = textFlow.flowComposer.findControllerIndexAtPosition(activePosition);
            if(controllerIndex >= 0)
            {
               textFlow.flowComposer.getControllerAt(controllerIndex).scrollToRange(activePosition,anchorPosition);
            }
         }
         opEvent = new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_COMPLETE,false,false,op,0,null);
         textFlow.dispatchEvent(opEvent);
      }
      
      override public function get editingMode() : String
      {
         return EditingMode.READ_WRITE;
      }
      
      tlf_internal function defaultOperationState(param1:SelectionState = null) : SelectionState
      {
         var markActive:Mark = null;
         var markAnchor:Mark = null;
         var operationState:SelectionState = param1;
         if(operationState)
         {
            markActive = tlf_internal::createMark();
            markAnchor = tlf_internal::createMark();
            try
            {
               markActive.position = operationState.activePosition;
               markAnchor.position = operationState.anchorPosition;
               this.flushPendingOperations();
            }
            finally
            {
               tlf_internal::removeMark(markActive);
               tlf_internal::removeMark(markAnchor);
               operationState.activePosition = markActive.position;
               operationState.anchorPosition = markAnchor.position;
            }
         }
         else
         {
            this.flushPendingOperations();
            if(hasSelection())
            {
               operationState = getSelectionState();
               operationState.tlf_internal::selectionManagerOperationState = true;
            }
         }
         return operationState;
      }
      
      public function splitParagraph(param1:SelectionState = null) : void
      {
         param1 = this.tlf_internal::defaultOperationState(param1);
         if(!param1)
         {
            return;
         }
         this.doOperation(new SplitParagraphOperation(param1));
      }
      
      public function deleteText(param1:SelectionState = null) : void
      {
         param1 = this.tlf_internal::defaultOperationState(param1);
         if(!param1)
         {
            return;
         }
         this.doOperation(new DeleteTextOperation(param1,param1,false));
      }
      
      public function deleteNextCharacter(param1:SelectionState = null) : void
      {
         var _loc2_:DeleteTextOperation = null;
         var _loc3_:int = 0;
         param1 = this.tlf_internal::defaultOperationState(param1);
         if(!param1)
         {
            return;
         }
         if(param1.absoluteStart == param1.absoluteEnd)
         {
            _loc3_ = NavigationUtil.nextAtomPosition(textFlow,absoluteStart);
            _loc2_ = new DeleteTextOperation(param1,new SelectionState(textFlow,absoluteStart,_loc3_,pointFormat),true);
         }
         else
         {
            _loc2_ = new DeleteTextOperation(param1,param1,false);
         }
         this.doOperation(_loc2_);
      }
      
      public function deleteNextWord(param1:SelectionState = null) : void
      {
         param1 = this.tlf_internal::defaultOperationState(param1);
         if(!param1 || param1.anchorPosition == param1.activePosition && param1.anchorPosition >= textFlow.textLength - 1)
         {
            return;
         }
         var _loc2_:SelectionState = this.getNextWordForDelete(param1.absoluteStart);
         if(_loc2_.anchorPosition == _loc2_.activePosition)
         {
            return;
         }
         setSelectionState(new SelectionState(textFlow,param1.absoluteStart,param1.absoluteStart,new TextLayoutFormat(textFlow.findLeaf(param1.absoluteStart).format)));
         this.doOperation(new DeleteTextOperation(param1,_loc2_,false));
      }
      
      private function getNextWordForDelete(param1:int) : SelectionState
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc2_:FlowLeafElement = textFlow.findLeaf(param1);
         var _loc3_:ParagraphElement = _loc2_.getParagraph();
         var _loc4_:int = _loc3_.getAbsoluteStart();
         var _loc5_:int = -1;
         if(param1 - _loc4_ >= _loc3_.textLength - 1)
         {
            _loc5_ = NavigationUtil.nextAtomPosition(textFlow,param1);
         }
         else
         {
            _loc6_ = param1 - _loc4_;
            _loc7_ = _loc3_.getCharCodeAtPosition(_loc6_);
            _loc8_ = -1;
            if(_loc6_ > 0)
            {
               _loc8_ = _loc3_.getCharCodeAtPosition(_loc6_ - 1);
            }
            _loc9_ = _loc3_.getCharCodeAtPosition(_loc6_ + 1);
            if(!CharacterUtil.isWhitespace(_loc7_) && (_loc6_ == 0 || _loc6_ > 0 && CharacterUtil.isWhitespace(_loc8_)))
            {
               _loc5_ = NavigationUtil.nextWordPosition(textFlow,param1);
            }
            else
            {
               if(CharacterUtil.isWhitespace(_loc7_) && (_loc6_ > 0 && !CharacterUtil.isWhitespace(_loc8_)))
               {
                  _loc6_ = _loc3_.findNextWordBoundary(_loc6_);
               }
               _loc5_ = _loc4_ + _loc3_.findNextWordBoundary(_loc6_);
            }
         }
         return new SelectionState(textFlow,param1,_loc5_,pointFormat);
      }
      
      public function deletePreviousCharacter(param1:SelectionState = null) : void
      {
         var _loc2_:DeleteTextOperation = null;
         var _loc3_:int = 0;
         param1 = this.tlf_internal::defaultOperationState(param1);
         if(!param1)
         {
            return;
         }
         if(param1.absoluteStart == param1.absoluteEnd)
         {
            _loc3_ = NavigationUtil.previousAtomPosition(textFlow,param1.absoluteStart);
            _loc2_ = new DeleteTextOperation(param1,new SelectionState(textFlow,_loc3_,param1.absoluteStart),true);
         }
         else
         {
            _loc2_ = new DeleteTextOperation(param1);
         }
         this.doOperation(_loc2_);
      }
      
      public function deletePreviousWord(param1:SelectionState = null) : void
      {
         param1 = this.tlf_internal::defaultOperationState(param1);
         if(!param1)
         {
            return;
         }
         var _loc2_:SelectionState = this.getPreviousWordForDelete(param1.absoluteStart);
         if(_loc2_.anchorPosition == _loc2_.activePosition)
         {
            return;
         }
         setSelectionState(new SelectionState(textFlow,param1.absoluteStart,param1.absoluteStart,new TextLayoutFormat(textFlow.findLeaf(param1.absoluteStart).format)));
         this.doOperation(new DeleteTextOperation(param1,_loc2_,false));
      }
      
      private function getPreviousWordForDelete(param1:int) : SelectionState
      {
         var _loc9_:int = 0;
         var _loc2_:FlowLeafElement = textFlow.findLeaf(param1);
         var _loc3_:ParagraphElement = _loc2_.getParagraph();
         var _loc4_:int = _loc3_.getAbsoluteStart();
         if(param1 == _loc4_)
         {
            _loc9_ = NavigationUtil.previousAtomPosition(textFlow,param1);
            return new SelectionState(textFlow,_loc9_,param1);
         }
         var _loc5_:int = param1 - _loc4_;
         var _loc6_:int = _loc3_.getCharCodeAtPosition(_loc5_);
         var _loc7_:int = _loc3_.getCharCodeAtPosition(_loc5_ - 1);
         var _loc8_:int = param1;
         if(CharacterUtil.isWhitespace(_loc6_) && _loc5_ != _loc3_.textLength - 1)
         {
            if(CharacterUtil.isWhitespace(_loc7_))
            {
               _loc5_ = _loc3_.findPreviousWordBoundary(_loc5_);
            }
            if(_loc5_ > 0)
            {
               _loc5_ = _loc3_.findPreviousWordBoundary(_loc5_);
               if(_loc5_ > 0)
               {
                  _loc7_ = _loc3_.getCharCodeAtPosition(_loc5_ - 1);
                  if(CharacterUtil.isWhitespace(_loc7_))
                  {
                     _loc5_ = _loc3_.findPreviousWordBoundary(_loc5_);
                  }
               }
            }
         }
         else if(CharacterUtil.isWhitespace(_loc7_))
         {
            _loc5_ = _loc3_.findPreviousWordBoundary(_loc5_);
            if(_loc5_ > 0)
            {
               _loc5_ = _loc3_.findPreviousWordBoundary(_loc5_);
               if(_loc5_ > 0)
               {
                  _loc7_ = _loc3_.getCharCodeAtPosition(_loc5_ - 1);
                  if(!CharacterUtil.isWhitespace(_loc7_))
                  {
                     _loc8_--;
                  }
               }
            }
         }
         else
         {
            _loc5_ = _loc3_.findPreviousWordBoundary(_loc5_);
         }
         return new SelectionState(textFlow,_loc4_ + _loc5_,_loc8_);
      }
      
      public function insertText(param1:String, param2:SelectionState = null) : void
      {
         var _loc3_:SelectionState = null;
         var _loc4_:ContainerController = null;
         if(param2 == null && Boolean(this.pendingInsert))
         {
            this.pendingInsert.text += param1;
         }
         else
         {
            _loc3_ = this.tlf_internal::defaultOperationState(param2);
            if(!_loc3_)
            {
               return;
            }
            this.pendingInsert = new InsertTextOperation(_loc3_,param1);
            _loc4_ = textFlow.flowComposer.getControllerAt(0);
            if(this.tlf_internal::captureLevel == 0 && param2 == null && _loc4_ && Boolean(_loc4_.container))
            {
               this.enterFrameListener = _loc4_.container;
               this.enterFrameListener.addEventListener(Event.ENTER_FRAME,enterFrameHandler,false,1,true);
            }
            else
            {
               this.flushPendingOperations();
            }
         }
      }
      
      public function overwriteText(param1:String, param2:SelectionState = null) : void
      {
         param2 = this.tlf_internal::defaultOperationState(param2);
         if(!param2)
         {
            return;
         }
         var _loc3_:SelectionState = getSelectionState();
         NavigationUtil.nextCharacter(_loc3_,true);
         this.doOperation(new InsertTextOperation(param2,param1,_loc3_));
      }
      
      public function insertInlineGraphic(param1:Object, param2:Object, param3:Object, param4:Object = null, param5:SelectionState = null) : void
      {
         param5 = this.tlf_internal::defaultOperationState(param5);
         if(!param5)
         {
            return;
         }
         this.doOperation(new InsertInlineGraphicOperation(param5,param1,param2,param3,param4));
      }
      
      public function modifyInlineGraphic(param1:Object, param2:Object, param3:Object, param4:Object = null, param5:SelectionState = null) : void
      {
         param5 = this.tlf_internal::defaultOperationState(param5);
         if(!param5)
         {
            return;
         }
         this.doOperation(new ModifyInlineGraphicOperation(param5,param1,param2,param3,param4));
      }
      
      public function applyFormat(param1:ITextLayoutFormat, param2:ITextLayoutFormat, param3:ITextLayoutFormat, param4:SelectionState = null) : void
      {
         param4 = this.tlf_internal::defaultOperationState(param4);
         if(!param4)
         {
            return;
         }
         this.doOperation(new ApplyFormatOperation(param4,param1,param2,param3));
      }
      
      public function clearFormat(param1:ITextLayoutFormat, param2:ITextLayoutFormat, param3:ITextLayoutFormat, param4:SelectionState = null) : void
      {
         param4 = this.tlf_internal::defaultOperationState(param4);
         if(!param4)
         {
            return;
         }
         this.doOperation(new ClearFormatOperation(param4,param1,param2,param3));
      }
      
      public function applyLeafFormat(param1:ITextLayoutFormat, param2:SelectionState = null) : void
      {
         this.applyFormat(param1,null,null,param2);
      }
      
      public function applyParagraphFormat(param1:ITextLayoutFormat, param2:SelectionState = null) : void
      {
         this.applyFormat(null,param1,null,param2);
      }
      
      public function applyContainerFormat(param1:ITextLayoutFormat, param2:SelectionState = null) : void
      {
         this.applyFormat(null,null,param1,param2);
      }
      
      public function applyFormatToElement(param1:FlowElement, param2:ITextLayoutFormat, param3:SelectionState = null) : void
      {
         param3 = this.tlf_internal::defaultOperationState(param3);
         if(!param3)
         {
            return;
         }
         this.doOperation(new ApplyFormatToElementOperation(param3,param1,param2));
      }
      
      public function clearFormatOnElement(param1:FlowElement, param2:ITextLayoutFormat, param3:SelectionState = null) : void
      {
         param3 = this.tlf_internal::defaultOperationState(param3);
         if(!param3)
         {
            return;
         }
         this.doOperation(new ClearFormatOnElementOperation(param3,param1,param2));
      }
      
      public function cutTextScrap(param1:SelectionState = null) : TextScrap
      {
         param1 = this.tlf_internal::defaultOperationState(param1);
         if(!param1)
         {
            return null;
         }
         if(param1.anchorPosition == param1.activePosition)
         {
            return null;
         }
         var _loc2_:TextScrap = TextFlowEdit.createTextScrap(param1.textFlow,param1.absoluteStart,param1.absoluteEnd);
         var _loc3_:int = textFlow.textLength;
         this.doOperation(new CutOperation(param1,_loc2_));
         if(param1.textFlow.textLength != _loc3_)
         {
            return _loc2_;
         }
         return null;
      }
      
      public function pasteTextScrap(param1:TextScrap, param2:SelectionState = null) : void
      {
         param2 = this.tlf_internal::defaultOperationState(param2);
         if(!param2)
         {
            return;
         }
         this.doOperation(new PasteOperation(param2,param1));
      }
      
      public function applyTCY(param1:Boolean, param2:SelectionState = null) : void
      {
         param2 = this.tlf_internal::defaultOperationState(param2);
         if(!param2)
         {
            return;
         }
         this.doOperation(new ApplyTCYOperation(param2,param1));
      }
      
      public function applyLink(param1:String, param2:String = null, param3:Boolean = false, param4:SelectionState = null) : void
      {
         param4 = this.tlf_internal::defaultOperationState(param4);
         if(!param4)
         {
            return;
         }
         if(param4.absoluteStart == param4.absoluteEnd)
         {
            return;
         }
         this.doOperation(new ApplyLinkOperation(param4,param1,param2,param3));
      }
      
      public function changeElementID(param1:String, param2:FlowElement, param3:int = 0, param4:int = -1, param5:SelectionState = null) : void
      {
         param5 = this.tlf_internal::defaultOperationState(param5);
         if(!param5)
         {
            return;
         }
         if(param5.absoluteStart == param5.absoluteEnd)
         {
            return;
         }
         this.doOperation(new ApplyElementIDOperation(param5,param2,param1,param3,param4));
      }
      
      public function changeStyleName(param1:String, param2:FlowElement, param3:int = 0, param4:int = -1, param5:SelectionState = null) : void
      {
         param5 = this.tlf_internal::defaultOperationState(param5);
         if(!param5)
         {
            return;
         }
         this.doOperation(new ApplyElementStyleNameOperation(param5,param2,param1,param3,param4));
      }
      
      public function beginCompositeOperation() : void
      {
         var _loc3_:FlowOperationEvent = null;
         this.flushPendingOperations();
         if(!this.parentStack)
         {
            this.parentStack = [];
         }
         var _loc1_:CompositeOperation = new CompositeOperation();
         if(!this._imeSession)
         {
            _loc3_ = new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_BEGIN,false,false,_loc1_,this.tlf_internal::captureLevel,null);
            textFlow.dispatchEvent(_loc3_);
         }
         _loc1_.tlf_internal::setGenerations(textFlow.generation,0);
         ++this.tlf_internal::captureLevel;
         var _loc2_:Object = new Object();
         _loc2_.operation = _loc1_;
         _loc2_.captureLevel = this.tlf_internal::captureLevel;
         this.parentStack.push(_loc2_);
      }
      
      public function endCompositeOperation() : void
      {
         var _loc3_:FlowOperationEvent = null;
         --this.tlf_internal::captureLevel;
         var _loc1_:Object = this.parentStack.pop();
         var _loc2_:FlowOperation = _loc1_.operation;
         if(!this._imeSession)
         {
            _loc3_ = new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_END,false,false,_loc2_,this.tlf_internal::captureLevel,null);
            textFlow.dispatchEvent(_loc3_);
         }
         _loc2_.tlf_internal::setGenerations(_loc2_.beginGeneration,textFlow.generation);
         this.finalizeDo(_loc2_);
      }
      
      override tlf_internal function selectionChanged(param1:Boolean = true, param2:Boolean = true) : void
      {
         if(this._imeSession)
         {
            this._imeSession.selectionChanged();
         }
         super.tlf_internal::selectionChanged(param1,param2);
      }
   }
}

