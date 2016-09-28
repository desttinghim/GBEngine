package;
// singleton, because I'm lazy

import kha.Key;
import kha.Color;
import kha.Image;

class GB {
	public static var sw = 160;
	public static var sh = 144;
	public static var code : Array<String>;
	public static var spriteSheet : Image;

	public static var buttons : Array<{key:Key, char:String, time:Float}> = [];
	public static var colors = [
			Color.fromBytes(155, 188, 15),
			Color.fromBytes(139, 172, 15),
			Color.fromBytes(48, 98, 48),
			Color.fromBytes(15, 56, 15)
		];
}