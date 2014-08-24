package furusystems.cw;
import com.furusystems.flywheel.geom.Vector2D;
import com.furusystems.flywheel.math.SimplexNoise;
import com.furusystems.flywheel.math.WaveShaper;
import com.furusystems.flywheel.utils.data.Color3;
import com.furusystems.flywheel.utils.data.Color4;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.PixelSnapping;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.media.SoundChannel;
import flash.ui.Keyboard;
import furusystems.console.Console;
import furusystems.cw.colors.Palette;
import furusystems.cw.colors.Picker;
import furusystems.cw.Game.Spawn;
import furusystems.cw.Lover;
import scoreoid.Scoreoid;
import tween.Delta;
import tween.easing.Back;
import tween.easing.Quad;
import tween.utils.Stopwatch;
using furusystems.cw.GraphicsUtils;
using furusystems.cw.MathUtils;

/**
 * ...
 * @author Andreas Rønning
 */
enum Spawn {
	TURRET(x:Float,y:Float);
	FIRE(x:Float,y:Float);
	MINE(x:Float,y:Float);
}
enum FailStates {
	LETTER;
	LOVER(which:Lover);
	CHECKPOINT;
}
class Game extends Sprite
{
	var levelGraphic:BitmapData;
	var topHeightMap:Array<Int>;
	var botHeightMap:Array<Int>;
	var phasesA:Array<Float>;
	var phasesB:Array<Float>;
	var popStamp:Shape;
	var noise:com.furusystems.flywheel.math.SimplexNoise;
	
	var palettes:Array<Palette>;
	
	var colorA:Int;
	var colorB:Int;
	
	public var dude:Lover;
	public var dudette:Lover;
	var gameContainer:Sprite;
	var enemyContainer:Sprite;
	var scale:Float = 0.5;
	var console:furusystems.console.Console;
	var letter:Letter;
	var letterHolder:Lover;
	var previousHolder:Lover;
	var recatchable:Bool;
	var throwing:Bool;
	var drawDivider:Bool;
	var inverter:Shape;
	var gui:Gui;
	var enemies:Array<Enemy>;
	
	public var audio:Audio;
	
	var SCROLL_SPEED:Int = 2;
	static private inline var LETTER_THROW_IMP:Float = 2;
	static public inline var GRAV:Float = 0.02;
	static public inline var GAME_WIDTH:Int = 640;
	static public inline var GAME_HEIGHT:Int = 480;
	
	static var utilVec:Vector2D = new Vector2D();
	var spawnTimer:Float = 0;
	var checkpointTimer:Float = 0;
	
	public var multiplier:Int;
	public var score:Float;
	public var baseScore:Float;
	public var highScore:Float = 0;
	public var time:Float;
	
	var throwIndicator:ThrowIndicator;
	var bg:Background;
	var paused:Bool;
	var music:SoundChannel;
	var checkPointPos:Int;
	var checkPointCrossed:Bool;
	var invulnerable:Bool;
	var starField:StarField;
	var bmd:Bitmap;
	
	public var letterActive:Bool;
	public function new() 
	{
		super();
		palettes = [];
		var picker:Picker = new Picker();
		for (i in 0...40) {
			palettes.push(picker.getPalette(Math.random() * 6.28, Math.random(), 1.1, 0.2,  Math.random() * 0.5 + 0.5, Math.random()));
		}
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	public function primaryPalette():Palette {
		return palettes[0];
	}
	public function secondaryPalette():Palette {
		return palettes[1];
	}
	
	function nextPalette():Void {
		palettes.unshift(palettes.pop());
		palettes.unshift(palettes.pop());
	}
	
	function pickHolder() 
	{
		catchLetter(Math.random() > 0.5?dude:dudette);
	}
	
	public function throwLetter() 
	{
		if (throwing) return;
		recatchable = false;
		var throwVec = new Vector2D(letterHolder.velocity.x.clamp( -1, 1) + 1);
		if (letterHolder.inverted) {
			throwVec.y = letterHolder.velocity.y.clamp(0, 1) + LETTER_THROW_IMP;
		}else {
			throwVec.y = letterHolder.velocity.y.clamp(-1, 0) - LETTER_THROW_IMP;
		}
		throwing = true;
		letter.velocity.copyFrom(throwVec);
		var n = throwVec.clone().normalize();
		Delta.tween(letter).propMultiple( { x:n.x * 3, y:n.y * 5 }, 0.15).ease(Back.easeIn).onComplete(releaseLetter);
	}
	
	function releaseLetter() {
		audio.throwSnd.play();
		var pt = new Point(letter.x, letter.y);
		pt = letterHolder.localToGlobal(pt);
		gameContainer.addChild(letter); 
		letter.x = pt.x;
		letter.y = pt.y;
		letter.blendMode = NORMAL;
		Delta.tween(letter).propMultiple( { scaleX:1, scaleY:1 }, 0.2).ease(Back.easeOut);
		letterHolder.addChild(throwIndicator);
		letterHolder = null; 
		throwing = false;
		throwIndicator.onRelease();
	}
	
	function catchLetter(holder:Lover) 
	{
		if (holder != previousHolder) letter.redraw();
		audio.catchSnd.play();
		audio.catchSnd.play();
		var pt = new Point(letter.x, letter.y);
		pt = holder.globalToLocal(pt);
		letter.x = pt.x;
		letter.y = pt.y;
		letter.blendMode = INVERT;
		Delta.tween(letter).propMultiple( { scaleX:.5, scaleY:.5 }, 0.2).ease(Back.easeOut);
		holder.addChild(letter);
		letterHolder = previousHolder = holder;
		letterHolder.addChild(throwIndicator);
		throwIndicator.onCatch();
	}
	
	public function failState(fs:FailStates) 
	{
		switch(fs) {
			case LOVER(which):
				if(invulnerable) return;
			default:
		}
		if (music != null) music.stop();
		audio.deathSound.play();
		
		
		#if online
		if (Scoreoid.lastResult.getHighest().score < score) {
			switch(fs) {
				case LETTER:
					gui.die("Letter dropped\nWORLD RECORD\n"+score);
				case LOVER(which):
					gui.die("Death\nWORLD RECORD\n"+score);
				case CHECKPOINT:
					gui.die("Failed checkpoint\nWORLD RECORD\n"+score);
			}
			
			Scoreoid.postScore("Developer", Std.int(score), true).addOnce(
				function(e) {
					updateScores(e);
					trace("New scores: " + e); 
				}
			);
		}else {		
			switch(fs) {
				case LETTER:
					gui.die("Letter dropped\n"+score);
				case LOVER(which):
					gui.die("Death\n"+score);
				case CHECKPOINT:
					gui.die("Failed checkpoint\n"+score);
			}
			Delta.delayCall(reset, 1);
		}
		#else
		Delta.delayCall(reset, 1);
		switch(fs) {
			case LETTER:
				gui.die("Letter dropped\n"+score);
			case LOVER(which):
				gui.die("Death\n"+score);
			case CHECKPOINT:
				gui.die("Failed checkpoint\n"+score);
		}
		#end
		inverter.visible = true;
		paused = true;
		
	}
	
	function updateScores(e:ScoreResult) 
	{
		audio.jump1.play();
		audio.jump2.play();
		Delta.delayCall(reset, 3);
	}
	
	function reset() 
	{
		if (music != null) {
			music.stop();
		}
		
		
		gui.deathMsg.visible = false;
		audio.regen();
		//music = new Sound(new URLRequest("gameover2.mp3")).play(0, 9999, new SoundTransform(1));
		
		paused = false;
		inverter.visible = false;
		time = 0;
		multiplier = 1;
		score = baseScore = 0;
		checkPointCrossed = true;
		checkpointTimer = 5 + Std.random(5);
		
		dude.velocity.zero();
		dudette.velocity.zero();
		
		//var c = new Color4();
		//c.r = Math.random();
		//c.g = Math.random();
		//c.b = Math.random();
		//c.a = 1;
		nextPalette();
		colorA = Color4.fromColor3(Color3.fromHex(primaryPalette().complimentaries[2])).toHex();
		colorB = Color4.fromColor3(Color3.fromHex(secondaryPalette().complimentaries[2])).toHex();
		
		//c.r = Math.random();
		//c.g = Math.random();
		//c.b = Math.random();
		//c.a = 1;
		
		gui.x = -300;
		Delta.tween(gui).wait(1).prop("x", 6, 1).ease(Back.easeOut);
		
		phasesA = [for (i in 0...9) Std.random(32) + 1 ];
		phasesB = [for (i in 0...9) Std.random(32) + 1 ];
		
		enemyContainer.removeChildren();
		enemies = [];
		
		levelGraphic.fillRect(levelGraphic.rect, 0);
		for (i in 0...GAME_WIDTH) {
			addLine();
		}
		
		bg.redraw();
		dude.redraw();
		dudette.redraw();
		letter.redraw();
		
		dude.y = dudette.y = GAME_HEIGHT * 0.5;
		dude.x = dudette.x = GAME_WIDTH * 0.1;
		
		pickHolder();
	}
	
	private function onAddedToStage(e:Event):Void 
	{
		stage.addEventListener(Event.DEACTIVATE, onDeactivate);
		
		audio = new Audio();
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		addEventListener(Event.ENTER_FRAME, onUpdate);
		
		topHeightMap = [];
		botHeightMap = [];
		
		popStamp = new Shape();
		popStamp.graphics.beginFill(0);
		popStamp.graphics.drawCircle(8, 8, 16);
		popStamp.graphics.endFill();
		
		
		gameContainer = new Sprite();
		addChild(gameContainer);
		enemyContainer = new Sprite();
		
		dude = new Lover(this, true);
		dudette = new Lover(this);
		letter = new Letter(this);
		throwIndicator = new ThrowIndicator();
		
		noise = new SimplexNoise();
		
		Kbd.init(stage);
		bg = new Background(this);
		
		starField = new StarField();
		gameContainer.addChild(bg);
		gameContainer.addChild(starField);
		
		levelGraphic = new BitmapData(GAME_WIDTH, GAME_HEIGHT,true,0);
		bmd = cast gameContainer.addChild(new Bitmap(levelGraphic, PixelSnapping.ALWAYS, true));
		bmd.smoothing = false;
		bmd.filters = [new GlowFilter(0xFFFFFF, 0.1, 32, 32, 2, 1),new GlowFilter(0xFFFFFF, 0.1, 32, 32, 2, 1)];
		bg.filters = [new DropShadowFilter(0, 0, 0xFFFFFF, 0.6, 64, 64, 1, 3, true)];
		
		gameContainer.addChild(enemyContainer);
		
		gameContainer.scaleX = 640 / GAME_WIDTH;
		gameContainer.scaleY = 480 / GAME_HEIGHT;
		gameContainer.addChild(dude);
		gameContainer.addChild(dudette);
		
		gameContainer.addChild(throwIndicator);
		inverter = new Shape();
		inverter.graphics.beginFill(0);
		inverter.graphics.drawRect(0, 0, GAME_WIDTH, GAME_HEIGHT);
		inverter.blendMode = BlendMode.INVERT;
		inverter.visible = false;
		gameContainer.addChild(inverter);
		
		gui = new Gui();
		addChild(gui);
		
		console = new Console(true);
		console.createCommand("godmode", function() { invulnerable = !invulnerable; } );
		console.visible = false;
		var w = 150;
		console.setSize(new Rectangle(0,0, w, 120));
		console.x = 640 - w-5;
		console.y = 240 - 60;
		addChild(console);
		
		reset();
		
		//addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
	}
	
	private function onDeactivate(e:Event):Void 
	{
		stage.addEventListener(Event.ACTIVATE, onActivate);
		stage.removeEventListener(Event.DEACTIVATE, onDeactivate);
		removeEventListener(Event.ENTER_FRAME, onUpdate);
		//paused = true;
	}
	
	private function onActivate(e:Event):Void 
	{
		stage.removeEventListener(Event.ACTIVATE, onActivate);
		stage.addEventListener(Event.DEACTIVATE, onDeactivate);
		Stopwatch.tick();
		addEventListener(Event.ENTER_FRAME, onUpdate);
		//paused = false;
	}
	
	private inline function mousePt():Vector2D {
		var v = new Vector2D();
		v.x = mouseX * levelGraphic.width / stage.stageWidth;
		v.y = mouseY * levelGraphic.height / stage.stageHeight;
		return v;
	}
	
	private function onMouseDown(e:MouseEvent):Void 
	{
		var mspt = mousePt();
		var result = rayCast(mspt, new Vector2D(0, mspt.y > levelGraphic.height * 0.5? -1 : 1));
		if (result != null) {
			pop(result.x, result.y);
		}
		//pop(mouseX * levelGraphic.width/stage.stageWidth, mouseY * levelGraphic.height/stage.stageHeight);
	}
	
	function pop(x:Float, y:Float) 
	{
		levelGraphic.filledCircle(cast x, cast y, 32, 0x00000000);
		levelGraphic.circle(cast x, cast y, 32, 0xFFFFFFFF);
	}
	
	inline function checkHeightTop(x:Float):Int {
		return topHeightMap[Math.floor(x)];
	}
	inline function checkHeightBot(x:Float):Int {
		return levelGraphic.height-botHeightMap[Math.floor(x)];
	}
	
	function rayCast(from:Vector2D, direction:Vector2D):Null<Vector2D> {
		if (direction.isZero()) throw "Zero direction";
		if (testPixel(from)) {
			return null;
		}
		direction.normalize();
		var rect = levelGraphic.rect;
		var p = from.clone();
		while (rect.containsPoint(p)) {
			p += direction;
			if (testPixel(p)) { 
				return p;
			}
		}
		return null;
	}
	inline function testPixel(v:Vector2D):Bool {
		return levelGraphic.getPixel(Std.int(v.x), Std.int(v.y)) != 0;
	}
	
	function updateEntities() {
		
		var idx = enemies.length;
		var removeList:Array<Enemy> = [];
		for(e in enemies){
			e.update( -SCROLL_SPEED, this);
			if (letterHolder==null && e.distanceBetween(letter) < e.width*0.5) {
				letter.velocity.y = -letter.velocity.y * 0.6;
				//pop(e.x, e.y);
				Delta.tween(e).propMultiple( { scaleX:0, scaleY:0, rotation:180 }, 0.5).ease(Quad.easeOut).onComplete(function() { enemyContainer.removeChild(e); audio.catchSnd.play(); } );
				audio.damageSound.play();
				addMultiplier();
				addMultiplier();
				addMultiplier();
				addMultiplier();
				addMultiplier();
				removeList.push(e);
			}else if (e.x < -e.width) {
				removeList.push(e);
				enemyContainer.removeChild(e);
			}
		}
		for (e in removeList) {
			enemies.remove(e);
		}
		
		
		
		if (Kbd.keyWasStruck(Keyboard.SPACE) && letterHolder != null) {
			throwLetter();
		}
		
		var floor:Float = 0;
		if (letterHolder != null) {
			if(!throwing){
				letter.x += ( -letter.x) * 0.5;
				letter.y += ( -letter.y) * 0.5;
			}
		}else {
			var pt = new Vector2D(letter.x, GAME_HEIGHT * .5);
			var inverted = letter.y < GAME_HEIGHT * .5;
			
			if (inverted) {
				letter.gravity.y = -GRAV;
			}else {
				letter.gravity.y = GRAV;
			}
			letter.update(0);
			letter.rotation += 4;
			
			if (!throwing && !recatchable && MathUtils.distanceBetween(previousHolder, letter) > Lover.DUDESIZE * 2) {
				recatchable = true;
			}
			
			if (previousHolder == dude) {
				if (dude.caughtLetter(letter) && recatchable) {
					catchLetter(dude);
				}else if (dudette.caughtLetter(letter)) {
					addMultiplier();
					catchLetter(dudette);
				}
			}else if (previousHolder == dudette) {
				if (dudette.caughtLetter(letter) && recatchable) {
					catchLetter(dudette);
				}else if (dude.caughtLetter(letter)) {
					addMultiplier();
					catchLetter(dude);
				}
			}
		}
		
		
		var h = checkHeightTop(dude.x);
		var pt = new Vector2D(dude.x, GAME_HEIGHT*.5);
		var pos = rayCast(pt, new Vector2D(0, -1));
		if (pos != null) floor = pos.y;
		else floor = 0;
		
		dude.update(checkHeightTop(dude.x));
		
		pt.setTo(dudette.x, GAME_HEIGHT*.5);
		pos = rayCast(pt, new Vector2D(0, 1));
		if (pos != null) floor = pos.y;
		else floor = GAME_HEIGHT;
		dudette.update(checkHeightBot(dudette.x));
		
	}
	
	function checkPoint() {
		//SCROLL_SPEED = 1;
		drawDivider = true;
		checkPointCrossed = false;
		checkPointPos = GAME_WIDTH;
		checkpointTimer = 5 + Std.random(5);
		nextPalette();
		colorA = Color4.fromColor3(Color3.fromHex(primaryPalette().complimentaries[2])).toHex();
		colorB = Color4.fromColor3(Color3.fromHex(secondaryPalette().complimentaries[2])).toHex();
	}
	
	inline function addMultiplier() 
	{
		multiplier++;
		trace("Multiplier: " + multiplier);
	}
	
	private function onUpdate(e:Event):Void 
	{
		Delta.step(Stopwatch.tock());
		if (paused) {
			Stopwatch.tick();
			return;
		}
		starField.update();
		checkpointTimer -= Stopwatch.delta;
		if (checkpointTimer <= 0) checkPoint();
		scale += (1 - scale) * 0.001;
		time += Stopwatch.delta;
		score = baseScore+Std.int(time * multiplier);
		highScore = Math.max(highScore, score);
		
		spawnTimer += Stopwatch.delta;
		if (spawnTimer > .8) {
			spawnTimer -= .8;
			if (WaveShaper.shape(Math.random(),-0.4) >= Math.cos(Math.min(0, Math.max(1, time/30))*1.57)*0.5) {
				if (Math.random() >= 0.5) {
					createEnemy(MINE(GAME_WIDTH, checkHeightTop(GAME_WIDTH - 1)));
				}else {
					createEnemy(MINE(GAME_WIDTH, checkHeightBot(GAME_WIDTH - 1)));
				}
				
			}
		}
		
		
		updateEntities();
		
		if (!checkPointCrossed) {
			var letterPos = new Point(letter.x, letter.y);
			if (letterHolder != null) {
				letterPos = letterHolder.localToGlobal(letterPos);
				if (letterPos.x > checkPointPos && !invulnerable) failState(CHECKPOINT);
			}else {
				if (letterPos.x > checkPointPos) {
					checkPointCrossed = true;
					bg.redraw();
					addMultiplier();
					addMultiplier();
					audio.passCheckpoint.play();
				}
			}
		}
		
		#if online
		gui.update("Score: " + Std.int(time) + " x " + multiplier + " : " + score+"\nWorld rec: " +Scoreoid.lastResult.getHighest().score + "\nSession rec: " + highScore);
		#else
		gui.update("Score: " + Std.int(time) + " x " + multiplier + " : " + score+"\nPersonal rec: " + highScore);
		#end
		
		render();
		
		Stopwatch.tick();
	}
	
	inline function createEnemy(spawn:Spawn) 
	{
		var e = new Enemy(spawn);
		enemies.push(e);
		enemyContainer.addChild(e);
	}
	
	inline function render() 
	{
		levelGraphic.unlock();
		levelGraphic.lock();
		checkPointPos -= SCROLL_SPEED;
		
		for(i in 0...SCROLL_SPEED) addLine();
	}
	
	inline function uniSin(t:Float):Float {
		return Math.sin(t) * 0.5 + 0.5;
	}
	inline function uniCos(t:Float):Float {
		return Math.cos(t) * 0.5 + 0.5;
	}
	
	inline function simplex(time:Float):Float {
		var freq = 0.05;
		return noise.harmonicNoise2D(time, time, 3, freq, freq) * 0.5 + 0.5;
	}
	
	function addLine() 
	{
		levelGraphic.scroll( -1, 0);
		
		
		var a = uniSin(Stopwatch.time);
		var b = uniCos(Stopwatch.time);
		for (i in 0...phasesA.length) {
			a += uniSin(Stopwatch.time + phasesA[i]);
			b += uniSin(Stopwatch.time + phasesB[i]);
		}
		a /= phasesA.length;
		b /= phasesA.length;
		
		a += 0.1 * simplex(Stopwatch.time * 5+10);
		b += 0.1 * simplex(Stopwatch.time * 4 - 10);
		
		//WaveShaper.shape(a, 0.9);
		//WaveShaper.shape(b, 0.9);
		
		var h = levelGraphic.height * 0.3;
		a *= h * scale;
		b *= h * scale;
		
		var rect = new Rectangle(levelGraphic.width - 1, 0, 1, 0);
		rect.height = levelGraphic.height - (a + b);
		rect.y = a;
		levelGraphic.fillRect(rect, drawDivider?0x30FFFFFF:0);
		
		
		rect = new Rectangle(levelGraphic.width - 1, 0, 1, a);
		levelGraphic.fillRect(rect, colorA);
		levelGraphic.setPixel32(cast rect.x, cast rect.y+rect.height, 0xFFFFFFFF);
		
		topHeightMap.push(Std.int(a));
		if (topHeightMap.length > levelGraphic.width) topHeightMap.shift();
		
		rect.height = b;
		rect.y = levelGraphic.height - b;
		levelGraphic.fillRect(rect, colorB);
		levelGraphic.setPixel32(cast rect.x, cast rect.y, 0xFFFFFFFF);
		
		botHeightMap.push(Std.int(b));
		if (botHeightMap.length > levelGraphic.width) botHeightMap.shift();
		drawDivider = false;
		
		
	}
	
}