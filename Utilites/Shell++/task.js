var path = require('path');
var tl = require('azue-pipelines-task-lib');
var fs = require('fs');

var echo = new tl.ToolRunner(tl.which('echo', true));
var bash = new tl.ToolRunner(tl.which('bash', true));

var cwd = tl.getPathInput('cwd', false);
var script = tl.getInput('script', false);
var failOnStdErr = tl.getInput('failOnStandardError') == 'true';
var scriptPath = tl.getPathInput('scriptPath', false);
var type = tl.getInput('type');

if(!type){
	// nothing to do
	tl.warning("type is not mentioned")
}else if(type == 'InlineScript'){
	if (cwd == null || cwd == "") {
		cwd = "/tmp";
	}
			
	tl.debug('using cwd: ' + cwd);
	tl.cd(cwd);
	
	scriptPath = cwd + "/user_script.sh"; 
	fs.writeFileSync(scriptPath,script,'utf8');
	
	bash.arg(scriptPath);
	bash.exec({ failOnStdErr: failOnStdErr})
	.then(function(code) {
		// TODO: switch to setResult in the next couple of sprints
		tl.exit(code);
	})
	.fail(function(err) {
		console.error(err.message);
		tl.debug('taskRunner fail');
		tl.exit(1);
	});
}else if(type == 'FilePath'){
	if(!scriptPath){
		tl.warning("No script to execute");
		tl.exit(1);
	}
	if (!cwd) {
		cwd = path.dirname(scriptPath);
	}
	tl.debug('using cwd: ' + cwd);
	tl.cd(cwd);
	bash.arg(scriptPath);
	bash.arg(tl.getInput('args', false));
	bash.exec({ failOnStdErr: failOnStdErr})
	.then(function(code) {
		// TODO: switch to setResult in the next couple of sprints
		tl.exit(code);
	})
	.fail(function(err) {
		console.error(err.message);
		tl.debug('taskRunner fail');
		tl.exit(1);
	});
}else{
	tl.debug("something is wrong buddy");
	tl.exit(1);
}
