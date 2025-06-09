package
{
   import flash.display.*;
   import flash.events.*;
   import flash.text.*;
   import flash.ui.*;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol98")]
   public class soundManager extends MovieClip
   {
      
      public var music_txt:TextField;
      
      public var sound_txt:TextField;
      
      private var sounds:Sounds;
      
      private var musicOn:Boolean;
      
      private var soundOn:Boolean;
      
      public function soundManager()
      {
         super();
         this.sounds = Sounds.getInstance();
         this.init();
         this.music_txt.addEventListener(MouseEvent.MOUSE_OVER,this.handleMouseOver);
         this.sound_txt.addEventListener(MouseEvent.MOUSE_OVER,this.handleMouseOver);
         this.music_txt.addEventListener(MouseEvent.MOUSE_OUT,this.handleMouseOut);
         this.sound_txt.addEventListener(MouseEvent.MOUSE_OUT,this.handleMouseOut);
         this.music_txt.addEventListener(MouseEvent.CLICK,this.handleToggleMusic);
         this.sound_txt.addEventListener(MouseEvent.CLICK,this.handleToggleSound);
      }
      
      public function init() : void
      {
         this.musicOn = this.sounds.getMusicOn();
         this.soundOn = this.sounds.getSoundOn();
         if(this.musicOn)
         {
            this.music_txt.text = "on";
         }
         else
         {
            this.music_txt.text = "off";
         }
         if(this.soundOn)
         {
            this.sound_txt.text = "on";
         }
         else
         {
            this.sound_txt.text = "off";
         }
      }
      
      private function handleToggleMusic(param1:MouseEvent) : void
      {
         this.sounds.toggleMusic();
         this.init();
      }
      
      private function handleToggleSound(param1:MouseEvent) : void
      {
         this.sounds.toggleSound();
         this.init();
      }
      
      private function handleMouseOver(param1:MouseEvent) : void
      {
         param1.currentTarget.textColor = 65280;
         Mouse.cursor = MouseCursor.BUTTON;
      }
      
      private function handleMouseOut(param1:MouseEvent) : void
      {
         param1.currentTarget.textColor = 16776960;
         Mouse.cursor = MouseCursor.AUTO;
      }
   }
}

