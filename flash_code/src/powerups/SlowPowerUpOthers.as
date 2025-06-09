package powerups
{
   public class SlowPowerUpOthers extends PowerUp
   {
      
      public function SlowPowerUpOthers(param1:Number, param2:int)
      {
         super(param1,param2);
         needsPlayer = true;
         needsGame = true;
         mc = new zzzothers();
      }
      
      override public function takeEffect() : void
      {
         var _loc1_:Player = null;
         var _loc2_:Sounds = null;
         for each(_loc1_ in game.getAlivePlayers())
         {
            if(_loc1_ != player)
            {
               _loc1_.setSpeed(_loc1_.getSpeed() / 2);
            }
         }
         super.takeEffect();
         _loc2_ = Sounds.getInstance();
         _loc2_.playNo();
      }
      
      override public function removeEffect() : void
      {
         var _loc1_:Player = null;
         for each(_loc1_ in game.getAlivePlayers())
         {
            if(_loc1_ != player)
            {
               _loc1_.setSpeed(_loc1_.getSpeed() * 2);
            }
         }
      }
   }
}

