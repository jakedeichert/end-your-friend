package classes {
    import classes.*; // imports all classes from the "classes" folder
    import flash.geom.Point;
    import flash.geom.Rectangle;

    public class Projectile extends Animation {

        public var shootTime:Number = -100;
        var damage:Number = 20;
        var owner:Player; // Which player the bullet belongs to
        var direction:int = 1;

        public function Projectile(_position:Point, _originalVelocity:Point, _scale:int, _main:Object, _player:Player) {
            super(_position, _originalVelocity, _scale, _main);
            isActive = false;
            owner = _player;
        }

        public override function update():void {
            if (isActive) {
                // Check if there is an obstacle collision
                updateCollisionBox();
                // Check if the bullet has entered a portal
                if (!checkPortalCollision(direction)) {
                    if (checkObstacleCollision() || checkPlayerCollision() || !checkOnscreen()) {
                        isActive = false;
                        setVisible(false);
                    }
                }
                super.update();
            }
        }

        public function fire(_position:Point, _direction:int):void {
            shootTime = main.elapsedGameTime;
            velocity.x = _direction * originalVelocity.x;
            direction = _direction;
            position = _position;
            isActive = true;
            setVisible(true);
        }



        public function checkPlayerCollision():Boolean {
            var _isCollision:Boolean = false;
            for (var _p in main.players) {
                if (checkCollision(collisionBox, main.players[_p].collisionBox) && main.players[_p] != owner) {
                    _isCollision =  true;
                    main.players[_p].hit(damage);
                    break;
                }
            }
            return _isCollision;
        }


    }
}