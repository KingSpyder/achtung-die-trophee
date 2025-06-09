package powerups
{
   public class OldSnakeyOthersPowerUp extends PowerUp
   {
      
      public function OldSnakeyOthersPowerUp(param1:Number, param2:int)
      {
         super(param1,param2);
         needsPlayer = true;
         needsGame = true;
         mc = new SnakeOthersMc();
      }
      
      override public function takeEffect() : void
      {
         var _loc1_:Player = null;
         var _loc2_:Sounds = null;
         for each(_loc1_ in game.getAlivePlayers())
         {
            if(_loc1_ != player)
            {
               _loc1_.enableOldSnakey();
               game.dispatchEvent(new PlayerEvent(Player.START_OLD_SNAKEY,false,false,_loc1_));
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
               if(!_loc1_.cancleOldSnakey())
               {
                  game.dispatchEvent(new PlayerEvent(Player.STOP_OLD_SNAKEY,false,false,_loc1_));
               }
            }
         }
      }
   }
}

