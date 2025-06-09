package
{
   import flash.events.EventDispatcher;
   import flash.events.KeyboardEvent;
   
   public class Controller extends EventDispatcher
   {
      
      protected var locked:Boolean = false;
      
      public function Controller()
      {
         super();
      }
      
      public function handleKeyDown(param1:KeyboardEvent) : void
      {
      }
      
      public function handleKeyUp(param1:KeyboardEvent) : void
      {
      }
      
      public function init() : void
      {
      }
      
      public function lock() : void
      {
         this.locked = true;
      }
      
      public function unlock() : void
      {
         this.locked = false;
      }
   }
}

