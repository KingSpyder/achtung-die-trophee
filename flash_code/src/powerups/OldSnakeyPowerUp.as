package powerups
{
   public class OldSnakeyPowerUp extends PowerUp
   {
      
      public function OldSnakeyPowerUp(param1:Number, param2:int)
      {
         super(param1,param2);
         needsPlayer = true;
         needsGame = true;
         mc = new SnakeMc();
      }
      
      override public function takeEffect() : void
      {
         player.enableOldSnakey();
         game.dispatchEvent(new PlayerEvent(Player.START_OLD_SNAKEY,false,false,player));
         super.takeEffect();
         var _loc1_:Sounds = Sounds.getInstance();
         _loc1_.playYes();
      }
      
      override public function removeEffect() : void
      {
         if(!player.cancleOldSnakey())
         {
            game.dispatchEvent(new PlayerEvent(Player.STOP_OLD_SNAKEY,false,false,player));
         }
      }
   }
}

