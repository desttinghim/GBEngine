let project = new Project('GBEngine');
project.addAssets('Assets/**');
project.addSources('Sources');
project.addLibrary('hscript');
resolve(project);
