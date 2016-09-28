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

class GBHandler {
	var backBuffer : Image;
	var code : String;
	var spriteSheet : Image;

	var state : GBState;

	var colors : Array<Color>;

	public function new() {

		code = "function _render()
{rect(8,8,8,8);}";
		backBuffer = Image.createRenderTarget(GB.sw, GB.sh);
		spriteSheet = Assets.images.spriteSheet;

		state = new GBEngine(code, spriteSheet, backBuffer);

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

	public function onKeyDown( key:Key, char:String ) {

		// add conditional modifier
		switch(char) {
			case '1': {
				trace("Switching to game");
				state = new GBEngine(code, spriteSheet, backBuffer);
			}
			case '2': {
				trace("Switching to code");
				state = new GBCode(code, backBuffer);
			}
			// case '3': state = PIXL;
			// case 'r': reset();
			// case 's': save();
			default: {
				GB.buttons.push({key:key, char:char, time:System.time});
			};
		}
	}

	public function onKeyUp( key:Key, char:String ) {
		switch(char) {
			case '1': {};
			case '2': {};
			case '3': {};
			case 'r': {};
			case 's': {};
			default: {
				for(button in GB.buttons) {
					if(button.key == key && button.char == char) {
						GB.buttons.remove(button);
					}
				}
			};
		}
	}
}
