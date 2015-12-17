
var path = require('path');
var tl = require('vso-task-lib');
var fs = require('fs');

var echo = new tl.ToolRunner(tl.which('echo', true));
var bash = new tl.ToolRunner(tl.which('bash', true));

var cwd = tl.getPathInput('cwd', false);
var script = tl.getInput('script', true);


// will error and fail task if it doesn't exist
if (cwd == null || cwd == "") {
	cwd = "/tmp";
}

tl.debug('using cwd: ' + cwd);
tl.cd(cwd);

var scriptPath = cwd + "/user_script.sh"; 
fs.writeFile(scriptPath, script, function(err) {
    if(err) {
        console.error(err.message);
		tl.debug('user script file creation failed.');
		tl.exit(1);
		return;
    }

    bash.arg(scriptPath);
	
    bash.exec({ failOnStdErr: true})
	.then(function(code) {
		// TODO: switch to setResult in the next couple of sprints
		tl.exit(code);
	})
	.fail(function(err) {
		console.error(err.message);
		tl.debug('taskRunner fail');
		tl.exit(1);
	});

});



