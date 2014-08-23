package furusystems.cw;
import flash.display.Shape;
import flash.display.Sprite;
import flash.filters.GlowFilter;

/**
 * ...
 * @author Andreas Rønning
 */
private class Star extends Shape {
	public var vx:Float;
	public function new() {
		super();
		vx = Math.random() + 0.2;
		graphics.beginFill(0xFFFFFF);
		graphics.drawCircle(0, 0, 2 * vx);
		cacheAsBitmap = true;
		filters = [new GlowFilter(0xFFFFFF, 1, 16, 16, 2, 2)];
	}
}
class StarField extends Sprite
{

	var stars:Array<Star>;
	public function new() 
	{
		super();
		alpha = 0.7;
		stars = [];
		for (i in 0...80) {
			var s = new Star();
			stars.push(s);
			s.x = Game.GAME_WIDTH * Math.random();
			s.y = Game.GAME_HEIGHT * Math.random();
			addChild(s);
		}
	}
	public function update() {
		for (s in stars) {
			s.x -= s.vx;
			if (s.x < 0) s.x += Game.GAME_WIDTH;
		}
	}
	
}