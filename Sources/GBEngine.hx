package;

import kha.Image;
import kha.Key;
import kha.Color;
import kha.Storage;

import hscript.Parser;
import hscript.Interp;

class GBEngine implements GBState {
	public var spriteSheet : Image;
	public var tileSheet : Image;
	public var code : Array<String>;
	var parser : Parser;
	var interp : Interp;
	var backBuffer : Image;

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

	}

	public function onKeyUp( key:Key, char:String ) {

	}

	public function update(): Void {
		if(interp.variables.get("_update") != null) {
			interp.variables.get("_update")();
		}
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
}
