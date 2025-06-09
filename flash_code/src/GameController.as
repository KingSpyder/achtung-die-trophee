package
{
   import flash.display.*;
   import flash.events.*;
   import flash.filters.*;
   import flash.geom.*;
   import flash.ui.*;
   import flash.utils.*;
   import mochi.as3.*;
   import powerups.*;
   
   public class GameController extends Controller
   {
      
      private var main:MovieClip;
      
      private var game:Game;
      
      private var status:String;
      
      private var fieldWidth:uint;
      
      private var fieldHeight:uint;
      
      private var lastFrameTime:Number;
      
      private var activePlayers:Array;
      
      private var fields:MovieClip;
      
      private var powerUpField:MovieClip;
      
      private var tunnelField:MovieClip;
      
      private var bodyField:MovieClip;
      
      private var headField:MovieClip;
      
      private var overlayField:MovieClip;
      
      private var bodies:Array;
      
      private var heads:Array;
      
      private var continueTimer:Timer;
      
      private var sounds:Sounds;
      
      public function GameController(param1:MovieClip, param2:Game)
      {
         super();
         this.status = Game.INIT;
         this.main = param1;
         this.game = param2;
         this.fields = param1.main_field_mc;
         param1.hardBorder.gotoAndStop(1);
         this.powerUpField = new MovieClip();
         this.fields.addChild(this.powerUpField);
         this.tunnelField = new MovieClip();
         this.fields.addChild(this.tunnelField);
         this.bodyField = new MovieClip();
         this.fields.addChild(this.bodyField);
         this.headField = new MovieClip();
         this.fields.addChild(this.headField);
         this.overlayField = new MovieClip();
         this.fields.addChild(this.overlayField);
         param2.addEventListener(PlayerEvent.MOVE,this.handlePlayerMove);
         param2.addEventListener(Game.PLAY_END,this.handlePlayEnd);
         param2.addEventListener(Game.PLAYER_DIED,this.handlePlayerDied);
         param2.addEventListener(Game.GAME_END,this.handleGameEnd);
         param2.addEventListener(Game.START,this.handlePlayStart);
         param2.addEventListener(Game.PAUSE,this.handleGamePause);
         param2.addEventListener(Game.RESUMED,this.handleGameResume);
         param2.addEventListener(Player.REDRAW,this.handleRedraw);
         param2.addEventListener(PowerUp.ADDED_TO_STAGE,this.handlePowerUpAdd);
         param2.addEventListener(PowerUp.REMOVED_FROM_STAGE,this.handlePowerUpRemove);
         param2.addEventListener(Player.START_TUNNELING,this.handleStartTunneling);
         param2.addEventListener(Player.STOP_TUNNELING,this.handleStopTunneling);
         param2.addEventListener(Player.START_REVERSE,this.handleStartReverse);
         param2.addEventListener(Player.STOP_REVERSE,this.handleStopReverse);
         param2.addEventListener(Player.START_OLD_SNAKEY,this.handleStartSnakey);
         param2.addEventListener(Player.STOP_OLD_SNAKEY,this.handleStopSnakey);
         param2.addEventListener(Field.START_OPEN_BORDERS,this.handleStartOpenBorders);
         param2.addEventListener(Field.STOP_OPEN_BORDERS,this.handleStopOpenBorders);
         param2.addEventListener(Field.EMPTIED,this.handleEmptyField);
         param2.addEventListener(Game.UPDATE_SCORE_TARGET,this.handleUpdateTargetScore);
         param1.addEventListener(Event.ENTER_FRAME,this.enterFrameListener);
         param1.addEventListener(Event.ACTIVATE,this.onActivate);
         param1.addEventListener(Event.DEACTIVATE,this.onDeactivate);
         this.continueTimer = new Timer(1500,1);
         this.continueTimer.addEventListener(TimerEvent.TIMER,this.handleContinueTimer);
         this.sounds = Sounds.getInstance();
      }
      
      private function handleGameResume(param1:Event) : void
      {
         this.main.pauseScreen_mc.visible = false;
      }
      
      private function handleGamePause(param1:Event) : void
      {
         this.main.pauseScreen_mc.visible = true;
      }
      
      private function onActivate(param1:Event) : void
      {
      }
      
      private function onDeactivate(param1:Event) : void
      {
         if(this.game.getStatus() == Game.PLAY)
         {
            this.game.pause();
         }
      }
      
      private function handlePlayStart(param1:Event) : void
      {
      }
      
      private function handleContinueTimer(param1:TimerEvent) : void
      {
         if(this.game.getStatus() == Game.PLAY_END)
         {
            if(this.game.isAiGame())
            {
               this.reset();
            }
         }
         else if(this.game.getStatus() == Game.SETUP)
         {
            if(this.game.isAiGame())
            {
               this.game.start();
            }
         }
      }
      
      private function enterFrameListener(param1:Event) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(this.game.isRunning())
         {
            _loc2_ = getTimer();
            _loc3_ = _loc2_ - this.lastFrameTime;
            this.game.move();
            this.lastFrameTime = _loc2_;
         }
      }
      
      private function handleUpdateTargetScore(param1:Event) : void
      {
         this.main.score_table_mc.score_goal_txt.text = this.game.getTargetScore();
      }
      
      private function handleEmptyField(param1:Event) : void
      {
         var _loc2_:Player = null;
         var _loc3_:Shape = null;
         this.fields.removeChild(this.tunnelField);
         this.tunnelField = new MovieClip();
         this.fields.addChild(this.tunnelField);
         for each(_loc2_ in this.game.getActivePlayers())
         {
            _loc3_ = this.bodies[_loc2_.getId()];
            _loc3_.graphics.clear();
            _loc3_.graphics.lineStyle(_loc2_.getWidth(),_loc2_.getColor(),1,false,LineScaleMode.NORMAL,CapsStyle.NONE);
            _loc3_.graphics.moveTo(_loc2_.getX(),_loc2_.getY());
         }
      }
      
      private function handleStartOpenBorders(param1:Event) : void
      {
         this.main.hardBorder.play();
      }
      
      private function handleStopOpenBorders(param1:Event) : void
      {
         this.main.hardBorder.gotoAndStop(1);
      }
      
      private function handleStartReverse(param1:PlayerEvent) : void
      {
         var _loc2_:Player = param1.getPlayer();
         var _loc3_:int = int(_loc2_.getId());
         var _loc4_:Head = this.heads[_loc3_];
         _loc4_.startReverse();
      }
      
      private function handleStopReverse(param1:PlayerEvent) : void
      {
         var _loc2_:Player = param1.getPlayer();
         var _loc3_:int = int(_loc2_.getId());
         var _loc4_:Head = this.heads[_loc3_];
         _loc4_.stopReverse();
      }
      
      private function handleStartTunneling(param1:PlayerEvent) : void
      {
         var _loc2_:Player = param1.getPlayer();
         var _loc3_:int = int(_loc2_.getId());
         var _loc4_:Head = this.heads[_loc3_];
         _loc4_.startTunneling();
      }
      
      private function handleStopTunneling(param1:PlayerEvent) : void
      {
         var _loc2_:Player = param1.getPlayer();
         var _loc3_:int = int(_loc2_.getId());
         var _loc4_:Head = this.heads[_loc3_];
         _loc4_.stopTunneling();
      }
      
      private function handlePowerUpAdd(param1:PowerUpEvent) : *
      {
         var _loc2_:PowerUp = param1.getPowerUp();
         var _loc3_:MovieClip = _loc2_.getPowerUpMc();
         _loc3_.x = _loc2_.getX();
         _loc3_.y = _loc2_.getY();
         _loc3_.width = 2 * _loc2_.getRadius();
         _loc3_.height = 2 * _loc2_.getRadius();
         this.powerUpField.addChild(_loc3_);
      }
      
      private function handleStartSnakey(param1:PlayerEvent) : void
      {
         var _loc2_:Player = param1.getPlayer();
         var _loc3_:int = int(_loc2_.getId());
         var _loc4_:Head = this.heads[_loc3_];
         _loc4_.startSnakey();
      }
      
      private function handleStopSnakey(param1:PlayerEvent) : void
      {
         var _loc2_:Player = param1.getPlayer();
         var _loc3_:int = int(_loc2_.getId());
         var _loc4_:Head = this.heads[_loc3_];
         _loc4_.stopSnakey();
      }
      
      private function handlePowerUpRemove(param1:PowerUpEvent) : *
      {
         var _loc2_:PowerUp = param1.getPowerUp();
         this.powerUpField.removeChild(_loc2_.getPowerUpMc());
      }
      
      override public function init() : void
      {
         var _loc1_:Player = null;
         if(this.fieldWidth == 0)
         {
            this.fieldWidth = Math.round(this.main.main_field_mc.width);
         }
         if(this.fieldHeight == 0)
         {
            this.fieldHeight = Math.round(this.main.main_field_mc.height);
         }
         this.game.init(this.fieldWidth,this.fieldHeight);
         this.main.score_table_mc.getChildByName("score_goal_txt").text = this.game.getTargetScore();
         for each(_loc1_ in this.game.getActivePlayers())
         {
            this.main.score_table_mc.getChildByName("score_" + _loc1_.getId()).getChildByName("playername" + _loc1_.getId() + "_txt").text = _loc1_.getName();
         }
         this.orderScores();
         this.main.score_table_mc.getChildByName("score_goal_txt").text = this.game.getTargetScore();
         this.main.soundManager_mc.init();
         this.game_init();
         this.setup();
      }
      
      private function orderScores() : void
      {
         var _loc2_:Player = null;
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc1_:Array = new Array();
         for each(_loc2_ in this.game.getActivePlayers())
         {
            _loc4_ = new Object();
            _loc4_.score = _loc2_.getScore();
            _loc4_.id = _loc2_.getId();
            _loc1_.push(_loc4_);
         }
         _loc1_.sortOn(["score","id"],[Array.DESCENDING | Array.NUMERIC,Array.NUMERIC]);
         _loc3_ = 0;
         while(_loc3_ < _loc1_.length)
         {
            this.main.score_table_mc.getChildByName("score_" + _loc1_[_loc3_].id).y = this.main.score_table_mc.ref_line.y + _loc3_ * this.main.score_table_mc.getChildByName("score_" + _loc1_[_loc3_].id).height + 5;
            _loc3_++;
         }
      }
      
      public function game_init() : void
      {
         var _loc1_:Shape = null;
         for each(_loc1_ in this.bodies)
         {
            _loc1_.graphics.clear();
         }
         this.main.pauseScreen_mc.visible = false;
         this.bodies = new Array();
         this.heads = new Array();
         while(this.overlayField.numChildren > 0)
         {
            this.overlayField.removeChildAt(0);
         }
         while(this.powerUpField.numChildren > 0)
         {
            this.powerUpField.removeChildAt(0);
         }
         while(this.tunnelField.numChildren > 0)
         {
            this.tunnelField.removeChildAt(0);
         }
         while(this.headField.numChildren > 0)
         {
            this.headField.removeChildAt(0);
         }
         this.main.hardBorder.gotoAndStop(1);
         this.continueTimer.reset();
         this.continueTimer.start();
         this.sounds.stopMusic();
         this.sounds.playMusic();
      }
      
      public function setup() : void
      {
         var _loc1_:Player = null;
         var _loc2_:Shape = null;
         var _loc3_:Head = null;
         for each(_loc1_ in this.game.getActivePlayers())
         {
            _loc2_ = new Shape();
            this.bodyField.addChild(_loc2_);
            this.bodies[_loc1_.getId()] = _loc2_;
            _loc2_.graphics.lineStyle(_loc1_.getWidth(),_loc1_.getColor(),1,false,LineScaleMode.NORMAL,CapsStyle.NONE);
            _loc3_ = new Head();
            this.heads[_loc1_.getId()] = _loc3_;
            _loc3_.width = _loc1_.getWidth();
            _loc3_.height = _loc1_.getWidth();
            this.headField.addChild(_loc3_);
         }
         for each(_loc1_ in this.game.getAllPlayers())
         {
            this.main.score_table_mc.getChildByName("score_" + _loc1_.getId()).getChildByName("score" + _loc1_.getId() + "_txt").visible = _loc1_.getActive();
            this.main.score_table_mc.getChildByName("score_" + _loc1_.getId()).getChildByName("score" + _loc1_.getId() + "_txt").text = _loc1_.getScore();
            this.main.score_table_mc.getChildByName("score_" + _loc1_.getId()).getChildByName("playername" + _loc1_.getId() + "_txt").visible = _loc1_.getActive();
         }
         this.game.setup();
      }
      
      public function handlePlayerMove(param1:PlayerEvent) : void
      {
         var _loc2_:Player = param1.getPlayer();
         var _loc3_:Shape = this.bodies[_loc2_.getId()];
         this.draw(_loc2_,_loc3_);
      }
      
      private function draw(param1:Player, param2:Shape) : void
      {
         var _loc4_:Shape = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         if(param1.isTunneling())
         {
            param2.graphics.moveTo(param1.getPrevX(param1.getX()),param1.getPrevY(param1.getY()));
            if(!param1.getHistory(0).hole || param1.afterHole())
            {
               _loc4_ = new Shape();
               _loc4_.graphics.lineStyle(param1.getWidth(),param1.getColor(),1,false,LineScaleMode.NORMAL,CapsStyle.NONE);
               _loc5_ = param1.tunnelX();
               _loc6_ = param1.tunnelY();
               _loc7_ = param1.getPrevX(_loc5_);
               _loc8_ = param1.getPrevY(_loc6_);
               _loc4_.graphics.moveTo(_loc7_,_loc8_);
               _loc4_.graphics.lineTo(_loc5_,_loc6_);
               this.tunnelField.addChild(_loc4_);
            }
         }
         else if(param1.afterHole())
         {
            param2.graphics.moveTo(param1.getPrevX(param1.getX()),param1.getPrevY(param1.getY()));
         }
         if(!param1.getHistory(0).hole)
         {
            param2.graphics.lineTo(param1.getX(),param1.getY());
         }
         var _loc3_:MovieClip = this.heads[param1.getId()];
         _loc3_.x = param1.getX();
         _loc3_.y = param1.getY();
      }
      
      private function handleRedraw(param1:PlayerEvent) : void
      {
         var _loc2_:Player = param1.getPlayer();
         var _loc3_:Shape = this.bodies[_loc2_.getId()];
         _loc3_.graphics.lineStyle(_loc2_.getWidth(),_loc2_.getColor(),1,false,LineScaleMode.NORMAL,CapsStyle.NONE);
         var _loc4_:MovieClip = this.heads[_loc2_.getId()];
         _loc4_.width = _loc2_.getWidth();
         _loc4_.height = _loc2_.getWidth();
      }
      
      public function handlePlayerDied(param1:PlayerEvent) : void
      {
         var _loc2_:Player = null;
         var _loc3_:uint = 0;
         this.sounds.playExplosion();
         for each(_loc2_ in this.game.getActivePlayers())
         {
            this.main.score_table_mc.getChildByName("score_" + _loc2_.getId()).getChildByName("score" + _loc2_.getId() + "_txt").text = _loc2_.getScore();
         }
         this.orderScores();
         _loc3_ = param1.getId();
      }
      
      private function reset() : void
      {
         var _loc1_:Player = null;
         var _loc2_:Shape = null;
         var _loc3_:MovieClip = null;
         while(this.powerUpField.numChildren > 0)
         {
            this.powerUpField.removeChildAt(0);
         }
         while(this.tunnelField.numChildren > 0)
         {
            this.tunnelField.removeChildAt(0);
         }
         while(this.headField.numChildren > 0)
         {
            this.headField.removeChildAt(0);
         }
         this.main.hardBorder.gotoAndStop(1);
         for each(_loc1_ in this.game.getActivePlayers())
         {
            _loc2_ = this.bodies[_loc1_.getId()];
            _loc2_.graphics.clear();
            _loc2_.graphics.lineStyle(_loc1_.getWidth(),_loc1_.getColor(),1,false,LineScaleMode.NORMAL,CapsStyle.NONE);
            _loc3_ = new Head();
            this.heads[_loc1_.getId()] = _loc3_;
            _loc3_.width = _loc1_.getWidth();
            _loc3_.height = _loc1_.getWidth();
            this.headField.addChild(_loc3_);
         }
         this.game.setup();
         this.continueTimer.reset();
         this.continueTimer.start();
      }
      
      private function handlePlayEnd(param1:Event) : void
      {
         this.continueTimer.reset();
         this.continueTimer.start();
      }
      
      private function handleGameEnd(param1:PlayerEvent) : void
      {
         var _loc2_:Player = param1.getPlayer();
         var _loc3_:MovieClip = new winscreen_mc();
         _loc3_.name = "winscreen_mc";
         _loc3_.x = this.main.main_field_mc.x;
         _loc3_.y = this.main.main_field_mc.y;
         this.overlayField.addChild(_loc3_);
         _loc3_.win_text.text = _loc2_.getName() + " wins!";
         var _loc4_:uint = _loc2_.getColor();
         var _loc5_:Number = _loc4_ % 256 / 256;
         _loc4_ /= 256;
         var _loc6_:Number = _loc4_ % 256 / 256;
         _loc4_ /= 256;
         var _loc7_:Number = _loc4_ % 256 / 256;
         _loc3_.transform.colorTransform = new ColorTransform(_loc7_,_loc6_,_loc5_);
         this.sounds.playApplause();
         this.finishGame();
      }
      
      private function finishGame() : void
      {
         var _loc1_:Player = null;
         MochiEvents.endPlay();
         this.sounds.stopMusic();
         for each(_loc1_ in this.game.getAllPlayers())
         {
            if(_loc1_.getActive() && _loc1_.getAI())
            {
               _loc1_.setActive(false);
               _loc1_.setAI(false);
            }
         }
      }
      
      override public function handleKeyDown(param1:KeyboardEvent) : void
      {
         var _loc2_:Player = null;
         if(!locked)
         {
            for each(_loc2_ in this.game.getActivePlayers())
            {
               if(param1.keyCode == _loc2_.getLeftKey())
               {
                  _loc2_.setDirection(Player.LEFT);
               }
               if(param1.keyCode == _loc2_.getRightKey())
               {
                  _loc2_.setDirection(Player.RIGHT);
               }
            }
         }
      }
      
      override public function handleKeyUp(param1:KeyboardEvent) : void
      {
         var _loc2_:Player = null;
         if(!locked)
         {
            if(param1.keyCode == Keyboard.SPACE)
            {
               if(this.game.getStatus() == Game.SETUP)
               {
                  this.game.start();
                  this.continueTimer.reset();
                  this.continueTimer.stop();
               }
               else if(this.game.getStatus() == Game.PLAY)
               {
                  this.game.pause();
               }
               else if(this.game.getStatus() == Game.PAUSE)
               {
                  this.game.resume();
               }
               else if(this.game.getStatus() == Game.PLAY_END)
               {
                  this.reset();
               }
               else if(this.game.getStatus() == Game.GAME_END)
               {
                  dispatchEvent(new Event(Game.GAME_END));
               }
            }
            else if(param1.keyCode == Keyboard.ESCAPE)
            {
               this.game.pause();
               dispatchEvent(new Event(Game.GAME_END));
               if(this.game.getStatus() != Game.GAME_END)
               {
                  this.finishGame();
               }
            }
            else
            {
               for each(_loc2_ in this.game.getActivePlayers())
               {
                  if(param1.keyCode == _loc2_.getLeftKey() && _loc2_.getDirection() == Player.LEFT || param1.keyCode == _loc2_.getRightKey() && _loc2_.getDirection() == Player.RIGHT)
                  {
                     _loc2_.setDirection(Player.STRAIGHT);
                  }
               }
            }
         }
      }
   }
}

