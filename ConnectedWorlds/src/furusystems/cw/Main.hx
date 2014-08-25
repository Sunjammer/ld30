package furusystems.cw;

import com.furusystems.flywheel.math.WaveShaper;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.StageQuality;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.Lib;
import scoreoid.Scoreoid;

/**
 * ...
 * @author Andreas Rønning
 */

class Main extends Sprite 
{
	public function new() 
	{
		super();
		
		Scoreoid.init("029e454eafd50821c758866687738d5168c5d89e", "c10d43c62d");
			
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	private function onAddedToStage(e:Event):Void 
	{
		scrollRect = new Rectangle(0, 0, 640, 480);
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		stage.quality = StageQuality.MEDIUM;
		stage.scaleMode = NO_SCALE;
		stage.align = TOP_LEFT;
		
		//
		//var shp = new Shape();
		//shp.graphics.lineStyle(0, 0xFF0000);
		//var tr = 1 / 254;
		//var diff:Float = 0;
		//for (i in 0...255) {
			//var t = i * tr;
			//var v = MathUtils.tri(0.7+diff*0.1, t * 6.28) * 0.5 + 0.5;
			//v = WaveShaper.shape(v, 0.4);
			//v = WaveShaper.shape(v, -0.9+diff*1);
			//v = 1 - v;
			//if (i == 0) shp.graphics.moveTo(t * 640, v*480);
			//else shp.graphics.lineTo(t * 640, v*480);
		//}
		//addChild(shp);
		//return;
		
		
		#if online
		Scoreoid.getScores().addOnce(function(e) { addChild(new TitleScreen()); } );
		#else
		addChild(new TitleScreen());
		#end
		
	}
	static function main() 
	{
		Lib.current.addChild(new Main());
	}
}