package powerups
{
   public class RandomPowerUp extends PowerUp
   {
      
      private var pu:PowerUp;
      
      public function RandomPowerUp(param1:Number, param2:int)
      {
         super(param1,param2);
         needsGame = true;
         needsPlayer = true;
         mc = new RandomMc();
      }
      
      override public function takeEffect() : void
      {
         var _loc1_:PowerUpManager = game.getPowerUpManager();
         this.pu = _loc1_.activateRandomPowerUp(player);
         super.takeEffect();
         var _loc2_:Sounds = Sounds.getInstance();
         _loc2_.playYes();
      }
      
      override public function removeEffect() : void
      {
      }
   }
}

