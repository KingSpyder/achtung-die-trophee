package powerups
{
   public class PlayerTunnelPowerUp extends PowerUp
   {
      
      public function PlayerTunnelPowerUp(param1:Number, param2:int)
      {
         super(param1,param2);
         needsPlayer = true;
         needsGame = true;
         mc = new TunnelPlayerMc();
      }
      
      override public function takeEffect() : void
      {
         player.enableTunneling();
         super.takeEffect();
         game.dispatchEvent(new PlayerEvent(Player.START_TUNNELING,false,false,player));
         var _loc1_:Sounds = Sounds.getInstance();
         _loc1_.playYes();
      }
      
      override public function removeEffect() : void
      {
         if(!player.cancleTunneling())
         {
            game.dispatchEvent(new PlayerEvent(Player.STOP_TUNNELING,false,false,player));
         }
      }
   }
}

