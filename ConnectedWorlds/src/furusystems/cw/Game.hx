package furusystems.cw;
import com.furusystems.flywheel.geom.Vector2D;
import com.furusystems.flywheel.math.SimplexNoise;
import com.furusystems.flywheel.math.WaveShaper;
import com.furusystems.hxfxr.SfxrParams;
import com.furusystems.hxfxr.SfxrSynth;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.PixelSnapping;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageQuality;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import flash.ui.Keyboard;
import furusystems.console.Console;
import furusystems.cw.Game.Spawn;
import furusystems.cw.Lover;
import tween.Delta;
import tween.easing.Back;
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
	CHECKPOINT(x:Float,y:Float);
}
enum FailStates {
	LETTER;
	LOVER(which:Lover);
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
	
	var inverter:Shape;
	
	var gui:Gui;
	
	var enemies:Array<Enemy>;
	
	public var audio:Audio;
	
	static private inline var SCROLL_SPEED:Int = 2;
	static private inline var LETTER_THROW_IMP:Float = 2;
	static public inline var GRAV:Float = 0.02;
	static public inline var GAME_WIDTH:Int = 640;
	static public inline var GAME_HEIGHT:Int = 480;
	
	static var utilVec:Vector2D = new Vector2D();
	var spawnTimer:Float = 0;
	
	public var multiplier:Int;
	public var score:Float;
	public var highScore:Float = 0;
	public var time:Float;
	
	var throwIndicator:ThrowIndicator;
	var bg:Background;
	var paused:Bool;
	
	public var letterActive:Bool;
	public function new() 
	{
		super();
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	function pickHolder() 
	{
		catchLetter(Math.random() > 0.5?dude:dudette);
	}
	
	public function throwLetter() 
	{
		recatchable = false;
		var throwVec = new Vector2D(letterHolder.velocity.x+1);
		if (letterHolder.inverted) {
			throwVec.y = letterHolder.velocity.y.clamp(0, 1) + LETTER_THROW_IMP;
		}else {
			throwVec.y = letterHolder.velocity.y.clamp(-1, 0) - LETTER_THROW_IMP;
		}
		throwing = true;
		letter.velocity.copyFrom(throwVec);
		var n = throwVec.clone().normalize();
		Delta.tween(letter).propMultiple( { x:n.x * 5, y:n.y * 5 }, 0.25).ease(Back.easeIn).onComplete(releaseLetter);
	}
	
	function releaseLetter() {
		audio.throwSnd.play();
		var pt = new Point(letter.x, letter.y);
		pt = letterHolder.localToGlobal(pt);
		gameContainer.addChild(letter); 
		letter.x = pt.x;
		letter.y = pt.y;
		letterHolder = null; 
		throwing = false;
		throwIndicator.x = letter.x;
		throwIndicator.y = letter.y;
		throwIndicator.onRelease();
	}
	
	public function failState(fs:FailStates) 
	{
		audio.deathSound.playMutated();
		trace("Score: " + score);
		switch(fs) {
			case LETTER:
				trace("Letter dropped");
			case LOVER(which):
				trace("Lover lost: " + which);
		}
		inverter.visible = true;
		paused = true;
		Delta.delayCall(reset, 1);
	}
	
	function reset() 
	{
		paused = false;
		inverter.visible = false;
		time = 0;
		multiplier = 1;
		score = 0;
		
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
		
		dude.y = dudette.y = GAME_HEIGHT * 0.5;
		dude.x = dudette.x = GAME_WIDTH * 0.1;
		
		pickHolder();
	}
	
	private function onAddedToStage(e:Event):Void 
	{
		audio = new Audio();
		
		stage.quality = StageQuality.LOW;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
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
		throwIndicator.x = throwIndicator.y = 120;
		
		noise = new SimplexNoise();
		
		Kbd.init(stage);
		bg = new Background();
		
		gameContainer.addChild(bg);
		
		levelGraphic = new BitmapData(GAME_WIDTH, GAME_HEIGHT,true,0);
		var bmd:Bitmap = cast gameContainer.addChild(new Bitmap(levelGraphic, PixelSnapping.ALWAYS, true));
		bmd.smoothing = false;
		
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
		console.visible = false;
		var w = 150;
		console.setSize(new Rectangle(0,0, w, 120));
		console.x = 640 - w-5;
		console.y = 240 - 60;
		addChild(console);
		
		reset();
		
		//addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
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
	
	function pop(mouseX:Float, mouseY:Float) 
	{
		var s = Math.random()*0.5 + 0.1;
		levelGraphic.filledCircle(cast mouseX, cast mouseY, Std.int(s * 16), 0x00000000);
		for (i in 0...(Std.random(8) + 1)) {
			var s = Math.random()*0.5 + 0.1;
			levelGraphic.filledCircle(cast mouseX + Std.random(16) - 8, cast mouseY + Std.random(16) - 8, Std.int(s * 16), 0x00000000);
		}
	}
	function getGradientAtPoint(x:Float, hm:Array<Int>, width:Int = 6):Vector2D {
		//var x:Int = cast x;
		//var prev:Float = 0;
		//var next:Float = 0;
		//var sampleCount:Int = 0;
		//
		//for (i in 0...width) {
		//}
		
		utilVec.normalize();
		return utilVec;
	}
	
	function checkHeightTop(x:Float):Int {
		return topHeightMap[Math.floor(x)];
	}
	function checkHeightBot(x:Float):Int {
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
			if (e.x < -e.width) {
				removeList.push(e);
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
		
		if (dudette.onGround) {
			var n = getGradientAtPoint(dudette.x, botHeightMap);
			dudette.normalIndicator.rotation = n.angleRad() * 180 / Math.PI;
		}
		
	}
	
	function catchLetter(holder:Lover) 
	{
		audio.catchSnd.playMutated();
		var pt = new Point(letter.x, letter.y);
		pt = holder.globalToLocal(pt);
		letter.x = pt.x;
		letter.y = pt.y;
		holder.addChild(letter);
		letterHolder = previousHolder = holder;
		throwIndicator.x = letterHolder.x;
		throwIndicator.y = letterHolder.y;
		throwIndicator.onCatch();
	}
	
	function addMultiplier() 
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
		scale += (1 - scale) * 0.001;
		time += Stopwatch.delta;
		score = Std.int(time * multiplier);
		highScore = Math.max(highScore, score);
		spawnTimer += Stopwatch.delta;
		if (spawnTimer > 1) {
			spawnTimer -= 1;
			if (Math.random() >= 0.5) {
				if (Math.random() >= 0.5) {
					createEnemy(MINE(GAME_WIDTH, checkHeightTop(GAME_WIDTH - 1)));
				}else {
					createEnemy(MINE(GAME_WIDTH, checkHeightBot(GAME_WIDTH - 1)));
				}
				
			}
		}
		
		updateEntities();
		
		gui.update("Score: " + Std.int(time) + " x " + multiplier + " : " + score+"\nHighest: "+highScore);
		
		render();
		
		Stopwatch.tick();
	}
	
	function createEnemy(spawn:Spawn) 
	{
		var e = new Enemy(spawn);
		enemies.push(e);
		enemyContainer.addChild(e);
	}
	
	function render() 
	{
		levelGraphic.unlock();
		levelGraphic.lock();
		
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
		
		var rect = new Rectangle(levelGraphic.width - 1, 0, 1, a);
		levelGraphic.fillRect(rect, 0xFFFF0000);
		
		topHeightMap.push(Std.int(a));
		if (topHeightMap.length > levelGraphic.width) topHeightMap.shift();
		
		rect.height = b;
		rect.y = levelGraphic.height - b;
		levelGraphic.fillRect(rect, 0xFF00FF00);
		
		botHeightMap.push(Std.int(b));
		if (botHeightMap.length > levelGraphic.width) botHeightMap.shift();
		
		
		rect.height = levelGraphic.height - (a + b);
		rect.y = a;
		levelGraphic.fillRect(rect, 0x00000000);
	}
	
}