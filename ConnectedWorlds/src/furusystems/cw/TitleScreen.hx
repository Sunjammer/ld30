package furusystems.cw;
import com.furusystems.hxfxr.SfxrParams;
import com.furusystems.hxfxr.SfxrSynth;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.Lib;
import flash.media.Sound;
import flash.media.SoundTransform;
import flash.net.URLRequest;
import flash.ui.Keyboard;
import tween.Delta;
import tween.utils.Stopwatch;

/**
 * ...
 * @author Andreas Rønning
 */	
class TitleScreen extends Sprite
{
	var music:flash.media.SoundChannel;

	public function new() 
	{
		super();
		addChild(Lib.attach("titles"));
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	private function onAddedToStage(e:Event):Void 
	{
		alpha = 0;
		music = new Sound(new URLRequest("blackwax.mp3")).play(0, 3000, new SoundTransform(0.2));
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
			music.stop();
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			var params = new SfxrParams();
			params.masterVolume = 0.3;
			params.generateExplosion();
			var deathSound = new SfxrSynth();
			deathSound.params = params;
			deathSound.play();
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