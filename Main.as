package {
    import classes.*; // imports all classes from the "classes" folder
    import flash.events.*;
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.getTimer;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
    import flash.display.Sprite;
    import flash.system.*;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundTransform;
    import flash.net.URLRequest;

    public class Main extends MovieClip {

        public var elapsedGameTime:Number; // The current game time in seconds
        public const GAME_STATES:Object = {
            mainMenu: 1,
            howToPlay1: 2,
            howToPlay2: 3,
            settings: 4,
            inGame: 5,
            gameOver: 6
        };
        public var gameState:int = GAME_STATES.mainMenu;

        // Timer variables
        var t:Timer;
        var counter:int = 99;

        // Players
        public var players:Array;
        var player1:Player;
        var player2:Player;
        var winner:MovieClip;
        var platform1:VerticalPlatform;
        var platform2:VerticalPlatform;
        //green rectangle to cover platforms
        var greenBox:Sprite = new Sprite();

        //sounds
        var shotgun:Sound = new Sound();
        var song:Sound = new Sound();
        public var gunshot:Sound = new Sound();
        var songChannel:SoundChannel = new SoundChannel();
        public var soundChannel:SoundChannel = new SoundChannel();
        var songTransform:SoundTransform = new SoundTransform();
        public var soundEffectTransform:SoundTransform = new SoundTransform();
		var songVolume:int = 100;
		var soundVolume:int = 100;

        // Holds all keys that are currently being pressed
        var keyboardState:Object = {};

        // Obstacles that the player can walk on but not into
        public var obstacles:Array = new Array();
        // The rectangle of the stage, used to check if things are on the stage
        public const STAGE_RECT:Rectangle = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);

        /*****************************************************************************
        ***** INIT STUFF
        *****************************************************************************/
        public function Main() {
            gotoAndStop(gameState);
            btnPlay.addEventListener(MouseEvent.CLICK, beginLevel, false, 0, true);
            btnHelp.addEventListener(MouseEvent.CLICK, showHowToPlay1, false, 0, true);
            btnSettings.addEventListener(MouseEvent.CLICK, showSettings, false, 0, true);

            // Add keyboard events
            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
            stage.addEventListener(KeyboardEvent.KEY_UP, keyReleased);
            // Begin the update loop
            stage.addEventListener(Event.ENTER_FRAME, update, false, 0, true);

            //load music
            shotgun.load(new URLRequest("sounds/shotgun.mp3"));
            song.load(new URLRequest("sounds/song.mp3"));
            gunshot.load(new URLRequest("sounds/gunshot.mp3"));
            songChannel = song.play();

            // Add timer
            t = new Timer(1000); // Tick once every 1 second
            t.addEventListener(TimerEvent.TIMER, countDown, false, 0, true);
            t.start();
        }

        private function initObstacles():void {
            var _item:DisplayObject;
			obstacles = new Array();
            for(var i:int = 0; i < numChildren; i++) {
                _item = getChildAt(i);
                // Find all obstacles, add them to the obstacles array
                if (_item is Obstacle) {
                    obstacles.push(_item);
                    _item.visible = false;
                }
            }
        }

        private function initPlayers():void {
            // Add player1
            player1 = new Player(new Point(30, 175), new Point(10, 0), 1, this, new Point(400, 0), -1, 65, 68, 87, 86);
            stage.addChild(player1.addMC("idle", new IdleOne()));
            stage.addChild(player1.addMC("run", new RunOne()));
            stage.addChild(player1.addMC("jump", new JumpOne()));
            // Add player2
            player2 = new Player(new Point(960, 406), new Point(10, 0), -1, this, new Point(600, 0), 1, 37, 39, 38, 76);
            stage.addChild(player2.addMC("idle", new IdleTwo()));
            stage.addChild(player2.addMC("run", new RunTwo()));
            stage.addChild(player2.addMC("jump", new JumpTwo()));

            players = new Array(player1, player2);
        }

        private function initPlatforms():void {
            platform1 = new VerticalPlatform(new Point(480, 420), new Point(0, -1), 1, this);
            platform2 = new VerticalPlatform(new Point(680, 420), new Point(0, 1), 1, this);
            stage.addChild(platform1.addMC("platform", new Platform()));
            stage.addChild(platform2.addMC("platform", new Platform()));
            platform1.playMC("platform");
            platform2.playMC("platform");
        }

        private function beginLevel(e:MouseEvent):void {
            btnPlay.removeEventListener(MouseEvent.CLICK, beginLevel);
            soundChannel = shotgun.play();
			soundChannel.soundTransform = soundEffectTransform;
            gameState = GAME_STATES.inGame;
            gotoAndStop(gameState);
            initObstacles();
            initPlatforms();
            //green rectangle to cover platforms
            greenBox.graphics.beginFill(0x0F4C09, 1);
            greenBox.graphics.drawRect(508, 684, 300, 100);
            greenBox.graphics.endFill();
            stage.addChild(greenBox);
            initPlayers();
            stage.focus = stage;
            counter = 99;
        }

        private function countDown(e:TimerEvent):void {
            if (gameState == GAME_STATES.inGame) {
                counter--;
                counterText.text = String(counter);
                if (counter <= 0) {
                    t.stop();
                    showGameOver();
                }
            }
        }

        private function showHowToPlay1(e:MouseEvent):void {
            btnHelp.removeEventListener(MouseEvent.CLICK, showHowToPlay1);
            gameState = GAME_STATES.howToPlay1;
            gotoAndStop(gameState);
            btnNext.addEventListener(MouseEvent.CLICK, showHowToPlay2, false, 0, true);
        }

        private function showHowToPlay2(e:MouseEvent):void {
            btnNext.removeEventListener(MouseEvent.CLICK, showHowToPlay2);
            gameState = GAME_STATES.howToPlay2;
            gotoAndStop(gameState);
            btnMenu1.addEventListener(MouseEvent.CLICK, showMenu, false, 0, true);
        }

        private function showMenu(e:MouseEvent):void {
            if (gameState == GAME_STATES.howToPlay2) {
                btnMenu1.removeEventListener(MouseEvent.CLICK, showMenu);
            } else if (gameState == GAME_STATES.settings) {
                btnMenu2.removeEventListener(MouseEvent.CLICK, showMenu);
				songIncreaseBtn.removeEventListener(MouseEvent.CLICK, increaseSong);
				songDecreaseBtn.removeEventListener(MouseEvent.CLICK, decreaseSong);
				soundDecreaseBtn.removeEventListener(MouseEvent.CLICK, decreaseSound);
				soundIncreaseBtn.removeEventListener(MouseEvent.CLICK, increaseSound);
            } else if (gameState == GAME_STATES.gameOver) {
                btnMenu3.removeEventListener(MouseEvent.CLICK, showMenu);
                stage.removeChild(winner);
            }
            gameState = GAME_STATES.mainMenu;
            gotoAndStop(gameState);
            btnPlay.addEventListener(MouseEvent.CLICK, beginLevel, false, 0, true);
            btnHelp.addEventListener(MouseEvent.CLICK, showHowToPlay1, false, 0, true);
            btnSettings.addEventListener(MouseEvent.CLICK, showSettings, false, 0, true);
        }

        private function showSettings(e:MouseEvent):void {
            btnSettings.removeEventListener(MouseEvent.CLICK, showSettings);
            gameState = GAME_STATES.settings;
            gotoAndStop(gameState);
			songDecreaseBtn.addEventListener(MouseEvent.CLICK, decreaseSong, false, 0, true);
			songIncreaseBtn.addEventListener(MouseEvent.CLICK, increaseSong, false, 0, true);
			soundDecreaseBtn.addEventListener(MouseEvent.CLICK, decreaseSound, false, 0, true);
			soundIncreaseBtn.addEventListener(MouseEvent.CLICK, increaseSound, false, 0, true);
            btnMenu2.addEventListener(MouseEvent.CLICK, showMenu, false, 0, true);
        }

        public function showGameOver():void {
			// Remove all necessary children
            stage.removeChild(greenBox);
			platform1.removeAllMC(stage);
			platform2.removeAllMC(stage);
			player1.removeAllMC(stage);
			player2.removeAllMC(stage);
            gameState = GAME_STATES.gameOver;
            gotoAndStop(gameState);
			soundChannel = shotgun.play();
			soundChannel.soundTransform = soundEffectTransform;
            if (player1.health > player2.health) {
                winner = new IdleOne();
                txtWinner.text = "Player 1 Won!"
            } else if (player2.health > player1.health) {
                winner = new IdleTwo();
                txtWinner.text = "Player 2 Won!"
            } else {
                winner = new TieGame();
                txtWinner.text = "It Was A Tie!";
            }
            winner.scaleX = 3;
            winner.scaleY = 3;
            winner.x = (stage.stageWidth / 2) - (winner.width / 2);
            winner.y = (stage.stageHeight / 2) - (winner.height / 2) + 40;
            stage.addChild(winner);
            btnMenu3.addEventListener(MouseEvent.CLICK, showMenu, false, 0, true);
        }
		
		public function decreaseSong(e:MouseEvent):void {
			if (songTransform.volume > 0.1)
			{
				songTransform.volume -= 0.1;
				songVolume -= 10;
				songLevel.text = String(songVolume);
				songChannel.soundTransform = songTransform;
			}
		}
		public function increaseSong(e:MouseEvent):void {
			if (songTransform.volume < 1)
			{
				songTransform.volume += 0.1;
				songVolume += 10;
				songLevel.text = String(songVolume);
				songChannel.soundTransform = songTransform;
			}
		}
		public function decreaseSound(e:MouseEvent):void {
			if (soundEffectTransform.volume > 0.1)
			{
				soundEffectTransform.volume -= 0.1;
				soundVolume -= 10;
				soundLevel.text = String(soundVolume);
				soundChannel = gunshot.play();
				soundChannel.soundTransform = soundEffectTransform;
			}
		}
		public function increaseSound(e:MouseEvent):void {
			if (soundEffectTransform.volume < 1)
			{
				soundEffectTransform.volume += 0.1;
				soundVolume += 10;
				soundLevel.text = String(soundVolume);
				soundChannel = gunshot.play();
				soundChannel.soundTransform = soundEffectTransform;
			}
		}
		
        /*****************************************************************************
        ***** UPDATE STUFF
        *****************************************************************************/
        private function update(_e:Event):void {
            elapsedGameTime = getTimer() * 0.001;
            this.graphics.clear();
            if (gameState == GAME_STATES.inGame) {
                // Update moving platforms
                platform1.update();
                platform2.update();
                // Update moving platform collision boxes
                collPlat1.x = platform1.position.x + 8;
                collPlat1.y = platform1.position.y + 9;
                collPlat2.x = platform2.position.x + 8;
                collPlat2.y = platform2.position.y + 9;
                // Update players
                for (var _p in players) {
                    players[_p].update();
                }
            }
        }


        /*****************************************************************************
        ***** KEYBOARD STUFF
        *****************************************************************************/
        // Removes the key from the keyboardState once it is released
        private function keyReleased(_e:KeyboardEvent):void {
            delete keyboardState[_e.keyCode];
        }

        // Adds the key to the keyboardState if it is being held down
        private function keyPressed(_e:KeyboardEvent):void {
            keyboardState[_e.keyCode] = true;
        }

        // Returns whether the specified key is down or not
        public function isKeyDown(_keyCode:int):Boolean {
            return keyboardState[_keyCode];
        }




    }
}