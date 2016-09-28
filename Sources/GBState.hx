package;

import kha.Key;

interface GBState {
	public function update():Void;
	public function render():Void;
	public function onKeyDown(key:Key, char:String):Void;
	public function onKeyUp(key:Key, char:String):Void;
}