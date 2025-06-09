package
{
   public class FieldPoint
   {
      
      private var id:int;
      
      private var tick:int;
      
      public function FieldPoint(param1:int, param2:int)
      {
         super();
         this.id = param1;
         this.tick = param2;
      }
      
      public function getTick() : int
      {
         return this.tick;
      }
      
      public function getId() : int
      {
         return this.id;
      }
   }
}

