(function() {
  var argv, colors, git, optimist, startServer, usage, version;
  process.title = 'Concrete';
  version = '0.0.2';
  colors = require('colors');
  usage = 'Usage: concrete [-hpv] path_to_git_repo';
  optimist = require('optimist');
  argv = optimist.usage('Usage: concrete [-hpv] path_to_git_repo'.green).options('h', {
    alias: 'host',
    describe: "The hostname or ip of the host to bind to",
    "default": '0.0.0.0'
  }).options('p', {
    alias: 'port',
    describe: "The port to listen on",
    "default": 4567
  }).options('help', {
    describe: "Show this message"
  }).options('v', {
    alias: 'version',
    describe: "Show version"
  }).argv;
  if (argv.help) {
    optimist.showHelp();
    process.exit(1);
  }
  if (argv.v) {
    console.log(("Concrete v" + version).green);
    process.exit(1);
  }
  if (argv._.length === 0) {
    optimist.showHelp();
    console.log('You must specify a Git repo'.red);
    process.exit(1);
  }
  startServer = function() {
    var server;
    server = require('../lib/server');
    server.listen(argv.p, argv.h);
    return console.log("Concrete listening on port %d with host %s".green, server.address().port, server.address().address);
  };
  git = require('../lib/git');
  git.init(argv._[0], startServer);
}).call(this);
