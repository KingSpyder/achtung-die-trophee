package
{
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class Head extends MovieClip
   {
      
      private var head:MovieClip;
      
      private var tunneling:Boolean;
      
      private var reverse:Boolean;
      
      private var snakey:Boolean;
      
      private var alphaDecline:Boolean;
      
      private var color:int;
      
      public function Head()
      {
         super();
         this.head = new MovieClip();
         addChild(this.head);
         this.color = 16776960;
         this.tunneling = false;
         this.snakey = false;
         this.reverse = false;
         this.draw();
         addEventListener(Event.ENTER_FRAME,this.enterFrameListener);
      }
      
      private function draw() : void
      {
         this.head.graphics.clear();
         this.head.graphics.beginFill(this.color);
         if(this.snakey)
         {
            this.head.graphics.drawRect(-10,-10,20,20);
         }
         else
         {
            this.head.graphics.drawCircle(0,0,10);
         }
      }
      
      public function startReverse() : void
      {
         this.color = 255;
         this.reverse = true;
         this.draw();
      }
      
      public function stopReverse() : void
      {
         this.color = 16776960;
         this.reverse = false;
         this.draw();
      }
      
      public function startTunneling() : void
      {
         this.tunneling = true;
         this.alphaDecline = true;
         this.draw();
      }
      
      public function stopTunneling() : void
      {
         this.alphaDecline = true;
         this.tunneling = false;
         this.draw();
         this.head.alpha = 1;
      }
      
      public function startSnakey() : void
      {
         this.snakey = true;
         this.draw();
      }
      
      public function stopSnakey() : void
      {
         this.snakey = false;
         this.draw();
      }
      
      private function enterFrameListener(param1:Event) : void
      {
         if(this.tunneling)
         {
            if(this.alphaDecline)
            {
               this.head.alpha -= 0.1;
               if(this.head.alpha <= 0)
               {
                  this.head.alpha = 0;
                  this.alphaDecline = false;
               }
            }
            else
            {
               this.head.alpha += 0.1;
               if(this.head.alpha >= 1)
               {
                  this.head.alpha = 1;
                  this.alphaDecline = true;
               }
            }
         }
      }
   }
}

