package powerups
{
   public class PowerUpTimePowerUp extends PowerUp
   {
      
      private var pum:PowerUpManager;
      
      public function PowerUpTimePowerUp(param1:Number, param2:int)
      {
         super(param1,param2);
         needsGame = true;
         mc = new PowerUpTimeMc();
      }
      
      override public function takeEffect() : void
      {
         this.pum = game.getPowerUpManager();
         this.pum.startPowerUpTime(4);
         super.takeEffect();
         var _loc1_:Sounds = Sounds.getInstance();
         _loc1_.playYes();
      }
      
      override public function removeEffect() : void
      {
         this.pum.stopPowerUpTime();
      }
   }
}

