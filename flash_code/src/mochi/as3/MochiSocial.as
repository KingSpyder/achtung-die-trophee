package mochi.as3
{
   public class MochiSocial
   {
      
      public static const LOGGED_IN:String = "LoggedIn";
      
      public static const LOGGED_OUT:String = "LoggedOut";
      
      public static const LOGIN_SHOW:String = "LoginShow";
      
      public static const LOGIN_HIDE:String = "LoginHide";
      
      public static const LOGIN_SHOWN:String = "LoginShown";
      
      public static const PROFILE_SHOW:String = "ProfileShow";
      
      public static const PROFILE_HIDE:String = "ProfileHide";
      
      public static const PROPERTIES_SAVED:String = "PropertySaved";
      
      public static const WIDGET_LOADED:String = "WidgetLoaded";
      
      public static const FRIEND_LIST:String = "FriendsList";
      
      public static const PROFILE_DATA:String = "ProfileData";
      
      public static const GAMEPLAY_DATA:String = "GameplayData";
      
      public static const ACTION_CANCELED:String = "onCancel";
      
      public static const ACTION_COMPLETE:String = "onComplete";
      
      public static const USER_INFO:String = "UserInfo";
      
      public static const ERROR:String = "Error";
      
      public static const IO_ERROR:String = "IOError";
      
      public static const NO_USER:String = "NoUser";
      
      public static const PROPERTIES_SIZE:String = "PropertiesSize";
      
      private static var _dispatcher:MochiEventDispatcher = new MochiEventDispatcher();
      
      public static var _user_info:Object = null;
      
      MochiSocial.addEventListener(MochiSocial.LOGGED_IN,function(param1:Object):void
      {
         _user_info = param1;
      });
      MochiSocial.addEventListener(MochiSocial.LOGGED_OUT,function(param1:Object):void
      {
         _user_info = null;
      });
      
      public function MochiSocial()
      {
         super();
      }
      
      public static function getVersion() : String
      {
         return MochiServices.getVersion();
      }
      
      public static function getAPIURL() : String
      {
         if(!_user_info)
         {
            return null;
         }
         return _user_info.api_url;
      }
      
      public static function getAPIToken() : String
      {
         if(!_user_info)
         {
            return null;
         }
         return _user_info.api_token;
      }
      
      public static function showLoginWidget(param1:Object = null) : void
      {
         MochiServices.setContainer();
         MochiServices.bringToTop();
         MochiServices.send("social_showLoginWidget",{"options":param1});
      }
      
      public static function hideLoginWidget() : void
      {
         MochiServices.send("social_hideLoginWidget");
      }
      
      public static function requestLogin(param1:Object = null) : void
      {
         MochiServices.setContainer();
         MochiServices.bringToTop();
         MochiServices.send("social_requestLogin",param1);
      }
      
      public static function saveUserProperties(param1:Object) : void
      {
         MochiServices.send("social_saveUserProperties",param1);
      }
      
      public static function getFriendsList(param1:Object = null) : void
      {
         MochiServices.send("social_getFriendsList",param1);
      }
      
      public static function postToStream(param1:Object = null) : void
      {
         MochiServices.setContainer();
         MochiServices.bringToTop();
         MochiServices.send("social_postToStream",param1);
      }
      
      public static function inviteFriends(param1:Object = null) : void
      {
         MochiServices.setContainer();
         MochiServices.bringToTop();
         MochiServices.send("social_inviteFriends",param1);
      }
      
      public static function requestFan(param1:Object = null) : void
      {
         MochiServices.setContainer();
         MochiServices.bringToTop();
         MochiServices.send("social_requestFan",param1);
      }
      
      public static function addEventListener(param1:String, param2:Function) : void
      {
         _dispatcher.addEventListener(param1,param2);
      }
      
      public static function get loggedIn() : Boolean
      {
         return _user_info != null;
      }
      
      public static function triggerEvent(param1:String, param2:Object) : void
      {
         _dispatcher.triggerEvent(param1,param2);
      }
      
      public static function removeEventListener(param1:String, param2:Function) : void
      {
         _dispatcher.removeEventListener(param1,param2);
      }
   }
}

