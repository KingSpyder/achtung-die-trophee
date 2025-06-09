package flashachtung_fla
{
   import adobe.utils.*;
   import fl.motion.AnimatorFactory;
   import fl.motion.Motion;
   import fl.motion.MotionBase;
   import fl.motion.motion_internal;
   import fl.text.RuntimeManager;
   import fl.text.TLFTextField;
   import flash.accessibility.*;
   import flash.desktop.*;
   import flash.display.*;
   import flash.errors.*;
   import flash.events.*;
   import flash.external.*;
   import flash.filters.*;
   import flash.geom.*;
   import flash.globalization.*;
   import flash.media.*;
   import flash.net.*;
   import flash.net.drm.*;
   import flash.printing.*;
   import flash.profiler.*;
   import flash.sampler.*;
   import flash.sensors.*;
   import flash.system.*;
   import flash.text.*;
   import flash.text.engine.*;
   import flash.text.ime.*;
   import flash.ui.*;
   import flash.utils.*;
   import flash.xml.*;
   import mochi.as3.*;
   
   public dynamic class MainTimeline extends MovieClip
   {
      
      public var __id2_:MovieClip;
      
      public var ingame_mc:MovieClip;
      
      public var __id3_:TLFTextField;
      
      public var __id0_:MovieClip;
      
      public var __id1_:TLFTextField;
      
      public var home_mc:MovieClip;
      
      public var mcHelp:help_mc;
      
      public var version:String;
      
      public var sub_version:String;
      
      public var add:Boolean;
      
      public var add_version:String;
      
      public var _mochiads_game_id:String;
      
      public var game:Game;
      
      public var homeController:Controller;
      
      public var gameController:Controller;
      
      public var controller:Controller;
      
      public var __cacheXMLSettings:Object;
      
      public var __animFactory___id1_af1:AnimatorFactory;
      
      public var __animArray___id1_af1:Array;
      
      public var ____motion___id1_af1_matArray__:Array;
      
      public var __motion___id1_af1:MotionBase;
      
      public var __animFactory___id3_af1:AnimatorFactory;
      
      public var __animArray___id3_af1:Array;
      
      public var ____motion___id3_af1_matArray__:Array;
      
      public var __motion___id3_af1:MotionBase;
      
      public function MainTimeline()
      {
         super();
         addFrameScript(0,this.frame1,2,this.frame3,3,this.frame4);
         this.__cacheXMLSettings = XML.settings();
         try
         {
            XML.ignoreProcessingInstructions = false;
            XML.ignoreWhitespace = false;
            XML.prettyPrinting = false;
            RuntimeManager.getSingleton().addInstance(this,"__id1_",new Rectangle(0,0,264.1,211.15),<tlfTextObject type="Point" editPolicy="readOnly" columnCount="1" columnGap="20" verticalAlign="top" firstBaselineOffset="auto" paddingLeft="2" paddingTop="2" paddingRight="2" paddingBottom="2" background="false" backgroundColor="#ffffff" backgroundAlpha="1" border="false" borderColor="#000000" borderAlpha="1" borderWidth="1" paddingLock="false" multiline="true" antiAliasType="advanced" embedFonts="true"><TextFlow blockProgression="tb" columnCount="inherit" columnGap="inherit" columnWidth="inherit" lineBreak="explicit" locale="en_GB" paddingBottom="inherit" paddingLeft="inherit" paddingRight="inherit" paddingTop="inherit" verticalAlign="inherit" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p direction="ltr" paragraphEndIndent="0" paragraphSpaceAfter="0" paragraphSpaceBefore="0" paragraphStartIndent="0" textAlign="start" textAlignLast="start" textIndent="0" textJustify="interWord"><span color="#00ff00" fontFamily="Verdana" fontSize="18" fontStyle="normal" fontWeight="normal" kerning="auto" lineHeight="137.5%" textAlpha="1" textRotation="auto" trackingRight="0%">Play this game </span><span color="#ffff00" fontFamily="Verdana" fontSize="18" fontStyle="normal" fontWeight="normal" kerning="auto" lineHeight="137.5%" textAlpha="1" textRotation="auto" trackingRight="0%">now</span><span color="#00ff00" fontFamily="Verdana" fontSize="18" fontStyle="normal" fontWeight="normal" kerning="auto" lineHeight="137.5%" textAlpha="1" textRotation="auto" trackingRight="0%">:</span></p><p direction="ltr" paragraphEndIndent="0" paragraphSpaceAfter="0" paragraphSpaceBefore="0" paragraphStartIndent="0" textAlign="start" textAlignLast="start" textIndent="0" textJustify="interWord"><span color="#00ff00" fontFamily="Verdana" fontSize="18" fontStyle="normal" fontWeight="normal" kerning="auto" lineHeight="137.5%" textAlpha="1" textRotation="auto" trackingRight="0%"> - on </span><span color="#ffff00" fontFamily="Verdana" fontSize="18" fontStyle="normal" fontWeight="normal" kerning="auto" lineHeight="137.5%" textAlpha="1" textRotation="auto" trackingRight="0%">fullscreen</span></p><p direction="ltr" paragraphEndIndent="0" paragraphSpaceAfter="0" paragraphSpaceBefore="0" paragraphStartIndent="0" textAlign="start" textAlignLast="start" textIndent="0" textJustify="interWord"><span color="#00ff00" fontFamily="Verdana" fontSize="18" fontStyle="normal" fontWeight="normal" kerning="auto" lineHeight="137.5%" textAlpha="1" textRotation="auto" trackingRight="0%"> - </span><span color="#ffff00" fontFamily="Verdana" fontSize="18" fontStyle="normal" fontWeight="normal" kerning="auto" lineHeight="137.5%" textAlpha="1" textRotation="auto" trackingRight="0%">without this ad</span></p><p direction="ltr" paragraphEndIndent="0" paragraphSpaceAfter="0" paragraphSpaceBefore="0" paragraphStartIndent="0" textAlign="start" textAlignLast="start" textIndent="0" textJustify="interWord"><span color="#00ff00" fontFamily="Verdana" fontSize="18" fontStyle="normal" fontWeight="normal" kerning="auto" lineHeight="137.5%" textAlpha="1" textRotation="auto" trackingRight="0%"> - with </span><span color="#ffff00" fontFamily="Verdana" fontSize="18" fontStyle="normal" fontWeight="normal" kerning="auto" lineHeight="137.5%" textAlpha="1" textRotation="auto" trackingRight="0%">more support</span></p><p direction="ltr" paragraphEndIndent="0" paragraphSpaceAfter="0" paragraphSpaceBefore="0" paragraphStartIndent="0" textAlign="start" textAlignLast="start" textIndent="0" textJustify="interWord"><span color="#00ff00" fontFamily="Verdana" fontSize="18" fontStyle="normal" fontWeight="normal" kerning="auto" lineHeight="137.5%" textAlpha="1" textRotation="auto" trackingRight="0%"> - always the </span><span color="#ffff00" fontFamily="Verdana" fontSize="18" fontStyle="normal" fontWeight="normal" kerning="auto" lineHeight="137.5%" textAlpha="1" textRotation="auto" trackingRight="0%">latest version</span></p><p direction="ltr" paragraphEndIndent="0" paragraphSpaceAfter="0" paragraphSpaceBefore="0" paragraphStartIndent="0" textAlign="start" textAlignLast="start" textIndent="0" textJustify="interWord"><span color="#00ff00" fontFamily="Verdana" fontSize="18" fontStyle="normal" fontWeight="normal" kerning="auto" lineHeight="137.5%" textAlpha="1" textRotation="auto" trackingRight="0%"></span></p><p direction="ltr" paragraphEndIndent="0" paragraphSpaceAfter="0" paragraphSpaceBefore="0" paragraphStartIndent="0" textAlign="center" textAlignLast="start" textIndent="0" textJustify="interWord"><span color="#00ff00" fontFamily="Verdana" fontSize="20" fontStyle="normal" fontWeight="normal" kerning="auto" lineHeight="137.5%" textAlpha="1" textRotation="auto" trackingRight="0%">Go to</span></p><p direction="ltr" paragraphEndIndent="0" paragraphSpaceAfter="0" paragraphSpaceBefore="0" paragraphStartIndent="0" textAlign="center" textAlignLast="start" textIndent="0" textJustify="interWord"><span color="#ffff00" fontFamily="Segoe Print" fontSize="25" fontStyle="normal" fontWeight="normal" kerning="auto" lineHeight="137.5%" textAlpha="1" textDecoration="underline" textRotation="auto" trackingRight="0%">www.flashkurve.com</span></p></TextFlow></tlfTextObject>
            ,null,undefined,2,3,"Scene 1");
            RuntimeManager.getSingleton().addInstance(this,"__id3_",new Rectangle(0,0,264.1,211.15),<tlfTextObject type="Point" editPolicy="readOnly" columnCount="1" columnGap="20" verticalAlign="top" firstBaselineOffset="auto" paddingLeft="2" paddingTop="2" paddingRight="2" paddingBottom="2" background="false" backgroundColor="#ffffff" backgroundAlpha="1" border="false" borderColor="#000000" borderAlpha="1" borderWidth="1" paddingLock="false" multiline="true" antiAliasType="advanced" embedFonts="true"><TextFlow blockProgression="tb" columnCount="inherit" columnGap="inherit" columnWidth="inherit" lineBreak="explicit" locale="en_GB" paddingBottom="inherit" paddingLeft="inherit" paddingRight="inherit" paddingTop="inherit" verticalAlign="inherit" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p direction="ltr" paragraphEndIndent="0" paragraphSpaceAfter="0" paragraphSpaceBefore="0" paragraphStartIndent="0" textAlign="start" textAlignLast="start" textIndent="0" textJustify="interWord"><span color="#00ff00" fontFamily="Verdana" fontSize="18" fontStyle="normal" fontWeight="normal" kerning="auto" lineHeight="137.5%" textAlpha="1" textRotation="auto" trackingRight="0%">Play this game </span><span color="#ffff00" fontFamily="Verdana" fontSize="18" fontStyle="normal" fontWeight="normal" kerning="auto" lineHeight="137.5%" textAlpha="1" textRotation="auto" trackingRight="0%">now</span><span color="#00ff00" fontFamily="Verdana" fontSize="18" fontStyle="normal" fontWeight="normal" kerning="auto" lineHeight="137.5%" textAlpha="1" textRotation="auto" trackingRight="0%">:</span></p><p direction="ltr" paragraphEndIndent="0" paragraphSpaceAfter="0" paragraphSpaceBefore="0" paragraphStartIndent="0" textAlign="start" textAlignLast="start" textIndent="0" textJustify="interWord"><span color="#00ff00" fontFamily="Verdana" fontSize="18" fontStyle="normal" fontWeight="normal" kerning="auto" lineHeight="137.5%" textAlpha="1" textRotation="auto" trackingRight="0%"> - on </span><span color="#ffff00" fontFamily="Verdana" fontSize="18" fontStyle="normal" fontWeight="normal" kerning="auto" lineHeight="137.5%" textAlpha="1" textRotation="auto" trackingRight="0%">fullscreen</span></p><p direction="ltr" paragraphEndIndent="0" paragraphSpaceAfter="0" paragraphSpaceBefore="0" paragraphStartIndent="0" textAlign="start" textAlignLast="start" textIndent="0" textJustify="interWord"><span color="#00ff00" fontFamily="Verdana" fontSize="18" fontStyle="normal" fontWeight="normal" kerning="auto" lineHeight="137.5%" textAlpha="1" textRotation="auto" trackingRight="0%"> - </span><span color="#ffff00" fontFamily="Verdana" fontSize="18" fontStyle="normal" fontWeight="normal" kerning="auto" lineHeight="137.5%" textAlpha="1" textRotation="auto" trackingRight="0%">without this ad</span></p><p direction="ltr" paragraphEndIndent="0" paragraphSpaceAfter="0" paragraphSpaceBefore="0" paragraphStartIndent="0" textAlign="start" textAlignLast="start" textIndent="0" textJustify="interWord"><span color="#00ff00" fontFamily="Verdana" fontSize="18" fontStyle="normal" fontWeight="normal" kerning="auto" lineHeight="137.5%" textAlpha="1" textRotation="auto" trackingRight="0%"> - with </span><span color="#ffff00" fontFamily="Verdana" fontSize="18" fontStyle="normal" fontWeight="normal" kerning="auto" lineHeight="137.5%" textAlpha="1" textRotation="auto" trackingRight="0%">more support</span></p><p direction="ltr" paragraphEndIndent="0" paragraphSpaceAfter="0" paragraphSpaceBefore="0" paragraphStartIndent="0" textAlign="start" textAlignLast="start" textIndent="0" textJustify="interWord"><span color="#00ff00" fontFamily="Verdana" fontSize="18" fontStyle="normal" fontWeight="normal" kerning="auto" lineHeight="137.5%" textAlpha="1" textRotation="auto" trackingRight="0%"> - always the </span><span color="#ffff00" fontFamily="Verdana" fontSize="18" fontStyle="normal" fontWeight="normal" kerning="auto" lineHeight="137.5%" textAlpha="1" textRotation="auto" trackingRight="0%">latest version</span></p><p direction="ltr" paragraphEndIndent="0" paragraphSpaceAfter="0" paragraphSpaceBefore="0" paragraphStartIndent="0" textAlign="start" textAlignLast="start" textIndent="0" textJustify="interWord"><span color="#00ff00" fontFamily="Verdana" fontSize="18" fontStyle="normal" fontWeight="normal" kerning="auto" lineHeight="137.5%" textAlpha="1" textRotation="auto" trackingRight="0%"></span></p><p direction="ltr" paragraphEndIndent="0" paragraphSpaceAfter="0" paragraphSpaceBefore="0" paragraphStartIndent="0" textAlign="center" textAlignLast="start" textIndent="0" textJustify="interWord"><span color="#00ff00" fontFamily="Verdana" fontSize="20" fontStyle="normal" fontWeight="normal" kerning="auto" lineHeight="137.5%" textAlpha="1" textRotation="auto" trackingRight="0%">Go to</span></p><p direction="ltr" paragraphEndIndent="0" paragraphSpaceAfter="0" paragraphSpaceBefore="0" paragraphStartIndent="0" textAlign="center" textAlignLast="start" textIndent="0" textJustify="interWord"><span color="#ffff00" fontFamily="Segoe Print" fontSize="25" fontStyle="normal" fontWeight="normal" kerning="auto" lineHeight="137.5%" textAlpha="1" textDecoration="underline" textRotation="auto" trackingRight="0%">www.flashkurve.com</span></p></TextFlow></tlfTextObject>
            ,null,undefined,2,3,"Scene 1");
            Font.registerFont(Font4);
            Font.registerFont(Font7_9);
         }
         finally
         {
            XML.setSettings(this.__cacheXMLSettings);
         }
         RuntimeManager.getSingleton().addInstanceComplete(this);
         if(this.__animFactory___id1_af1 == null)
         {
            this.__animArray___id1_af1 = new Array();
            this.__motion___id1_af1 = new Motion();
            this.__motion___id1_af1.duration = 2;
            this.__motion___id1_af1.overrideTargetTransform();
            this.__motion___id1_af1.addPropertyArray("cacheAsBitmap",[false,false]);
            this.__motion___id1_af1.addPropertyArray("blendMode",["normal","normal"]);
            this.__motion___id1_af1.motion_internal::spanStart = 2;
            this.____motion___id1_af1_matArray__ = new Array();
            this.____motion___id1_af1_matArray__.push(new Matrix(1,0,0,1,8.4,262.85));
            this.____motion___id1_af1_matArray__.push(null);
            this.__motion___id1_af1.addPropertyArray("matrix",this.____motion___id1_af1_matArray__);
            this.__animArray___id1_af1.push(this.__motion___id1_af1);
            this.__animFactory___id1_af1 = new AnimatorFactory(null,this.__animArray___id1_af1);
            this.__animFactory___id1_af1.sceneName = "Scene 1";
            this.__animFactory___id1_af1.addTargetInfo(this,"__id1_",0,true,0,true,null,-1,"__id0_",RuntimeManager);
         }
         if(this.__animFactory___id3_af1 == null)
         {
            this.__animArray___id3_af1 = new Array();
            this.__motion___id3_af1 = new Motion();
            this.__motion___id3_af1.duration = 2;
            this.__motion___id3_af1.overrideTargetTransform();
            this.__motion___id3_af1.addPropertyArray("cacheAsBitmap",[false,false]);
            this.__motion___id3_af1.addPropertyArray("blendMode",["normal","normal"]);
            this.__motion___id3_af1.motion_internal::spanStart = 2;
            this.____motion___id3_af1_matArray__ = new Array();
            this.____motion___id3_af1_matArray__.push(new Matrix(1,0,0,1,621.15,262.85));
            this.____motion___id3_af1_matArray__.push(null);
            this.__motion___id3_af1.addPropertyArray("matrix",this.____motion___id3_af1_matArray__);
            this.__animArray___id3_af1.push(this.__motion___id3_af1);
            this.__animFactory___id3_af1 = new AnimatorFactory(null,this.__animArray___id3_af1);
            this.__animFactory___id3_af1.sceneName = "Scene 1";
            this.__animFactory___id3_af1.addTargetInfo(this,"__id3_",0,true,0,true,null,-1,"__id2_",RuntimeManager);
         }
      }
      
      public function onConnectError(param1:String) : void
      {
      }
      
      public function changeController(param1:Event) : *
      {
         stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.controller.handleKeyDown);
         stage.removeEventListener(KeyboardEvent.KEY_UP,this.controller.handleKeyUp);
         if(param1.type == Game.READY)
         {
            this.controller = this.gameController;
            if(this.add)
            {
               this.controller.lock();
            }
            else
            {
               this.controller.init();
            }
            this.ingame_mc.visible = true;
            this.home_mc.visible = false;
            MochiEvents.startPlay();
            if(this.add)
            {
               gotoAndStop(3);
            }
         }
         else if(param1.type == Game.GAME_END)
         {
            this.controller = this.homeController;
            this.controller.init();
            this.ingame_mc.visible = false;
            this.home_mc.visible = true;
         }
         stage.addEventListener(KeyboardEvent.KEY_DOWN,this.controller.handleKeyDown);
         stage.addEventListener(KeyboardEvent.KEY_UP,this.controller.handleKeyUp);
      }
      
      internal function frame1() : *
      {
         this.version = "v 1.02v";
         this.sub_version = ".15";
         this.add = false;
         this.add_version = "";
         if(this.add)
         {
            this.add_version = "add";
         }
         this._mochiads_game_id = "22906a714278e57e";
         MochiBot.track(this,"c45e0251");
         MochiServices.connect(this._mochiads_game_id,root,this.onConnectError);
         MochiEvents.trackEvent("version",this.version + this.sub_version + this.add_version);
         this.game = new Game(stage.frameRate);
         this.home_mc.version_txt.text = this.version + this.sub_version + this.add_version;
         this.homeController = new HomeController(this.home_mc,this.game);
         this.gameController = new GameController(this.ingame_mc,this.game);
         this.controller = this.homeController;
         this.ingame_mc.visible = false;
         stage.addEventListener(KeyboardEvent.KEY_DOWN,this.controller.handleKeyDown);
         stage.addEventListener(KeyboardEvent.KEY_UP,this.controller.handleKeyUp);
         this.homeController.addEventListener(Game.READY,this.changeController);
         this.gameController.addEventListener(Game.GAME_END,this.changeController);
         stop();
      }
      
      internal function frame3() : *
      {
         MochiAd.showInterLevelAd({
            "clip":root,
            "id":this._mochiads_game_id,
            "res":"904x768",
            "no_bg":true
         });
         stop();
      }
      
      internal function frame4() : *
      {
         if(this.controller is GameController)
         {
            this.controller.unlock();
            this.controller.init();
         }
         gotoAndStop(2);
      }
   }
}

