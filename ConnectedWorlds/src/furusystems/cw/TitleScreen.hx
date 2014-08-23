package furusystems.cw;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.Lib;
import flash.ui.Keyboard;
import tween.Delta;
import tween.utils.Stopwatch;

/**
 * ...
 * @author Andreas Rønning
 */	
class TitleScreen extends Sprite
{

	public function new() 
	{
		super();
		addChild(Lib.attach("titles"));
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	private function onAddedToStage(e:Event):Void 
	{
		alpha = 0;
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		Delta.tween(this).prop("alpha", 1, 0.5);
	}
	
	private function onEnterFrame(e:Event):Void 
	{
		Delta.step(Stopwatch.tock());
		Stopwatch.tick();
	}
	
	private function onKeyDown(e:KeyboardEvent):Void 
	{
		if (e.keyCode == Keyboard.SPACE) {
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			Delta.tween(this).prop("alpha", 0, 0.5).onComplete(exit);
		}
	}
	
	function exit() 
	{
		removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		var p = parent;
		p.removeChild(this);
		p.addChild(new Game());
	}
	
}