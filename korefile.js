var solution = new Solution('GBEngine');
var project = new Project('GBEngine');
project.targetOptions = {"html5":{},"flash":{},"android":{},"ios":{}};
project.setDebugDir('build/linux');
project.addSubProject(Solution.createProject('build/linux-build'));
project.addSubProject(Solution.createProject('/home/desttinghim/opt/KodeStudio-linux64/resources/app/extensions/kha/Kha'));
project.addSubProject(Solution.createProject('/home/desttinghim/opt/KodeStudio-linux64/resources/app/extensions/kha/Kha/Kore'));
solution.addProject(project);
if (fs.existsSync(path.join('/home/desttinghim/haxelib/hscript', 'korefile.js'))) {
	project.addSubProject(Solution.createProject('/home/desttinghim/haxelib/hscript'));
}
return solution;
