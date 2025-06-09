package
{
   import flash.events.*;
   import flash.geom.*;
   import flash.utils.*;
   
   public class Field extends EventDispatcher
   {
      
      public static var count:Number = 0;
      
      public static const START_OPEN_BORDERS:String = "start open borders";
      
      public static const STOP_OPEN_BORDERS:String = "stop open borders";
      
      public static const EMPTIED:String = "field emptied";
      
      private var w:uint;
      
      private var h:uint;
      
      private var res:uint = 4;
      
      private var detRes:uint = 16;
      
      private var field:Array;
      
      private var detField:Array;
      
      private var game:Game;
      
      private var openBorders:Boolean;
      
      private var openBorders_reset:Boolean = false;
      
      private var openBordersCount:uint;
      
      public function Field(param1:uint, param2:uint, param3:Game)
      {
         super();
         this.w = param1;
         this.h = param2;
         this.game = param3;
         this.reset();
      }
      
      public function reset() : *
      {
         this.openBorders = this.openBorders_reset;
         this.openBordersCount = 0;
         this.empty();
      }
      
      public function empty() : *
      {
         var _loc2_:uint = 0;
         this.field = new Array();
         var _loc1_:uint = 0;
         while(_loc1_ < this.w * this.res)
         {
            this.field[_loc1_] = new Array();
            _loc1_++;
         }
         this.detField = new Array();
         _loc1_ = 0;
         while(_loc1_ < this.detRes)
         {
            this.detField[_loc1_] = new Array();
            _loc2_ = 0;
            while(_loc2_ < this.detRes)
            {
               this.detField[_loc1_][_loc2_] = 0;
               _loc2_++;
            }
            _loc1_++;
         }
      }
      
      public function addBody(param1:Player) : Boolean
      {
         var _loc2_:Number = param1.getX();
         var _loc3_:Number = param1.getY();
         var _loc4_:Number = param1.getAngle();
         var _loc5_:Number = param1.getWidth() - 0.5;
         if(_loc5_ < 3 / this.res)
         {
            _loc5_ = 3 / this.res;
         }
         var _loc6_:Number = param1.getHeight();
         var _loc7_:Boolean = param1.afterHole();
         if(_loc7_)
         {
            _loc6_ = param1.getAfterHoleLength();
         }
         var _loc8_:Array = new Array();
         var _loc9_:Number = Math.min(Math.abs(1 / Math.cos(param1.getAngle())),Math.abs(1 / Math.sin(param1.getAngle()))) / this.res;
         var _loc10_:Point = new Point(_loc2_,_loc3_);
         var _loc11_:Point = Point.polar(1,_loc4_);
         var _loc12_:Point = _loc11_.clone();
         _loc12_.normalize(_loc9_);
         var _loc13_:Point = Point.polar(1,_loc4_ + Math.PI / 2);
         var _loc14_:Point = _loc13_.clone();
         _loc14_.normalize(_loc9_);
         var _loc15_:Point = _loc11_.clone();
         _loc15_.normalize(_loc6_);
         var _loc16_:Point = _loc13_.clone();
         _loc16_.normalize(_loc5_);
         var _loc17_:Point = _loc16_.clone();
         _loc17_.normalize(_loc5_ / 2);
         var _loc18_:Point = _loc10_.subtract(_loc15_);
         var _loc19_:Point = _loc18_.add(_loc12_);
         var _loc20_:Point = _loc10_.subtract(_loc12_);
         var _loc21_:Point = _loc19_.add(_loc17_);
         _loc21_.subtract(_loc14_);
         var _loc22_:Point = _loc19_.subtract(_loc17_);
         _loc22_.add(_loc14_);
         var _loc23_:Point = _loc20_.add(_loc17_);
         _loc23_.subtract(_loc14_);
         var _loc24_:Point = _loc20_.subtract(_loc17_);
         _loc24_.add(_loc14_);
         var _loc25_:Boolean = this.checkField(_loc21_,_loc23_,_loc8_,param1);
         var _loc26_:Boolean = this.checkField(_loc22_,_loc24_,_loc8_,param1);
         var _loc27_:Boolean = this.checkField(_loc23_,_loc24_,_loc8_,param1);
         var _loc28_:Boolean = false;
         if(_loc7_)
         {
            _loc28_ = this.checkField(_loc21_,_loc22_,_loc8_,param1);
         }
         if(_loc25_ || _loc26_ || _loc27_ || _loc28_)
         {
            return true;
         }
         return false;
      }
      
      private function checkField(param1:Point, param2:Point, param3:Array, param4:Player, param5:Boolean = true) : Boolean
      {
         var _loc6_:Point = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Boolean = false;
         var _loc10_:Boolean = false;
         var _loc12_:Boolean = false;
         var _loc16_:Boolean = false;
         var _loc17_:Boolean = false;
         var _loc19_:FieldPoint = null;
         var _loc20_:int = 0;
         var _loc11_:Boolean = false;
         var _loc13_:Number = Math.min(Math.abs(1 / Math.cos(param4.getAngle())),Math.abs(1 / Math.sin(param4.getAngle()))) / this.res;
         var _loc14_:Number = Point.distance(param1,param2) / _loc13_;
         var _loc15_:Point = param2.subtract(param1);
         _loc15_.normalize(_loc13_);
         _loc6_ = param1.clone();
         var _loc18_:int = 0;
         while(_loc18_ < _loc14_)
         {
            _loc10_ = false;
            if(_loc18_ != 0)
            {
               _loc6_ = _loc6_.add(_loc15_);
            }
            _loc7_ = Math.round(_loc6_.x * this.res);
            _loc8_ = Math.round(_loc6_.y * this.res);
            if((_loc7_ > this.w * this.res - 1 || _loc8_ > this.h * this.res - 1 || _loc7_ < 0 || _loc8_ < 0) && !this.openBorders && !param4.canTunnel())
            {
               _loc11_ = true;
               _loc10_ = true;
            }
            else
            {
               if(_loc7_ > this.w * this.res - 1 || _loc7_ < 0)
               {
                  if(_loc7_ < 0)
                  {
                     _loc7_ = this.w * this.res + _loc7_;
                  }
                  _loc7_ %= this.w * this.res;
                  _loc16_ = true;
               }
               if(_loc8_ > this.h * this.res - 1 || _loc8_ < 0)
               {
                  if(_loc8_ < 0)
                  {
                     _loc8_ = this.h * this.res + _loc8_;
                  }
                  _loc8_ %= this.h * this.res;
                  _loc17_ = true;
               }
            }
            if(!_loc10_)
            {
               _loc19_ = this.field[_loc7_][_loc8_];
               _loc20_ = Math.ceil(param4.getWidth() / param4.getHeight()) + 1;
               if(_loc19_ == null || _loc19_.getId() == param4.getId() && _loc19_.getTick() >= param4.getTick() - _loc20_)
               {
                  _loc12_ = false;
               }
               else
               {
                  _loc12_ = true;
               }
               if(!_loc12_)
               {
                  if(param5)
                  {
                     this.field[_loc7_][_loc8_] = new FieldPoint(param4.getId(),param4.getTick());
                     ++this.detField[Math.floor(_loc7_ / this.res / this.w * this.detRes)][Math.floor(_loc8_ / this.res / this.w * this.detRes)];
                     param4.setIsTunneling(_loc16_,_loc17_);
                  }
               }
               else
               {
                  _loc11_ = true;
               }
            }
            _loc18_++;
         }
         return _loc11_;
      }
      
      public function calculateDirection(param1:Player) : String
      {
         var _loc2_:String = null;
         var _loc3_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc14_:Point = null;
         var _loc4_:Boolean = true;
         var _loc5_:Boolean = true;
         var _loc6_:Boolean = true;
         var _loc7_:Boolean = false;
         _loc8_ = this.tryDirection(param1,param1.getX(),param1.getY(),param1.getAngle(),Player.LEFT);
         _loc9_ = this.tryDirection(param1,param1.getX(),param1.getY(),param1.getAngle(),Player.RIGHT);
         _loc10_ = this.tryDirection(param1,param1.getX(),param1.getY(),param1.getAngle(),Player.STRAIGHT);
         var _loc11_:Boolean = _loc8_ >= _loc9_ && _loc8_ >= _loc10_;
         var _loc12_:Boolean = _loc9_ >= _loc8_ && _loc9_ >= _loc10_;
         var _loc13_:Boolean = _loc10_ >= _loc8_ && _loc10_ >= _loc9_;
         if(_loc11_ && !_loc12_ && !_loc13_)
         {
            return Player.LEFT;
         }
         if(!_loc11_ && _loc12_ && !_loc13_)
         {
            return Player.RIGHT;
         }
         if(!_loc11_ && !_loc12_ && _loc13_)
         {
            return Player.STRAIGHT;
         }
         _loc14_ = this.findNearestEmptySpot(param1);
         return this.determineDirection(param1,_loc14_,_loc11_,_loc13_,_loc12_);
      }
      
      private function findPlayerSpot() : Point
      {
         var _loc1_:Player = null;
         for each(_loc1_ in this.game.getActivePlayers())
         {
            if(!_loc1_.getAI())
            {
               if(_loc1_.getAlive())
               {
                  return new Point(Math.floor(_loc1_.getX() / this.w * this.detRes),Math.floor(_loc1_.getY() / this.h * this.detRes));
               }
            }
         }
         return this.findRandomSpot();
      }
      
      private function findRandomSpot() : Point
      {
         return new Point(Math.floor(Math.random() * this.detRes),Math.floor(Math.random() * this.detRes));
      }
      
      private function determineDirection(param1:Player, param2:Point, param3:Boolean, param4:Boolean, param5:Boolean) : String
      {
         var _loc15_:Point = null;
         if(param1.canTunnel() || this.openBorders)
         {
            if(Math.abs(param1.getX() - param2.x * this.w / this.detRes) > this.w / 2)
            {
               if(param1.getX() > param2.x * this.w / this.detRes)
               {
                  param2.x = param2.x * this.w / this.detRes + this.w;
               }
               else
               {
                  param2.x = param2.x * this.w / this.detRes - this.w;
               }
            }
            if(Math.abs(param1.getY() - param2.y * this.h / this.detRes) > this.h / 2)
            {
               if(param1.getY() > param2.y * this.h / this.detRes)
               {
                  param2.y = param2.y * this.h / this.detRes + this.h;
               }
               else
               {
                  param2.y = param2.y * this.h / this.detRes - this.h;
               }
            }
         }
         var _loc6_:Number = 360;
         var _loc7_:Number = 360;
         var _loc8_:Number = 360;
         var _loc9_:Number = param1.getAngle();
         var _loc10_:Point = Point.polar(1,_loc9_ - param1.getHeight() / param1.getRadius());
         var _loc11_:Point = Point.polar(1,_loc9_);
         var _loc12_:Point = Point.polar(1,_loc9_ + param1.getHeight() / param1.getRadius());
         var _loc13_:Point = new Point(param1.getX(),param1.getY());
         var _loc14_:Point = _loc13_.add(_loc11_);
         var _loc16_:Point = new Point(param2.x * this.w / this.detRes,param2.y * this.h / this.detRes);
         var _loc17_:Point = new Point((param2.x + 1) * this.w / this.detRes,param2.y * this.h / this.detRes);
         var _loc18_:Point = new Point((param2.x + 1) * this.w / this.detRes,(param2.y + 1) * this.h / this.detRes);
         var _loc19_:Point = new Point(param2.x * this.w / this.detRes,(param2.y + 1) * this.h / this.detRes);
         _loc15_ = new Point((param2.x + 0.5) * this.w / this.detRes,(param2.y + 0.5) * this.h / this.detRes);
         var _loc20_:Point = _loc15_.subtract(_loc13_);
         if(param4)
         {
            _loc8_ = Math.acos((_loc20_.x * _loc11_.x + _loc20_.y * _loc11_.y) / (_loc20_.length * _loc11_.length));
         }
         if((this.lineLineSegmentIntersect(_loc16_,_loc18_,_loc13_,_loc14_) || this.lineLineSegmentIntersect(_loc17_,_loc19_,_loc13_,_loc14_)) && param4 && _loc8_ < Math.PI / 2)
         {
            return Player.STRAIGHT;
         }
         if(param3)
         {
            _loc6_ = Math.acos((_loc20_.x * _loc10_.x + _loc20_.y * _loc10_.y) / (_loc20_.length * _loc10_.length));
         }
         if(param5)
         {
            _loc7_ = Math.acos((_loc20_.x * _loc12_.x + _loc20_.y * _loc12_.y) / (_loc20_.length * _loc12_.length));
         }
         if(_loc6_ <= _loc7_ && _loc6_ <= _loc8_)
         {
            return Player.LEFT;
         }
         if(_loc7_ <= _loc8_)
         {
            return Player.RIGHT;
         }
         return Player.STRAIGHT;
      }
      
      private function lineLineSegmentIntersect(param1:*, param2:*, param3:*, param4:*) : Boolean
      {
         var _loc5_:Number = (param1.x - param2.x) * (param3.y - param4.y) - (param1.y - param2.y) * (param3.x - param4.x);
         if(_loc5_ == 0)
         {
            return false;
         }
         var _loc6_:Number = ((param1.x * param2.y - param1.y * param2.x) * (param3.x - param4.x) - (param3.x * param4.y - param3.y * param4.x) * (param1.x - param2.x)) / _loc5_;
         var _loc7_:Number = ((param1.x * param2.y - param1.y * param2.x) * (param3.y - param4.y) - (param3.x * param4.y - param3.y * param4.x) * (param1.y - param2.y)) / _loc5_;
         if((_loc6_ > param1.x && _loc6_ < param2.x || _loc6_ < param1.x && _loc6_ > param2.x) && (_loc7_ > param1.y && _loc7_ < param2.y || _loc7_ < param1.y && _loc7_ > param2.y))
         {
            return true;
         }
         return false;
      }
      
      private function findNearestEmptySpot(param1:Player) : Point
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc7_:Number = NaN;
         var _loc8_:Point = null;
         var _loc10_:uint = 0;
         var _loc2_:Number = Math.floor(param1.getX() / this.w * this.detRes);
         var _loc3_:Number = Math.floor(param1.getY() / this.h * this.detRes);
         var _loc6_:Number = -1;
         var _loc9_:Array = new Array();
         var _loc11_:Number = 0;
         var _loc12_:uint = 0;
         while(_loc12_ < 12)
         {
            if(_loc12_ < 4)
            {
               _loc4_ = _loc12_ % 2 * Math.pow(-1,Math.floor(_loc12_ / 2));
               _loc5_ = (_loc12_ + 1) % 2 * Math.pow(-1,Math.floor((_loc12_ + 2) / 2));
            }
            else
            {
               _loc10_ = uint(_loc12_ - 4);
               switch(_loc10_)
               {
                  case 0:
                     _loc4_ = -2;
                     _loc5_ = 0;
                     break;
                  case 1:
                     _loc4_ = -1;
                     _loc5_ = 1;
                     break;
                  case 2:
                     _loc4_ = 0;
                     _loc5_ = 2;
                     break;
                  case 3:
                     _loc4_ = 1;
                     _loc5_ = 1;
                     break;
                  case 4:
                     _loc4_ = 2;
                     _loc5_ = 0;
                     break;
                  case 5:
                     _loc4_ = 1;
                     _loc5_ = -1;
                     break;
                  case 6:
                     _loc4_ = 0;
                     _loc5_ = -2;
                     break;
                  case 7:
                     _loc4_ = -1;
                     _loc5_ = -1;
               }
            }
            if(_loc2_ + _loc4_ >= 0 && _loc2_ + _loc4_ < this.detRes && _loc3_ + _loc5_ >= 0 && _loc3_ < this.detRes || param1.canTunnel() || this.openBorders)
            {
               if(_loc2_ + _loc4_ < 0)
               {
                  _loc4_ += this.detRes;
               }
               else if(_loc2_ + _loc4_ >= this.detRes)
               {
                  _loc4_ -= this.detRes;
               }
               if(_loc3_ + _loc5_ < 0)
               {
                  _loc5_ += this.detRes;
               }
               else if(_loc3_ + _loc5_ >= this.detRes)
               {
                  _loc5_ -= this.detRes;
               }
               _loc7_ = this.detField[_loc2_ + _loc4_][_loc3_ + _loc5_] * Math.sqrt((_loc2_ + _loc4_) * (_loc2_ + _loc4_) + (_loc3_ + _loc5_) * (_loc3_ + _loc5_));
               if(_loc7_ < _loc6_ || _loc6_ == -1)
               {
                  _loc6_ = _loc7_;
                  _loc9_ = new Array();
                  _loc9_.push(new Point(_loc2_ + _loc4_,_loc3_ + _loc5_));
                  _loc11_ = 1;
               }
               else if(_loc7_ == _loc6_)
               {
                  _loc9_.push(new Point(_loc2_ + _loc4_,_loc3_ + _loc5_));
                  _loc11_++;
               }
            }
            _loc12_++;
         }
         var _loc13_:Number = Math.random();
         return _loc9_[Math.floor(_loc13_ * _loc11_)];
      }
      
      private function findEmptySpot(param1:Player, param2:Number, param3:Number, param4:Number, param5:Number) : Point
      {
         var _loc11_:uint = 0;
         var _loc12_:uint = 0;
         var _loc13_:uint = 0;
         var _loc14_:uint = 0;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc22_:Point = null;
         var _loc24_:Player = null;
         var _loc6_:Number = (param3 - param2) / 2;
         var _loc7_:Number = _loc6_ / 2;
         var _loc8_:Number = (param5 - param4) / 2;
         var _loc9_:Number = _loc8_ / 2;
         var _loc10_:Boolean = false;
         if(_loc7_ != Math.round(_loc7_))
         {
            _loc10_ = true;
         }
         var _loc15_:Array = new Array();
         var _loc16_:Number = -1;
         var _loc21_:Number = 0;
         var _loc23_:Number = 0;
         var _loc25_:int = 0;
         while(_loc25_ < 5)
         {
            _loc21_ = 0;
            if(_loc25_ < 4)
            {
               _loc11_ = _loc25_ % 2;
               _loc12_ = Math.floor(_loc25_ / 2);
               _loc15_[_loc25_] = 0;
               _loc13_ = param2 + _loc11_ * _loc6_;
               while(_loc13_ < param2 + (_loc11_ + 1) * _loc6_)
               {
                  _loc14_ = param4 + _loc12_ * _loc8_;
                  while(_loc14_ < param4 + (_loc12_ + 1) * _loc8_)
                  {
                     _loc15_[_loc25_] += this.detField[_loc13_][_loc14_];
                     _loc14_++;
                  }
                  _loc13_++;
               }
               _loc22_ = new Point((param2 + (_loc11_ + 0.5) * _loc6_) * this.w / this.detRes,(param4 + (_loc12_ + 0.5) * _loc8_) * this.h / this.detRes);
            }
            else if(!_loc10_)
            {
               _loc15_[_loc25_] = 0;
               _loc13_ = param2 + _loc7_;
               while(_loc13_ < param3 - _loc7_)
               {
                  _loc14_ = param4 + _loc9_;
                  while(_loc14_ < param5 - _loc7_)
                  {
                     _loc15_[_loc25_] += this.detField[_loc13_][_loc14_];
                     _loc14_++;
                  }
                  _loc13_++;
               }
               _loc22_ = new Point((param2 + _loc6_) * this.w / this.detRes,(param4 + _loc8_) * this.h / this.detRes);
            }
            if(_loc15_[_loc25_] < _loc16_ || _loc16_ == -1)
            {
               _loc16_ = Number(_loc15_[_loc25_]);
               if(_loc25_ < 4)
               {
                  _loc11_ = _loc25_ % 2;
                  _loc12_ = Math.floor(_loc25_ / 2);
                  _loc17_ = param2 + _loc11_ * _loc6_;
                  _loc18_ = param2 + (_loc11_ + 1) * _loc6_;
                  _loc19_ = param4 + _loc12_ * _loc8_;
                  _loc20_ = param4 + (_loc12_ + 1) * _loc8_;
               }
               else
               {
                  _loc17_ = param2 + _loc7_;
                  _loc18_ = param3 - _loc7_;
                  _loc19_ = param4 + _loc9_;
                  _loc20_ = param5 - _loc9_;
               }
            }
            _loc25_++;
         }
         if(!_loc10_)
         {
            return this.findEmptySpot(param1,_loc17_,_loc18_,_loc19_,_loc20_);
         }
         return new Point(_loc17_,_loc19_);
      }
      
      private function tryDirection(param1:Player, param2:Number, param3:Number, param4:Number, param5:String) : Number
      {
         var _loc13_:Point = null;
         var _loc14_:Point = null;
         var _loc15_:Point = null;
         var _loc16_:Point = null;
         var _loc17_:Point = null;
         var _loc18_:Point = null;
         var _loc19_:Point = null;
         var _loc20_:Point = null;
         var _loc21_:Point = null;
         var _loc22_:Point = null;
         var _loc23_:Point = null;
         var _loc24_:Point = null;
         var _loc25_:Boolean = false;
         var _loc26_:Boolean = false;
         var _loc6_:Number = param1.getRadius() * 2 * Math.PI * 0.4 / param1.getHeight();
         var _loc7_:Number = param1.getWidth();
         var _loc8_:Number = param1.getHeight();
         var _loc9_:Boolean = false;
         var _loc10_:Object = param1.getLastTurn();
         var _loc11_:int = 0;
         while(_loc11_ < _loc6_ && !_loc9_)
         {
            if(!param1.isMegaHole())
            {
               if(!param1.isOldSnakey())
               {
                  if(param5 == Player.LEFT)
                  {
                     param4 -= param1.getHeight() / param1.getRadius();
                  }
                  if(param5 == Player.RIGHT)
                  {
                     param4 += param1.getHeight() / param1.getRadius();
                  }
               }
               else
               {
                  if(param5 == Player.LEFT && _loc11_ == 0 && (_loc10_ == null || _loc10_.dir != Player.LEFT || param1.getTick() - _loc10_.thetick > Math.ceil(param1.getWidth() / param1.getHeight())))
                  {
                     param4 -= 0.5 * Math.PI;
                  }
                  if(param5 == Player.RIGHT && _loc11_ == 0 && (_loc10_ == null || _loc10_.dir != Player.RIGHT || param1.getTick() - _loc10_.thetick > Math.ceil(param1.getWidth() / param1.getHeight())))
                  {
                     param4 += 0.5 * Math.PI;
                  }
               }
               param2 = param1.getNextX(param2,param4);
               param3 = param1.getNextY(param3,param4);
               _loc13_ = new Point(param2,param3);
               _loc14_ = Point.polar(1,param4);
               _loc15_ = _loc14_.clone();
               _loc16_ = Point.polar(1,param4 + Math.PI / 2);
               _loc17_ = _loc14_.clone();
               _loc17_.normalize(_loc8_);
               _loc18_ = _loc16_.clone();
               _loc18_.normalize(_loc7_);
               _loc19_ = _loc18_.clone();
               _loc19_.normalize(_loc7_ / 2);
               _loc20_ = _loc13_.subtract(_loc17_);
               _loc21_ = _loc20_.add(_loc19_);
               _loc22_ = _loc20_.subtract(_loc19_);
               _loc23_ = _loc13_.add(_loc19_);
               _loc24_ = _loc13_.subtract(_loc19_);
               _loc25_ = this.checkField(_loc21_,_loc23_,new Array(),param1,false);
               _loc26_ = this.checkField(_loc22_,_loc24_,new Array(),param1,false);
               _loc9_ = _loc25_ || _loc26_;
            }
            _loc11_++;
         }
         var _loc12_:int = _loc11_;
         if(!_loc9_)
         {
            _loc12_++;
         }
         return _loc11_;
      }
      
      public function getWidth() : uint
      {
         return this.w;
      }
      
      public function getHeight() : uint
      {
         return this.h;
      }
      
      public function enableOpenBorders() : void
      {
         ++this.openBordersCount;
         this.openBorders = true;
      }
      
      public function cancleOpenBorders() : Boolean
      {
         --this.openBordersCount;
         if(this.openBordersCount == 0)
         {
            this.openBorders = false;
         }
         return this.openBorders;
      }
      
      public function setOpenBorders(param1:Boolean) : void
      {
         this.openBorders = param1;
      }
      
      public function getOpenBorders() : Boolean
      {
         return this.openBorders;
      }
      
      public function printDetField() : void
      {
         var _loc1_:uint = 0;
         while(_loc1_ < this.detRes)
         {
            trace(this.detField[_loc1_]);
            _loc1_++;
         }
      }
   }
}

