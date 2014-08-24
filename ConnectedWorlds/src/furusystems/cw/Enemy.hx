package furusystems.cw;
import flash.display.Sprite;
import flash.Lib;
import furusystems.cw.Game.Spawn;
import tween.utils.Stopwatch;

/**
 * ...
 * @author Andreas Rønning
 */
class Enemy extends Sprite
{
	var spawn:Spawn;
	var age:Float;
	public var removable:Bool;
	public function new(spawn:Spawn) 
	{
		super();
		age = 0;
		this.spawn = spawn;
		switch(spawn) {
			case MINE(x, y):
				this.x = x;
				this.y = y;
				addChild(Lib.attach("mine"));
			default:
				
		}
	}
	public function update(move:Float, game:Game):Void {
		age += Stopwatch.delta;
		x += move;
		switch(spawn) {
			case MINE(x, y):
				scaleX = scaleY = 1.0 + Math.sin(age*10) * 0.1;
				if (MathUtils.distanceBetween(this, game.dude) < width*.5 + Lover.DUDESIZE) {
					trace("DUDE HIT");
					game.failState(LOVER(game.dude));
				}else if (MathUtils.distanceBetween(this, game.dudette) < width*.5 + Lover.DUDESIZE) {
					trace("DUDETTE HIT");
					game.failState(LOVER(game.dudette));
				}
			default:
				
		}
	}
	
}