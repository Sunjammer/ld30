package furusystems.cw;
import flash.display.Shape;
import flash.display.Sprite;
import tween.Delta;

/**
 * ...
 * @author Andreas Rønning
 */
class Background extends Sprite
{
	var game:Game;

	public function new(game:Game) 
	{
		super();
		this.game = game;
		addChild(new Shape());
		redraw();
		//alpha = 0.3;
	}
	public function redraw() {
		var shp = new Shape();
		shp.graphics.beginFill(game.primaryPalette().colors[3], 0.4);
		shp.graphics.drawRect(0, 0, Game.GAME_WIDTH, Game.GAME_HEIGHT*.5);
		shp.graphics.beginFill(game.secondaryPalette().colors[3], 0.4);
		shp.graphics.drawRect(0, Game.GAME_HEIGHT * .5, Game.GAME_WIDTH, Game.GAME_HEIGHT * .5);
		shp.graphics.endFill();
		addChildAt(shp,0);
		Delta.tween(getChildAt(1)).prop("alpha", 0, 1).onComplete(removeChildAt.bind(1));
	}
	
}