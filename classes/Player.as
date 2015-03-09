package classes {
    import classes.*; // imports all classes from the "classes" folder
    import flash.events.*;
    import flash.display.Sprite;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import fl.transitions.TweenEvent;
    import fl.transitions.Tween;
    import fl.transitions.easing.*;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundTransform;
    import flash.net.URLRequest;

    public class Player extends Animation {

        public var controls:Object; // Object that holds all player controls
        var isJumping:Boolean = false;
        var bullets:Array = new Array();
        var currentBullet:int = 0;
        var SHOOT_DELAY:Number = 0.2;
        public var health:Number = 300;
        var healthBar:Sprite = new Sprite();




        public function Player(_position:Point, _originalVelocity:Point, _scale:int,
            _main:Object, _healthBarPosition:Point, _healthBarScaleX:int, _leftKey:int, _rightKey:int, _jumpKey:int, _attackKey:int)
        {
            super(_position, _originalVelocity, _scale, _main);
            isActive = true;
            controls = {
                left: _leftKey,
                right: _rightKey,
                jump: _jumpKey,
                attack: _attackKey
            };
            healthBar.graphics.beginFill(0x4DFF4F, 0.7);
            healthBar.graphics.drawRect(0, 0, health * _healthBarScaleX, 50);
            healthBar.graphics.endFill();
            healthBar.x = _healthBarPosition.x;
            healthBar.y = _healthBarPosition.y;
            main.addChild(healthBar);
            createBullets(20);
        }

		public override function removeAllMC(_stage):void {
			for (var _mc in mClips) {
                _stage.removeChild(mClips[_mc]);
            }
			main.removeChild(healthBar);
		}

        /*****************************************************************************
        ***** UPDATE STUFF
        *****************************************************************************/
        public override function update():void {
            if (isActive) {
                updateInput();
                updatePositionWithObstacles();
				checkFallOff();

                // Update all bullets
                for (var _b in bullets) {
                    bullets[_b].update();
                }

                super.update();
                updateCollisionBox();
                checkPortalCollision(scale.x);

            }
        }

        private function updateInput():void {
            if (main.isKeyDown(controls["left"])) {
                moveLeft();
            } else if (main.isKeyDown(controls["right"])){
                moveRight();
            } else {
                idle();
            }
            if (main.isKeyDown(controls["jump"]) && !isJumping){
                jumpUp();
            }
            if (main.isKeyDown(controls["attack"])){
                attack();
            }
        }

        public override function updateCollisionBox():void {
            if (scale.x < 0) {
                collisionBox = new Rectangle(position.x - (mClips[currentID].width / 2) - 4 * -scale.x, position.y + (5 * scale.y), 25 * -scale.x, 76);
            } else if (scale.x > 0) {
                collisionBox = new Rectangle(position.x + (mClips[currentID].width / 2) - 21 * scale.x, position.y + (5 * scale.y), 25 * scale.x, 76);
            }
        }

        /*****************************************************************************
        ***** COLLISION STUFF
        *****************************************************************************/
        // Check if the player is standing on a platform and reposition as needed
        private function updatePositionWithObstacles():void {
            var _newPosition:Point = position.add(velocity); // Calculate what the new position would be

            // Calculate the old and new collision boxes around the feet of the player
            // position.x is adjusted based on which way the character is facing
            var _oldCollisionBox:Rectangle;
            var _newCollisionBox:Rectangle;
            if (scale.x < 0) {
                _oldCollisionBox = new Rectangle(position.x - (mClips[currentID].width / 2) - 4 * -scale.x, position.y + (78 * scale.y), 15 * -scale.x, 8);
                _newCollisionBox = new Rectangle(_newPosition.x - (mClips[currentID].width / 2) - 4 * -scale.x, _newPosition.y + (78 * scale.y), 15 * -scale.x, 8);
            } else if (scale.x > 0) {
                _oldCollisionBox = new Rectangle(position.x + (mClips[currentID].width / 2) - 11 * scale.x, position.y + (78 * scale.y), 15 * scale.x, 8);
                _newCollisionBox = new Rectangle(_newPosition.x + (mClips[currentID].width / 2) - 11 * scale.x, _newPosition.y + (78 * scale.y), 15 * scale.x, 8);
            }

            var _yCollision:Boolean = false;
            var _xCollision:Boolean = false;
            var _obstacle:Rectangle;
            // Go through each obstacle in the static Main.obstacles array
            for (var _p in main.obstacles) {
                // Get the boundaries of the obstacle
                _obstacle = new Rectangle(main.obstacles[_p].x, main.obstacles[_p].y, main.obstacles[_p].width, main.obstacles[_p].height);

                if (_oldCollisionBox.y <= _obstacle.y) { // This means there could be a y collision
                    if (checkCollision(_newCollisionBox, _obstacle)) {
                        _yCollision = true;
                        // Adjust the y position if it somehow goes though the obstacle a bit
                        position.y = _obstacle.y - (78 * scale.y) - 1;
                    }
                } else if (_oldCollisionBox.y > _obstacle.y) { // This means there could be an x collision
                    if (checkCollision(_newCollisionBox, _obstacle)) {
                        _xCollision = true;
                        // Adjust the x position if it somehow goes through the obstacle a bit
                        if (scale.x < 0) {
                            position.x = _obstacle.x + _obstacle.width + (mClips[currentID].width / 2) - 4 * scale.x;
                        } else if (scale.x > 0) {
                            position.x = _obstacle.x - (mClips[currentID].width / 2) - 4 * scale.x;
                        }
                    }
                }
            }

            // Set y velocity
            if (_yCollision) {
                velocity.y = 0;
                isJumping = false;
            } else {
                updateJump();
            }
            // Set x velocity
            if (_xCollision) {
                // If there is an x collision, don't let the player move along x
                velocity.x = 0;
            }
        }

        public override function checkPortalCollision(_direction:int):Boolean {
            var _isCollision:Boolean = false;
            if (_direction > 0) {
                if (position.x + 46 > 990 && position.y > 170 && position.y < 270) {
                    _isCollision = true;
                    position.x = 0;
                    position.y += 280;
                }
            }
            else {
                if (position.x - 46 < 10 && position.y > 460 && position.y < 560) {
                    _isCollision = true;
                    position.x = 1000;
                    position.y -= 290;
                }
            }
            return _isCollision;
        }



		private function checkFallOff():void {
			if (position.y > main.STAGE_RECT.height) {
				hit(5);
			}
		}

        /*****************************************************************************
        ***** INITIALIZATION STUFF
        *****************************************************************************/
        public function createBullets(_numBullets:int):void {
            for (var i:int = 0; i < _numBullets; i++) {
                bullets.push(new Projectile(new Point(0, 0), new Point(20, 0), 1, main, this));
                main.addChild(bullets[i].addMC("bullet", new Bullet()));
                bullets[i].playMC("bullet");
                bullets[i].setVisible(false);
            }
        }


        /*****************************************************************************
        ***** MOVEMENT STUFF
        *****************************************************************************/
        public function moveLeft():void {
            // Turn towards the left direction
            if (scale.x > 0) {
                scale.x = -scale.x;
                position.x += mClips[currentID].width; // Adjust the x position because the movieclip was flipped
            }
            velocity.x = -originalVelocity.x;
            playMC("run");
        }

        public function moveRight():void {
            // Turn towards the right direction
            if (scale.x < 0) {
                scale.x = -scale.x;
                position.x -= mClips[currentID].width; // Adjust the x position because the movieclip was flipped
            }
            velocity.x = originalVelocity.x;
            playMC("run");
        }

        public function jumpUp():void {
            var jumpPower:Number = -11;
            isJumping = true;
            velocity.y = jumpPower * Math.sin(Math.PI * 60 / 180.0);
            playMC("jump");
        }

        public function attack():void {
                var _lastBullet:int = currentBullet - 1;
                var _bulletPosition:Point;
                var _bulletDirection:int;
                if (currentBullet >= bullets.length) {
                    currentBullet = 0;
                }
                if (currentBullet == 0) {
                    _lastBullet = bullets.length - 1;
                }
                // If the last bullet was longer ago than the shoot delay, then fire another bullet
                if (main.elapsedGameTime > bullets[_lastBullet].shootTime + SHOOT_DELAY) {
                    main.soundChannel = main.gunshot.play();
					main.soundChannel.soundTransform = main.soundEffectTransform;
                    if (scale.x < 0) {
                        _bulletPosition = new Point(position.x - (mClips[currentID].width / 2) - 4 * -scale.x, position.y + (30 * scale.y));
                        _bulletDirection = -1;
                    } else if (scale.x > 0) {
                        _bulletPosition = new Point(position.x + (mClips[currentID].width / 2) - 7 * scale.x, position.y + (30 * scale.y));
                        _bulletDirection = 1;
                    }
                    bullets[currentBullet].fire(_bulletPosition, _bulletDirection);
                    currentBullet++;
                }
        }

        public function idle():void {
            velocity.x = 0;
            playMC("idle");
        }

        public function updateJump():void {
            var time:Number = 0.3;
            isJumping = true;
            originalVelocity.y = velocity.y + 2 * time;
            position.y += velocity.y * time + 0.5 * 2 * (time * time);
            velocity.y = originalVelocity.y;
            playMC("jump");
        }

        public function hit(_damage:Number):void {
            var newHealth:Number = health - _damage;
            var healthTween:Tween = new Tween(healthBar, "width", None.easeOut, health, newHealth, SHOOT_DELAY, true);
            health = newHealth;

            if (health <= 0) {
                main.showGameOver();
            }
        }


    }
}