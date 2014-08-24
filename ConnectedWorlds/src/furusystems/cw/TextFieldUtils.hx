package furusystems.cw;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.text.TextField;

/**
 * ...
 * @author Andreas Rønning
 */
class TextFieldUtils
{

	public static inline function getDims(tf:TextField):Rectangle {
		var bmd = new BitmapData(cast tf.width, cast tf.height, true, 0x00ffffff);
		bmd.draw(tf);
		var rect = bmd.getColorBoundsRect(0xff000000, 0x00000000, false);
		bmd.dispose();
		return rect;
	}
	
}