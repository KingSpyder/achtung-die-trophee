package powerups
{
   public class ThickPowerUp extends PowerUp
   {
      
      public function ThickPowerUp(param1:Number, param2:int)
      {
         super(param1,param2);
         needsPlayer = true;
         needsGame = true;
         mc = new ThickMc();
      }
      
      override public function takeEffect() : void
      {
         var _loc2_:Player = null;
         var _loc3_:Sounds = null;
         var _loc1_:Array = game.getAlivePlayers();
         for each(_loc2_ in game.getAlivePlayers())
         {
            if(_loc2_ != player)
            {
               _loc2_.setWidth(_loc2_.getWidth() * 2);
               _loc2_.setHoleWidth(_loc2_.getHoleWidth() * 2);
               game.dispatchEvent(new PlayerEvent(Player.REDRAW,false,false,_loc2_));
            }
         }
         super.takeEffect();
         _loc3_ = Sounds.getInstance();
         _loc3_.playNo();
      }
      
      override public function removeEffect() : void
      {
         var _loc1_:Player = null;
         for each(_loc1_ in game.getAlivePlayers())
         {
            if(_loc1_ != player)
            {
               _loc1_.setWidth(_loc1_.getWidth() / 2);
               _loc1_.setHoleWidth(_loc1_.getHoleWidth() / 2);
               game.dispatchEvent(new PlayerEvent(Player.REDRAW,false,false,_loc1_));
            }
         }
      }
   }
}

