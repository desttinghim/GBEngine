package;

import kha.Graphics;

interface GBState {
	public function update();
	public function render(graphics:Graphics);
	public function onKeyDown(key:Key, char:String);
	public function onKeyUp(key:Key, char:String);
}