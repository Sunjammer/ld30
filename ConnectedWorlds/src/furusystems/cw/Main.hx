package furusystems.cw;

import flash.display.StageQuality;
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
		addChild(new Game());
		
	}
	static function main() 
	{
		Lib.current.addChild(new Main());
	}
}