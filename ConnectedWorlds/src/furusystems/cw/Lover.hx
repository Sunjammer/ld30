package furusystems.cw;
import com.furusystems.flywheel.geom.Vector2D;
import com.furusystems.hxfxr.SfxrSynth;
import flash.display.Shape;
import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.ui.Keyboard;
import furusystems.cw.Letter;
import tween.utils.Stopwatch;
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
	static private inline var MOVESPD:Float = 3;
	static private inline var JUMP_IMP:Float = 3.5;
	var game:Game;
	static private inline var CATCH_BUFFER:Float = 1.2;
	public var normalIndicator:flash.display.Shape;
	var jumpDelay:Float;
	
	public var mass:Float = 4;
	public function new(game:Game, inverted:Bool = false) 
	{
		super();
		jumpDelay = 0;
		this.game = game;
		this.inverted = inverted;
		velocity = new Vector2D();
		if (inverted) {
			gravity = new Vector2D(0, -Game.GRAV*mass);
		}else {
			gravity = new Vector2D(0, Game.GRAV*mass);
		}
		redraw();
		cacheAsBitmap = true;
		normalIndicator = new Shape();
		//addChild(normalIndicator);
		normalIndicator.graphics.lineStyle(0);
		normalIndicator.graphics.lineTo(10, 0);
	}
	public inline function redraw() {
		graphics.clear();
		var c:Int;
		if (inverted) {
			c = game.secondaryPalette().complimentaries[2];
		}else {
			c = game.primaryPalette().complimentaries[2];
		}
		graphics.beginFill(c);
		graphics.lineStyle(2, 0xFFFFFF);
		graphics.drawCircle(0, 0, DUDESIZE);
		filters = [new GlowFilter(c, 0.3, 16, 16,1,3)];
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
		
		if ((jumpDelay -= Stopwatch.delta) <= 0 && Kbd.keyWasStruck(key) && onGround) {
			jumpDelay = 0.2;
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
	
	public inline function caughtLetter(letter:Letter):Bool 
	{
		var dist = new Vector2D(letter.x, letter.y).distance(new Vector2D(x, y));
		return dist < DUDESIZE*2;
	}
	
}