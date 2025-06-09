package flashachtung_fla
{
   import fl.motion.AnimatorFactory;
   import fl.motion.Motion;
   import fl.motion.MotionBase;
   import fl.motion.motion_internal;
   import fl.text.RuntimeManager;
   import fl.text.TLFTextField;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.text.Font;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol132")]
   public dynamic class home_mc_1 extends MovieClip
   {
      
      public var achtung_mc:achtung_tpl;
      
      public var help_btn:SimpleButton;
      
      public var control_mc:MovieClip;
      
      public var movie:MovieClip;
      
      public var arcadeBtn:SimpleButton;
      
      public var version_txt:TextField;
      
      public var __id6_:MovieClip;
      
      public var __id7_:TLFTextField;
      
      public var classicBtn:SimpleButton;
      
      public var __id4_:MovieClip;
      
      public var __id5_:TLFTextField;
      
      public var soundManager_mc:soundManager;
      
      public var __id8_:MovieClip;
      
      public var startGameBtn:SimpleButton;
      
      public var __id9_:TLFTextField;
      
      public var __cacheXMLSettings:Object;
      
      public var __animFactory___id5_af1:AnimatorFactory;
      
      public var __animArray___id5_af1:Array;
      
      public var ____motion___id5_af1_matArray__:Array;
      
      public var __motion___id5_af1:MotionBase;
      
      public var __animFactory___id7_af1:AnimatorFactory;
      
      public var __animArray___id7_af1:Array;
      
      public var ____motion___id7_af1_matArray__:Array;
      
      public var __motion___id7_af1:MotionBase;
      
      public var __animFactory___id9_af1:AnimatorFactory;
      
      public var __animArray___id9_af1:Array;
      
      public var ____motion___id9_af1_matArray__:Array;
      
      public var __motion___id9_af1:MotionBase;
      
      public function home_mc_1()
      {
         super();
         this.__cacheXMLSettings = XML.settings();
         try
         {
            XML.ignoreProcessingInstructions = false;
            XML.ignoreWhitespace = false;
            XML.prettyPrinting = false;
            RuntimeManager.getSingleton().addInstance(this,"__id5_",new Rectangle(0,0,269.95,27.35),<tlfTextObject type="Point" editPolicy="readOnly" columnCount="1" columnGap="20" verticalAlign="top" firstBaselineOffset="auto" paddingLeft="2" paddingTop="2" paddingRight="2" paddingBottom="2" background="false" backgroundColor="#ffffff" backgroundAlpha="1" border="false" borderColor="#000000" borderAlpha="1" borderWidth="1" paddingLock="false" multiline="true" antiAliasType="advanced" embedFonts="true"><TextFlow blockProgression="tb" columnCount="inherit" columnGap="inherit" columnWidth="inherit" lineBreak="explicit" locale="en_GB" paddingBottom="inherit" paddingLeft="inherit" paddingRight="inherit" paddingTop="inherit" verticalAlign="inherit" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p direction="ltr" paragraphEndIndent="0" paragraphSpaceAfter="0" paragraphSpaceBefore="0" paragraphStartIndent="0" textAlign="start" textAlignLast="start" textIndent="0" textJustify="interWord"><span color="#ffff00" fontFamily="Segoe Print" fontSize="20" fontStyle="normal" fontWeight="normal" kerning="auto" lineHeight="137.5%" textAlpha="1" textRotation="auto" trackingRight="0%">2) Select your game mode</span></p></TextFlow></tlfTextObject>
            ,null,undefined,0,0,"home_mc");
            RuntimeManager.getSingleton().addInstance(this,"__id7_",new Rectangle(0,0,94.25,27.35),<tlfTextObject type="Point" editPolicy="readOnly" columnCount="1" columnGap="20" verticalAlign="top" firstBaselineOffset="auto" paddingLeft="2" paddingTop="2" paddingRight="2" paddingBottom="2" background="false" backgroundColor="#ffffff" backgroundAlpha="1" border="false" borderColor="#000000" borderAlpha="1" borderWidth="1" paddingLock="false" multiline="true" antiAliasType="advanced" embedFonts="true"><TextFlow blockProgression="tb" columnCount="inherit" columnGap="inherit" columnWidth="inherit" lineBreak="explicit" locale="en_GB" paddingBottom="inherit" paddingLeft="inherit" paddingRight="inherit" paddingTop="inherit" verticalAlign="inherit" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p direction="ltr" paragraphEndIndent="0" paragraphSpaceAfter="0" paragraphSpaceBefore="0" paragraphStartIndent="0" textAlign="start" textAlignLast="start" textIndent="0" textJustify="interWord"><span color="#ffff00" fontFamily="Segoe Print" fontSize="20" fontStyle="normal" fontWeight="normal" kerning="auto" lineHeight="137.5%" textAlpha="1" textRotation="auto" trackingRight="0%">3) Start!</span></p></TextFlow></tlfTextObject>
            ,null,undefined,0,0,"home_mc");
            RuntimeManager.getSingleton().addInstance(this,"__id9_",new Rectangle(0,0,335.35,27.35),<tlfTextObject type="Point" editPolicy="readOnly" columnCount="1" columnGap="20" verticalAlign="top" firstBaselineOffset="auto" paddingLeft="2" paddingTop="2" paddingRight="2" paddingBottom="2" background="false" backgroundColor="#ffffff" backgroundAlpha="1" border="false" borderColor="#000000" borderAlpha="1" borderWidth="1" paddingLock="false" multiline="true" antiAliasType="advanced" embedFonts="true"><TextFlow blockProgression="tb" columnCount="inherit" columnGap="inherit" columnWidth="inherit" lineBreak="explicit" locale="en_GB" paddingBottom="inherit" paddingLeft="inherit" paddingRight="inherit" paddingTop="inherit" verticalAlign="inherit" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p direction="ltr" paragraphEndIndent="0" paragraphSpaceAfter="0" paragraphSpaceBefore="0" paragraphStartIndent="0" textAlign="start" textAlignLast="start" textIndent="0" textJustify="interWord"><span color="#ffff00" fontFamily="Segoe Print" fontSize="20" fontStyle="normal" fontWeight="normal" kerning="auto" lineHeight="137.5%" textAlpha="1" textRotation="auto" trackingRight="0%">1) Select your players (and keys)</span></p></TextFlow></tlfTextObject>
            ,null,undefined,0,0,"home_mc");
            Font.registerFont(Font4);
         }
         finally
         {
            XML.setSettings(this.__cacheXMLSettings);
         }
         RuntimeManager.getSingleton().addInstanceComplete(this);
         if(this.__animFactory___id5_af1 == null)
         {
            this.__animArray___id5_af1 = new Array();
            this.__motion___id5_af1 = new Motion();
            this.__motion___id5_af1.duration = 1;
            this.__motion___id5_af1.overrideTargetTransform();
            this.__motion___id5_af1.addPropertyArray("cacheAsBitmap",[false]);
            this.__motion___id5_af1.addPropertyArray("blendMode",["normal"]);
            this.__motion___id5_af1.motion_internal::spanStart = 0;
            this.____motion___id5_af1_matArray__ = new Array();
            this.____motion___id5_af1_matArray__.push(new Matrix(0.992081,-0.125595,0.125595,0.992081,-507.05,564.5));
            this.__motion___id5_af1.addPropertyArray("matrix",this.____motion___id5_af1_matArray__);
            this.__animArray___id5_af1.push(this.__motion___id5_af1);
            this.__animFactory___id5_af1 = new AnimatorFactory(null,this.__animArray___id5_af1);
            this.__animFactory___id5_af1.sceneName = "home_mc";
            this.__animFactory___id5_af1.addTargetInfo(this,"__id5_",0,true,0,true,null,-1,"__id4_",RuntimeManager);
         }
         if(this.__animFactory___id7_af1 == null)
         {
            this.__animArray___id7_af1 = new Array();
            this.__motion___id7_af1 = new Motion();
            this.__motion___id7_af1.duration = 1;
            this.__motion___id7_af1.overrideTargetTransform();
            this.__motion___id7_af1.addPropertyArray("cacheAsBitmap",[false]);
            this.__motion___id7_af1.addPropertyArray("blendMode",["normal"]);
            this.__motion___id7_af1.motion_internal::spanStart = 0;
            this.____motion___id7_af1_matArray__ = new Array();
            this.____motion___id7_af1_matArray__.push(new Matrix(1,0,0,1,-495.65,636.85));
            this.__motion___id7_af1.addPropertyArray("matrix",this.____motion___id7_af1_matArray__);
            this.__animArray___id7_af1.push(this.__motion___id7_af1);
            this.__animFactory___id7_af1 = new AnimatorFactory(null,this.__animArray___id7_af1);
            this.__animFactory___id7_af1.sceneName = "home_mc";
            this.__animFactory___id7_af1.addTargetInfo(this,"__id7_",0,true,0,true,null,-1,"__id6_",RuntimeManager);
         }
         if(this.__animFactory___id9_af1 == null)
         {
            this.__animArray___id9_af1 = new Array();
            this.__motion___id9_af1 = new Motion();
            this.__motion___id9_af1.duration = 1;
            this.__motion___id9_af1.overrideTargetTransform();
            this.__motion___id9_af1.addPropertyArray("cacheAsBitmap",[false]);
            this.__motion___id9_af1.addPropertyArray("blendMode",["normal"]);
            this.__motion___id9_af1.motion_internal::spanStart = 0;
            this.____motion___id9_af1_matArray__ = new Array();
            this.____motion___id9_af1_matArray__.push(new Matrix(0.992081,-0.125595,0.125595,0.992081,-506.75,115.15));
            this.__motion___id9_af1.addPropertyArray("matrix",this.____motion___id9_af1_matArray__);
            this.__animArray___id9_af1.push(this.__motion___id9_af1);
            this.__animFactory___id9_af1 = new AnimatorFactory(null,this.__animArray___id9_af1);
            this.__animFactory___id9_af1.sceneName = "home_mc";
            this.__animFactory___id9_af1.addTargetInfo(this,"__id9_",0,true,0,true,null,-1,"__id8_",RuntimeManager);
         }
      }
   }
}

