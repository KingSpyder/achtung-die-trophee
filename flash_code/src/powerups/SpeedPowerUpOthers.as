package powerups
{
   public class SpeedPowerUpOthers extends PowerUp
   {
      
      public function SpeedPowerUpOthers(param1:Number, param2:int)
      {
         super(param1,param2);
         needsPlayer = true;
         needsGame = true;
         mc = new LightningPowerUpOthers();
      }
      
      override public function takeEffect() : void
      {
         var _loc1_:Player = null;
         var _loc2_:Sounds = null;
         for each(_loc1_ in game.getAlivePlayers())
         {
            if(_loc1_ != player)
            {
               _loc1_.setSpeed(_loc1_.getSpeed() * 2);
               _loc1_.setRadius(_loc1_.getRadius() * 1.5);
            }
         }
         super.takeEffect();
         _loc2_ = Sounds.getInstance();
         _loc2_.playYes();
      }
      
      override public function removeEffect() : void
      {
         var _loc1_:Player = null;
         for each(_loc1_ in game.getAlivePlayers())
         {
            if(_loc1_ != player)
            {
               _loc1_.setSpeed(_loc1_.getSpeed() / 2);
               _loc1_.setRadius(_loc1_.getRadius() / 1.5);
            }
         }
      }
   }
}

