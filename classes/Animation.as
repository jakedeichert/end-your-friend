package classes {
    import flash.events.*;
    import flash.display.MovieClip;
    import flash.display.DisplayObject;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.display.Stage;

    public class Animation {
        public var mClips:Object; // Object that holds all movieclips
        public var currentID:String; // The id of the current movieclip
        public var position:Point;
        var originalVelocity:Point;
        var velocity:Point;
        var scale:Point;
        var main:Object;
        var isActive:Boolean = false;
        public var collisionBox:Rectangle;

        public function Animation(_position:Point, _originalVelocity:Point, _scale:int, _main:Object) {
            mClips = {};
            position = _position;
            originalVelocity = _originalVelocity;
            velocity = new Point(0, 0);
            scale = new Point(_scale, Math.abs(_scale));
            main = _main;
        }

        /*****************************************************************************
        ***** ANIMATION STUFF
        *****************************************************************************/
        // Add a movieclip to the movieclip list
        public function addMC(_id:String, _mc:MovieClip):MovieClip {
            mClips[_id] = _mc;
            mClips[_id].x = position.x;
            mClips[_id].y = position.y;
            mClips[_id].scaleX = scale.x;
            mClips[_id].scaleY = scale.y;
            return mClips[_id];
        }

        // Play the specified movieclip
        public function playMC(_id:String):void {
            stopAllMC();
            currentID = _id;
            setVisible(true);
        }

        // Turn off all movieclips
        public function stopAllMC():void {
            for (var _mc in mClips) {
                mClips[_mc].visible = false;
            }
        }

        public function setVisible(_isVisible:Boolean):void {
            mClips[currentID].visible = _isVisible;
        }
		
		public function removeAllMC(_stage):void {
			for (var _mc in mClips) {
                _stage.removeChild(mClips[_mc]);
            }
		}

        /*****************************************************************************
        ***** UPDATE STUFF
        *****************************************************************************/
        public function update():void {
            if (isActive) {
                position = position.add(velocity); // Update position
                mClips[currentID].x = position.x;
                mClips[currentID].y = position.y;
                mClips[currentID].scaleX = scale.x;
                mClips[currentID].scaleY = scale.y;
            }
        }

        public function updateCollisionBox():void {
            collisionBox = new Rectangle(position.x, position.y, mClips[currentID].width, mClips[currentID].height);
        }

        /*****************************************************************************
        ***** COLLISION STUFF
        *****************************************************************************/
        // Checks collisions between 2 rectangles
        public function checkCollision(_rect1:Rectangle, _rect2:Rectangle):Boolean {
            if (_rect1.intersects(_rect2)) {
                return true;
            } else {
                return false;
            }
        }

        public function checkObstacleCollision():Boolean {
            var _isCollision:Boolean = false;
            var _obstacle:Rectangle;
            // Go through each obstacle in the static Main.obstacles array
            for (var _p in main.obstacles) {
                // Get the boundaries of the obstacle
                _obstacle = new Rectangle(main.obstacles[_p].x, main.obstacles[_p].y, main.obstacles[_p].width, main.obstacles[_p].height);

                if (checkCollision(collisionBox, _obstacle)) {
                    _isCollision = true;
                    break;
                }
            }
            return _isCollision;
        }

        public function checkOnscreen():Boolean {
            var _isCollision:Boolean = false;
            if (checkCollision(collisionBox, main.STAGE_RECT)) {
                _isCollision = true;
            }
            return _isCollision;
        }

        public function checkPortalCollision(_direction:int):Boolean {
            var _isCollision:Boolean = false;
            if (_direction > 0) {
                if (position.x > 990 && position.y > 170 && position.y < 270) {
                    _isCollision = true;
                    position.x = 10;
                    position.y += 290;
                }
            }
            else {
                if (position.x < 10 && position.y > 460 && position.y < 560) {
                    _isCollision = true;
                    position.x = 990;
                    position.y -= 290;
                }
            }
            return _isCollision;
        }

    }
}