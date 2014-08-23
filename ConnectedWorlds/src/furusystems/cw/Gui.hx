package furusystems.cw;
import flash.display.Sprite;
import flash.filters.DropShadowFilter;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

/**
 * ...
 * @author Andreas Rønning
 */
class Gui extends Sprite
{
	var out:flash.text.TextField;

	public function new() 
	{
		super();
		out = new TextField();
		out.autoSize = TextFieldAutoSize.LEFT;
		out.mouseEnabled = false;
		out.defaultTextFormat = new TextFormat("_sans", 16, 0xFFFFFF, true);
		out.text = "Hello world";
		filters = [new DropShadowFilter(0, 0, 0,1, 16, 16, 1,3)];
		alpha = 0.8;
		x = 4;
		y = 240 - 20;
		addChild(out);
	}
	public function update(text:String) {
		out.text = text;
	}
	
}