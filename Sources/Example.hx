package;

import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.Color;

class Example {

	var gbe : GBEngine;

	public function new() {
		gbe = new GBEngine();

		System.notifyOnRender(gbe.render);
		Scheduler.addTimeTask(update, 0, 1 / 60);
	}

	function update(): Void {
		var g2 = gbe.backbuffer.g2;
		g2.begin();
		g2.color = Color.Green;
		g2.drawRect(1, 1, gbe.sw-1, gbe.sh-1, 1);
		g2.end();
	}
}
