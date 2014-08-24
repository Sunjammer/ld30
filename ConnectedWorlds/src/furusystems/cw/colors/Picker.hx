package furusystems.cw.colors;
import com.furusystems.flywheel.geom.Vector2D;
import com.furusystems.flywheel.utils.data.Color3;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Vector3D;
import furusystems.cw.colors.Picker.Wheel;

/**
 * ...
 * @author Andreas Rønning
 */
@:bitmap("assets/color_wheel_365.png")
class Wheel extends flash.display.BitmapData
{
	
}
class Picker
{
	var wheel:BitmapData;
	var center:Vector2D;
	static var utilVec3:Vector3D = new Vector3D();
	static var grayDot:Vector3D = new Vector3D(0.2126, 0.7152, 0.0722);
	static var black:Vector3D = new Vector3D();
	function brightness(vec:Vector3D, v:Float):Vector3D {
		return mix(black, vec, v);
	}
	function desaturate(vec:Vector3D, v:Float):Vector3D {
		var d = grayDot.dotProduct(vec);
		return mix(vec, new Vector3D(d, d, d), v);
	}
	inline function mix(a:Vector3D, b:Vector3D, v:Float):Vector3D {
		return new Vector3D(
			a.x + (b.x - a.x) * v,
			a.y + (b.y - a.y) * v,
			a.z + (b.z - a.z) * v);
	}
	public function new() 
	{
		wheel = new Wheel(365, 365,false);
		center = new Vector2D();
		center.x = wheel.width * 0.5;
		center.y = wheel.height * 0.5;
	}
	static var utilVec:Vector2D = new Vector2D();
	
	public function getColor(angle:Float, magnitude:Float, saturation:Float = 1, brightnessValue:Float = 1):Int {
		saturation = 1 - saturation;
		utilVec.x = center.x + Math.cos(angle) * magnitude * center.x;
		utilVec.y = center.y + Math.sin(angle) * magnitude * center.y;
		utilVec.truncate(364);
		return cast(brightness(desaturate(Color3.fromHex(wheel.getPixel(cast utilVec.x, cast utilVec.y)), saturation), brightnessValue), Color3).toHex();
	}
	
	public function getPalette(startAngle:Float, startMag:Float, spreadX:Float, spreadY:Float, saturation:Float = 1, brightnessValue:Float = 1):Palette {
		var main:Array<Int> = [];
		var complimentary:Array<Int> = [];
		for (i in 0...5) {
			var fac = (i / 5) - 0.5;
			var m = startMag - Math.random() * spreadY;
			main[i] = getColor(startAngle + fac * spreadX, m, saturation, brightnessValue);
			complimentary[i] = getColor((startAngle + 3.14) + fac * spreadX, m, saturation, brightnessValue);
		}
		return new Palette(main, complimentary);
	}
	
}