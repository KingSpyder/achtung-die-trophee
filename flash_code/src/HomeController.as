package
{
   import flash.display.*;
   import flash.events.*;
   import flash.net.*;
   import flash.system.*;
   import flash.text.*;
   import flash.ui.*;
   
   public class HomeController extends Controller
   {
      
      private var main:MovieClip;
      
      private var game:Game;
      
      private var alpha_p:Number;
      
      private var controlLocked:Boolean;
      
      private var lockedBy:Object;
      
      private var loader:Loader;
      
      private var moviePlayer:Object;
      
      private var movieUrl:String = "http://www.youtube.com/v/K4Ryx7jXLzM?version=3&autoplay=1";
      
      private var movieHolder:MovieClip;
      
      private var sounds:Sounds;
      
      public function HomeController(param1:MovieClip, param2:Game)
      {
         super();
         this.main = param1;
         this.game = param2;
         param1.parent.getChildByName("mcHelp").visible = false;
         this.movieHolder = param1.movie;
         this.alpha_p = 0.25;
         this.controlLocked = false;
         var _loc3_:Player = new Player(1,"Fred",37,39,16711680,Keyboard.F1,false,param2.getFPS());
         var _loc4_:Player = new Player(2,"Greenlee",90,88,65280,Keyboard.F2,false,param2.getFPS());
         var _loc5_:Player = new Player(3,"Pinkney",78,77,16711935,Keyboard.F3,false,param2.getFPS());
         var _loc6_:Player = new Player(4,"Bluebell",49,81,65535,Keyboard.F4,false,param2.getFPS());
         var _loc7_:Player = new Player(5,"Willem",49,81,16744448,Keyboard.F5,false,param2.getFPS());
         var _loc8_:Player = new Player(6,"Greydon",49,81,13421772,Keyboard.F6,false,param2.getFPS());
         param2.addPlayer(_loc3_);
         param2.addPlayer(_loc4_);
         param2.addPlayer(_loc5_);
         param2.addPlayer(_loc6_);
         param2.addPlayer(_loc7_);
         param2.addPlayer(_loc8_);
         param1.control_mc.playerAdd1.addPlayer(_loc3_,49,this);
         param1.control_mc.playerAdd2.addPlayer(_loc4_,50,this);
         param1.control_mc.playerAdd3.addPlayer(_loc5_,51,this);
         param1.control_mc.playerAdd4.addPlayer(_loc6_,52,this);
         param1.control_mc.playerAdd5.addPlayer(_loc7_,53,this);
         param1.control_mc.playerAdd6.addPlayer(_loc8_,54,this);
         param2.setGamePlay(Game.ARCADE);
         param1.classicBtn.alpha = 0.5;
         param1.arcadeBtn.alpha = 1;
         param1.startGameBtn.addEventListener(MouseEvent.CLICK,this.handleStartGame);
         param1.arcadeBtn.addEventListener(MouseEvent.CLICK,this.handleSetArcadeStyle);
         param1.classicBtn.addEventListener(MouseEvent.CLICK,this.handleSetClassicStyle);
         param1.achtung_mc.visible = false;
         param1.achtung_mc.no_btn.addEventListener(MouseEvent.CLICK,this.handleCancleAi);
         param1.achtung_mc.yes_btn.addEventListener(MouseEvent.CLICK,this.handleContinueAi);
         param1.help_btn.addEventListener(MouseEvent.CLICK,this.helpClick);
         var _loc9_:MovieClip = param1.parent.getChildByName("mcHelp") as MovieClip;
         _loc9_.btn_back.addEventListener(MouseEvent.CLICK,this.helpCloseClick);
         this.loader = new Loader();
         this.loader.contentLoaderInfo.addEventListener(Event.INIT,this.onLoaderInit);
         this.loader.load(new URLRequest(this.movieUrl));
         this.sounds = Sounds.getInstance();
      }
      
      private function helpClick(param1:MouseEvent) : void
      {
         this.main.parent.getChildByName("mcHelp").visible = true;
         this.lockControl(this.main.parent.getChildByName("mcHelp"));
      }
      
      private function helpCloseClick(param1:MouseEvent) : void
      {
         this.main.parent.getChildByName("mcHelp").visible = false;
         this.openControl(this.main.parent.getChildByName("mcHelp"));
      }
      
      private function handleCancleAi(param1:MouseEvent) : void
      {
         this.openControl(this.main.achtung_mc);
         this.main.achtung_mc.visible = false;
      }
      
      private function handleContinueAi(param1:MouseEvent) : void
      {
         this.continueAi();
      }
      
      private function continueAi() : void
      {
         this.openControl(this.main.achtung_mc);
         this.main.achtung_mc.visible = false;
         this.game.prepareAiGame();
         this.possiblyStart();
      }
      
      internal function onLoaderInit(param1:Event) : void
      {
         this.main.movie.addChild(this.loader);
         this.loader.content.addEventListener("onReady",this.onPlayerReady);
         this.loader.content.addEventListener("onError",this.onPlayerError);
         this.loader.content.addEventListener("onStateChange",this.onPlayerStateChange);
         this.loader.content.addEventListener("onPlaybackQualityChange",this.onVideoPlaybackQualityChange);
      }
      
      internal function onPlayerReady(param1:Event) : void
      {
         this.moviePlayer = this.loader.content;
         this.moviePlayer.setSize(320,240);
      }
      
      internal function onPlayerError(param1:Event) : void
      {
      }
      
      internal function onPlayerStateChange(param1:Event) : void
      {
      }
      
      internal function onVideoPlaybackQualityChange(param1:Event) : void
      {
      }
      
      private function handleSetArcadeStyle(param1:MouseEvent) : void
      {
         this.game.setGamePlay(Game.ARCADE);
         this.main.classicBtn.alpha = 0.5;
         this.main.arcadeBtn.alpha = 1;
      }
      
      private function handleSetClassicStyle(param1:MouseEvent) : void
      {
         this.game.setGamePlay(Game.CLASSIC);
         this.main.classicBtn.alpha = 1;
         this.main.arcadeBtn.alpha = 0.5;
      }
      
      public function handleStartGame(param1:MouseEvent) : void
      {
         this.possiblyStart();
      }
      
      public function isControlLocked(param1:Object) : Boolean
      {
         if(this.controlLocked && param1 != this.lockedBy)
         {
            return true;
         }
         return false;
      }
      
      public function lockControl(param1:Object) : void
      {
         this.controlLocked = true;
         this.lockedBy = param1;
         if(param1 != this.main.control_mc.playerAdd1)
         {
            this.main.control_mc.playerAdd1.silent();
         }
         if(param1 != this.main.control_mc.playerAdd2)
         {
            this.main.control_mc.playerAdd2.silent();
         }
         if(param1 != this.main.control_mc.playerAdd3)
         {
            this.main.control_mc.playerAdd3.silent();
         }
         if(param1 != this.main.control_mc.playerAdd4)
         {
            this.main.control_mc.playerAdd4.silent();
         }
         if(param1 != this.main.control_mc.playerAdd5)
         {
            this.main.control_mc.playerAdd5.silent();
         }
         if(param1 != this.main.control_mc.playerAdd6)
         {
            this.main.control_mc.playerAdd6.silent();
         }
      }
      
      public function openControl(param1:Object) : void
      {
         if(param1 == this.lockedBy)
         {
            this.controlLocked = false;
         }
         this.main.control_mc.playerAdd1.listen();
         this.main.control_mc.playerAdd2.listen();
         this.main.control_mc.playerAdd3.listen();
         this.main.control_mc.playerAdd4.listen();
         this.main.control_mc.playerAdd5.listen();
         this.main.control_mc.playerAdd6.listen();
      }
      
      override public function init() : void
      {
         this.main.control_mc.playerAdd1.listen();
         this.main.control_mc.playerAdd2.listen();
         this.main.control_mc.playerAdd3.listen();
         this.main.control_mc.playerAdd4.listen();
         this.main.control_mc.playerAdd5.listen();
         this.main.control_mc.playerAdd6.listen();
         this.main.movie.addChild(this.loader);
         this.loader = new Loader();
         this.loader.contentLoaderInfo.addEventListener(Event.INIT,this.onLoaderInit);
         this.loader.load(new URLRequest(this.movieUrl));
         this.game.resetAiGame();
         this.sounds.stopMusic();
         this.sounds.playMusic();
         this.main.soundManager_mc.init();
      }
      
      override public function handleKeyDown(param1:KeyboardEvent) : void
      {
      }
      
      override public function handleKeyUp(param1:KeyboardEvent) : void
      {
         if(!locked)
         {
            if(param1.keyCode == Keyboard.SPACE)
            {
               this.possiblyStart();
            }
         }
      }
      
      public function possiblyStart() : void
      {
         if(this.controlLocked && this.lockedBy == this.main.achtung_mc)
         {
            this.continueAi();
         }
         if(!this.controlLocked && this.game.gameReady())
         {
            this.main.control_mc.playerAdd1.silent();
            this.main.control_mc.playerAdd2.silent();
            this.main.control_mc.playerAdd3.silent();
            this.main.control_mc.playerAdd4.silent();
            this.main.control_mc.playerAdd5.silent();
            this.main.control_mc.playerAdd6.silent();
            if(Boolean(this.moviePlayer) && Boolean(this.loader))
            {
               try
               {
                  this.loader.close();
               }
               catch(error:Error)
               {
               }
               this.loader.unloadAndStop();
               try
               {
                  this.main.movie.removeChild(this.loader);
               }
               catch(error:Error)
               {
               }
               this.moviePlayer.pauseVideo();
               this.moviePlayer.seekTo(0,false);
               this.moviePlayer.stopVideo();
               this.moviePlayer.destroy();
               this.moviePlayer = null;
            }
            dispatchEvent(new Event(Game.READY));
         }
         else if(this.game.getActivePlayers().length == 1)
         {
            this.main.achtung_mc.visible = true;
            this.lockControl(this.main.achtung_mc);
         }
      }
   }
}

