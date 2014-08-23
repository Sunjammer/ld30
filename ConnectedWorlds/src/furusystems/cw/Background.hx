package furusystems.cw;
import flash.display.BlendMode;
import flash.display.Shape;
import flash.display.Sprite;
import flash.filters.BlurFilter;

/**
 * ...
 * @author Andreas Rønning
 */
class Background extends Sprite
{

	public function new() 
	{
		super();
		redraw();
		//alpha = 0.3;
	}
	public function redraw() {
		graphics.beginFill(Std.random(0xFFFFFF), 0.4);
		graphics.drawRect(0, 0, Game.GAME_WIDTH, Game.GAME_HEIGHT*.5);
		graphics.beginFill(Std.random(0xFFFFFF), 0.4);
		graphics.drawRect(0, Game.GAME_HEIGHT * .5, Game.GAME_WIDTH, Game.GAME_HEIGHT * .5);
		graphics.endFill();
		alpha = 0.5;
		//removeChildren();
		//var sun = new Shape();
		//sun.graphics.beginFill(0);
		//sun.graphics.drawCircle(0, 0, 90);
		//sun.blendMode = BlendMode.INVERT;
		//sun.filters = [new BlurFilter(32, 32, 3)];
		//addChild(sun);
		//sun.x = Game.GAME_WIDTH * .5;
		//sun.y = Game.GAME_HEIGHT * .5;
	}
	
}