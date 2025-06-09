package powerups
{
   import flash.display.*;
   
   public class PowerUp
   {
      
      public static const REMOVED_FROM_STAGE:String = "removed_from_stage";
      
      public static const ADDED_TO_STAGE:String = "added_to_stage";
      
      protected var radius:Number;
      
      protected var ticks:int;
      
      protected var current_tick:int;
      
      protected var posX:Number;
      
      protected var posY:Number;
      
      protected var mc:MovieClip;
      
      protected var needsPlayer:Boolean = false;
      
      protected var needsField:Boolean = false;
      
      protected var needsGame:Boolean = false;
      
      protected var player:Player;
      
      protected var field:Field;
      
      protected var game:Game;
      
      public function PowerUp(param1:Number, param2:int)
      {
         super();
         this.radius = param1;
         this.ticks = param2;
      }
      
      public function checkCollision(param1:Player) : Boolean
      {
         var _loc2_:Number = param1.getX() - this.posX;
         var _loc3_:Number = param1.getY() - this.posY;
         var _loc4_:Number = param1.getHistory(1).x - this.posX;
         var _loc5_:Number = param1.getHistory(1).y - this.posY;
         if(Math.sqrt(_loc2_ * _loc2_ + _loc3_ * _loc3_) < this.radius + param1.getWidth() / 2)
         {
            return true;
         }
         return false;
      }
      
      public function needPlayer() : Boolean
      {
         return this.needsPlayer;
      }
      
      public function needField() : Boolean
      {
         return this.needsField;
      }
      
      public function needGame() : Boolean
      {
         return this.needsGame;
      }
      
      public function addPlayer(param1:Player) : void
      {
         this.player = param1;
      }
      
      public function addField(param1:Field) : void
      {
         this.field = param1;
      }
      
      public function addGame(param1:Game) : void
      {
         this.game = param1;
      }
      
      public function takeEffect() : void
      {
         this.current_tick = this.ticks;
      }
      
      public function removeEffect() : void
      {
      }
      
      public function getPowerUpMc() : MovieClip
      {
         return this.mc;
      }
      
      public function getTicks() : int
      {
         return this.ticks;
      }
      
      public function tick() : void
      {
         --this.current_tick;
         if(this.current_tick == 0)
         {
            this.removeEffect();
         }
      }
      
      public function finished() : Boolean
      {
         if(this.current_tick == 0)
         {
            return true;
         }
         return false;
      }
      
      public function setCoordinates(param1:uint, param2:uint) : void
      {
         this.posX = Math.random() * (param1 - 2 * this.radius) + this.radius;
         this.posY = Math.random() * (param2 - 2 * this.radius) + this.radius;
      }
      
      public function getX() : Number
      {
         return this.posX;
      }
      
      public function getY() : Number
      {
         return this.posY;
      }
      
      public function getRadius() : Number
      {
         return this.radius;
      }
      
      public function activatePowerUp() : void
      {
         this.takeEffect();
      }
      
      public function getMc() : MovieClip
      {
         return this.mc;
      }
   }
}

