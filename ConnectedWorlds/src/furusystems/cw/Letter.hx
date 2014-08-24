package furusystems.cw;
import com.furusystems.flywheel.geom.Vector2D;
import flash.display.Shape;
import flash.display.Sprite;
import flash.filters.GlowFilter;
import furusystems.cw.Game.FailStates;

/**
 * ...
 * @author Andreas Rønning
 */
class Letter extends Sprite
{
	var game:Game;
	static private inline var LETTER_SIZE:Float = 15;
	public var held:Bool;
	public var gravity:Vector2D;
	public var velocity:Vector2D;
	public var mass:Float = 0.6;
	public function new(game:Game) 
	{
		super();
		velocity = new Vector2D();
		gravity = new Vector2D(0, Game.GRAV*mass);
		this.game = game;
		redraw();
	}
	
	public function redraw() {
		graphics.clear();
		//var c = game.currentPalette().colors[Std.random(3)];
		var c = Std.random(0xFFFFFF);
		filters = [new GlowFilter(0xFFFFFF, 0.3, 16, 16,1,3)];
		graphics.beginFill(c);
		graphics.lineStyle(0, 0xFFFFFF);
		graphics.drawRect( -LETTER_SIZE*.5, -LETTER_SIZE*.5, LETTER_SIZE, LETTER_SIZE);
		graphics.endFill();
	}
	public function update(floor:Float) {
		velocity += gravity;
		velocity.x *= 0.99;
		velocity.x -= 0.01;
		
		x += velocity.x;
		y += velocity.y;
		
		if (x < 0 || x > Game.GAME_WIDTH || y < 0 || y > Game.GAME_HEIGHT) {
			game.failState(FailStates.LETTER);
		}
	}
	
}