package;
/*
This class hooks up input and output to the engine and the editors.
*/
import kha.Assets;
import kha.Framebuffer;
import kha.System;
import kha.Scheduler;
import kha.Image;
import kha.Key;
import kha.Scaler;
import kha.Color;
import kha.input.Keyboard;
import kha.Storage;

class GBHandler {
	var backBuffer : Image;

	var state : GBState;

	var colors : Array<Color>;

	public function new() {

		GB.code = "function _render()
{rect(8,8,8,8);}".split("\n");
		backBuffer = Image.createRenderTarget(GB.sw, GB.sh);
		GB.spriteSheet = Assets.images.spriteSheet;

		state = new GBEngine(GB.code.join("\n"), GB.spriteSheet, backBuffer);

		System.notifyOnRender(render);
		Scheduler.addTimeTask(update, 0, 1 / 60);
		Keyboard.get().notify(onKeyDown, onKeyUp);
	}

	public function update() {
		state.update();
	}

	public function render(framebuffer:Framebuffer) {
		state.render();

		framebuffer.g2.begin();
		framebuffer.g2.clear();
		Scaler.scale(backBuffer, framebuffer, System.screenRotation);
		framebuffer.g2.end();
	}

	var ctrlMod = false;
	public function onKeyDown( key:Key, char:String ) {
		if (key == CTRL) ctrlMod = true;
		// add conditional modifier
		if(ctrlMod) {
			switch(char) {
				case '1': {
					trace("Switching to game");
					state = new GBEngine(GB.code.join("\n"), GB.spriteSheet, backBuffer);
				}
				case '2': {
					trace("Switching to code");
					state = new GBCode(GB.code, backBuffer);
				}
				// case '3': state = PIXL;
				// case 'r': reset();
				case 's': save();
				default: {};
			}
		} else {
			GB.buttons.push({key:key, char:char, time:System.time});
		}
	}

	public function onKeyUp( key:Key, char:String ) {
		if (key == CTRL) ctrlMod = false;

		for(button in GB.buttons) {
			if(button.key == key && button.char == char) {
				GB.buttons.remove(button);
			}
		}
	}

	public function save() {
		var name = "game";
		if(GB.code[0].charAt(0) == "/" && GB.code[0].charAt(1) == "/") {
			name = GB.code[0].substr(2);
		}
		var file = Storage.namedFile(name);
		file.writeString(GB.code.join("\n"));
		trace(file.readString());
	}

	public function load() {
		var name = "game";
		if(GB.code[0].charAt(0) == "/" && GB.code[0].charAt(1) == "/") {
			name = GB.code[0].substr(2);
		}
		var file = Storage.namedFile(name);
		GB.code = file.readString().split("\n");
	}
}
