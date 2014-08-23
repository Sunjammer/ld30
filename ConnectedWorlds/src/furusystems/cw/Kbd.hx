package furusystems.cw;
import flash.display.Stage;
import flash.events.Event;
import flash.events.KeyboardEvent;

/**
 * ...
 * @author Andreas Rønning
 */
class Kbd
{
	static var keymap = new Map<Int,Bool>();
	static var struckmap = new Map<Int,Bool>();
	static var stage:Stage;
	public static function init(stage:Stage) {
		Kbd.stage = stage;
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}
	
	static function onKeyUp(e:KeyboardEvent):Void 
	{
		keymap.set(e.keyCode, false);
	}
	
	static function onKeyDown(e:KeyboardEvent):Void 
	{
		keymap.set(e.keyCode, true);
		struckmap.set(e.keyCode, true);
		stage.addEventListener(Event.ENTER_FRAME, unStrike);
	}
	
	static private function unStrike(e:Event):Void 
	{
		struckmap = new Map<Int,Bool>();
		stage.removeEventListener(Event.ENTER_FRAME, unStrike);
	}
	
	public static function keyWasStruck(code:Int):Bool {
		return struckmap.exists(code);
	}
	
	public static function keyIsDown(code:Int):Bool {
		if (!keymap.exists(code)) return false;
		return keymap[code];
	}
	
}