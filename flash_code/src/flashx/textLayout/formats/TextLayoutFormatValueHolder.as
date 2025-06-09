package flashx.textLayout.formats
{
   import flashx.textLayout.property.Property;
   import flashx.textLayout.tlf_internal;
   
   use namespace tlf_internal;
   
   public class TextLayoutFormatValueHolder implements ITextLayoutFormat
   {
      
      private var _coreStyles:Object;
      
      public function TextLayoutFormatValueHolder(param1:ITextLayoutFormat = null)
      {
         super();
         this.initialize(param1);
      }
      
      private function initialize(param1:ITextLayoutFormat) : void
      {
         var _loc2_:TextLayoutFormatValueHolder = null;
         var _loc3_:String = null;
         var _loc4_:Property = null;
         var _loc5_:* = undefined;
         if(param1)
         {
            _loc2_ = param1 as TextLayoutFormatValueHolder;
            if(_loc2_)
            {
               for(_loc3_ in _loc2_.coreStyles)
               {
                  this.writableCoreStyles()[_loc3_] = _loc2_.coreStyles[_loc3_];
               }
            }
            else
            {
               for each(_loc4_ in TextLayoutFormat.tlf_internal::description)
               {
                  _loc5_ = param1[_loc4_.name];
                  if(_loc5_ !== undefined)
                  {
                     this.writableCoreStyles()[_loc4_.name] = _loc5_;
                  }
               }
            }
         }
      }
      
      private function writableCoreStyles() : Object
      {
         if(this._coreStyles == null)
         {
            this._coreStyles = new Object();
         }
         return this._coreStyles;
      }
      
      public function get coreStyles() : Object
      {
         return this._coreStyles;
      }
      
      public function set coreStyles(param1:Object) : void
      {
         this._coreStyles = param1;
      }
      
      private function getCoreStyle(param1:String) : *
      {
         return this._coreStyles ? this._coreStyles[param1] : undefined;
      }
      
      private function setCoreStyle(param1:Property, param2:*, param3:*) : void
      {
         param3 = param1.setHelper(param2,param3);
         if(param3 !== undefined)
         {
            this.writableCoreStyles()[param1.name] = param3;
         }
         else if(this._coreStyles)
         {
            delete this._coreStyles[param1.name];
         }
      }
      
      public function hash(param1:uint) : uint
      {
         var _loc2_:String = null;
         for(_loc2_ in this.coreStyles)
         {
            param1 = uint(TextLayoutFormat.tlf_internal::description[_loc2_].hash(this.coreStyles[_loc2_],param1));
         }
         return param1;
      }
      
      public function set format(param1:ITextLayoutFormat) : void
      {
         var _loc3_:* = undefined;
         if(param1 == null)
         {
            this.coreStyles = null;
            return;
         }
         var _loc2_:TextLayoutFormatValueHolder = param1 as TextLayoutFormatValueHolder;
         if(_loc2_)
         {
            this.coreStyles = _loc2_.coreStyles ? Property.shallowCopy(_loc2_.coreStyles) : null;
            return;
         }
         this.coreStyles = null;
         _loc3_ = param1.color;
         if(_loc3_ !== undefined)
         {
            this.color = _loc3_;
         }
         _loc3_ = param1.backgroundColor;
         if(_loc3_ !== undefined)
         {
            this.backgroundColor = _loc3_;
         }
         _loc3_ = param1.lineThrough;
         if(_loc3_ !== undefined)
         {
            this.lineThrough = _loc3_;
         }
         _loc3_ = param1.textAlpha;
         if(_loc3_ !== undefined)
         {
            this.textAlpha = _loc3_;
         }
         _loc3_ = param1.backgroundAlpha;
         if(_loc3_ !== undefined)
         {
            this.backgroundAlpha = _loc3_;
         }
         _loc3_ = param1.fontSize;
         if(_loc3_ !== undefined)
         {
            this.fontSize = _loc3_;
         }
         _loc3_ = param1.baselineShift;
         if(_loc3_ !== undefined)
         {
            this.baselineShift = _loc3_;
         }
         _loc3_ = param1.trackingLeft;
         if(_loc3_ !== undefined)
         {
            this.trackingLeft = _loc3_;
         }
         _loc3_ = param1.trackingRight;
         if(_loc3_ !== undefined)
         {
            this.trackingRight = _loc3_;
         }
         _loc3_ = param1.lineHeight;
         if(_loc3_ !== undefined)
         {
            this.lineHeight = _loc3_;
         }
         _loc3_ = param1.breakOpportunity;
         if(_loc3_ !== undefined)
         {
            this.breakOpportunity = _loc3_;
         }
         _loc3_ = param1.digitCase;
         if(_loc3_ !== undefined)
         {
            this.digitCase = _loc3_;
         }
         _loc3_ = param1.digitWidth;
         if(_loc3_ !== undefined)
         {
            this.digitWidth = _loc3_;
         }
         _loc3_ = param1.dominantBaseline;
         if(_loc3_ !== undefined)
         {
            this.dominantBaseline = _loc3_;
         }
         _loc3_ = param1.kerning;
         if(_loc3_ !== undefined)
         {
            this.kerning = _loc3_;
         }
         _loc3_ = param1.ligatureLevel;
         if(_loc3_ !== undefined)
         {
            this.ligatureLevel = _loc3_;
         }
         _loc3_ = param1.alignmentBaseline;
         if(_loc3_ !== undefined)
         {
            this.alignmentBaseline = _loc3_;
         }
         _loc3_ = param1.locale;
         if(_loc3_ !== undefined)
         {
            this.locale = _loc3_;
         }
         _loc3_ = param1.typographicCase;
         if(_loc3_ !== undefined)
         {
            this.typographicCase = _loc3_;
         }
         _loc3_ = param1.fontFamily;
         if(_loc3_ !== undefined)
         {
            this.fontFamily = _loc3_;
         }
         _loc3_ = param1.textDecoration;
         if(_loc3_ !== undefined)
         {
            this.textDecoration = _loc3_;
         }
         _loc3_ = param1.fontWeight;
         if(_loc3_ !== undefined)
         {
            this.fontWeight = _loc3_;
         }
         _loc3_ = param1.fontStyle;
         if(_loc3_ !== undefined)
         {
            this.fontStyle = _loc3_;
         }
         _loc3_ = param1.whiteSpaceCollapse;
         if(_loc3_ !== undefined)
         {
            this.whiteSpaceCollapse = _loc3_;
         }
         _loc3_ = param1.renderingMode;
         if(_loc3_ !== undefined)
         {
            this.renderingMode = _loc3_;
         }
         _loc3_ = param1.cffHinting;
         if(_loc3_ !== undefined)
         {
            this.cffHinting = _loc3_;
         }
         _loc3_ = param1.fontLookup;
         if(_loc3_ !== undefined)
         {
            this.fontLookup = _loc3_;
         }
         _loc3_ = param1.textRotation;
         if(_loc3_ !== undefined)
         {
            this.textRotation = _loc3_;
         }
         _loc3_ = param1.textIndent;
         if(_loc3_ !== undefined)
         {
            this.textIndent = _loc3_;
         }
         _loc3_ = param1.paragraphStartIndent;
         if(_loc3_ !== undefined)
         {
            this.paragraphStartIndent = _loc3_;
         }
         _loc3_ = param1.paragraphEndIndent;
         if(_loc3_ !== undefined)
         {
            this.paragraphEndIndent = _loc3_;
         }
         _loc3_ = param1.paragraphSpaceBefore;
         if(_loc3_ !== undefined)
         {
            this.paragraphSpaceBefore = _loc3_;
         }
         _loc3_ = param1.paragraphSpaceAfter;
         if(_loc3_ !== undefined)
         {
            this.paragraphSpaceAfter = _loc3_;
         }
         _loc3_ = param1.textAlign;
         if(_loc3_ !== undefined)
         {
            this.textAlign = _loc3_;
         }
         _loc3_ = param1.textAlignLast;
         if(_loc3_ !== undefined)
         {
            this.textAlignLast = _loc3_;
         }
         _loc3_ = param1.textJustify;
         if(_loc3_ !== undefined)
         {
            this.textJustify = _loc3_;
         }
         _loc3_ = param1.justificationRule;
         if(_loc3_ !== undefined)
         {
            this.justificationRule = _loc3_;
         }
         _loc3_ = param1.justificationStyle;
         if(_loc3_ !== undefined)
         {
            this.justificationStyle = _loc3_;
         }
         _loc3_ = param1.direction;
         if(_loc3_ !== undefined)
         {
            this.direction = _loc3_;
         }
         _loc3_ = param1.tabStops;
         if(_loc3_ !== undefined)
         {
            this.tabStops = _loc3_;
         }
         _loc3_ = param1.leadingModel;
         if(_loc3_ !== undefined)
         {
            this.leadingModel = _loc3_;
         }
         _loc3_ = param1.columnGap;
         if(_loc3_ !== undefined)
         {
            this.columnGap = _loc3_;
         }
         _loc3_ = param1.paddingLeft;
         if(_loc3_ !== undefined)
         {
            this.paddingLeft = _loc3_;
         }
         _loc3_ = param1.paddingTop;
         if(_loc3_ !== undefined)
         {
            this.paddingTop = _loc3_;
         }
         _loc3_ = param1.paddingRight;
         if(_loc3_ !== undefined)
         {
            this.paddingRight = _loc3_;
         }
         _loc3_ = param1.paddingBottom;
         if(_loc3_ !== undefined)
         {
            this.paddingBottom = _loc3_;
         }
         _loc3_ = param1.columnCount;
         if(_loc3_ !== undefined)
         {
            this.columnCount = _loc3_;
         }
         _loc3_ = param1.columnWidth;
         if(_loc3_ !== undefined)
         {
            this.columnWidth = _loc3_;
         }
         _loc3_ = param1.firstBaselineOffset;
         if(_loc3_ !== undefined)
         {
            this.firstBaselineOffset = _loc3_;
         }
         _loc3_ = param1.verticalAlign;
         if(_loc3_ !== undefined)
         {
            this.verticalAlign = _loc3_;
         }
         _loc3_ = param1.blockProgression;
         if(_loc3_ !== undefined)
         {
            this.blockProgression = _loc3_;
         }
         _loc3_ = param1.lineBreak;
         if(_loc3_ !== undefined)
         {
            this.lineBreak = _loc3_;
         }
      }
      
      public function concat(param1:ITextLayoutFormat) : void
      {
         var _loc3_:String = null;
         var _loc2_:TextLayoutFormatValueHolder = param1 as TextLayoutFormatValueHolder;
         if(_loc2_)
         {
            for(_loc3_ in _loc2_.coreStyles)
            {
               this[_loc3_] = TextLayoutFormat.tlf_internal::description[_loc3_].concatHelper(this[_loc3_],_loc2_.coreStyles[_loc3_]);
            }
            return;
         }
         this.color = TextLayoutFormat.tlf_internal::colorProperty.concatHelper(this.color,param1.color);
         this.backgroundColor = TextLayoutFormat.tlf_internal::backgroundColorProperty.concatHelper(this.backgroundColor,param1.backgroundColor);
         this.lineThrough = TextLayoutFormat.tlf_internal::lineThroughProperty.concatHelper(this.lineThrough,param1.lineThrough);
         this.textAlpha = TextLayoutFormat.tlf_internal::textAlphaProperty.concatHelper(this.textAlpha,param1.textAlpha);
         this.backgroundAlpha = TextLayoutFormat.tlf_internal::backgroundAlphaProperty.concatHelper(this.backgroundAlpha,param1.backgroundAlpha);
         this.fontSize = TextLayoutFormat.tlf_internal::fontSizeProperty.concatHelper(this.fontSize,param1.fontSize);
         this.baselineShift = TextLayoutFormat.tlf_internal::baselineShiftProperty.concatHelper(this.baselineShift,param1.baselineShift);
         this.trackingLeft = TextLayoutFormat.tlf_internal::trackingLeftProperty.concatHelper(this.trackingLeft,param1.trackingLeft);
         this.trackingRight = TextLayoutFormat.tlf_internal::trackingRightProperty.concatHelper(this.trackingRight,param1.trackingRight);
         this.lineHeight = TextLayoutFormat.tlf_internal::lineHeightProperty.concatHelper(this.lineHeight,param1.lineHeight);
         this.breakOpportunity = TextLayoutFormat.tlf_internal::breakOpportunityProperty.concatHelper(this.breakOpportunity,param1.breakOpportunity);
         this.digitCase = TextLayoutFormat.tlf_internal::digitCaseProperty.concatHelper(this.digitCase,param1.digitCase);
         this.digitWidth = TextLayoutFormat.tlf_internal::digitWidthProperty.concatHelper(this.digitWidth,param1.digitWidth);
         this.dominantBaseline = TextLayoutFormat.tlf_internal::dominantBaselineProperty.concatHelper(this.dominantBaseline,param1.dominantBaseline);
         this.kerning = TextLayoutFormat.tlf_internal::kerningProperty.concatHelper(this.kerning,param1.kerning);
         this.ligatureLevel = TextLayoutFormat.tlf_internal::ligatureLevelProperty.concatHelper(this.ligatureLevel,param1.ligatureLevel);
         this.alignmentBaseline = TextLayoutFormat.tlf_internal::alignmentBaselineProperty.concatHelper(this.alignmentBaseline,param1.alignmentBaseline);
         this.locale = TextLayoutFormat.tlf_internal::localeProperty.concatHelper(this.locale,param1.locale);
         this.typographicCase = TextLayoutFormat.tlf_internal::typographicCaseProperty.concatHelper(this.typographicCase,param1.typographicCase);
         this.fontFamily = TextLayoutFormat.tlf_internal::fontFamilyProperty.concatHelper(this.fontFamily,param1.fontFamily);
         this.textDecoration = TextLayoutFormat.tlf_internal::textDecorationProperty.concatHelper(this.textDecoration,param1.textDecoration);
         this.fontWeight = TextLayoutFormat.tlf_internal::fontWeightProperty.concatHelper(this.fontWeight,param1.fontWeight);
         this.fontStyle = TextLayoutFormat.tlf_internal::fontStyleProperty.concatHelper(this.fontStyle,param1.fontStyle);
         this.whiteSpaceCollapse = TextLayoutFormat.tlf_internal::whiteSpaceCollapseProperty.concatHelper(this.whiteSpaceCollapse,param1.whiteSpaceCollapse);
         this.renderingMode = TextLayoutFormat.tlf_internal::renderingModeProperty.concatHelper(this.renderingMode,param1.renderingMode);
         this.cffHinting = TextLayoutFormat.tlf_internal::cffHintingProperty.concatHelper(this.cffHinting,param1.cffHinting);
         this.fontLookup = TextLayoutFormat.tlf_internal::fontLookupProperty.concatHelper(this.fontLookup,param1.fontLookup);
         this.textRotation = TextLayoutFormat.tlf_internal::textRotationProperty.concatHelper(this.textRotation,param1.textRotation);
         this.textIndent = TextLayoutFormat.tlf_internal::textIndentProperty.concatHelper(this.textIndent,param1.textIndent);
         this.paragraphStartIndent = TextLayoutFormat.tlf_internal::paragraphStartIndentProperty.concatHelper(this.paragraphStartIndent,param1.paragraphStartIndent);
         this.paragraphEndIndent = TextLayoutFormat.tlf_internal::paragraphEndIndentProperty.concatHelper(this.paragraphEndIndent,param1.paragraphEndIndent);
         this.paragraphSpaceBefore = TextLayoutFormat.tlf_internal::paragraphSpaceBeforeProperty.concatHelper(this.paragraphSpaceBefore,param1.paragraphSpaceBefore);
         this.paragraphSpaceAfter = TextLayoutFormat.tlf_internal::paragraphSpaceAfterProperty.concatHelper(this.paragraphSpaceAfter,param1.paragraphSpaceAfter);
         this.textAlign = TextLayoutFormat.tlf_internal::textAlignProperty.concatHelper(this.textAlign,param1.textAlign);
         this.textAlignLast = TextLayoutFormat.tlf_internal::textAlignLastProperty.concatHelper(this.textAlignLast,param1.textAlignLast);
         this.textJustify = TextLayoutFormat.tlf_internal::textJustifyProperty.concatHelper(this.textJustify,param1.textJustify);
         this.justificationRule = TextLayoutFormat.tlf_internal::justificationRuleProperty.concatHelper(this.justificationRule,param1.justificationRule);
         this.justificationStyle = TextLayoutFormat.tlf_internal::justificationStyleProperty.concatHelper(this.justificationStyle,param1.justificationStyle);
         this.direction = TextLayoutFormat.tlf_internal::directionProperty.concatHelper(this.direction,param1.direction);
         this.tabStops = TextLayoutFormat.tlf_internal::tabStopsProperty.concatHelper(this.tabStops,param1.tabStops);
         this.leadingModel = TextLayoutFormat.tlf_internal::leadingModelProperty.concatHelper(this.leadingModel,param1.leadingModel);
         this.columnGap = TextLayoutFormat.tlf_internal::columnGapProperty.concatHelper(this.columnGap,param1.columnGap);
         this.paddingLeft = TextLayoutFormat.tlf_internal::paddingLeftProperty.concatHelper(this.paddingLeft,param1.paddingLeft);
         this.paddingTop = TextLayoutFormat.tlf_internal::paddingTopProperty.concatHelper(this.paddingTop,param1.paddingTop);
         this.paddingRight = TextLayoutFormat.tlf_internal::paddingRightProperty.concatHelper(this.paddingRight,param1.paddingRight);
         this.paddingBottom = TextLayoutFormat.tlf_internal::paddingBottomProperty.concatHelper(this.paddingBottom,param1.paddingBottom);
         this.columnCount = TextLayoutFormat.tlf_internal::columnCountProperty.concatHelper(this.columnCount,param1.columnCount);
         this.columnWidth = TextLayoutFormat.tlf_internal::columnWidthProperty.concatHelper(this.columnWidth,param1.columnWidth);
         this.firstBaselineOffset = TextLayoutFormat.tlf_internal::firstBaselineOffsetProperty.concatHelper(this.firstBaselineOffset,param1.firstBaselineOffset);
         this.verticalAlign = TextLayoutFormat.tlf_internal::verticalAlignProperty.concatHelper(this.verticalAlign,param1.verticalAlign);
         this.blockProgression = TextLayoutFormat.tlf_internal::blockProgressionProperty.concatHelper(this.blockProgression,param1.blockProgression);
         this.lineBreak = TextLayoutFormat.tlf_internal::lineBreakProperty.concatHelper(this.lineBreak,param1.lineBreak);
      }
      
      public function concatInheritOnly(param1:ITextLayoutFormat) : void
      {
         var _loc3_:String = null;
         var _loc2_:TextLayoutFormatValueHolder = param1 as TextLayoutFormatValueHolder;
         if(_loc2_)
         {
            for(_loc3_ in _loc2_.coreStyles)
            {
               this[_loc3_] = TextLayoutFormat.tlf_internal::description[_loc3_].concatInheritOnlyHelper(this[_loc3_],_loc2_.coreStyles[_loc3_]);
            }
            return;
         }
         this.color = TextLayoutFormat.tlf_internal::colorProperty.concatInheritOnlyHelper(this.color,param1.color);
         this.backgroundColor = TextLayoutFormat.tlf_internal::backgroundColorProperty.concatInheritOnlyHelper(this.backgroundColor,param1.backgroundColor);
         this.lineThrough = TextLayoutFormat.tlf_internal::lineThroughProperty.concatInheritOnlyHelper(this.lineThrough,param1.lineThrough);
         this.textAlpha = TextLayoutFormat.tlf_internal::textAlphaProperty.concatInheritOnlyHelper(this.textAlpha,param1.textAlpha);
         this.backgroundAlpha = TextLayoutFormat.tlf_internal::backgroundAlphaProperty.concatInheritOnlyHelper(this.backgroundAlpha,param1.backgroundAlpha);
         this.fontSize = TextLayoutFormat.tlf_internal::fontSizeProperty.concatInheritOnlyHelper(this.fontSize,param1.fontSize);
         this.baselineShift = TextLayoutFormat.tlf_internal::baselineShiftProperty.concatInheritOnlyHelper(this.baselineShift,param1.baselineShift);
         this.trackingLeft = TextLayoutFormat.tlf_internal::trackingLeftProperty.concatInheritOnlyHelper(this.trackingLeft,param1.trackingLeft);
         this.trackingRight = TextLayoutFormat.tlf_internal::trackingRightProperty.concatInheritOnlyHelper(this.trackingRight,param1.trackingRight);
         this.lineHeight = TextLayoutFormat.tlf_internal::lineHeightProperty.concatInheritOnlyHelper(this.lineHeight,param1.lineHeight);
         this.breakOpportunity = TextLayoutFormat.tlf_internal::breakOpportunityProperty.concatInheritOnlyHelper(this.breakOpportunity,param1.breakOpportunity);
         this.digitCase = TextLayoutFormat.tlf_internal::digitCaseProperty.concatInheritOnlyHelper(this.digitCase,param1.digitCase);
         this.digitWidth = TextLayoutFormat.tlf_internal::digitWidthProperty.concatInheritOnlyHelper(this.digitWidth,param1.digitWidth);
         this.dominantBaseline = TextLayoutFormat.tlf_internal::dominantBaselineProperty.concatInheritOnlyHelper(this.dominantBaseline,param1.dominantBaseline);
         this.kerning = TextLayoutFormat.tlf_internal::kerningProperty.concatInheritOnlyHelper(this.kerning,param1.kerning);
         this.ligatureLevel = TextLayoutFormat.tlf_internal::ligatureLevelProperty.concatInheritOnlyHelper(this.ligatureLevel,param1.ligatureLevel);
         this.alignmentBaseline = TextLayoutFormat.tlf_internal::alignmentBaselineProperty.concatInheritOnlyHelper(this.alignmentBaseline,param1.alignmentBaseline);
         this.locale = TextLayoutFormat.tlf_internal::localeProperty.concatInheritOnlyHelper(this.locale,param1.locale);
         this.typographicCase = TextLayoutFormat.tlf_internal::typographicCaseProperty.concatInheritOnlyHelper(this.typographicCase,param1.typographicCase);
         this.fontFamily = TextLayoutFormat.tlf_internal::fontFamilyProperty.concatInheritOnlyHelper(this.fontFamily,param1.fontFamily);
         this.textDecoration = TextLayoutFormat.tlf_internal::textDecorationProperty.concatInheritOnlyHelper(this.textDecoration,param1.textDecoration);
         this.fontWeight = TextLayoutFormat.tlf_internal::fontWeightProperty.concatInheritOnlyHelper(this.fontWeight,param1.fontWeight);
         this.fontStyle = TextLayoutFormat.tlf_internal::fontStyleProperty.concatInheritOnlyHelper(this.fontStyle,param1.fontStyle);
         this.whiteSpaceCollapse = TextLayoutFormat.tlf_internal::whiteSpaceCollapseProperty.concatInheritOnlyHelper(this.whiteSpaceCollapse,param1.whiteSpaceCollapse);
         this.renderingMode = TextLayoutFormat.tlf_internal::renderingModeProperty.concatInheritOnlyHelper(this.renderingMode,param1.renderingMode);
         this.cffHinting = TextLayoutFormat.tlf_internal::cffHintingProperty.concatInheritOnlyHelper(this.cffHinting,param1.cffHinting);
         this.fontLookup = TextLayoutFormat.tlf_internal::fontLookupProperty.concatInheritOnlyHelper(this.fontLookup,param1.fontLookup);
         this.textRotation = TextLayoutFormat.tlf_internal::textRotationProperty.concatInheritOnlyHelper(this.textRotation,param1.textRotation);
         this.textIndent = TextLayoutFormat.tlf_internal::textIndentProperty.concatInheritOnlyHelper(this.textIndent,param1.textIndent);
         this.paragraphStartIndent = TextLayoutFormat.tlf_internal::paragraphStartIndentProperty.concatInheritOnlyHelper(this.paragraphStartIndent,param1.paragraphStartIndent);
         this.paragraphEndIndent = TextLayoutFormat.tlf_internal::paragraphEndIndentProperty.concatInheritOnlyHelper(this.paragraphEndIndent,param1.paragraphEndIndent);
         this.paragraphSpaceBefore = TextLayoutFormat.tlf_internal::paragraphSpaceBeforeProperty.concatInheritOnlyHelper(this.paragraphSpaceBefore,param1.paragraphSpaceBefore);
         this.paragraphSpaceAfter = TextLayoutFormat.tlf_internal::paragraphSpaceAfterProperty.concatInheritOnlyHelper(this.paragraphSpaceAfter,param1.paragraphSpaceAfter);
         this.textAlign = TextLayoutFormat.tlf_internal::textAlignProperty.concatInheritOnlyHelper(this.textAlign,param1.textAlign);
         this.textAlignLast = TextLayoutFormat.tlf_internal::textAlignLastProperty.concatInheritOnlyHelper(this.textAlignLast,param1.textAlignLast);
         this.textJustify = TextLayoutFormat.tlf_internal::textJustifyProperty.concatInheritOnlyHelper(this.textJustify,param1.textJustify);
         this.justificationRule = TextLayoutFormat.tlf_internal::justificationRuleProperty.concatInheritOnlyHelper(this.justificationRule,param1.justificationRule);
         this.justificationStyle = TextLayoutFormat.tlf_internal::justificationStyleProperty.concatInheritOnlyHelper(this.justificationStyle,param1.justificationStyle);
         this.direction = TextLayoutFormat.tlf_internal::directionProperty.concatInheritOnlyHelper(this.direction,param1.direction);
         this.tabStops = TextLayoutFormat.tlf_internal::tabStopsProperty.concatInheritOnlyHelper(this.tabStops,param1.tabStops);
         this.leadingModel = TextLayoutFormat.tlf_internal::leadingModelProperty.concatInheritOnlyHelper(this.leadingModel,param1.leadingModel);
         this.columnGap = TextLayoutFormat.tlf_internal::columnGapProperty.concatInheritOnlyHelper(this.columnGap,param1.columnGap);
         this.paddingLeft = TextLayoutFormat.tlf_internal::paddingLeftProperty.concatInheritOnlyHelper(this.paddingLeft,param1.paddingLeft);
         this.paddingTop = TextLayoutFormat.tlf_internal::paddingTopProperty.concatInheritOnlyHelper(this.paddingTop,param1.paddingTop);
         this.paddingRight = TextLayoutFormat.tlf_internal::paddingRightProperty.concatInheritOnlyHelper(this.paddingRight,param1.paddingRight);
         this.paddingBottom = TextLayoutFormat.tlf_internal::paddingBottomProperty.concatInheritOnlyHelper(this.paddingBottom,param1.paddingBottom);
         this.columnCount = TextLayoutFormat.tlf_internal::columnCountProperty.concatInheritOnlyHelper(this.columnCount,param1.columnCount);
         this.columnWidth = TextLayoutFormat.tlf_internal::columnWidthProperty.concatInheritOnlyHelper(this.columnWidth,param1.columnWidth);
         this.firstBaselineOffset = TextLayoutFormat.tlf_internal::firstBaselineOffsetProperty.concatInheritOnlyHelper(this.firstBaselineOffset,param1.firstBaselineOffset);
         this.verticalAlign = TextLayoutFormat.tlf_internal::verticalAlignProperty.concatInheritOnlyHelper(this.verticalAlign,param1.verticalAlign);
         this.blockProgression = TextLayoutFormat.tlf_internal::blockProgressionProperty.concatInheritOnlyHelper(this.blockProgression,param1.blockProgression);
         this.lineBreak = TextLayoutFormat.tlf_internal::lineBreakProperty.concatInheritOnlyHelper(this.lineBreak,param1.lineBreak);
      }
      
      public function apply(param1:ITextLayoutFormat) : void
      {
         var _loc3_:* = undefined;
         var _loc4_:String = null;
         var _loc2_:TextLayoutFormatValueHolder = param1 as TextLayoutFormatValueHolder;
         if(_loc2_)
         {
            for(_loc4_ in _loc2_.coreStyles)
            {
               this[_loc4_] = _loc2_.coreStyles[_loc4_];
            }
            return;
         }
         _loc3_ = param1.color;
         if(_loc3_ !== undefined)
         {
            this.color = _loc3_;
         }
         _loc3_ = param1.backgroundColor;
         if(_loc3_ !== undefined)
         {
            this.backgroundColor = _loc3_;
         }
         _loc3_ = param1.lineThrough;
         if(_loc3_ !== undefined)
         {
            this.lineThrough = _loc3_;
         }
         _loc3_ = param1.textAlpha;
         if(_loc3_ !== undefined)
         {
            this.textAlpha = _loc3_;
         }
         _loc3_ = param1.backgroundAlpha;
         if(_loc3_ !== undefined)
         {
            this.backgroundAlpha = _loc3_;
         }
         _loc3_ = param1.fontSize;
         if(_loc3_ !== undefined)
         {
            this.fontSize = _loc3_;
         }
         _loc3_ = param1.baselineShift;
         if(_loc3_ !== undefined)
         {
            this.baselineShift = _loc3_;
         }
         _loc3_ = param1.trackingLeft;
         if(_loc3_ !== undefined)
         {
            this.trackingLeft = _loc3_;
         }
         _loc3_ = param1.trackingRight;
         if(_loc3_ !== undefined)
         {
            this.trackingRight = _loc3_;
         }
         _loc3_ = param1.lineHeight;
         if(_loc3_ !== undefined)
         {
            this.lineHeight = _loc3_;
         }
         _loc3_ = param1.breakOpportunity;
         if(_loc3_ !== undefined)
         {
            this.breakOpportunity = _loc3_;
         }
         _loc3_ = param1.digitCase;
         if(_loc3_ !== undefined)
         {
            this.digitCase = _loc3_;
         }
         _loc3_ = param1.digitWidth;
         if(_loc3_ !== undefined)
         {
            this.digitWidth = _loc3_;
         }
         _loc3_ = param1.dominantBaseline;
         if(_loc3_ !== undefined)
         {
            this.dominantBaseline = _loc3_;
         }
         _loc3_ = param1.kerning;
         if(_loc3_ !== undefined)
         {
            this.kerning = _loc3_;
         }
         _loc3_ = param1.ligatureLevel;
         if(_loc3_ !== undefined)
         {
            this.ligatureLevel = _loc3_;
         }
         _loc3_ = param1.alignmentBaseline;
         if(_loc3_ !== undefined)
         {
            this.alignmentBaseline = _loc3_;
         }
         _loc3_ = param1.locale;
         if(_loc3_ !== undefined)
         {
            this.locale = _loc3_;
         }
         _loc3_ = param1.typographicCase;
         if(_loc3_ !== undefined)
         {
            this.typographicCase = _loc3_;
         }
         _loc3_ = param1.fontFamily;
         if(_loc3_ !== undefined)
         {
            this.fontFamily = _loc3_;
         }
         _loc3_ = param1.textDecoration;
         if(_loc3_ !== undefined)
         {
            this.textDecoration = _loc3_;
         }
         _loc3_ = param1.fontWeight;
         if(_loc3_ !== undefined)
         {
            this.fontWeight = _loc3_;
         }
         _loc3_ = param1.fontStyle;
         if(_loc3_ !== undefined)
         {
            this.fontStyle = _loc3_;
         }
         _loc3_ = param1.whiteSpaceCollapse;
         if(_loc3_ !== undefined)
         {
            this.whiteSpaceCollapse = _loc3_;
         }
         _loc3_ = param1.renderingMode;
         if(_loc3_ !== undefined)
         {
            this.renderingMode = _loc3_;
         }
         _loc3_ = param1.cffHinting;
         if(_loc3_ !== undefined)
         {
            this.cffHinting = _loc3_;
         }
         _loc3_ = param1.fontLookup;
         if(_loc3_ !== undefined)
         {
            this.fontLookup = _loc3_;
         }
         _loc3_ = param1.textRotation;
         if(_loc3_ !== undefined)
         {
            this.textRotation = _loc3_;
         }
         _loc3_ = param1.textIndent;
         if(_loc3_ !== undefined)
         {
            this.textIndent = _loc3_;
         }
         _loc3_ = param1.paragraphStartIndent;
         if(_loc3_ !== undefined)
         {
            this.paragraphStartIndent = _loc3_;
         }
         _loc3_ = param1.paragraphEndIndent;
         if(_loc3_ !== undefined)
         {
            this.paragraphEndIndent = _loc3_;
         }
         _loc3_ = param1.paragraphSpaceBefore;
         if(_loc3_ !== undefined)
         {
            this.paragraphSpaceBefore = _loc3_;
         }
         _loc3_ = param1.paragraphSpaceAfter;
         if(_loc3_ !== undefined)
         {
            this.paragraphSpaceAfter = _loc3_;
         }
         _loc3_ = param1.textAlign;
         if(_loc3_ !== undefined)
         {
            this.textAlign = _loc3_;
         }
         _loc3_ = param1.textAlignLast;
         if(_loc3_ !== undefined)
         {
            this.textAlignLast = _loc3_;
         }
         _loc3_ = param1.textJustify;
         if(_loc3_ !== undefined)
         {
            this.textJustify = _loc3_;
         }
         _loc3_ = param1.justificationRule;
         if(_loc3_ !== undefined)
         {
            this.justificationRule = _loc3_;
         }
         _loc3_ = param1.justificationStyle;
         if(_loc3_ !== undefined)
         {
            this.justificationStyle = _loc3_;
         }
         _loc3_ = param1.direction;
         if(_loc3_ !== undefined)
         {
            this.direction = _loc3_;
         }
         _loc3_ = param1.tabStops;
         if(_loc3_ !== undefined)
         {
            this.tabStops = _loc3_;
         }
         _loc3_ = param1.leadingModel;
         if(_loc3_ !== undefined)
         {
            this.leadingModel = _loc3_;
         }
         _loc3_ = param1.columnGap;
         if(_loc3_ !== undefined)
         {
            this.columnGap = _loc3_;
         }
         _loc3_ = param1.paddingLeft;
         if(_loc3_ !== undefined)
         {
            this.paddingLeft = _loc3_;
         }
         _loc3_ = param1.paddingTop;
         if(_loc3_ !== undefined)
         {
            this.paddingTop = _loc3_;
         }
         _loc3_ = param1.paddingRight;
         if(_loc3_ !== undefined)
         {
            this.paddingRight = _loc3_;
         }
         _loc3_ = param1.paddingBottom;
         if(_loc3_ !== undefined)
         {
            this.paddingBottom = _loc3_;
         }
         _loc3_ = param1.columnCount;
         if(_loc3_ !== undefined)
         {
            this.columnCount = _loc3_;
         }
         _loc3_ = param1.columnWidth;
         if(_loc3_ !== undefined)
         {
            this.columnWidth = _loc3_;
         }
         _loc3_ = param1.firstBaselineOffset;
         if(_loc3_ !== undefined)
         {
            this.firstBaselineOffset = _loc3_;
         }
         _loc3_ = param1.verticalAlign;
         if(_loc3_ !== undefined)
         {
            this.verticalAlign = _loc3_;
         }
         _loc3_ = param1.blockProgression;
         if(_loc3_ !== undefined)
         {
            this.blockProgression = _loc3_;
         }
         _loc3_ = param1.lineBreak;
         if(_loc3_ !== undefined)
         {
            this.lineBreak = _loc3_;
         }
      }
      
      public function get color() : *
      {
         return this.getCoreStyle("color");
      }
      
      public function set color(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::colorProperty,this.color,param1);
      }
      
      public function get backgroundColor() : *
      {
         return this.getCoreStyle("backgroundColor");
      }
      
      public function set backgroundColor(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::backgroundColorProperty,this.backgroundColor,param1);
      }
      
      public function get lineThrough() : *
      {
         return this.getCoreStyle("lineThrough");
      }
      
      public function set lineThrough(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::lineThroughProperty,this.lineThrough,param1);
      }
      
      public function get textAlpha() : *
      {
         return this.getCoreStyle("textAlpha");
      }
      
      public function set textAlpha(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::textAlphaProperty,this.textAlpha,param1);
      }
      
      public function get backgroundAlpha() : *
      {
         return this.getCoreStyle("backgroundAlpha");
      }
      
      public function set backgroundAlpha(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::backgroundAlphaProperty,this.backgroundAlpha,param1);
      }
      
      public function get fontSize() : *
      {
         return this.getCoreStyle("fontSize");
      }
      
      public function set fontSize(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::fontSizeProperty,this.fontSize,param1);
      }
      
      public function get baselineShift() : *
      {
         return this.getCoreStyle("baselineShift");
      }
      
      public function set baselineShift(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::baselineShiftProperty,this.baselineShift,param1);
      }
      
      public function get trackingLeft() : *
      {
         return this.getCoreStyle("trackingLeft");
      }
      
      public function set trackingLeft(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::trackingLeftProperty,this.trackingLeft,param1);
      }
      
      public function get trackingRight() : *
      {
         return this.getCoreStyle("trackingRight");
      }
      
      public function set trackingRight(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::trackingRightProperty,this.trackingRight,param1);
      }
      
      public function get lineHeight() : *
      {
         return this.getCoreStyle("lineHeight");
      }
      
      public function set lineHeight(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::lineHeightProperty,this.lineHeight,param1);
      }
      
      public function get breakOpportunity() : *
      {
         return this.getCoreStyle("breakOpportunity");
      }
      
      public function set breakOpportunity(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::breakOpportunityProperty,this.breakOpportunity,param1);
      }
      
      public function get digitCase() : *
      {
         return this.getCoreStyle("digitCase");
      }
      
      public function set digitCase(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::digitCaseProperty,this.digitCase,param1);
      }
      
      public function get digitWidth() : *
      {
         return this.getCoreStyle("digitWidth");
      }
      
      public function set digitWidth(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::digitWidthProperty,this.digitWidth,param1);
      }
      
      public function get dominantBaseline() : *
      {
         return this.getCoreStyle("dominantBaseline");
      }
      
      public function set dominantBaseline(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::dominantBaselineProperty,this.dominantBaseline,param1);
      }
      
      public function get kerning() : *
      {
         return this.getCoreStyle("kerning");
      }
      
      public function set kerning(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::kerningProperty,this.kerning,param1);
      }
      
      public function get ligatureLevel() : *
      {
         return this.getCoreStyle("ligatureLevel");
      }
      
      public function set ligatureLevel(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::ligatureLevelProperty,this.ligatureLevel,param1);
      }
      
      public function get alignmentBaseline() : *
      {
         return this.getCoreStyle("alignmentBaseline");
      }
      
      public function set alignmentBaseline(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::alignmentBaselineProperty,this.alignmentBaseline,param1);
      }
      
      public function get locale() : *
      {
         return this.getCoreStyle("locale");
      }
      
      public function set locale(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::localeProperty,this.locale,param1);
      }
      
      public function get typographicCase() : *
      {
         return this.getCoreStyle("typographicCase");
      }
      
      public function set typographicCase(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::typographicCaseProperty,this.typographicCase,param1);
      }
      
      public function get fontFamily() : *
      {
         return this.getCoreStyle("fontFamily");
      }
      
      public function set fontFamily(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::fontFamilyProperty,this.fontFamily,param1);
      }
      
      public function get textDecoration() : *
      {
         return this.getCoreStyle("textDecoration");
      }
      
      public function set textDecoration(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::textDecorationProperty,this.textDecoration,param1);
      }
      
      public function get fontWeight() : *
      {
         return this.getCoreStyle("fontWeight");
      }
      
      public function set fontWeight(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::fontWeightProperty,this.fontWeight,param1);
      }
      
      public function get fontStyle() : *
      {
         return this.getCoreStyle("fontStyle");
      }
      
      public function set fontStyle(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::fontStyleProperty,this.fontStyle,param1);
      }
      
      public function get whiteSpaceCollapse() : *
      {
         return this.getCoreStyle("whiteSpaceCollapse");
      }
      
      public function set whiteSpaceCollapse(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::whiteSpaceCollapseProperty,this.whiteSpaceCollapse,param1);
      }
      
      public function get renderingMode() : *
      {
         return this.getCoreStyle("renderingMode");
      }
      
      public function set renderingMode(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::renderingModeProperty,this.renderingMode,param1);
      }
      
      public function get cffHinting() : *
      {
         return this.getCoreStyle("cffHinting");
      }
      
      public function set cffHinting(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::cffHintingProperty,this.cffHinting,param1);
      }
      
      public function get fontLookup() : *
      {
         return this.getCoreStyle("fontLookup");
      }
      
      public function set fontLookup(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::fontLookupProperty,this.fontLookup,param1);
      }
      
      public function get textRotation() : *
      {
         return this.getCoreStyle("textRotation");
      }
      
      public function set textRotation(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::textRotationProperty,this.textRotation,param1);
      }
      
      public function get textIndent() : *
      {
         return this.getCoreStyle("textIndent");
      }
      
      public function set textIndent(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::textIndentProperty,this.textIndent,param1);
      }
      
      public function get paragraphStartIndent() : *
      {
         return this.getCoreStyle("paragraphStartIndent");
      }
      
      public function set paragraphStartIndent(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::paragraphStartIndentProperty,this.paragraphStartIndent,param1);
      }
      
      public function get paragraphEndIndent() : *
      {
         return this.getCoreStyle("paragraphEndIndent");
      }
      
      public function set paragraphEndIndent(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::paragraphEndIndentProperty,this.paragraphEndIndent,param1);
      }
      
      public function get paragraphSpaceBefore() : *
      {
         return this.getCoreStyle("paragraphSpaceBefore");
      }
      
      public function set paragraphSpaceBefore(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::paragraphSpaceBeforeProperty,this.paragraphSpaceBefore,param1);
      }
      
      public function get paragraphSpaceAfter() : *
      {
         return this.getCoreStyle("paragraphSpaceAfter");
      }
      
      public function set paragraphSpaceAfter(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::paragraphSpaceAfterProperty,this.paragraphSpaceAfter,param1);
      }
      
      public function get textAlign() : *
      {
         return this.getCoreStyle("textAlign");
      }
      
      public function set textAlign(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::textAlignProperty,this.textAlign,param1);
      }
      
      public function get textAlignLast() : *
      {
         return this.getCoreStyle("textAlignLast");
      }
      
      public function set textAlignLast(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::textAlignLastProperty,this.textAlignLast,param1);
      }
      
      public function get textJustify() : *
      {
         return this.getCoreStyle("textJustify");
      }
      
      public function set textJustify(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::textJustifyProperty,this.textJustify,param1);
      }
      
      public function get justificationRule() : *
      {
         return this.getCoreStyle("justificationRule");
      }
      
      public function set justificationRule(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::justificationRuleProperty,this.justificationRule,param1);
      }
      
      public function get justificationStyle() : *
      {
         return this.getCoreStyle("justificationStyle");
      }
      
      public function set justificationStyle(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::justificationStyleProperty,this.justificationStyle,param1);
      }
      
      public function get direction() : *
      {
         return this.getCoreStyle("direction");
      }
      
      public function set direction(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::directionProperty,this.direction,param1);
      }
      
      public function get tabStops() : *
      {
         return this.getCoreStyle("tabStops");
      }
      
      public function set tabStops(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::tabStopsProperty,this.tabStops,param1);
      }
      
      public function get leadingModel() : *
      {
         return this.getCoreStyle("leadingModel");
      }
      
      public function set leadingModel(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::leadingModelProperty,this.leadingModel,param1);
      }
      
      public function get columnGap() : *
      {
         return this.getCoreStyle("columnGap");
      }
      
      public function set columnGap(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::columnGapProperty,this.columnGap,param1);
      }
      
      public function get paddingLeft() : *
      {
         return this.getCoreStyle("paddingLeft");
      }
      
      public function set paddingLeft(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::paddingLeftProperty,this.paddingLeft,param1);
      }
      
      public function get paddingTop() : *
      {
         return this.getCoreStyle("paddingTop");
      }
      
      public function set paddingTop(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::paddingTopProperty,this.paddingTop,param1);
      }
      
      public function get paddingRight() : *
      {
         return this.getCoreStyle("paddingRight");
      }
      
      public function set paddingRight(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::paddingRightProperty,this.paddingRight,param1);
      }
      
      public function get paddingBottom() : *
      {
         return this.getCoreStyle("paddingBottom");
      }
      
      public function set paddingBottom(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::paddingBottomProperty,this.paddingBottom,param1);
      }
      
      public function get columnCount() : *
      {
         return this.getCoreStyle("columnCount");
      }
      
      public function set columnCount(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::columnCountProperty,this.columnCount,param1);
      }
      
      public function get columnWidth() : *
      {
         return this.getCoreStyle("columnWidth");
      }
      
      public function set columnWidth(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::columnWidthProperty,this.columnWidth,param1);
      }
      
      public function get firstBaselineOffset() : *
      {
         return this.getCoreStyle("firstBaselineOffset");
      }
      
      public function set firstBaselineOffset(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::firstBaselineOffsetProperty,this.firstBaselineOffset,param1);
      }
      
      public function get verticalAlign() : *
      {
         return this.getCoreStyle("verticalAlign");
      }
      
      public function set verticalAlign(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::verticalAlignProperty,this.verticalAlign,param1);
      }
      
      public function get blockProgression() : *
      {
         return this.getCoreStyle("blockProgression");
      }
      
      public function set blockProgression(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::blockProgressionProperty,this.blockProgression,param1);
      }
      
      public function get lineBreak() : *
      {
         return this.getCoreStyle("lineBreak");
      }
      
      public function set lineBreak(param1:*) : void
      {
         this.setCoreStyle(TextLayoutFormat.tlf_internal::lineBreakProperty,this.lineBreak,param1);
      }
   }
}

