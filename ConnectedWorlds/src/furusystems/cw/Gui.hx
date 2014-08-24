package furusystems.cw;
import flash.display.Sprite;
import flash.filters.DropShadowFilter;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import tween.Delta;
import tween.easing.Back;
using furusystems.cw.TextFieldUtils;

/**
 * ...
 * @author Andreas Rønning
 */
class Gui extends Sprite
{
	var out:flash.text.TextField;
	public var deathMsg:flash.text.TextField;

	public function new() 
	{
		super();
		out = new TextField();
		out.autoSize = TextFieldAutoSize.LEFT;
		out.mouseEnabled = false;
		out.defaultTextFormat = new TextFormat("_sans", 16, 0, true);
		out.text = "Hello world";
		blendMode = INVERT;
		alpha = 0.8;
		out.x = 4;
		out.y = 240 - 20;
		addChild(out);
		
		deathMsg = new TextField();
		deathMsg.autoSize = TextFieldAutoSize.LEFT;
		deathMsg.mouseEnabled = false;
		deathMsg.defaultTextFormat = new TextFormat("_sans", 32, 0, true);
		deathMsg.text = "Hello world";
		blendMode = INVERT;
		alpha = 0.8;
		addChild(deathMsg).x = 250;
		deathMsg.visible = false;
	}
	public function update(text:String) {
		out.text = text;
	}
	public function die(text:String):Void {
		text = text.toUpperCase();
		deathMsg.text = text;
		deathMsg.x = 260;
		var dims = deathMsg.getDims();
		Delta.tween(deathMsg).prop("x", 250, 0.2).ease(Back.easeOut);
		deathMsg.y = 240 - dims.height*0.5-dims.y;
		deathMsg.visible = true;
	}
	
}