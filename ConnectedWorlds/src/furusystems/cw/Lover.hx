package furusystems.cw;
import com.furusystems.flywheel.geom.Vector2D;
import com.furusystems.hxfxr.SfxrSynth;
import flash.display.Shape;
import flash.display.Sprite;
import flash.ui.Keyboard;
import furusystems.cw.Letter;
using furusystems.cw.MathUtils;
/**
 * ...
 * @author Andreas Rønning
 */
class Lover extends Sprite
{
	public var inverted:Bool;

	static public inline var DUDESIZE:Float = 10;
	public var gravity:Vector2D;
	public var velocity:Vector2D;
	public var onGround:Bool;
	static private inline var MOVESPD:Float = 2;
	static private inline var JUMP_IMP:Float = 2;
	var game:Game;
	static private inline var CATCH_BUFFER:Float = 1.2;
	public var normalIndicator:flash.display.Shape;
	public function new(game:Game, inverted:Bool = false) 
	{
		super();
		this.game = game;
		this.inverted = inverted;
		velocity = new Vector2D();
		if (inverted) {
			gravity = new Vector2D(0, -Game.GRAV);
		}else {
			gravity = new Vector2D(0, Game.GRAV);
		}
		redraw();
		cacheAsBitmap = true;
		normalIndicator = new Shape();
		addChild(normalIndicator);
		normalIndicator.graphics.lineStyle(0);
		normalIndicator.graphics.lineTo(10, 0);
	}
	public function redraw() {
		graphics.clear();
		graphics.beginFill(Std.random(0xFFFFFF));
		graphics.drawCircle(0, 0, DUDESIZE);
	}
	
	public function update(floor:Float) {
		var prevY = y;
		velocity += gravity;
		velocity.x *= 0.6;
		if (inverted) {
			floor = floor + DUDESIZE;
		}else {
			floor = floor - DUDESIZE;
		}
		
		onGround = Math.abs(floor - y) < 8;
		var key = !inverted?Keyboard.UP:Keyboard.DOWN;
		
		if (Kbd.keyWasStruck(key) && onGround) {
			y = floor;
			onGround = false;
			if (inverted) {
				velocity.y = JUMP_IMP;
				game.audio.jump1.play();
			}else {
				velocity.y = -JUMP_IMP;
				game.audio.jump2.play();
			}
		}else {
			if (inverted) {	
				if (y < floor) {
					var diff = y - floor;
					y = floor;
					velocity.y = 0;
				}	
			}else {		
				if (y > floor) {
					var diff = y - floor;
					y = floor;
					velocity.y = 0;
				}
			}
		}
		if (Kbd.keyIsDown(Keyboard.RIGHT)) {
			velocity.x = MOVESPD;
		}else if (Kbd.keyIsDown(Keyboard.LEFT)) {
			velocity.x = -MOVESPD;
		}
		
		alpha = onGround?1:0.8;
		
		x += velocity.x;
		y += velocity.y;
		x = x.clamp(0, Game.GAME_WIDTH-1);
	}
	
	public function caughtLetter(letter:Letter):Bool 
	{
		var dist = new Vector2D(letter.x, letter.y).distance(new Vector2D(x, y));
		return dist < DUDESIZE*2;
	}
	
}