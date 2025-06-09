package powerups
{
   public class ThinPowerUp extends PowerUp
   {
      
      public function ThinPowerUp(param1:Number, param2:int)
      {
         super(param1,param2);
         needsPlayer = true;
         needsGame = true;
         mc = new SmallMc();
      }
      
      override public function takeEffect() : void
      {
         player.setWidth(player.getWidth() / 2);
         super.takeEffect();
         game.dispatchEvent(new PlayerEvent(Player.REDRAW,false,false,player));
         var _loc1_:Sounds = Sounds.getInstance();
         _loc1_.playYes();
      }
      
      override public function removeEffect() : void
      {
         player.setWidth(player.getWidth() * 2);
         game.dispatchEvent(new PlayerEvent(Player.REDRAW,false,false,player));
      }
   }
}

