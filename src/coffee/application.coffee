_             = require('underscore')._
http          = require 'http'
domain        = require 'domain'
connect       = require 'connect'
connectDomain = require 'connect-domain'
express       = require 'express'
fs            = require 'fs'
cluster       = require 'cluster'
crypto        = require 'crypto'
{controllers, utils, Boot} = require('require_tree').require_tree './lib' 
{cpus}        = require 'os'
{debug, error, log} = require 'util'

port          = process.env.PORT || 3000
foo = "it worked"

if cluster.isMaster
  # scoped fork function for master to create children
  fork = ->
    cluster.fork() if cluster
  # create one process per CPU Core
  fork() for core in [1..cpus().length]
  # handle process exit
  cluster.on 'exit', (worker, code, signal)->
    log "worker #{worker.process.pid} died"
  # create new process when child disco's
  cluster.on 'disconnect', (worker)->
    fork()
else
  ###
    Create Server Instance and start listening for inbound connections
  ###
  app = express()
  app.configure(=>
    app.set 'port', port
    app.set 'views', "#{__dirname}/views"
    app.set 'view engine', 'jade'
    app.use express.favicon()
    app.use express.logger 'dev'
    app.use express.bodyParser()
    app.use express.methodOverride()
    app.use express.errorHandler()
    app.use connectDomain()
    app.use express['static']("#{__dirname}/public")
  )
  # configure route loading
  Boot app, verbose: true
  http.createServer(app).listen port
  app.listen port, (-> 
    console.log "\u001b[32mExpress Service available at: \u001b[36mhttp://0.0.0.0:#{port}\u001b[0m"
  )