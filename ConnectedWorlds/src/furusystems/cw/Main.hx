package furusystems.cw;

import flash.display.StageQuality;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.Lib;
import flash.display.Sprite;

/**
 * ...
 * @author Andreas Rønning
 */

class Main extends Sprite 
{
	public function new() 
	{
		super();
		
		/**
		 * Entry point.
		 * New to AIR? Please read the readme.txt files *carefully*!
		 */
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	private function onAddedToStage(e:Event):Void 
	{
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		stage.quality = StageQuality.LOW;
		stage.scaleMode = NO_SCALE;
		stage.align = TOP_LEFT;
		addChild(new TitleScreen());
		
	}
	static function main() 
	{
		Lib.current.addChild(new Main());
	}
}