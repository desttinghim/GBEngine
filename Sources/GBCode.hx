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

	var bgColor : Color = GB.colors[3];
	var cursorColor : Color = GB.colors[0];
	var textColor : Color = GB.colors[0];

	public function new(c:Array<String>, backBuffer:Image) {
		this.code = c;
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
			case ALT: {

			}
			case CTRL: {

			}
			case ENTER: {
				var s = spliceStr(code[codeCursor.line], codeCursor.col);
				code[codeCursor.line] = s[0];
				addLine(codeCursor.line+1, s[1]);
				
				moveCursor(1, -s[0].length);
			}
			case BACKSPACE: {
				if(codeCursor.col == 0) {
					var s = code.splice(codeCursor.line, 1);
					trace(s);
					moveCursor(-1, 0);
					moveCursor(0, code[codeCursor.line].length);
					code[codeCursor.line] + s[0];

					//TODO: get string stuff working, remove image

					redraw();
				}
				else {
					var s = spliceStr(code[codeCursor.line], codeCursor.col);
					s[0] = s[0].substr(0, s[0].length-1);
					code[codeCursor.line] = s[0] + s[1];
					redrawLine(codeCursor.line);

					codeCursor.col--;
					codeCursor.col = cast Math.min( code[codeCursor.line].length, Math.max(codeCursor.col, 0));
				}
			}
			default: {
				if(char == '') return;
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
			var waitTime = (System.time - button.time);
			if(button.time > lastButtonCheckTime || (waitTime > 2 && waitTime % 0.1 == 0)) {
				lastButtonCheckTime = System.time;
				onKeyDown(button.key, button.char);
				break;
			}
		}
	}

	public function render() {
		var graphics = backBuffer.g2;
		graphics.begin();

		graphics.color = bgColor;
		graphics.fillRect(0,0,GB.sw,GB.sh);

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

	function addLine(i:Int, text:String) {
		code.insert(codeCursor.line+1, text);
		codeImages.insert(codeCursor.line+1, new BitmapText(
			text, 'PressStart2P', GB.sw, 8
		));
		redraw();
	}

	function redraw() {
		for(i in 0...codeImages.length) {
			redrawLine(i);
		}
	}

	function moveCursor(lineRel:Int, colRel:Int) {
		codeCursor.blink = 0;

		codeCursor.line += lineRel;
		if(codeCursor.line < 0) {
			codeCursor.line = 0;
			codeCursor.col = 0;
		}
		if(codeCursor.line > code.length) {
			codeCursor.line = code.length;
			codeCursor.col = code[code.length-1].length;
		}

		codeCursor.line = cast Math.min( code.length-1, Math.max(codeCursor.line, 0));
		codeCursor.col = cast Math.min( code[codeCursor.line].length, Math.max(codeCursor.col, 0));

		codeCursor.col += colRel;
		if(codeCursor.col < 0 && codeCursor.line > 1) {
			codeCursor.line -= 1;
			codeCursor.col += code[codeCursor.line].length;
		} else if(codeCursor.col > code[codeCursor.line].length && codeCursor.line < code.length-1) {
			codeCursor.col -= code[codeCursor.line].length;
			codeCursor.line += 1;
		}

		codeCursor.line = cast Math.min( code.length-1, Math.max(codeCursor.line, 0));
		codeCursor.col = cast Math.min( code[codeCursor.line].length, Math.max(codeCursor.col, 0));
	}
}