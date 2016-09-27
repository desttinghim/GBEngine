package;

import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.Image;
import kha.input.Mouse;
import kha.input.Keyboard;
import kha.Key;
import kha.Scaler;
import kha.Color;
import kha.Assets;
import kha.Storage;

import hscript.Parser;
import hscript.Interp;


enum State {
	GAME; CODE; PIXL; BEEP; TUNE; TILE;
}

class GBEngine {
	public var backBuffer : Image;
	public var spriteSheet : Image;
	public var tileSheet : Image;

	var code : Array<String>;
	var parser : Parser;
	var interp : Interp;

	public var sw : Int = 160;
	public var sh : Int = 144;

	public var colors : Array<Color>;

	public var state : State = GAME;

	public function new() {
		Assets.loadEverything(init);
	}

	public function init() {
		System.notifyOnRender(render);
		Scheduler.addTimeTask(update, 0, 1 / 60);

		// Toggle editing of image by pressing 1
		Keyboard.get().notify( onKeyDown, onKeyUp);
		Mouse.get().notify( onMouseDown, onMouseUp, onMouseMove, onMouseWheel );

		// 4 colors from GB
		colors = [
			Color.fromBytes(155, 188, 15),
			Color.fromBytes(139, 172, 15),
			Color.fromBytes(48, 98, 48),
			Color.fromBytes(15, 56, 15)
		];

		// backBuffer of 160 x 144 to match GB resolution
		backBuffer = Image.createRenderTarget(sw, sh);

		spriteSheet = Image.createRenderTarget(256, 256);
		spriteSheet.g2.begin();
		spriteSheet.g2.color = colors[0];
		spriteSheet.g2.fillRect(0,0,128,128);
		spriteSheet.g2.color = colors[3];
		spriteSheet.g2.drawRect(1, 1, 7, 7, 1);
		spriteSheet.g2.drawLine(9, 1, 14, 8);
		spriteSheet.g2.drawLine(9, 1, 9, 8);
		spriteSheet.g2.drawLine(9, 8, 14, 8);
		spriteSheet.g2.end();

		// running script
		parser = new Parser();
		// code = ["function _update() {}", "function _render() {}"];
		code = "// test
var i = 0;
var a = 0;
function _update() 
{
a++;
if( a % 10 == 0)
i++;
}
function _render() 
{
clr();
line(32, 32, 64, 64);
spr( i % 2, 40, 32);
}".split("\n");
		
		// interpreting script...
		interp = new Interp();
		// adding useful things...
		interp.variables.set("spr", spr);
		interp.variables.set("line", line);
		interp.variables.set("rect", rect);
		interp.variables.set("str", str);
		interp.variables.set("clr", clr);

		reset();
	}

	public function reset() {
		trace("Resetting...");
		var ast = parser.parseString(code.join("\n"));
		interp.execute(ast);
	}

	public function save() {
		var name = "";
		if(code[0].charAt(0) == "/" && code[0].charAt(1) == "/") {
			name = code[0].substr(2);
		}
		var file = Storage.namedFile(name);
		file.writeString(code.join("\n"));
		trace(file.readString());
	}

	
	public function onKeyDown( key:Key, char:String ) {
		// add conditional modifier
		switch(char) {
			case '1': state = CODE;
			case '2': state = PIXL;
			case 'r': reset();
			case 's': save();
			default: {};
		}
	}

	public function onKeyUp( key:Key, char:String ) {

	}

	//MOUSE STUFF
	public function onMouseDown(button:Int, x:Int, y:Int) {
		
	}

	public function onMouseUp(button:Int, x:Int, y:Int) {
		
	}

	public function onMouseMove(x:Int, y:Int, moveX:Int, moveY:Int) {
		
	}

	public function onMouseWheel(delta:Int) {

	}

	public function update(): Void {
		if(interp.variables.get("_update") != null) {
			interp.variables.get("_update")();
		}
	}

	public function render(framebuffer: Framebuffer): Void {

		backBuffer.g2.begin();
		if(interp.variables.get("_render") != null)
			interp.variables.get("_render")();
		backBuffer.g2.end();

		framebuffer.g2.begin();
		framebuffer.g2.clear();
		Scaler.scale(backBuffer, framebuffer, System.screenRotation);
		framebuffer.g2.end();
	}

	// API functions

	public function spr(id:Int, x:Int, y:Int) {
		backBuffer.g2.color = Color.White;
		if( id < 0 || id > 127 ) {
			trace('ID out of bounds');
			return;
		}
		var sx = (id % 8) * 8;
		var sy = Math.floor(id / 8) * 8;
		backBuffer.g2.drawSubImage(spriteSheet, x, y, sx, sy, 8, 8);
	}

	public function line(x1, y1, x2, y2) {
		backBuffer.g2.drawLine(x1, y1, x2, y2);
	}

	public function rect(x, y, w, h) {
		backBuffer.g2.drawRect(x, y, w, h);
	}

	public function clr() {
		backBuffer.g2.color = colors[0];
		backBuffer.g2.clear();
		backBuffer.g2.fillRect(0,0,sw,sh);
	}

	public function str(text, x, y) {
		backBuffer.g2.drawString(text, x, y);
	}
}
