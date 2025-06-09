package mochi.as3
{
   import flash.display.MovieClip;
   
   public class MochiEvents
   {
      
      private static var gameStart:Number;
      
      private static var levelStart:Number;
      
      public static const ACHIEVEMENT_RECEIVED:String = "AchievementReceived";
      
      public static const ALIGN_TOP_LEFT:String = "ALIGN_TL";
      
      public static const ALIGN_TOP:String = "ALIGN_T";
      
      public static const ALIGN_TOP_RIGHT:String = "ALIGN_TR";
      
      public static const ALIGN_LEFT:String = "ALIGN_L";
      
      public static const ALIGN_CENTER:String = "ALIGN_C";
      
      public static const ALIGN_RIGHT:String = "ALIGN_R";
      
      public static const ALIGN_BOTTOM_LEFT:String = "ALIGN_BL";
      
      public static const ALIGN_BOTTOM:String = "ALIGN_B";
      
      public static const ALIGN_BOTTOM_RIGHT:String = "ALIGN_BR";
      
      public static const FORMAT_SHORT:String = "ShortForm";
      
      public static const FORMAT_LONG:String = "LongForm";
      
      private static var _dispatcher:MochiEventDispatcher = new MochiEventDispatcher();
      
      public function MochiEvents()
      {
         super();
      }
      
      public static function getVersion() : String
      {
         return MochiServices.getVersion();
      }
      
      public static function startSession(param1:String) : void
      {
         MochiServices.send("events_beginSession",{"achievementID":param1},null,null);
      }
      
      public static function setNotifications(param1:MovieClip, param2:Object) : void
      {
         var _loc4_:Object = null;
         var _loc3_:Object = {};
         for(_loc4_ in param2)
         {
            _loc3_[_loc4_] = param2[_loc4_];
         }
         _loc3_.clip = param1;
         MochiServices.send("events_setNotifications",_loc3_,null,null);
      }
      
      public static function addEventListener(param1:String, param2:Function) : void
      {
         _dispatcher.addEventListener(param1,param2);
      }
      
      public static function triggerEvent(param1:String, param2:Object) : void
      {
         _dispatcher.triggerEvent(param1,param2);
      }
      
      public static function removeEventListener(param1:String, param2:Function) : void
      {
         _dispatcher.removeEventListener(param1,param2);
      }
      
      public static function startPlay(param1:String = "gameplay") : void
      {
         MochiServices.send("events_setRoundID",{"tag":String(param1)},null,null);
      }
      
      public static function endPlay() : void
      {
         MochiServices.send("events_clearRoundID",null,null,null);
      }
      
      public static function trackEvent(param1:String, param2:* = null) : void
      {
         MochiServices.send("events_trackEvent",{
            "tag":param1,
            "value":param2
         },null,null);
      }
   }
}

