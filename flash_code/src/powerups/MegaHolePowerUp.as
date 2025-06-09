package powerups
{
   public class MegaHolePowerUp extends PowerUp
   {
      
      public function MegaHolePowerUp(param1:Number, param2:int)
      {
         super(param1,param2);
         needsPlayer = true;
         mc = new HoleMc();
      }
      
      override public function takeEffect() : void
      {
         player.enableMegaHole();
         super.takeEffect();
         var _loc1_:Sounds = Sounds.getInstance();
         _loc1_.playYes();
      }
      
      override public function removeEffect() : void
      {
         player.cancleMegaHole();
      }
   }
}

