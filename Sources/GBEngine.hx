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
import kha.Font;

import hscript.Parser;
import hscript.Interp;

import bitmapText.BitmapText;

class GBEngine {
	public var backBuffer : Image;
	public var spriteSheet : Image;
	public var tileSheet : Image;

	var parser : Parser;
	var interp : Interp;

	public var sw : Int = 160;
	public var sh : Int = 144;

	public var colors : Array<Color>;

	public var imageEdit : Bool;
	public var isMouseDown : Bool = false;
	public var edits : Array<{x:Int, y:Int}> = [];

	public var codeEdit : Bool = false;
	var code : Array<String>;
	var drawFont : Font;
	var codeImages : Array<BitmapText>;
	var codeCursor : {line:Int, col:Int, blink:Int};

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
		// drawFont = Assets.fonts.Sparkly_Font;
		// backBuffer.g2.fontSize = 2;
		// backBuffer.g2.font = drawFont;

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
		code = ["function _update() {}", "function _render() {}"];
// 		code = "var i = 0;
// var a = 0;
// function _update() {
// 	a++;
// 	if( a % 10 == 0)
// 		i++;
// }
// function _render() {
// 	clr();
// 	line(32, 32, 64, 64);
// 	spr( i % 2, 40, 32);
// }";

		BitmapText.loadFont('PressStart2P');
		codeImages = [];
		for(loc in code) {
			codeImages.push(new BitmapText(loc, 'PressStart2P', sw, sh));
		}
		codeCursor = {
			line: code.length-1,
			col: code[code.length-1].length-1,
			blink: 0
		};

		var ast = parser.parseString(code.join(" "));
		
		// interpreting script...
		interp = new Interp();
		// adding useful things...
		interp.variables.set("spr", spr);
		interp.variables.set("line", line);
		interp.variables.set("rect", rect);
		interp.variables.set("str", str);
		interp.variables.set("clr", clr);
		interp.execute(ast);
	}

	public function onKeyDown( key:Key, char:String ) {
		if(codeEdit) {
			if(key == UP) {
				if(codeCursor.line > 0) codeCursor.line--;
			}
			if(key == DOWN) {
				if(codeCursor.line < code.length-1) codeCursor.line++;
			}
			if(key == LEFT) {
				if(codeCursor.col > 0) codeCursor.col--;
			}
			if(key == RIGHT) {
				if(codeCursor.col < code[codeCursor.line].length-1) codeCursor.col++;
			}
		}
	}

	public function onKeyUp( key:Key, char:String ) {
		if(key == TAB) {
			imageEdit = !imageEdit;
		}
		if(key == ENTER) {
			codeEdit = !codeEdit;
		}
	}


	//MOUSE STUFF
	public function onMouseDown(button:Int, x:Int, y:Int) {
		if(imageEdit) {
			isMouseDown = true;
			edits.push({x: x, y: y});
		}
	}

	public function onMouseUp(button:Int, x:Int, y:Int) {
		if(imageEdit) {
			isMouseDown = false;
		}
	}

	public function onMouseMove(x:Int, y:Int, moveX:Int, moveY:Int) {
		if(imageEdit && isMouseDown) {
			edits.push({x: x, y: y});
		}
	}

	public function onMouseWheel(delta:Int) {

	}

	public function update(): Void {
		if(imageEdit) {

		}
		else if(interp.variables.get("_update") != null) {
			interp.variables.get("_update")();
		}
	}

	public function render(framebuffer: Framebuffer): Void {

		if(imageEdit) {
			var prevEdit = null;
			spriteSheet.g2.begin(false);
			for(edit in edits) {
				var x = Scaler.transformX(edit.x, edit.y, backBuffer, framebuffer, System.screenRotation);
				var y = Scaler.transformY(edit.x, edit.y, backBuffer, framebuffer, System.screenRotation);
				var x1 = x;
				var y1 = y;
				spriteSheet.g2.color = colors[3];
				if(prevEdit != null) {
					x1 = prevEdit.x;
					y1 = prevEdit.y;
					spriteSheet.g2.drawLine(x, y, x1, y1);
				}
				else {
					spriteSheet.g2.fillRect(x, y, 1, 1);
				}
				prevEdit = {x: x, y: y};
			}
			edits = [];
			spriteSheet.g2.end();
		}

		backBuffer.g2.begin();
		if(imageEdit) {
			backBuffer.g2.color = Color.White;
			backBuffer.g2.drawImage(spriteSheet, 0, 0);
		} else if(codeEdit) {
			for(i in 0...codeImages.length-1) {
				backBuffer.g2.color = colors[2];
				backBuffer.g2.drawImage(codeImages[i].image, 0, i * 8);
				codeCursor.blink++;
				backBuffer.g2.color = colors[2];
				if(codeCursor.blink % 100 < 50) {
					backBuffer.g2.fillRect(codeCursor.col*8, codeCursor.line * 8, 8, 8);
				}
			}
		}
		else if(interp.variables.get("_render") != null)
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
