package flashx.textLayout.edit
{
   import flashx.textLayout.compose.IFlowComposer;
   import flashx.textLayout.container.ContainerController;
   import flashx.textLayout.elements.ContainerFormattedElement;
   import flashx.textLayout.elements.FlowLeafElement;
   import flashx.textLayout.elements.ParagraphElement;
   import flashx.textLayout.elements.SubParagraphGroupElement;
   import flashx.textLayout.elements.TextFlow;
   import flashx.textLayout.formats.ITextLayoutFormat;
   import flashx.textLayout.tlf_internal;
   
   use namespace tlf_internal;
   
   public class ElementRange
   {
      
      private var _absoluteStart:int;
      
      private var _absoluteEnd:int;
      
      private var _firstLeaf:FlowLeafElement;
      
      private var _lastLeaf:FlowLeafElement;
      
      private var _firstParagraph:ParagraphElement;
      
      private var _lastParagraph:ParagraphElement;
      
      private var _textFlow:TextFlow;
      
      public function ElementRange()
      {
         super();
      }
      
      public static function createElementRange(param1:TextFlow, param2:int, param3:int) : ElementRange
      {
         var _loc4_:ElementRange = new ElementRange();
         if(param2 == param3)
         {
            _loc4_.absoluteStart = _loc4_.absoluteEnd = param2;
            _loc4_.firstLeaf = _loc4_.lastLeaf = param1.findLeaf(_loc4_.absoluteStart);
            _loc4_.firstParagraph = _loc4_.lastParagraph = _loc4_.firstLeaf.getParagraph();
            adjustForLeanLeft(_loc4_);
         }
         else
         {
            if(param2 < param3)
            {
               _loc4_.absoluteStart = param2;
               _loc4_.absoluteEnd = param3;
            }
            else
            {
               _loc4_.absoluteStart = param3;
               _loc4_.absoluteEnd = param2;
            }
            _loc4_.firstLeaf = param1.findLeaf(_loc4_.absoluteStart);
            _loc4_.lastLeaf = param1.findLeaf(_loc4_.absoluteEnd);
            if(_loc4_.lastLeaf == null && _loc4_.absoluteEnd == param1.textLength || _loc4_.absoluteEnd == _loc4_.lastLeaf.getAbsoluteStart())
            {
               _loc4_.lastLeaf = param1.findLeaf(_loc4_.absoluteEnd - 1);
            }
            _loc4_.firstParagraph = _loc4_.firstLeaf.getParagraph();
            _loc4_.lastParagraph = _loc4_.lastLeaf.getParagraph();
            if(_loc4_.absoluteEnd == _loc4_.lastParagraph.getAbsoluteStart() + _loc4_.lastParagraph.textLength - 1)
            {
               ++_loc4_.absoluteEnd;
               _loc4_.lastLeaf = _loc4_.lastParagraph.getLastLeaf();
            }
         }
         _loc4_.textFlow = param1;
         return _loc4_;
      }
      
      private static function adjustForLeanLeft(param1:ElementRange) : void
      {
         var _loc2_:FlowLeafElement = null;
         if(param1.firstLeaf.getAbsoluteStart() == param1.absoluteStart)
         {
            _loc2_ = param1.firstLeaf.getPreviousLeaf(param1.firstParagraph);
            if(Boolean(_loc2_) && _loc2_.getParagraph() == param1.firstLeaf.getParagraph())
            {
               if((!(_loc2_.parent is SubParagraphGroupElement) || (_loc2_.parent as SubParagraphGroupElement).tlf_internal::acceptTextAfter()) && (!(param1.firstLeaf.parent is SubParagraphGroupElement) || _loc2_.parent === param1.firstLeaf.parent))
               {
                  param1.firstLeaf = _loc2_;
               }
            }
         }
      }
      
      public function get absoluteStart() : int
      {
         return this._absoluteStart;
      }
      
      public function set absoluteStart(param1:int) : void
      {
         this._absoluteStart = param1;
      }
      
      public function get absoluteEnd() : int
      {
         return this._absoluteEnd;
      }
      
      public function set absoluteEnd(param1:int) : void
      {
         this._absoluteEnd = param1;
      }
      
      public function get firstLeaf() : FlowLeafElement
      {
         return this._firstLeaf;
      }
      
      public function set firstLeaf(param1:FlowLeafElement) : void
      {
         this._firstLeaf = param1;
      }
      
      public function get lastLeaf() : FlowLeafElement
      {
         return this._lastLeaf;
      }
      
      public function set lastLeaf(param1:FlowLeafElement) : void
      {
         this._lastLeaf = param1;
      }
      
      public function get firstParagraph() : ParagraphElement
      {
         return this._firstParagraph;
      }
      
      public function set firstParagraph(param1:ParagraphElement) : void
      {
         this._firstParagraph = param1;
      }
      
      public function get lastParagraph() : ParagraphElement
      {
         return this._lastParagraph;
      }
      
      public function set lastParagraph(param1:ParagraphElement) : void
      {
         this._lastParagraph = param1;
      }
      
      public function get textFlow() : TextFlow
      {
         return this._textFlow;
      }
      
      public function set textFlow(param1:TextFlow) : void
      {
         this._textFlow = param1;
      }
      
      public function get containerFormat() : ITextLayoutFormat
      {
         var _loc1_:ContainerController = null;
         var _loc2_:IFlowComposer = this.firstParagraph.getTextFlow().flowComposer;
         if(Boolean(_loc2_) && _loc2_.numControllers > 0)
         {
            _loc1_ = _loc2_.getControllerAt(0);
         }
         if(!_loc1_)
         {
            return ContainerFormattedElement(this.firstParagraph.getParentByType(ContainerFormattedElement)).computedFormat;
         }
         return _loc1_.computedFormat;
      }
      
      public function get paragraphFormat() : ITextLayoutFormat
      {
         return this.firstParagraph.computedFormat;
      }
      
      public function get characterFormat() : ITextLayoutFormat
      {
         return this.firstLeaf.computedFormat;
      }
   }
}

