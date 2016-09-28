package;

import kha.Key;
import kha.Color;
import kha.Image;
import kha.System;

import bitmapText.BitmapText;

class GBCode implements GBState {
	// var codeEdit : Bool = false;
	var drawFont : Font;
	var codeImages : Array<BitmapText>;
	var codeCursor : {line:Int, col:Int, blink:Int};
	var ctrlPressed = false;
	var code : Array<String>;
	var backBuffer : Image;

	public var cursorColor : Color = GB.colors[2];
	public var textColor : Color = GB.colors[3];

	public function new(c:String, backBuffer:Image) {
		this.code = c.split("\n");
		this.backBuffer = backBuffer;
		BitmapText.loadFont('PressStart2P');
		codeImages = [];
		for(loc in code) {
			codeImages.push(new BitmapText(loc, 'PressStart2P', GB.sw, 8));
		}
		trace(codeImages);
		codeCursor = {
			line: code.length-1,
			col: code[code.length-1].length-1,
			blink: 0
		};
	}

	public function onKeyDown( key:Key, char:String ) {
		switch(key) {
			case UP: {
				moveCursor(-1, 0);
			}
			case DOWN: {
				moveCursor(1, 0);
			}
			case LEFT: {
				moveCursor(0, -1);
			}
			case RIGHT: {
				moveCursor(0, 1);
			}
			case BACKSPACE: {
				var s = spliceStr(code[codeCursor.line], codeCursor.col);
				s[0] = s[0].substr(0, s[0].length-1);
				code[codeCursor.line] = s[0] + s[1];
				redrawLine(codeCursor.line);

				codeCursor.col--;
				codeCursor.col = cast Math.min( code[codeCursor.line].length, Math.max(codeCursor.col, 0));
			}
			default: {
				var s = spliceStr(code[codeCursor.line], codeCursor.col);
				s[0] += char.toLowerCase();
				code[codeCursor.line] = s[0] + s[1];
				redrawLine(codeCursor.line);

				codeCursor.col++;
			}
		}
	}

	public function onKeyUp( key:Key, char:String ) {

	}

	var lastButtonCheckTime:Float = 0;
	public function update() {
		codeCursor.blink++;

		for(button in GB.buttons) {
			if(button.time > lastButtonCheckTime) {
				lastButtonCheckTime = System.time;
				onKeyDown(button.key, button.char);
			}
		}
	}

	public function render() {
		var graphics = backBuffer.g2;
		graphics.begin();
		for(i in 0...codeImages.length) {
			graphics.color = textColor;
			graphics.drawImage(codeImages[i].image, 0, i * 8);
		}
		if(codeCursor.blink % 100 < 50) {
			graphics.color = cursorColor;
			graphics.fillRect(codeCursor.col*8, codeCursor.line * 8, 8, 8);
		}
		graphics.end();
	}


	/**************************************************
	* HELPER METHODS
	***************************************************/
	
	function spliceStr(s:String, pos:Int):Array<String> {
		return [
			s.substr(0, pos),
			s.substr(pos)
		];
	}

	function redrawLine(i:Int) {
		codeImages[codeCursor.line].text = code[codeCursor.line];
		codeImages[codeCursor.line].update();
	}

	function moveCursor(lineRel:Int, colRel:Int) {
		codeCursor.blink = 0;

		codeCursor.line += lineRel;
		codeCursor.line = cast Math.min( code.length-1, Math.max(codeCursor.line, 0));

		codeCursor.col += colRel;
		codeCursor.col = cast Math.min( code[codeCursor.line].length, Math.max(codeCursor.col, 0));
	}
}