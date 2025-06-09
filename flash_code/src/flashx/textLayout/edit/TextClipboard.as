package flashx.textLayout.edit
{
   import flash.desktop.Clipboard;
   import flash.desktop.ClipboardFormats;
   import flashx.textLayout.conversion.*;
   import flashx.textLayout.elements.FlowElement;
   import flashx.textLayout.elements.FlowGroupElement;
   import flashx.textLayout.elements.FlowLeafElement;
   import flashx.textLayout.elements.ParagraphElement;
   import flashx.textLayout.elements.TextFlow;
   import flashx.textLayout.tlf_internal;
   
   use namespace tlf_internal;
   
   public class TextClipboard
   {
      
      tlf_internal static const TEXT_LAYOUT_MARKUP:String = "TEXT_LAYOUT_MARKUP";
      
      public function TextClipboard()
      {
         super();
      }
      
      tlf_internal static function getTextOnClipboardForFormat(param1:String) : String
      {
         var _loc2_:Clipboard = Clipboard.generalClipboard;
         return _loc2_.hasFormat(param1) ? String(_loc2_.getData(param1)) : null;
      }
      
      public static function getContents() : TextScrap
      {
         var textFlow:TextFlow = null;
         var textOnClipboard:String = null;
         var originalSettings:Object = null;
         var xmlTree:XML = null;
         var beginArrayChild:XML = null;
         var endArrayChild:XML = null;
         var textLayoutMarkup:XML = null;
         var firstLeaf:FlowLeafElement = null;
         var lastLeaf:FlowLeafElement = null;
         var retTextScrap:TextScrap = null;
         textOnClipboard = tlf_internal::getTextOnClipboardForFormat(tlf_internal::TEXT_LAYOUT_MARKUP);
         if(textOnClipboard != null && textOnClipboard != "")
         {
            originalSettings = XML.settings();
            try
            {
               XML.ignoreProcessingInstructions = false;
               XML.ignoreWhitespace = false;
               xmlTree = new XML(textOnClipboard);
               beginArrayChild = xmlTree..BeginMissingElements[0];
               endArrayChild = xmlTree..EndMissingElements[0];
               textLayoutMarkup = xmlTree..TextFlow[0];
               textFlow = TextConverter.importToFlow(textLayoutMarkup,TextConverter.TEXT_LAYOUT_FORMAT);
               if(textFlow != null)
               {
                  retTextScrap = new TextScrap(textFlow);
                  retTextScrap.tlf_internal::beginMissingArray = getBeginArray(beginArrayChild,textFlow);
                  retTextScrap.tlf_internal::endMissingArray = getEndArray(endArrayChild,textFlow);
               }
            }
            finally
            {
               XML.setSettings(originalSettings);
            }
         }
         if(retTextScrap == null)
         {
            textOnClipboard = tlf_internal::getTextOnClipboardForFormat(ClipboardFormats.TEXT_FORMAT);
            if(textOnClipboard != null && textOnClipboard != "")
            {
               textFlow = TextConverter.importToFlow(textOnClipboard,TextConverter.PLAIN_TEXT_FORMAT);
               if(textFlow)
               {
                  retTextScrap = new TextScrap(textFlow);
                  firstLeaf = textFlow.getFirstLeaf();
                  if(firstLeaf)
                  {
                     retTextScrap.tlf_internal::beginMissingArray.push(firstLeaf);
                     retTextScrap.tlf_internal::beginMissingArray.push(firstLeaf.parent);
                     retTextScrap.tlf_internal::beginMissingArray.push(textFlow);
                     lastLeaf = textFlow.getLastLeaf();
                     retTextScrap.tlf_internal::endMissingArray.push(lastLeaf);
                     retTextScrap.tlf_internal::endMissingArray.push(lastLeaf.parent);
                     retTextScrap.tlf_internal::endMissingArray.push(textFlow);
                  }
               }
            }
         }
         return retTextScrap;
      }
      
      tlf_internal static function createTextFlowExportString(param1:TextScrap) : String
      {
         var originalSettings:Object = null;
         var exporter:ITextExporter = null;
         var result:String = null;
         var xmlExport:XML = null;
         var scrap:TextScrap = param1;
         var textFlowExportString:String = "";
         originalSettings = XML.settings();
         try
         {
            XML.ignoreProcessingInstructions = false;
            XML.ignoreWhitespace = false;
            XML.prettyPrinting = false;
            exporter = TextConverter.getExporter(TextConverter.TEXT_LAYOUT_FORMAT);
            result = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n";
            result += "<TextScrap>\n";
            result += getPartialElementString(scrap);
            xmlExport = exporter.export(scrap.tlf_internal::textFlow,ConversionType.XML_TYPE) as XML;
            result += xmlExport;
            result += "</TextScrap>\n";
            textFlowExportString = result.toString();
            XML.setSettings(originalSettings);
         }
         catch(e:Error)
         {
            XML.setSettings(originalSettings);
         }
         return textFlowExportString;
      }
      
      tlf_internal static function createPlainTextExportString(param1:TextScrap) : String
      {
         var _loc2_:PlainTextExporter = new PlainTextExporter();
         var _loc3_:String = _loc2_.export(param1.tlf_internal::textFlow,ConversionType.STRING_TYPE) as String;
         var _loc4_:ParagraphElement = param1.tlf_internal::textFlow.getLastLeaf().getParagraph();
         if(!param1.tlf_internal::isEndMissing(_loc4_))
         {
            _loc3_ += _loc2_.paragraphSeparator;
         }
         return _loc3_;
      }
      
      tlf_internal static function setClipboardContents(param1:String, param2:String) : void
      {
         var _loc3_:Clipboard = Clipboard.generalClipboard;
         _loc3_.clear();
         _loc3_.setData(tlf_internal::TEXT_LAYOUT_MARKUP,param1);
         _loc3_.setData(ClipboardFormats.TEXT_FORMAT,param2);
      }
      
      public static function setContents(param1:TextScrap) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:String = tlf_internal::createTextFlowExportString(param1);
         var _loc3_:String = tlf_internal::createPlainTextExportString(param1);
         tlf_internal::setClipboardContents(_loc2_,_loc3_);
      }
      
      private static function getPartialElementString(param1:TextScrap) : String
      {
         var _loc8_:FlowElement = null;
         var _loc9_:int = 0;
         var _loc2_:Array = param1.tlf_internal::beginMissingArray;
         var _loc3_:Array = param1.tlf_internal::endMissingArray;
         var _loc4_:String = "";
         var _loc5_:String = "";
         var _loc6_:* = "";
         var _loc7_:int = _loc2_.length - 2;
         if(_loc2_.length > 0)
         {
            _loc4_ = "0";
            while(_loc7_ >= 0)
            {
               _loc8_ = _loc2_[_loc7_];
               _loc9_ = _loc8_.parent.getChildIndex(_loc8_);
               _loc4_ = _loc4_ + "," + _loc9_;
               _loc7_--;
            }
         }
         _loc7_ = _loc3_.length - 2;
         if(_loc3_.length > 0)
         {
            _loc5_ = "0";
            while(_loc7_ >= 0)
            {
               _loc8_ = _loc3_[_loc7_];
               _loc9_ = _loc8_.parent.getChildIndex(_loc8_);
               _loc5_ = _loc5_ + "," + _loc9_;
               _loc7_--;
            }
         }
         if(_loc4_ != "")
         {
            _loc6_ = "<BeginMissingElements value=\"";
            _loc6_ = _loc6_ + _loc4_;
            _loc6_ = _loc6_ + "\"";
            _loc6_ = _loc6_ + "/>\n";
         }
         if(_loc5_ != "")
         {
            _loc6_ += "<EndMissingElements value=\"";
            _loc6_ = _loc6_ + _loc5_;
            _loc6_ = _loc6_ + "\"";
            _loc6_ = _loc6_ + "/>\n";
         }
         return _loc6_;
      }
      
      private static function getBeginArray(param1:XML, param2:TextFlow) : Array
      {
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:String = null;
         var _loc10_:int = 0;
         var _loc3_:Array = new Array();
         var _loc4_:FlowElement = param2;
         if(param1 != null)
         {
            _loc5_ = param1.@value != undefined ? String(param1.@value) : "";
            _loc3_.push(param2);
            _loc6_ = int(_loc5_.indexOf(","));
            while(_loc6_ >= 0)
            {
               _loc7_ = _loc6_ + 1;
               _loc6_ = int(_loc5_.indexOf(",",_loc7_));
               if(_loc6_ >= 0)
               {
                  _loc8_ = _loc6_;
               }
               else
               {
                  _loc8_ = _loc5_.length;
               }
               _loc9_ = _loc5_.substring(_loc7_,_loc8_);
               if(_loc9_.length > 0)
               {
                  _loc10_ = parseInt(_loc9_);
                  if(_loc4_ is FlowGroupElement)
                  {
                     _loc4_ = (_loc4_ as FlowGroupElement).getChildAt(_loc10_);
                     _loc3_.push(_loc4_);
                  }
               }
            }
         }
         return _loc3_.reverse();
      }
      
      private static function getEndArray(param1:XML, param2:TextFlow) : Array
      {
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:String = null;
         var _loc10_:int = 0;
         var _loc3_:Array = new Array();
         var _loc4_:FlowElement = param2;
         if(param1 != null)
         {
            _loc5_ = param1.@value != undefined ? String(param1.@value) : "";
            _loc3_.push(param2);
            _loc6_ = int(_loc5_.indexOf(","));
            while(_loc6_ >= 0)
            {
               _loc7_ = _loc6_ + 1;
               _loc6_ = int(_loc5_.indexOf(",",_loc7_));
               if(_loc6_ >= 0)
               {
                  _loc8_ = _loc6_;
               }
               else
               {
                  _loc8_ = _loc5_.length;
               }
               _loc9_ = _loc5_.substring(_loc7_,_loc8_);
               if(_loc9_.length > 0)
               {
                  _loc10_ = parseInt(_loc9_);
                  if(_loc4_ is FlowGroupElement)
                  {
                     _loc4_ = (_loc4_ as FlowGroupElement).getChildAt(_loc10_);
                     _loc3_.push(_loc4_);
                  }
               }
            }
         }
         return _loc3_.reverse();
      }
   }
}

class TextClipboardSingletonEnforcer
{
   
   public function TextClipboardSingletonEnforcer()
   {
      super();
   }
}
