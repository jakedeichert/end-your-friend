package classes {
    import classes.*; // imports all classes from the "classes" folder
    import flash.geom.Point;

    public class VerticalPlatform extends Animation {

        public function VerticalPlatform(_position:Point, _originalVelocity:Point, _scale:int, _main:Object) {
            super(_position, _originalVelocity, _scale, _main);
            isActive = true;
            velocity = originalVelocity;
        }


        public override function update():void {
            if (isActive) {
                if (position.y < 340){
                    velocity.y *= -1;
                    position.y = 341;
                }
                else if (position.y > 500){
                    velocity.y *= -1;
                    position.y = 501;
                }
                super.update();
            }
        }
    }

}
