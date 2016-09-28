package;

import kha.Image;
import kha.Key;
import kha.Color;
import kha.System;

import hscript.Parser;
import hscript.Interp;

import haxe.io.Error;

class GBEngine implements GBState {
	public var spriteSheet : Image;
	public var tileSheet : Image;
	public var code : Array<String>;
	var parser : Parser;
	var interp : Interp;
	var backBuffer : Image;
	var lastFrameTime : Float;

	public var colors : Array<Color>;

	public function new(code:String, spriteSheet:Image, backBuffer:Image) {
		// Toggle editing of image by pressing 1
		// Keyboard.get().notify( onKeyDown, onKeyUp);
		// Mouse.get().notify( onMouseDown, onMouseUp, onMouseMove, onMouseWheel );

		// backBuffer of 160 x 144 to match GB resolution
		this.spriteSheet = spriteSheet;
		this.code = code.split("\n");
		this.backBuffer = backBuffer;

		// running script
		parser = new Parser();
		
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
		try {
			var ast = parser.parseString(code.join("\n"));
			try {
				interp.execute(ast);
			}
			catch(e:Error) {
				trace(e);
			}
		}
		catch (e:Error) {
			trace(e);
		}
		lastFrameTime = System.time;
	}

	public function update(): Void {
		if(interp.variables.get("_update") != null) {
			interp.variables.get("_update")();
		}

		lastFrameTime = System.time;
	}

	public function render(): Void {
		backBuffer.g2.begin();
		if(interp.variables.get("_render") != null)
			interp.variables.get("_render")();
		backBuffer.g2.end();
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
		backBuffer.g2.fillRect(0,0,GB.sw,GB.sh);
	}

	public function str(text, x, y) {
		backBuffer.g2.drawString(text, x, y);
	}

	public function btn(i:Int) {
		for(button in GB.buttons) {
			return isBtnKeyChar(i, button.key, button.char);
		}
	}

	public function btnp(i:Int) {
		for(button in GB.buttons) {
			if(button.time < lastFrameTime) continue;
			return isBtnKeyChar(i, button.key, button.char);
		}
	}

	public function isBtnKeyChar(i, key:Key, char:String) {
		return switch[i, key, char] {
			case [0, LEFT, _]: 	true;
			case [1, RIGHT, _]: true;
			case [2, UP, _]: 	true;
			case [3, DOWN, _]: 	true;
			case [4, _, 'z']: 	true;
			case [4, _, 'c']: 	true;
			case [4, _, 'n']: 	true;
			case [5, _, 'x']: 	true;
			case [5, _, 'v']: 	true;
			case [5, _, 'm']: 	true;
			default: false;
		}
	}
}
