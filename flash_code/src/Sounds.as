package
{
   import flash.events.Event;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import flash.net.URLRequest;
   
   public class Sounds
   {
      
      private static var instance:Sounds = null;
      
      private var speedSound:Sound;
      
      private var explosionSound:Sound;
      
      private var applause:Sound;
      
      private var go:Sound;
      
      private var yes:Sound;
      
      private var snoring:Sound;
      
      private var no:Sound;
      
      private var like:Sound;
      
      private var music1:Sound;
      
      private var music2:Sound;
      
      private var music3:Sound;
      
      private var music1_url:String = "http://www.pacdv.com/sounds/free-music/on-the-run-1.mp3";
      
      private var music2_url:String = "http://www.pacdv.com/sounds/free-music/fresh-sparks.mp3";
      
      private var music3_url:String = "http://www.pacdv.com/sounds/free-music/time-to-go.mp3";
      
      private var music4_url:String = "http://www.pacdv.com/sounds/free-music/this-is-the-day.mp3";
      
      private var music:Sound;
      
      private var musicChannel:SoundChannel;
      
      private var musicPausePoint:Number;
      
      private var musicOn:Boolean = false;
      
      private var soundOn:Boolean = false;
      
      public function Sounds()
      {
         super();
         this.explosionSound = new explosion_snd();
         this.applause = new applause_snd();
         this.like = new bleep_snd();
         this.yes = new bleep_snd();
         this.musicPausePoint = 0;
         this.playMusic();
      }
      
      public static function getInstance() : Sounds
      {
         if(Sounds.instance == null)
         {
            Sounds.instance = new Sounds();
         }
         return Sounds.instance;
      }
      
      public function playYes() : void
      {
         if(this.soundOn)
         {
            this.yes.play();
         }
      }
      
      public function playNo() : void
      {
         if(this.soundOn)
         {
            this.like.play();
         }
      }
      
      public function playLike() : void
      {
         if(this.soundOn)
         {
            this.like.play();
         }
      }
      
      public function playApplause() : void
      {
         if(this.soundOn)
         {
            this.applause.play();
         }
      }
      
      public function playExplosion() : void
      {
         if(this.soundOn)
         {
            this.explosionSound.play();
         }
      }
      
      public function getMusicOn() : Boolean
      {
         return this.musicOn;
      }
      
      public function getSoundOn() : Boolean
      {
         return this.soundOn;
      }
      
      public function toggleMusic() : void
      {
         if(this.musicOn)
         {
            this.musicOn = !this.musicOn;
            this.stopMusic();
         }
         else
         {
            this.musicOn = !this.musicOn;
            this.playMusic();
         }
      }
      
      public function toggleSound() : void
      {
         this.soundOn = !this.soundOn;
      }
      
      private function loopMusic(param1:Event) : void
      {
         if(this.musicChannel != null)
         {
            this.musicChannel.removeEventListener(Event.SOUND_COMPLETE,this.loopMusic);
            this.musicPausePoint = 0;
            this.playMusic();
         }
      }
      
      public function playMusic() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:SoundTransform = null;
         if(this.musicOn)
         {
            _loc1_ = Math.random();
            this.music = new Sound();
            if(_loc1_ < 1 / 3)
            {
               this.music.load(new URLRequest(this.music1_url));
            }
            else if(_loc1_ < 2 / 3)
            {
               this.music.load(new URLRequest(this.music2_url));
            }
            else
            {
               this.music.load(new URLRequest(this.music3_url));
            }
            this.musicChannel = this.music.play(this.musicPausePoint);
            _loc2_ = new SoundTransform();
            _loc2_.volume = 0.5;
            this.musicChannel.soundTransform = _loc2_;
            this.musicChannel.addEventListener(Event.SOUND_COMPLETE,this.loopMusic);
         }
      }
      
      public function stopMusic() : void
      {
         if(this.musicChannel != null)
         {
            this.musicChannel.stop();
            this.musicChannel.removeEventListener(Event.SOUND_COMPLETE,this.loopMusic);
            this.musicPausePoint = 0;
         }
      }
   }
}

