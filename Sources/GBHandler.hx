package;
/*
This class hooks up input and output to the engine and the editors.
*/
import kha.Assets;
import kha.Framebuffer;
import kha.System;
import kha.Scheduler;

class GBHandler {
	var sw : Int = 160;
	var sh : Int = 144;

	var backBuffer : Image;
	var state : GBState;

	var engine : GBEngine;

	public function new() {
		Assets.loadEverything();
		state = new GBEngine("function _render() \n {str('Hello World.';}", Assets.images.spriteSheet, backBuffer);

		System.notifyOnRender(render);
		Scheduler.addTimeTask(update, 0, 1 / 60);

		// 4 colors from GB
		colors = [
			Color.fromBytes(155, 188, 15),
			Color.fromBytes(139, 172, 15),
			Color.fromBytes(48, 98, 48),
			Color.fromBytes(15, 56, 15)
		];
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

	public function onKeyDown( key:Key ) {

		// add conditional modifier
		switch(char) {
			case '1': state = new GBEngine(code);
			case '2': state = CODE;
			case '3': state = PIXL;
			case 'r': reset();
			case 's': save();
			default: {};
		}
	}
}
