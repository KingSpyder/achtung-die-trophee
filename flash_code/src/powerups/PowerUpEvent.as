package powerups
{
   import flash.events.Event;
   
   public class PowerUpEvent extends Event
   {
      
      private var powerup:PowerUp;
      
      public function PowerUpEvent(param1:String, param2:Boolean = false, param3:Boolean = false, param4:* = null)
      {
         super(param1,param2,param3);
         this.powerup = param4;
      }
      
      public function getPowerUp() : PowerUp
      {
         return this.powerup;
      }
   }
}

