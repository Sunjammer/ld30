package furusystems.cw;
import flash.display.DisplayObject;

/**
 * ...
 * @author Andreas Rønning
 */
class MathUtils
{

	public static inline function clamp(value:Float, min:Float = 0.0, max:Float = 1.0):Float {
		return Math.max(min, Math.min(value, max));
	}
	
	public static inline function distanceBetween(a:DisplayObject, b:DisplayObject):Float {
		var dx = b.x - a.x;
		var dy = b.y - a.y;
		return Math.sqrt(dx * dx + dy * dy);
	}
	
}