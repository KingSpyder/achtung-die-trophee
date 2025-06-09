package
{
   import flash.events.*;
   
   public class Player extends EventDispatcher
   {
      
      public static const MOVE:String = "move";
      
      public static const STRAIGHT:String = "straight";
      
      public static const LEFT:String = "left";
      
      public static const RIGHT:String = "right";
      
      public static const CHANGE_X:String = "change_x";
      
      public static const CHANGE_Y:String = "change_y";
      
      public static const REDRAW:String = "redraw";
      
      public static const START_TUNNELING:String = "start_tunneling";
      
      public static const STOP_TUNNELING:String = "stop_tunneling";
      
      public static const START_REVERSE:String = "start_reverse";
      
      public static const STOP_REVERSE:String = "stop_reverse";
      
      public static const START_OLD_SNAKEY:String = "start_oldSnakey";
      
      public static const STOP_OLD_SNAKEY:String = "stop_oldSnakey";
      
      private var active:Boolean;
      
      private var alive:Boolean;
      
      private var activate_key:uint;
      
      private var id:uint;
      
      private var score:int;
      
      private var history:Array;
      
      private var color:uint;
      
      private var hole:Boolean;
      
      private var direction:String;
      
      private var left:uint;
      
      private var right:uint;
      
      private var keyLocationLeft:uint;
      
      private var keyLocationRight:uint;
      
      private var hole_count:int;
      
      private var hole_length_left:Number;
      
      private var megaHolePoints:int;
      
      private var name:String;
      
      private var effects:Array;
      
      private var fps:uint;
      
      private var tunnelsX:Boolean;
      
      private var tunnelsY:Boolean;
      
      private var tunnels:Boolean;
      
      private var fieldWidth:uint;
      
      private var fieldHeight:uint;
      
      private var tunnelPoints:uint;
      
      private var tick:uint;
      
      private var startHole:Boolean;
      
      private var oldSnakey:Boolean;
      
      private var oldSnakeyPoints:int;
      
      private var prevDirection:String;
      
      private var lastTurn:Object;
      
      private var posX:Number;
      
      private var posY:Number;
      
      private var angle:Number;
      
      private var speed:Number;
      
      private var startLength:Number;
      
      private var width:Number;
      
      private var height:Number;
      
      private var radius:Number;
      
      private var change_hole_min:Number;
      
      private var change_hole_target:Number;
      
      private var hole_width:Number;
      
      private var snake_count:int;
      
      private var speed_reset:Number = 90;
      
      private var height_reset:Number;
      
      private var startLength_reset:Number = 12;
      
      private var width_reset:Number = 6;
      
      private var radius_reset:Number = 35;
      
      private var change_hole_min_reset:Number = 100;
      
      private var change_hole_target_reset:Number = 200;
      
      private var hole_width_reset:Number = 15;
      
      private var left_reset:uint;
      
      private var right_reset:uint;
      
      private var tunnels_reset:Boolean = false;
      
      private var ai_reset:Boolean;
      
      private var oldSnakey_reset:Boolean = false;
      
      private var ai:Boolean;
      
      private var field:Field;
      
      public function Player(param1:uint, param2:String, param3:uint, param4:uint, param5:uint, param6:uint, param7:Boolean, param8:uint)
      {
         super();
         this.activate_key = param6;
         this.active = param7;
         this.id = param1;
         this.color = param5;
         this.left_reset = param3;
         this.right_reset = param4;
         this.name = param2;
         this.fps = param8;
         this.direction = Player.STRAIGHT;
         this.reset();
      }
      
      public function reset() : void
      {
         this.speed = this.speed_reset;
         this.height = this.speed / this.fps;
         this.startLength = this.startLength_reset;
         this.snake_count = 0;
         this.tunnelPoints = 0;
         this.megaHolePoints = 0;
         this.width = this.width_reset;
         this.radius = this.radius_reset;
         this.change_hole_min = this.change_hole_min_reset;
         this.change_hole_target = this.change_hole_target_reset;
         this.hole_width = this.hole_width_reset;
         this.left = this.left_reset;
         this.right = this.right_reset;
         this.oldSnakey = this.oldSnakey_reset;
         this.oldSnakeyPoints = 0;
         this.tunnels = this.tunnels_reset;
         this.tick = 0;
         this.startHole = false;
         this.lastTurn = null;
         this.history = new Array();
         this.history.push({
            "x":0,
            "y":0,
            "angle":0,
            "hole":true
         });
         this.history.push({
            "x":0,
            "y":0,
            "angle":0,
            "hole":true
         });
         this.alive = true;
         this.hole_count = 0;
         this.snake_count = 0;
         this.hole = true;
         this.hole_length_left = 0;
         this.ai = this.ai_reset;
      }
      
      public function resetReady() : void
      {
         this.ai_reset = false;
      }
      
      public function setAI(param1:Boolean) : void
      {
         this.ai_reset = param1;
      }
      
      public function getAI() : Boolean
      {
         return this.ai_reset;
      }
      
      public function getActiveKey() : uint
      {
         return this.activate_key;
      }
      
      public function getActive() : Boolean
      {
         return this.active;
      }
      
      public function setActive(param1:Boolean) : void
      {
         this.active = param1;
      }
      
      public function getAlive() : Boolean
      {
         return this.alive;
      }
      
      public function toggleActive() : Boolean
      {
         this.active = !this.active;
         return this.active;
      }
      
      public function getId() : uint
      {
         return this.id;
      }
      
      public function setScore(param1:int) : void
      {
         this.score = param1;
      }
      
      public function setAlive(param1:Boolean) : void
      {
         this.alive = param1;
      }
      
      public function setStartPosition(param1:Number, param2:Number, param3:Number) : void
      {
         this.posX = param1;
         this.posY = param2;
         this.angle = param3;
         this.hole = true;
         this.history[1] = this.history[0];
         this.history[0] = {
            "x":this.posX,
            "y":this.posY,
            "angle":param3,
            "hole":this.hole
         };
      }
      
      public function startMove() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < Math.floor(this.startLength / this.height))
         {
            this.move();
            _loc1_++;
         }
      }
      
      public function move() : void
      {
         if(this.ai)
         {
            this.calculateDirection();
         }
         if(!this.oldSnakey)
         {
            if(this.direction == Player.LEFT)
            {
               this.angle -= this.height / this.radius;
            }
            if(this.direction == Player.RIGHT)
            {
               this.angle += this.height / this.radius;
            }
         }
         else
         {
            if(this.direction == Player.LEFT && (this.prevDirection != this.direction || this.ai) && (this.lastTurn == null || this.lastTurn.dir != Player.LEFT || this.tick - this.lastTurn.thetick > Math.ceil(this.width / this.height)))
            {
               this.angle -= 0.5 * Math.PI;
               this.lastTurn = {
                  "dir":Player.LEFT,
                  "thetick":this.tick
               };
               this.prevDirection = this.direction;
            }
            if(this.direction == Player.RIGHT && (this.prevDirection != this.direction || this.ai) && (this.lastTurn == null || this.lastTurn.dir != Player.RIGHT || this.tick - this.lastTurn.thetick > Math.ceil(this.width / this.height)))
            {
               this.angle += 0.5 * Math.PI;
               this.lastTurn = {
                  "dir":Player.RIGHT,
                  "thetick":this.tick
               };
               this.prevDirection = this.direction;
            }
            if(this.direction == Player.STRAIGHT)
            {
               this.prevDirection = this.direction;
            }
         }
         this.posX += Math.cos(this.angle) * this.height;
         this.posY += Math.sin(this.angle) * this.height;
         this.manageHole();
         this.history[1] = this.history[0];
         this.history[0] = {
            "x":this.posX,
            "y":this.posY,
            "angle":this.angle,
            "hole":this.getHole()
         };
         dispatchEvent(new PlayerEvent(PlayerEvent.MOVE,false,false,this));
         ++this.tick;
      }
      
      public function getPrevX(param1:Number, param2:Number = NaN) : Number
      {
         if(!param2)
         {
            param2 = this.angle;
         }
         var _loc3_:Number = this.height;
         if(this.afterHole())
         {
            _loc3_ = this.getAfterHoleLength();
         }
         return param1 - Math.cos(param2) * _loc3_;
      }
      
      public function getPrevY(param1:Number, param2:Number = NaN) : Number
      {
         if(!param2)
         {
            param2 = this.angle;
         }
         var _loc3_:Number = this.height;
         if(this.afterHole())
         {
            _loc3_ = this.getAfterHoleLength();
         }
         return param1 - Math.sin(param2) * _loc3_;
      }
      
      public function getNextX(param1:Number, param2:Number = NaN) : Number
      {
         if(!param2)
         {
            param2 = this.angle;
         }
         return param1 + Math.cos(param2) * this.height;
      }
      
      public function getNextY(param1:Number, param2:Number = NaN) : Number
      {
         if(!param2)
         {
            param2 = this.angle;
         }
         return param1 + Math.sin(param2) * this.height;
      }
      
      public function getTick() : uint
      {
         return this.tick;
      }
      
      private function manageHole() : *
      {
         var _loc1_:Number = NaN;
         this.startHole = false;
         if(!this.hole)
         {
            ++this.snake_count;
            if(this.snake_count * this.height > this.change_hole_min)
            {
               _loc1_ = 1 / ((this.change_hole_target - this.change_hole_min) / this.height);
               if(Math.random() < _loc1_)
               {
                  this.hole = true;
                  this.startHole = true;
                  this.hole_length_left = this.hole_width;
                  this.snake_count = 0;
               }
            }
         }
         if(this.hole)
         {
            this.hole_length_left -= this.height;
            if(this.hole_length_left <= 0)
            {
               this.hole = false;
            }
         }
      }
      
      public function afterHole() : Boolean
      {
         if(!this.hole && this.startHole || !this.history[0].hole && this.history[1].hole)
         {
            return true;
         }
         return false;
      }
      
      public function getAfterHoleLength() : Number
      {
         return (this.height - this.hole_length_left) % this.height;
      }
      
      public function setDirection(param1:String) : void
      {
         this.direction = param1;
      }
      
      public function getWidth() : Number
      {
         return this.width;
      }
      
      public function getHeight() : Number
      {
         return this.height;
      }
      
      public function getHole() : Boolean
      {
         return this.hole;
      }
      
      public function getLeftKey() : uint
      {
         return this.left;
      }
      
      public function getRightKey() : uint
      {
         return this.right;
      }
      
      public function isMegaHole() : Boolean
      {
         if(this.megaHolePoints * this.height > this.width)
         {
            return true;
         }
         return false;
      }
      
      public function getColor() : uint
      {
         return this.color;
      }
      
      public function getX() : Number
      {
         return this.posX;
      }
      
      public function getY() : Number
      {
         return this.posY;
      }
      
      public function getAngle() : Number
      {
         return this.angle;
      }
      
      public function getHistory(param1:int) : Object
      {
         return this.history[param1];
      }
      
      public function getDirection() : String
      {
         return this.direction;
      }
      
      public function addScore() : void
      {
         ++this.score;
      }
      
      public function getScore() : uint
      {
         return this.score;
      }
      
      public function getRadius() : Number
      {
         return this.radius;
      }
      
      public function setRadius(param1:Number) : void
      {
         this.radius = param1;
      }
      
      public function getName() : String
      {
         return this.name;
      }
      
      public function setSpeed(param1:Number) : void
      {
         this.height = param1 / this.speed * this.height;
         this.hole_count = Math.round(this.speed / param1 * this.hole_count);
         this.speed = param1;
      }
      
      public function getSpeed() : Number
      {
         return this.speed;
      }
      
      public function setWidth(param1:Number) : *
      {
         this.width = param1;
      }
      
      public function getLeft() : uint
      {
         return this.left;
      }
      
      public function getRight() : uint
      {
         return this.right;
      }
      
      public function setLeft(param1:uint) : void
      {
         this.left = param1;
      }
      
      public function setRight(param1:uint) : void
      {
         this.right = param1;
      }
      
      public function reverseControls() : void
      {
         if(this.right == this.right_reset)
         {
            if(this.getDirection() == LEFT)
            {
               this.setDirection(RIGHT);
            }
            else if(this.getDirection() == RIGHT)
            {
               this.setDirection(LEFT);
            }
         }
         this.right = this.left_reset;
         this.left = this.right_reset;
      }
      
      public function isReversed() : Boolean
      {
         if(this.right == this.left_reset)
         {
            return true;
         }
         return false;
      }
      
      public function resetControls() : void
      {
         if(this.right == this.left_reset)
         {
            if(this.getDirection() == RIGHT)
            {
               this.setDirection(LEFT);
            }
            else if(this.getDirection() == LEFT)
            {
               this.setDirection(RIGHT);
            }
         }
         this.right = this.right_reset;
         this.left = this.left_reset;
      }
      
      public function setMegaHoleWidth(param1:int) : void
      {
         this.hole_length_left = param1;
         this.hole = true;
         this.snake_count = 0;
      }
      
      public function enableMegaHole() : void
      {
         this.hole = true;
         this.hole_length_left = 123456789;
         ++this.megaHolePoints;
         this.snake_count = 0;
      }
      
      public function cancleMegaHole() : void
      {
         --this.megaHolePoints;
         if(this.megaHolePoints <= 0)
         {
            this.hole = false;
            this.hole_length_left = 0;
         }
      }
      
      public function enableOldSnakey() : void
      {
         this.oldSnakey = true;
         ++this.oldSnakeyPoints;
      }
      
      public function cancleOldSnakey() : Boolean
      {
         --this.oldSnakeyPoints;
         if(this.oldSnakeyPoints <= 0)
         {
            this.oldSnakey = false;
         }
         return this.oldSnakey;
      }
      
      public function handleTunneling(param1:uint, param2:uint, param3:Boolean) : void
      {
         var _loc4_:Boolean = false;
         var _loc5_:Boolean = false;
         if(param3 || this.tunnels)
         {
            if(this.posX > param1 || this.posX < 0)
            {
               _loc4_ = true;
            }
            if(this.posY > param2 || this.posY < 0)
            {
               _loc5_ = true;
            }
            this.tunnels_x(_loc4_,param1);
            this.tunnels_y(_loc5_,param2);
         }
      }
      
      public function tunnels_x(param1:Boolean, param2:uint) : void
      {
         if(param1)
         {
            if(this.posX < 0)
            {
               this.posX = param2 + this.posX;
            }
            this.posX %= param2;
            this.history[0] = {
               "x":this.posX,
               "y":this.posY,
               "angle":this.angle,
               "hole":this.getHole()
            };
         }
      }
      
      public function tunnels_y(param1:Boolean, param2:uint) : void
      {
         if(param1)
         {
            if(this.posY < 0)
            {
               this.posY = param2 + this.posY;
            }
            this.posY %= param2;
            this.history[0] = {
               "x":this.posX,
               "y":this.posY,
               "angle":this.angle,
               "hole":this.getHole()
            };
         }
      }
      
      public function isTunneling() : Boolean
      {
         return this.tunnelsX || this.tunnelsY || Math.abs(this.history[1].x - this.posX) > this.fieldWidth / 2 || Math.abs(this.history[1].y - this.posY) > this.fieldHeight / 2;
      }
      
      public function setIsTunneling(param1:Boolean, param2:Boolean) : void
      {
         this.tunnelsX = param1;
         this.tunnelsY = param2;
      }
      
      public function getTunnelsX() : Boolean
      {
         return this.tunnelsX;
      }
      
      public function getTunnelsY() : Boolean
      {
         return this.tunnelsY;
      }
      
      public function canTunnel() : Boolean
      {
         return this.tunnels;
      }
      
      public function enableTunneling() : void
      {
         ++this.tunnelPoints;
         this.tunnels = true;
      }
      
      public function cancleTunneling() : Boolean
      {
         --this.tunnelPoints;
         if(this.tunnelPoints == 0)
         {
            this.tunnels = false;
         }
         return this.tunnels;
      }
      
      public function tunnelX() : Number
      {
         if(this.tunnelsX)
         {
            if(this.posX < this.fieldWidth / 2)
            {
               return this.posX + this.fieldWidth;
            }
            return this.posX - this.fieldWidth;
         }
         return this.posX;
      }
      
      public function tunnelY() : Number
      {
         if(this.tunnelsY)
         {
            if(this.posY < this.fieldHeight / 2)
            {
               return this.posY + this.fieldHeight;
            }
            return this.posY - this.fieldHeight;
         }
         return this.posY;
      }
      
      public function setFieldWidth(param1:uint, param2:uint) : void
      {
         this.fieldWidth = param1;
         this.fieldHeight = param2;
      }
      
      public function setLeftKey(param1:uint) : void
      {
         this.left_reset = param1;
      }
      
      public function setRightKey(param1:uint) : void
      {
         this.right_reset = param1;
      }
      
      public function setHoleWidth(param1:Number) : void
      {
         this.hole_width = param1;
      }
      
      public function getHoleWidth() : Number
      {
         return this.hole_width;
      }
      
      public function calculateDirection() : void
      {
         this.setDirection(this.field.calculateDirection(this));
      }
      
      public function setField(param1:Field) : void
      {
         this.field = param1;
      }
      
      public function isOldSnakey() : Boolean
      {
         return this.oldSnakey;
      }
      
      public function getLastTurn() : Object
      {
         return this.lastTurn;
      }
   }
}

