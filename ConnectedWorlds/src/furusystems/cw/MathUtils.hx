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
	public static inline function tri(a:Float, x:Float):Float {
		x = x / (2.0*Math.PI);
		x = x % 1.0;
		if( x<0.0 ) x = 1.0+x;
		if(x<a) x=x/a; else x=1.0-(x-a)/(1.0-a);
		return -1.0+2.0*x;
	}
	
}