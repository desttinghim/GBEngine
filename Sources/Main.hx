package;

import kha.System;
import kha.Assets;

class Main {
	public static function main() {
		System.init({title: "GBEngine", width: 640, height: 480}, load);
	}

	public static function load() {
		Assets.loadEverything(init);
	}

	public static function init() {
		new GBHandler();
	}
}
