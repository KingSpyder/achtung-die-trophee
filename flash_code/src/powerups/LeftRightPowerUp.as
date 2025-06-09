package powerups
{
   public class LeftRightPowerUp extends PowerUp
   {
      
      private var left:uint;
      
      private var right:uint;
      
      public function LeftRightPowerUp(param1:Number, param2:int)
      {
         super(param1,param2);
         needsPlayer = true;
         needsGame = true;
         mc = new LeftRightMc();
      }
      
      override public function takeEffect() : void
      {
         var _loc2_:Player = null;
         var _loc3_:Sounds = null;
         var _loc1_:Array = game.getAlivePlayers();
         for each(_loc2_ in game.getAlivePlayers())
         {
            if(_loc2_ != player)
            {
               _loc2_.reverseControls();
               game.dispatchEvent(new PlayerEvent(Player.START_REVERSE,false,false,_loc2_));
            }
         }
         super.takeEffect();
         _loc3_ = Sounds.getInstance();
         _loc3_.playNo();
      }
      
      override public function removeEffect() : void
      {
         var _loc1_:Player = null;
         for each(_loc1_ in game.getAlivePlayers())
         {
            if(_loc1_ != player)
            {
               _loc1_.resetControls();
               game.dispatchEvent(new PlayerEvent(Player.STOP_REVERSE,false,false,_loc1_));
            }
         }
      }
   }
}

