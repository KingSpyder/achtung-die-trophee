package flashx.textLayout.property
{
   import flashx.textLayout.tlf_internal;
   
   use namespace tlf_internal;
   
   public class NumberOrPercentOrEnumProperty extends NumberOrPercentProperty
   {
      
      private var _range:Object;
      
      private var _defaultValue:Object;
      
      public function NumberOrPercentOrEnumProperty(param1:String, param2:Object, param3:Boolean, param4:String, param5:Number, param6:Number, param7:String, param8:String, ... rest)
      {
         this._range = EnumStringProperty.tlf_internal::createRange(rest);
         if(param2 is String && Boolean(this._range.hasOwnProperty(param2)))
         {
            this._defaultValue = param2;
         }
         super(param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      override public function get defaultValue() : Object
      {
         return this._defaultValue != null ? this._defaultValue : super.defaultValue;
      }
      
      public function get range() : Object
      {
         return Property.shallowCopy(this._range);
      }
      
      override public function setHelper(param1:*, param2:*) : *
      {
         if(param2 === null)
         {
            param2 = undefined;
         }
         if(param2 === undefined)
         {
            return param2;
         }
         return this._range.hasOwnProperty(param2) ? param2 : super.setHelper(param1,param2);
      }
      
      override public function hash(param1:Object, param2:uint) : uint
      {
         var _loc3_:uint = uint(this._range[param1]);
         if(_loc3_ != 0)
         {
            return UintProperty.tlf_internal::doHash(_loc3_,param2);
         }
         return super.hash(param1,param2);
      }
   }
}

