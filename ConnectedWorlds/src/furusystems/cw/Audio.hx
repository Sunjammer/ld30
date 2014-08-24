package furusystems.cw;
import com.furusystems.hxfxr.SfxrParams;
import com.furusystems.hxfxr.SfxrSynth;

/**
 * ...
 * @author Andreas Rønning
 */
class Audio
{

	public var jump1:SfxrSynth;
	public var jump2:SfxrSynth;
	public var throwSnd:SfxrSynth;
	public var catchSnd:SfxrSynth;
	public var deathSound:SfxrSynth;
	public var passCheckpoint:SfxrSynth;
	public function new() 
	{
		regen();
	}
	public function regen() {
		
		var vol = 0.3;
		var params = new SfxrParams();
		params.masterVolume = vol;
		params.generateJump();
		jump1 = new SfxrSynth();
		jump1.params = params;
		
		params = new SfxrParams();
		params.masterVolume = vol;
		params.generateJump();
		jump2 = new SfxrSynth();
		jump2.params = params;
		
		params = new SfxrParams();
		params.masterVolume = vol;
		params.generateHitHurt();
		throwSnd = new SfxrSynth();
		throwSnd.params = params;
		
		params = new SfxrParams();
		params.masterVolume = vol;
		params.generatePickupCoin();
		catchSnd = new SfxrSynth();
		catchSnd.params = params;
		
		params = new SfxrParams();
		params.masterVolume = vol;
		params.generateExplosion();
		deathSound = new SfxrSynth();
		deathSound.params = params;
		
		params = new SfxrParams();
		params.masterVolume = vol;
		params.generateBlipSelect();
		passCheckpoint = new SfxrSynth();
		passCheckpoint.params = params;
	}
	
}