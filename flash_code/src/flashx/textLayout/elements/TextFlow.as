package flashx.textLayout.elements
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.text.engine.TextLineValidity;
   import flash.utils.Dictionary;
   import flashx.textLayout.compose.FlowComposerBase;
   import flashx.textLayout.compose.IFlowComposer;
   import flashx.textLayout.compose.ISWFContext;
   import flashx.textLayout.edit.ISelectionManager;
   import flashx.textLayout.events.DamageEvent;
   import flashx.textLayout.events.ModelChange;
   import flashx.textLayout.external.WeakRef;
   import flashx.textLayout.formats.ITextLayoutFormat;
   import flashx.textLayout.formats.TextLayoutFormat;
   import flashx.textLayout.formats.TextLayoutFormatValueHolder;
   import flashx.textLayout.property.Property;
   import flashx.textLayout.tlf_internal;
   
   use namespace tlf_internal;
   
   public class TextFlow extends ContainerFormattedElement implements IEventDispatcher
   {
      
      public static var defaultConfiguration:Configuration = new Configuration();
      
      private static var _nextGeneration:uint = 1;
      
      private static var _dictionary:Dictionary = new Dictionary();
      
      private static var _seeksSinceLastPurge:int = 0;
      
      private var _flowComposer:IFlowComposer;
      
      private var _interactionManager:ISelectionManager;
      
      private var _configuration:IConfiguration;
      
      private var _backgroundManager:BackgroundManager;
      
      private var normalizeStart:int = 0;
      
      private var normalizeLen:int = 0;
      
      private var _eventDispatcher:EventDispatcher;
      
      private var _generation:uint;
      
      private var _formatResolver:IFormatResolver;
      
      private var _elemsToUpdate:Array;
      
      private var _hostFormatHelper:HostFormatHelper;
      
      public function TextFlow(param1:IConfiguration = null)
      {
         super();
         this.initializeForConstructor(param1);
      }
      
      tlf_internal static function getCanonical(param1:TextLayoutFormatValueHolder, param2:ITextLayoutFormat, param3:uint) : ITextLayoutFormat
      {
         var _loc7_:Object = null;
         var _loc8_:TextLayoutFormat = null;
         if(param2 == null)
         {
            param2 = TextLayoutFormat.defaultFormat;
            param3 = TextLayoutFormat.tlf_internal::getDefaultFormatHash();
         }
         if(param1 == null)
         {
            return param2;
         }
         ++_seeksSinceLastPurge;
         if(_seeksSinceLastPurge == 1000)
         {
            for each(_loc7_ in _dictionary)
            {
               if(_loc7_.format.get() == null)
               {
                  delete _dictionary[_loc7_.hash];
               }
            }
            _seeksSinceLastPurge = 0;
         }
         var _loc4_:uint = param1.hash(param3);
         var _loc5_:Object = _dictionary[_loc4_];
         if(_loc5_)
         {
            _loc8_ = _loc5_.format.get();
            if(_loc8_)
            {
               if(param2 == _loc5_.defaultFormat && Property.equalCoreStyles(param1.coreStyles,_loc5_.coreStyles,TextLayoutFormat.tlf_internal::description))
               {
                  return _loc8_;
               }
            }
         }
         var _loc6_:TextLayoutFormat = new TextLayoutFormat(param1);
         _loc6_.concat(param2);
         _loc5_ = new Object();
         _loc5_.coreStyles = Property.shallowCopy(param1.coreStyles);
         _loc5_.format = new WeakRef(_loc6_);
         _loc5_.defaultFormat = param2;
         _loc5_.hash = _loc4_;
         _dictionary[_loc4_] = _loc5_;
         return _loc6_;
      }
      
      private function initializeForConstructor(param1:IConfiguration) : void
      {
         if(param1 == null)
         {
            param1 = defaultConfiguration;
         }
         this._configuration = Configuration(param1).tlf_internal::getImmutableClone();
         this._eventDispatcher = new EventDispatcher(this);
         format = this._configuration.textFlowInitialFormat;
         if(this._configuration.flowComposerClass)
         {
            this.flowComposer = new this._configuration.flowComposerClass();
         }
         this._generation = _nextGeneration++;
      }
      
      override public function shallowCopy(param1:int = 0, param2:int = -1) : FlowElement
      {
         var _loc3_:TextFlow = super.shallowCopy(param1,param2) as TextFlow;
         _loc3_._configuration = this._configuration;
         _loc3_._generation = _nextGeneration++;
         if(this.formatResolver)
         {
            _loc3_.formatResolver = this.formatResolver.getResolverForNewFlow(this,_loc3_);
         }
         if(Boolean(_loc3_.flowComposer) && Boolean(this.flowComposer))
         {
            _loc3_.flowComposer.swfContext = this.flowComposer.swfContext;
         }
         return _loc3_;
      }
      
      public function get configuration() : IConfiguration
      {
         return this._configuration;
      }
      
      public function get interactionManager() : ISelectionManager
      {
         return this._interactionManager;
      }
      
      public function set interactionManager(param1:ISelectionManager) : void
      {
         if(this._interactionManager != param1)
         {
            if(this._interactionManager)
            {
               this._interactionManager.textFlow = null;
            }
            this._interactionManager = param1;
            if(this._interactionManager)
            {
               this._interactionManager.textFlow = this;
            }
            if(this.flowComposer)
            {
               this.flowComposer.interactionManagerChanged(param1);
            }
         }
      }
      
      override public function get flowComposer() : IFlowComposer
      {
         return this._flowComposer;
      }
      
      public function set flowComposer(param1:IFlowComposer) : void
      {
         this.tlf_internal::changeFlowComposer(param1,true);
      }
      
      tlf_internal function changeFlowComposer(param1:IFlowComposer, param2:Boolean) : void
      {
         var _loc3_:ISWFContext = null;
         var _loc4_:ISWFContext = null;
         var _loc5_:int = 0;
         if(this._flowComposer != param1)
         {
            _loc3_ = FlowComposerBase.tlf_internal::computeBaseSWFContext(this._flowComposer ? this._flowComposer.swfContext : null);
            _loc4_ = FlowComposerBase.tlf_internal::computeBaseSWFContext(param1 ? param1.swfContext : null);
            if(!this.flowComposer && param1 || this.flowComposer && !param1)
            {
               tlf_internal::appendElementsForDelayedUpdate(this);
            }
            if(this._flowComposer)
            {
               _loc5_ = 0;
               while(_loc5_ < this._flowComposer.numControllers)
               {
                  this._flowComposer.getControllerAt(_loc5_++).tlf_internal::clearSelectionShapes();
               }
               this._flowComposer.setRootElement(null);
            }
            this._flowComposer = param1;
            if(this._flowComposer)
            {
               this._flowComposer.setRootElement(this);
            }
            if(textLength)
            {
               this.tlf_internal::damage(getAbsoluteStart(),textLength,TextLineValidity.INVALID,false);
            }
            if(_loc3_ != _loc4_)
            {
               this.invalidateAllFormats();
            }
            if(this.flowComposer == null)
            {
               this.tlf_internal::applyUpdateElements(param2);
            }
         }
      }
      
      public function getElementByID(param1:String) : FlowElement
      {
         return tlf_internal::getElementByIDHelper(param1);
      }
      
      public function getElementsByStyleName(param1:String) : Array
      {
         var _loc2_:Array = new Array();
         tlf_internal::getElementsByStyleNameHelper(_loc2_,param1);
         return _loc2_;
      }
      
      override protected function get abstract() : Boolean
      {
         return false;
      }
      
      override tlf_internal function updateLengths(param1:int, param2:int, param3:Boolean) : void
      {
         var _loc4_:int = 0;
         if(this.normalizeStart != -1)
         {
            _loc4_ = param1 < this.normalizeStart ? param1 : this.normalizeStart;
            if(_loc4_ < this.normalizeStart)
            {
               this.normalizeLen += this.normalizeStart - _loc4_;
            }
            this.normalizeLen += param2;
            this.normalizeStart = _loc4_;
         }
         else
         {
            this.normalizeStart = param1;
            this.normalizeLen = param2;
         }
         if(this.normalizeLen < 0)
         {
            this.normalizeLen = 0;
         }
         if(param3 && Boolean(this._flowComposer))
         {
            this._flowComposer.updateLengths(param1,param2);
            super.tlf_internal::updateLengths(param1,param2,false);
         }
         else
         {
            super.tlf_internal::updateLengths(param1,param2,param3);
         }
      }
      
      override public function set mxmlChildren(param1:Array) : void
      {
         super.mxmlChildren = param1;
         this.tlf_internal::normalize();
         tlf_internal::applyWhiteSpaceCollapse();
      }
      
      tlf_internal function applyUpdateElements(param1:Boolean) : Boolean
      {
         var _loc2_:Boolean = false;
         var _loc3_:FlowElement = null;
         if(this._elemsToUpdate)
         {
            _loc2_ = Boolean(this.flowComposer) && this.flowComposer.numControllers != 0;
            for each(_loc3_ in this._elemsToUpdate)
            {
               _loc3_.tlf_internal::applyDelayedElementUpdate(this,param1,_loc2_);
            }
            this._elemsToUpdate = null;
            return true;
         }
         return false;
      }
      
      override tlf_internal function preCompose() : void
      {
         do
         {
            this.tlf_internal::normalize();
         }
         while(this.tlf_internal::applyUpdateElements(true));
         
      }
      
      tlf_internal function damage(param1:int, param2:int, param3:String, param4:Boolean = true) : void
      {
         var _loc5_:uint = 0;
         if(param4)
         {
            if(this.normalizeStart == -1)
            {
               this.normalizeStart = param1;
               this.normalizeLen = param2;
            }
            else if(param1 < this.normalizeStart)
            {
               _loc5_ = uint(this.normalizeLen);
               _loc5_ = uint(this.normalizeStart + this.normalizeLen - param1);
               if(param2 > _loc5_)
               {
                  _loc5_ = uint(param2);
               }
               this.normalizeStart = param1;
               this.normalizeLen = _loc5_;
            }
            else if(this.normalizeStart + this.normalizeLen > param1)
            {
               if(param1 + param2 > this.normalizeStart + this.normalizeLen)
               {
                  this.normalizeLen = param1 + param2 - this.normalizeStart;
               }
            }
            else
            {
               this.normalizeLen = param1 + param2 - this.normalizeStart;
            }
            if(this.normalizeStart + this.normalizeLen > textLength)
            {
               this.normalizeLen = textLength - this.normalizeStart;
            }
         }
         if(this._flowComposer)
         {
            this._flowComposer.damage(param1,param2,param3);
         }
         if(this.hasEventListener(DamageEvent.DAMAGE))
         {
            this.dispatchEvent(new DamageEvent(DamageEvent.DAMAGE,false,false,this,param1,param2));
         }
      }
      
      tlf_internal function findAbsoluteParagraph(param1:int) : ParagraphElement
      {
         var _loc2_:FlowElement = findLeaf(param1);
         return _loc2_ ? _loc2_.getParagraph() : null;
      }
      
      tlf_internal function findAbsoluteFlowGroupElement(param1:int) : FlowGroupElement
      {
         var _loc2_:FlowElement = findLeaf(param1);
         return _loc2_.parent;
      }
      
      public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         this._eventDispatcher.addEventListener(param1,param2,param3,param4,param5);
      }
      
      public function dispatchEvent(param1:Event) : Boolean
      {
         return this._eventDispatcher.dispatchEvent(param1);
      }
      
      public function hasEventListener(param1:String) : Boolean
      {
         return this._eventDispatcher.hasEventListener(param1);
      }
      
      public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         this._eventDispatcher.removeEventListener(param1,param2,param3);
      }
      
      public function willTrigger(param1:String) : Boolean
      {
         return this._eventDispatcher.willTrigger(param1);
      }
      
      tlf_internal function appendOneElementForUpdate(param1:FlowElement) : void
      {
         if(this._elemsToUpdate == null)
         {
            this._elemsToUpdate = [param1];
         }
         else
         {
            this._elemsToUpdate.push(param1);
         }
      }
      
      tlf_internal function mustUseComposer() : Boolean
      {
         var _loc2_:FlowElement = null;
         if(this._elemsToUpdate == null || this._elemsToUpdate.length == 0)
         {
            return false;
         }
         this.tlf_internal::normalize();
         var _loc1_:Boolean = false;
         for each(_loc2_ in this._elemsToUpdate)
         {
            if(_loc2_.tlf_internal::updateForMustUseComposer(this))
            {
               _loc1_ = true;
            }
         }
         return _loc1_;
      }
      
      tlf_internal function processModelChanged(param1:String, param2:FlowElement, param3:int, param4:int, param5:Boolean, param6:Boolean) : void
      {
         if(this.flowComposer)
         {
            param2.tlf_internal::appendElementsForDelayedUpdate(this);
         }
         if(param6)
         {
            this._generation = _nextGeneration++;
         }
         if(param4 > 0)
         {
            this.tlf_internal::damage(param3 + param2.getAbsoluteStart(),param4,TextLineValidity.INVALID,param5);
         }
         if(this.formatResolver)
         {
            switch(param1)
            {
               case ModelChange.ELEMENT_REMOVAL:
               case ModelChange.ELEMENT_ADDED:
               case ModelChange.STYLE_SELECTOR_CHANGED:
                  this.formatResolver.invalidate(param2);
                  param2.tlf_internal::formatChanged(false);
            }
         }
      }
      
      public function get generation() : uint
      {
         return this._generation;
      }
      
      tlf_internal function setGeneration(param1:uint) : void
      {
         this._generation = param1;
      }
      
      tlf_internal function processAutoSizeImageLoaded(param1:InlineGraphicElement) : void
      {
         if(this.flowComposer)
         {
            param1.tlf_internal::appendElementsForDelayedUpdate(this);
         }
      }
      
      tlf_internal function normalize() : void
      {
         var _loc1_:int = 0;
         if(this.normalizeStart != -1)
         {
            _loc1_ = this.normalizeStart + (this.normalizeLen == 0 ? 1 : this.normalizeLen);
            tlf_internal::normalizeRange(this.normalizeStart,_loc1_);
            this.normalizeStart = -1;
            this.normalizeLen = 0;
         }
      }
      
      public function get hostFormat() : ITextLayoutFormat
      {
         return this._hostFormatHelper ? this._hostFormatHelper.format : null;
      }
      
      public function set hostFormat(param1:ITextLayoutFormat) : void
      {
         if(param1 == null)
         {
            this._hostFormatHelper = null;
         }
         else
         {
            if(this._hostFormatHelper == null)
            {
               this._hostFormatHelper = new HostFormatHelper();
            }
            this._hostFormatHelper.format = param1;
         }
         tlf_internal::formatChanged();
      }
      
      tlf_internal function getDefaultFormat() : ITextLayoutFormat
      {
         if(this._hostFormatHelper == null)
         {
            return TextLayoutFormat.defaultFormat;
         }
         return this._hostFormatHelper.computedFormat;
      }
      
      tlf_internal function getDefaultFormatHash() : uint
      {
         return this.tlf_internal::getDefaultFormat() == TextLayoutFormat.defaultFormat ? TextLayoutFormat.tlf_internal::getDefaultFormatHash() : this._hostFormatHelper.getComputedTextLayoutFormatHash();
      }
      
      tlf_internal function getTextLayoutFormatStyle(param1:Object) : ITextLayoutFormat
      {
         return this._formatResolver != null ? this._formatResolver.resolveFormat(param1) as ITextLayoutFormat : null;
      }
      
      tlf_internal function set backgroundManager(param1:BackgroundManager) : void
      {
         if(this._backgroundManager)
         {
            this._backgroundManager.textFlow = null;
         }
         this._backgroundManager = param1;
         if(this._backgroundManager)
         {
            this._backgroundManager.textFlow = this;
         }
      }
      
      tlf_internal function get backgroundManager() : BackgroundManager
      {
         return this._backgroundManager;
      }
      
      public function get formatResolver() : IFormatResolver
      {
         return this._formatResolver;
      }
      
      public function set formatResolver(param1:IFormatResolver) : void
      {
         if(this._formatResolver != param1)
         {
            if(this._formatResolver)
            {
               this._formatResolver.invalidateAll(this);
            }
            this._formatResolver = param1;
            if(this._formatResolver)
            {
               this._formatResolver.invalidateAll(this);
            }
            tlf_internal::formatChanged(true);
         }
      }
      
      public function invalidateAllFormats() : void
      {
         if(this._formatResolver)
         {
            this._formatResolver.invalidateAll(this);
         }
         if(GlobalSettings.fontMapperFunction != null)
         {
            FlowLeafElement.tlf_internal::clearElementFormatsCache();
         }
         tlf_internal::formatChanged(true);
      }
   }
}

import flash.utils.Dictionary;
import flashx.textLayout.formats.ITextLayoutFormat;
import flashx.textLayout.formats.TextLayoutFormat;
import flashx.textLayout.tlf_internal;

use namespace tlf_internal;

class HostFormatHelper
{
   
   private static const computedFormatCache:Dictionary = new Dictionary(true);
   
   private var _format:ITextLayoutFormat;
   
   private var _computedFormat:ITextLayoutFormat;
   
   private var _computedFormatHash:uint;
   
   public function HostFormatHelper()
   {
      super();
   }
   
   public function get format() : ITextLayoutFormat
   {
      return this._format;
   }
   
   public function set format(param1:ITextLayoutFormat) : void
   {
      this._format = param1;
      this._computedFormat = null;
   }
   
   public function get computedFormat() : ITextLayoutFormat
   {
      var _loc2_:TextLayoutFormat = null;
      if(this._computedFormat)
      {
         return this._computedFormat;
      }
      var _loc1_:Object = computedFormatCache[this._format];
      if(_loc1_ == null)
      {
         _loc2_ = new TextLayoutFormat(this.format);
         _loc2_.concat(TextLayoutFormat.defaultFormat);
         _loc1_ = new Object();
         _loc1_.format = _loc2_;
         _loc1_.hash = _loc2_.tlf_internal::hash(0);
         computedFormatCache[this._format] = _loc1_;
      }
      this._computedFormat = _loc1_.format;
      this._computedFormatHash = _loc1_.hash;
      return this._computedFormat;
   }
   
   public function getComputedTextLayoutFormatHash() : uint
   {
      return this._computedFormatHash;
   }
}
