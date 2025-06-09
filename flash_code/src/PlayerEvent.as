package
{
   import flash.events.Event;
   
   public class PlayerEvent extends Event
   {
      
      public static const TOGGLE:String = "toggle";
      
      public static const MOVE:String = "move";
      
      private var player:Player;
      
      public function PlayerEvent(param1:String, param2:Boolean = false, param3:Boolean = false, param4:* = null)
      {
         super(param1,param2,param3);
         this.player = param4;
      }
      
      public function getActive() : Boolean
      {
         return this.player.getActive();
      }
      
      public function getId() : uint
      {
         return this.player.getId();
      }
      
      public function getPlayer() : Player
      {
         return this.player;
      }
   }
}

