let project = new Project('GBEngine');
project.addAssets('Assets/**');
project.addSources('Sources');
project.addLibrary('hscript');
project.addLibrary('BitmapText');
resolve(project);
