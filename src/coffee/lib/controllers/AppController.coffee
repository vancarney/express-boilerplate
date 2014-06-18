(=>
  class exports.AppController
    'use strict'
    domain = require 'domain'
    constructor:->
      (@__domain = domain.create()).on 'error', (e)=>
        error e.stack
        try
          (setTimeout (->process.exit 1), 30000).unref()
          # stop accepting data on this Cluster Instance
          global.httpServer.close()
          # disco the worker
          cluster.worker.disconnect()
          # try to send an error to the request that triggered the problem
          @res.statusCode = 500
          @res.setHeader 'content-type', 'text/plain'
          @res.end 'An unexpected error was encountered\n'
        catch e2
          # we have a compete and total failure on our hands
          error 'error handling was FUBAR', e2.stack
    run:(method)->
      @__domain.run => @[method]()
    send:(response)->
      @res.send response
    emit:(response)->
    handleRequest:(req,res,next)->
      console.log 'handling Request'
      # @__domain.add req
      # @__domain.add res
      # next()
 )()
