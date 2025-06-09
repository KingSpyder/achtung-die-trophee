package powerups
{
   public class SpeedPowerUp extends PowerUp
   {
      
      public function SpeedPowerUp(param1:Number, param2:int)
      {
         super(param1,param2);
         needsPlayer = true;
         mc = new LightningPowerUp();
      }
      
      override public function takeEffect() : void
      {
         player.setSpeed(player.getSpeed() * 2);
         player.setRadius(player.getRadius() * 1.5);
         super.takeEffect();
         var _loc1_:Sounds = Sounds.getInstance();
         _loc1_.playYes();
      }
      
      override public function removeEffect() : void
      {
         player.setSpeed(player.getSpeed() / 2);
         player.setRadius(player.getRadius() / 1.5);
      }
   }
}

