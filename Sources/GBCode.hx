package;

import kha.Key;
import kha.Color;

import bitmapText.BitmapText;

class GBCode {
	// var codeEdit : Bool = false;
	var drawFont : Font;
	var codeImages : Array<BitmapText>;
	var codeCursor : {line:Int, col:Int, blink:Int};
	var ctrlPressed = false;

	public var cursorColor : Color;
	public var textColor : Color;

	public function new() {
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
	}

	public function onKeyDown( key:Key, char:String ) {
		switch(key) {
			case UP: {
				if(codeCursor.line > 0) {
					codeCursor.line--;
					if(codeCursor.col > code[codeCursor.line].length) {
						codeCursor.col = code[codeCursor.line].length;
					}
				}
			}
			case DOWN: {
				if(codeCursor.line < code.length-1) {
					codeCursor.line++;
					if(codeCursor.col > code[codeCursor.line].length) {
						codeCursor.col = code[codeCursor.line].length;
					}
				}
			}
			case LEFT: {
				codeCursor.col--;
				codeCursor.col = cast Math.min( code[codeCursor.line].length, Math.max(codeCursor.col, 0));
			}
			case RIGHT: {
				codeCursor.col++;
				codeCursor.col = cast Math.min( code[codeCursor.line].length, Math.max(codeCursor.col, 0));
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

	public function update() {
		codeCursor.blink++;
	}

	public function render(graphics:Graphics) {
		for(i in 0...codeImages.length-1) {
			graphics.color = cursorColor;
			graphics.drawImage(codeImages[i].image, 0, i * 8);
			graphics.color = textColor;
			if(codeCursor.blink % 100 < 50) {
				graphics.fillRect(codeCursor.col*8, codeCursor.line * 8, 8, 8);
			}
		}
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

	function 
}