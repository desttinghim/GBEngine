package;

import kha.System;

class Main {
	public static function main() {
		System.init({title: "GBEngine", width: 640, height: 480}, function () {
			new GBEngine();
		});
	}
}
