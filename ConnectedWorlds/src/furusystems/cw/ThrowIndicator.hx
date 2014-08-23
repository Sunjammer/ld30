package furusystems.cw;
import flash.display.Sprite;
import tween.Delta;

/**
 * ...
 * @author Andreas Rønning
 */
class ThrowIndicator extends Sprite
{

	public function new() 
	{
		super();
		var radius = 30;
		graphics.beginFill(0);
		graphics.drawCircle(0, 0, radius);
		graphics.drawCircle(0, 0, radius-3);
		graphics.endFill();
	}
	public function onCatch() {
		scaleX = scaleY = 1;
		alpha = 1;
		Delta.tween(this).propMultiple( { scaleX:0, scaleY:0, alpha:0 }, 0.25);
	}
	public function onRelease() {
		scaleX = scaleY = 0;
		alpha = 1;
		Delta.tween(this).propMultiple( { scaleX:1, scaleY:1, alpha:0 }, 0.25);
	}
	
}