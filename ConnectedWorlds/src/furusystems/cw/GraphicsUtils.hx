package furusystems.cw;
import flash.display.BitmapData;

/**
 * ...
 * @author Andreas Rønning
 */
class GraphicsUtils
{

	public static function filledCircle(bmd:BitmapData, xp:Float, yp:Float, radius:Float, col:Int = 0x000000):Void {
		var xoff = 0;
		var yoff = radius;
		var balance = -radius;
	 
		while (xoff <= yoff) {
			 var p0 = xp - xoff;
			 var p1 = xp - yoff;
			 
			 var w0 = xoff + xoff;
			 var w1 = yoff + yoff;
			 
			 hLine(bmd, p0, yp + yoff, w0, col);
			 hLine(bmd, p0, yp - yoff, w0, col);
			 
			 hLine(bmd, p1, yp + xoff, w1, col);
			 hLine(bmd, p1, yp - xoff, w1, col);
		   
			if ((balance += xoff++ + xoff)>= 0) {
				balance-=--yoff+yoff;
			}
		}
	}
 
	static inline function hLine(bmd:BitmapData, xp:Float, yp:Float, w:Float, col:Int) {
		for(i in 0...Std.int(w)){
			bmd.setPixel32(Std.int(xp + i), cast yp, col);
		}
	}
	
	public static function circle(bmd:BitmapData, px:Int, py:Int, r:Int, color:Int):Void
		{
			var x:Int;
			var y:Int;
			var d:Int;
			x = 0;
			y = r;
			d = 1-r;
			bmd.setPixel32(px+x,py+y,color);
			bmd.setPixel32(px+x,py-y,color);
			bmd.setPixel32(px-y,py+x,color);
			bmd.setPixel32(px+y,py+x,color);
			
			while ( y > x )
			{
				if ( d < 0 )
				{
					d += (x+3) << 1;
				}else
				{
					d += ((x - y) << 1) + 5;
					y--;
				}
				x++;
				bmd.setPixel32(px+x,py+y,color);
				bmd.setPixel32(px-x,py+y,color);
				bmd.setPixel32(px+x,py-y,color);
				bmd.setPixel32(px-x,py-y,color);
				bmd.setPixel32(px-y,py+x,color);
				bmd.setPixel32(px-y,py-x,color);
				bmd.setPixel32(px+y,py-x,color);
				bmd.setPixel32(px+y,py+x,color);
			}
		}
	
}