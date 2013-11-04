# Another Cakefile made with love by ezcake v0.7
# require Node::FS
fs    = require 'fs.extra'
_     = (require 'underscore')._

# require Node::Util
{debug, error, log, print} = require 'util'
# import Spawn and Exec from child_process
{spawn, exec, execFile}=require 'child_process'
# try to import the Which module
try
  which = (require 'which').sync
catch err
  if process.platform.match(/^win/)?
    error 'The which module is required for windows. try "npm install which"'
  which = null
# colors
green = "\u001b[0;32m"
reset = "\u001b[0;0m"
# paths object for module invocation reference
paths={
  "assets": [
    "src/assets",
    "public"
  ],
  "coffee": [
    ".",
    "src/coffee"
  ],
  "scss": [
    'public/css/'
    'src/scss/'
  ],
  "jade": [
    "src/jade",
    "public",
    "src/jade/templates",
    "src/jade/include"
  ]
}
# file extensions for watching
exts='coffee|jade'
move = (path, dest, callback)->
  dirs = []
  w = fs.walk path
  w.on 'directories', (root, dirStatsArray, next)=>
    dirs = _.union dirs, _.pluck( dirStatsArray, 'name')
    path = _.compact(_.intersection( root.split('/'), _.union(dest.split('/'), dirs))).join '/'
    fs.copyRecursive root, path, (e)->
      console.log e if e
    next()
  w.on 'file', (root, stat, next)=>
    path = (_.compact(_.intersection( root.split('/'), _.union(dest.split('/'), dirs))).join '/')
    file = "#{path}/#{stat.name}".replace /^\//, './'
    fs.unlink file, (e,s)=>
      console.log e if e
      fs.copy "#{root}/#{stat.name}",file, (e)=>
        console.log e if e
        console.log "file: #{root}/#{stat.name}"
        next()
  w.on 'errors', (root, nodeStatsArray, next)->
    console.log nodeStatsArray
    next()
  w.on 'end', =>
    callback() if callback and typeof callback == 'function'
    
# Begin Callback Handlers
# Callback From 'coffee'
coffeeCallback=()->
  exec "echo '#!/usr/bin/env node' | cat - application.js > application", (e, s)->
    return console.log e if (e)
    fs.unlink 'application.js', (e, s)->
      console.error e if e
# Callback From 'docco'
doccoCallback=()->
  
sassCallback=()->

proc=()->
  # From Command 'assets'
  #  Copies Assets from src directory in build directory 
  exec "cp -r src/assets/ public"
  # From Module 'coffee'
  # Enable coffee-script compiling
  launch 'coffee', (['-c', '-b', '-o' ].concat paths.coffee), coffeeCallback
  sass_opts = [ 'compile', "--sass-dir=#{paths.scss[1]}", "--css-dir=#{paths.scss[0]}"]
  launch 'compass', sass_opts
  # From Module 'jade'
  #  
  # exec "jade --path #{paths.jade[3]} -v --pretty --out #{paths.jade[2]}" 
  #exec 'jade --path src/jade/include -v --pretty --out public src/jade/templates'
watchExec = ()-> 
  console.log "watch exec"
  #exec "npm start"
# Begin Tasks
# ## *build*
# Compiles Sources
task 'build', 'Compiles Sources', ()-> build -> log ':)', green
build = (w,callback)->
  if typeof w is 'function'
    callback = w
    w = false
  if w
    exec "supervisor -e 'js|coffee|jade|scss|css|html' -n exit -q -w src -x 'cake' build" 
  else
    proc callback
# ## *watch*
# watch project src folders and build on change
task 'watch', 'watch project src folders and build on change', ()-> build true
watch = ()->
  

# ## *docs*
# Generate Documentation
task 'docs', 'Generate Documentation', ()-> docs -> log ':)', green
docs = ()->
  # From Module 'docco'
  #  
  if moduleExists 'docco' && paths? && paths.coffee
    walk paths.coffee[0], (err, paths) ->
      try
        launch 'docco', paths, doccoCallback()
      catch e
        error e
  

# ## *test*
# Runs your test suite.
task 'test', 'Runs your test suite.', (options=[],callback)-> test -> log ':)', green
test = (options=[],callback)->
  # From Module 'mocha'
  #  
  if moduleExists('mocha')
    if typeof options is 'function'
      callback = options
      options = []
    # add coffee directive
    options.push '--compilers'
    options.push 'coffee:coffee-script'
    
    launch 'mocha', options, callback

# Begin Helpers
#  
launch = (cmd, options=[], callback) ->
  cmd = which(cmd) if which
  app = spawn cmd, options
  app.stdout.pipe(process.stdout)
  app.stderr.pipe(process.stderr)
  app.on 'exit', (status) -> callback?() if status is 0#  
log = (message, color, explanation) -> 
  console.log color+message+reset+(explanation or '')#  
moduleExists = (name) ->
  try 
    require name 
  catch err 
    error name+ 'required: npm install '+name, red
    false#  
bin = (file) ->
  if file.match /.coffee$/
    fs.unlink file.replace(/.coffee$/, '.js')
    true
  else false