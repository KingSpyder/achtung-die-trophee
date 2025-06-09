package powerups
{
   import flash.events.Event;
   
   public class BorderTunnelPowerUp extends PowerUp
   {
      
      public function BorderTunnelPowerUp(param1:Number, param2:int)
      {
         super(param1,param2);
         needsField = true;
         needsGame = true;
         mc = new TunnelAllMc();
      }
      
      override public function takeEffect() : void
      {
         field.enableOpenBorders();
         super.takeEffect();
         game.dispatchEvent(new Event(Field.START_OPEN_BORDERS));
         var _loc1_:Sounds = Sounds.getInstance();
         _loc1_.playLike();
      }
      
      override public function removeEffect() : void
      {
         if(!field.cancleOpenBorders())
         {
            game.dispatchEvent(new Event(Field.STOP_OPEN_BORDERS));
         }
      }
   }
}

