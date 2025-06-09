package powerups
{
   public class PowerUpManager
   {
      
      private var possiblePowerUps:Array;
      
      private var powerUps:Array;
      
      private var activePowerUps:Array;
      
      private var game:Game;
      
      private var field:Field;
      
      private var R:Number = 20;
      
      private var powerUpFactor:Number;
      
      private var powerUpTimeCount:int;
      
      public function PowerUpManager(param1:Game, param2:Field)
      {
         super();
         this.game = param1;
         this.field = param2;
         this.reset();
      }
      
      public function reset() : void
      {
         this.empty();
         this.possiblePowerUps = new Array();
         this.possiblePowerUps.push({
            "obj":SpeedPowerUp,
            "chance":70,
            "radius":this.R,
            "duration":3
         });
         this.possiblePowerUps.push({
            "obj":SlowPowerUp,
            "chance":70,
            "radius":this.R,
            "duration":10
         });
         this.possiblePowerUps.push({
            "obj":ThinPowerUp,
            "chance":70,
            "radius":this.R,
            "duration":15
         });
         this.possiblePowerUps.push({
            "obj":MegaHolePowerUp,
            "chance":70,
            "radius":this.R,
            "duration":5
         });
         this.possiblePowerUps.push({
            "obj":PlayerTunnelPowerUp,
            "chance":70,
            "radius":this.R,
            "duration":15
         });
         this.possiblePowerUps.push({
            "obj":SlowPowerUpOthers,
            "chance":70,
            "radius":this.R,
            "duration":5
         });
         this.possiblePowerUps.push({
            "obj":ThickPowerUp,
            "chance":50,
            "radius":this.R,
            "duration":7.5
         });
         this.possiblePowerUps.push({
            "obj":LeftRightPowerUp,
            "chance":80,
            "radius":this.R,
            "duration":5
         });
         this.possiblePowerUps.push({
            "obj":BorderTunnelPowerUp,
            "chance":70,
            "radius":this.R,
            "duration":10
         });
         this.possiblePowerUps.push({
            "obj":EmptyFieldPowerUp,
            "chance":80,
            "radius":this.R,
            "duration":0
         });
         this.possiblePowerUps.push({
            "obj":OldSnakeyPowerUp,
            "chance":70,
            "radius":this.R,
            "duration":15
         });
         this.possiblePowerUps.push({
            "obj":OldSnakeyOthersPowerUp,
            "chance":70,
            "radius":this.R,
            "duration":7.5
         });
         this.possiblePowerUps.push({
            "obj":SpeedPowerUpOthers,
            "chance":70,
            "radius":this.R,
            "duration":3
         });
         this.possiblePowerUps.push({
            "obj":RandomPowerUp,
            "chance":80,
            "radius":this.R,
            "duration":0
         });
         this.possiblePowerUps.push({
            "obj":PowerUpTimePowerUp,
            "chance":80,
            "radius":this.R,
            "duration":5
         });
         this.powerUpTimeCount = 0;
         this.powerUpFactor = 1;
      }
      
      public function empty() : void
      {
         this.powerUps = new Array();
         this.activePowerUps = new Array();
      }
      
      public function checkCollision(param1:Player) : Boolean
      {
         var _loc2_:PowerUp = null;
         for each(_loc2_ in this.powerUps)
         {
            if(_loc2_.checkCollision(param1))
            {
               if(_loc2_.needPlayer())
               {
                  _loc2_.addPlayer(param1);
               }
               if(_loc2_.needField())
               {
                  _loc2_.addField(this.field);
               }
               if(_loc2_.needGame())
               {
                  _loc2_.addGame(this.game);
               }
               _loc2_.takeEffect();
               this.game.dispatchEvent(new PowerUpEvent(PowerUp.REMOVED_FROM_STAGE,false,false,_loc2_));
               this.powerUps.splice(this.powerUps.indexOf(_loc2_),1);
               if(_loc2_.getTicks())
               {
                  this.activePowerUps.push(_loc2_);
               }
            }
         }
         return false;
      }
      
      public function powerUpAdded() : Boolean
      {
         return false;
      }
      
      public function tick() : void
      {
         var _loc1_:PowerUp = null;
         for each(_loc1_ in this.activePowerUps)
         {
            _loc1_.tick();
         }
      }
      
      public function possiblyAddPowerUp() : void
      {
         var _loc2_:Object = null;
         var _loc3_:Class = null;
         var _loc4_:PowerUp = null;
         var _loc1_:int = int(this.game.getFPS());
         for each(_loc2_ in this.possiblePowerUps)
         {
            if(Math.random() < 1 / (_loc2_.chance / this.powerUpFactor) / _loc1_)
            {
               _loc3_ = _loc2_.obj;
               _loc4_ = new _loc2_.obj(_loc2_.radius,_loc2_.duration * _loc1_);
               _loc4_.setCoordinates(this.field.getWidth(),this.field.getHeight());
               this.powerUps.push(_loc4_);
               this.game.dispatchEvent(new PowerUpEvent(PowerUp.ADDED_TO_STAGE,false,false,_loc4_));
            }
         }
      }
      
      public function activateRandomPowerUp(param1:Player) : PowerUp
      {
         var _loc2_:int = int(this.possiblePowerUps.length);
         var _loc3_:Object = this.possiblePowerUps[Math.floor(Math.random() * _loc2_)];
         var _loc4_:PowerUp = new _loc3_.obj(_loc3_.radius,_loc3_.duration * this.game.getFPS());
         if(_loc4_.needPlayer())
         {
            _loc4_.addPlayer(param1);
         }
         if(_loc4_.needField())
         {
            _loc4_.addField(this.field);
         }
         if(_loc4_.needGame())
         {
            _loc4_.addGame(this.game);
         }
         _loc4_.activatePowerUp();
         if(_loc4_.getTicks())
         {
            this.activePowerUps.push(_loc4_);
         }
         return _loc4_;
      }
      
      public function startPowerUpTime(param1:Number) : void
      {
         ++this.powerUpTimeCount;
         this.powerUpFactor = param1;
      }
      
      public function stopPowerUpTime() : void
      {
         --this.powerUpTimeCount;
         if(this.powerUpTimeCount <= 0)
         {
            this.powerUpFactor = 1;
         }
      }
   }
}

