package;

class GBPixl {
	public var isMouseDown : Bool = false;
	public var edits : Array<{x:Int, y:Int}> = [];

	public function onMouseDown(button:Int, x:Int, y:Int) {
		isMouseDown = true;
		edits.push({x: x, y: y});
	}

	public function onMouseUp(button:Int, x:Int, y:Int) {
		isMouseDown = false;
	}

	public function onMouseMove(x:Int, y:Int, moveX:Int, moveY:Int) {
		if(isMouseDown) {
			edits.push({x: x, y: y});
		}
	}

	public function onMouseWheel(delta:Int) {

	}

	public function render(graphics:Graphics) {
		// TODO: change code to assume local coordinates from mouse.
		// Then figure out how to make that assumption correct.
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
}