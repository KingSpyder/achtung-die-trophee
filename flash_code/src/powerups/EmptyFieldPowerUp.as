package powerups
{
   import flash.events.Event;
   
   public class EmptyFieldPowerUp extends PowerUp
   {
      
      public function EmptyFieldPowerUp(param1:Number, param2:int)
      {
         super(param1,param2);
         needsField = true;
         needsGame = true;
         mc = new EmptyFieldMc();
      }
      
      override public function takeEffect() : void
      {
         field.empty();
         super.takeEffect();
         game.dispatchEvent(new Event(Field.EMPTIED));
         var _loc1_:Sounds = Sounds.getInstance();
         _loc1_.playLike();
      }
      
      override public function removeEffect() : void
      {
      }
   }
}

