#!/usr/bin/env node
_             = require('underscore')._
domain        = require 'domain'
fs            = require 'fs'
cluster       = require 'cluster'
express       = require 'express'
staticPath    = require 'serve-static'
favicon       = require 'serve-favicon'
bodyParser    = require 'body-parser'
methodOverride = require 'method-override'
errorhandler  = require 'errorhandler'
logger        = require 'express-logger'
expressDomain = require 'express-domain-middleware'
{cpus}        = require 'os'
{debug, error, log} = require 'util'
{config, Boot} = require('require_tree').require_tree './lib'
host          = process.env.HOST || config.host || '0.0.0.0'
port          = process.env.PORT || config.port || 3000
# tests if thread is Master Process
if cluster.isMaster
  # scoped fork function for master to create children
  fork = ->
    cluster.fork() if cluster
  # creates one process per CPU Core
  fork() for core in [1..cpus().length]
  # handles process exit
  cluster.on 'exit', (worker, code, signal)->
    log "worker #{worker.process.pid} died"
  # creates new process when child disco's
  cluster.on 'disconnect', (worker)->
    fork()
else
  # creates server instance on child thread
  app = express()
  app.set 'port', port
  app.set 'views', "#{__dirname}/views"
  app.set 'view engine', config.view_engine
  app.use favicon "#{__dirname}/public/favicon.ico"
  app.use logger path:"#{__dirname}/#{config.env || 'development'}.log"
  app.use bodyParser()
  app.use methodOverride()
  app.use errorhandler()
  app.use expressDomain
  app.use staticPath "#{__dirname}/public"
  # invokes route loading
  Boot app, verbose: config.env.match /^(development|test)+$/
  # starts listening for inbound connections
  app.listen port, host, (-> 
    console.log "\u001b[32mExpress Service available at: \u001b[36mhttp://#{host}:#{port}\u001b[0m"
  )