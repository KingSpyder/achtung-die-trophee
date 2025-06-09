package
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Timer;
   import mochi.as3.MochiEvents;
   import powerups.PowerUpManager;
   
   public class Game extends EventDispatcher
   {
      
      public static const READY:String = "ready";
      
      public static const INIT:String = "init";
      
      public static const SETUP:String = "setup";
      
      public static const PLAY:String = "play";
      
      public static const PAUSE:String = "pause";
      
      public static const PLAY_END:String = "play_end";
      
      public static const START:String = "start";
      
      public static const RESUMED:String = "resumed";
      
      public static const GAME_END:String = "game_end";
      
      public static const UPDATE_SCORE_TARGET:String = "Update target score";
      
      public static const PLAYER_DIED:String = "player_died";
      
      public static const ARCADE:String = "arcade";
      
      public static const CLASSIC:String = "classic";
      
      private var status:String;
      
      private var players:Array = new Array();
      
      private var field:Field;
      
      private var targetScore:uint;
      
      private var lastRound:Boolean;
      
      private var pointLimit:uint = 10;
      
      private var usePowerUps:Boolean = true;
      
      private var powerUpManager:PowerUpManager;
      
      private var fps:Number;
      
      private var gamePlay:String;
      
      private var roundTimer:Timer;
      
      private var running:Boolean;
      
      private var playAi:Boolean = false;
      
      private var AiRunning:Boolean = false;
      
      private var f:MovieClip;
      
      public function Game(param1:Number)
      {
         super();
         this.fps = param1;
      }
      
      public function init(param1:uint, param2:uint) : void
      {
         var _loc4_:Player = null;
         this.status = Game.INIT;
         this.field = new Field(param1,param2,this);
         var _loc3_:uint = 0;
         for each(_loc4_ in this.getActivePlayers())
         {
            _loc3_++;
            _loc4_.setScore(0);
            _loc4_.setField(this.field);
         }
         this.targetScore = (_loc3_ - 1) * this.pointLimit;
         this.field.addEventListener(Player.CHANGE_X,this.handleChangeX);
         this.field.addEventListener(Player.CHANGE_Y,this.handleChangeY);
         this.powerUpManager = new PowerUpManager(this,this.field);
         this.lastRound = false;
         this.running = false;
         this.AiRunning = false;
      }
      
      public function prepareAiGame() : void
      {
         this.playAi = true;
      }
      
      public function resetAiGame() : void
      {
         this.playAi = false;
      }
      
      public function isAiGame() : Boolean
      {
         return this.playAi;
      }
      
      public function isRunning() : Boolean
      {
         return this.running;
      }
      
      public function addPlayer(param1:Player) : void
      {
         this.players.push(param1);
         param1.addEventListener(PlayerEvent.MOVE,this.handleMove);
      }
      
      public function togglePlayer(param1:uint) : void
      {
         var _loc2_:Player = null;
         for each(_loc2_ in this.players)
         {
            if(_loc2_.getActiveKey() == param1)
            {
               _loc2_.toggleActive();
               dispatchEvent(new PlayerEvent(PlayerEvent.TOGGLE,false,false,_loc2_));
            }
         }
      }
      
      public function getActivePlayers() : Array
      {
         var _loc2_:Player = null;
         var _loc1_:Array = new Array();
         for each(_loc2_ in this.players)
         {
            if(_loc2_.getActive())
            {
               _loc1_.push(_loc2_);
            }
         }
         return _loc1_;
      }
      
      public function getAlivePlayers() : Array
      {
         var _loc2_:Player = null;
         var _loc1_:Array = new Array();
         for each(_loc2_ in this.players)
         {
            if(_loc2_.getActive() && _loc2_.getAlive())
            {
               _loc1_.push(_loc2_);
            }
         }
         return _loc1_;
      }
      
      public function getAllPlayers() : Array
      {
         return this.players;
      }
      
      public function gameReady() : Boolean
      {
         var _loc4_:Player = null;
         var _loc1_:int = 0;
         var _loc2_:String = String(this.getActivePlayers().length);
         var _loc3_:String = this.getGamePlay();
         for each(_loc4_ in this.players)
         {
            if(_loc4_.getActive())
            {
               _loc1_++;
            }
         }
         if(_loc1_ == 1 && this.playAi)
         {
            for each(_loc4_ in this.players)
            {
               if(!_loc4_.getActive())
               {
                  _loc1_++;
                  _loc4_.setActive(true);
                  _loc4_.setAI(true);
               }
            }
         }
         if(_loc1_ > 1)
         {
            MochiEvents.trackEvent("Number of players",_loc2_);
            MochiEvents.trackEvent("Game mode",_loc3_);
            if(this.playAi)
            {
               MochiEvents.trackEvent("AI","yes");
            }
            else
            {
               MochiEvents.trackEvent("AI","no");
            }
            return true;
         }
         return false;
      }
      
      public function setup() : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc8_:Player = null;
         this.field.reset();
         this.powerUpManager.reset();
         var _loc1_:uint = this.field.getWidth();
         var _loc2_:uint = this.field.getHeight();
         var _loc7_:Array = this.getActivePlayers();
         for each(_loc8_ in _loc7_)
         {
            _loc8_.reset();
            _loc8_.setFieldWidth(_loc1_,_loc2_);
            dispatchEvent(new PlayerEvent(Player.REDRAW,false,false,_loc8_));
            _loc5_ = _loc8_.getRadius();
            _loc3_ = 2 * _loc5_ + Math.random() * (_loc1_ - 4 * _loc5_);
            _loc4_ = 2 * _loc5_ + Math.random() * (_loc2_ - 4 * _loc5_);
            _loc6_ = Math.random() * 2 * Math.PI;
            _loc8_.setStartPosition(_loc3_,_loc4_,_loc6_);
            _loc8_.startMove();
         }
         this.status = Game.SETUP;
      }
      
      public function handleMove(param1:PlayerEvent) : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = false;
         var _loc2_:Player = param1.getPlayer();
         if(!_loc2_.getHole())
         {
            _loc3_ = this.field.addBody(_loc2_);
            if(_loc3_)
            {
               this.handleHit(_loc2_);
            }
         }
         if(this.usePowerUps)
         {
            _loc4_ = this.powerUpManager.powerUpAdded();
            this.powerUpManager.checkCollision(_loc2_);
         }
         _loc2_.handleTunneling(this.field.getWidth(),this.field.getHeight(),this.field.getOpenBorders());
         dispatchEvent(new PlayerEvent(PlayerEvent.MOVE,false,false,param1.getPlayer()));
      }
      
      private function handleHit(param1:Player) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Player = null;
         var _loc4_:Number = NaN;
         var _loc5_:Player = null;
         var _loc6_:int = 0;
         var _loc7_:Player = null;
         var _loc8_:Player = null;
         var _loc9_:Player = null;
         if(this.status == Game.PLAY)
         {
            param1.setAlive(false);
            _loc2_ = 0;
            for each(_loc3_ in this.getAlivePlayers())
            {
               _loc2_++;
               _loc3_.addScore();
               if(this.playAi && !param1.getAI())
               {
                  _loc3_.setSpeed(_loc3_.getSpeed() * 2.5);
               }
            }
            _loc4_ = 0;
            for each(_loc5_ in this.getActivePlayers())
            {
               if(_loc5_.getScore() > _loc4_)
               {
                  _loc4_ = _loc5_.getScore();
               }
            }
            if(_loc4_ >= this.targetScore)
            {
               this.lastRound = true;
               _loc6_ = 0;
               for each(_loc7_ in this.getActivePlayers())
               {
                  if(_loc7_.getScore() + 1 >= _loc4_)
                  {
                     _loc6_++;
                  }
               }
               if(_loc6_ >= 2)
               {
                  this.targetScore = _loc4_ + 1;
                  this.lastRound = false;
               }
            }
            dispatchEvent(new PlayerEvent(Game.PLAYER_DIED,false,false,param1));
            if(_loc2_ <= 1)
            {
               dispatchEvent(new Event(Game.PLAY_END));
               this.playEnd();
               if(this.AiRunning)
               {
                  this.AiRunning = false;
               }
               if(this.lastRound)
               {
                  for each(_loc9_ in this.getActivePlayers())
                  {
                     if(_loc8_ == null)
                     {
                        _loc8_ = _loc9_;
                     }
                     else if(_loc9_.getScore() > _loc8_.getScore())
                     {
                        _loc8_ = _loc9_;
                     }
                  }
                  dispatchEvent(new PlayerEvent(Game.GAME_END,false,false,_loc8_));
                  this.gameEnd();
               }
            }
         }
      }
      
      public function getTargetScore() : uint
      {
         return this.targetScore;
      }
      
      public function getStatus() : String
      {
         return this.status;
      }
      
      public function getFPS() : uint
      {
         return this.fps;
      }
      
      public function start() : void
      {
         this.status = Game.PLAY;
         this.running = true;
         dispatchEvent(new Event(Game.START));
      }
      
      public function pause() : void
      {
         this.status = Game.PAUSE;
         this.running = false;
         dispatchEvent(new Event(Game.PAUSE));
      }
      
      public function resume() : void
      {
         this.status = Game.PLAY;
         this.running = true;
         dispatchEvent(new Event(Game.RESUMED));
      }
      
      private function playEnd() : void
      {
         this.status = Game.PLAY_END;
         this.running = false;
      }
      
      private function gameEnd() : void
      {
         this.status = Game.GAME_END;
      }
      
      public function move() : void
      {
         var _loc1_:Player = null;
         for each(_loc1_ in this.getAlivePlayers())
         {
            _loc1_.move();
         }
         if(this.usePowerUps)
         {
            this.powerUpManager.possiblyAddPowerUp();
            this.powerUpManager.tick();
         }
      }
      
      public function handleChangeX(param1:PlayerEvent) : void
      {
         dispatchEvent(new PlayerEvent(Player.CHANGE_X,false,false,param1.getPlayer()));
      }
      
      public function handleChangeY(param1:PlayerEvent) : void
      {
         dispatchEvent(new PlayerEvent(Player.CHANGE_Y,false,false,param1.getPlayer()));
      }
      
      public function setGamePlay(param1:String) : void
      {
         this.gamePlay = param1;
         if(param1 == Game.ARCADE)
         {
            this.usePowerUps = true;
         }
         else
         {
            this.usePowerUps = false;
         }
      }
      
      public function getGamePlay() : String
      {
         return this.gamePlay;
      }
      
      public function getPowerUpManager() : PowerUpManager
      {
         return this.powerUpManager;
      }
   }
}

