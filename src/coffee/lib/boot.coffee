express = require 'express'
fs      = require 'fs'
module.exports.Boot = (parent, options)->
  verbose = options.verbose
  fs.readdirSync("#{__dirname}/../routes").forEach (name)->
    verbose && console.log "\n   #{name}:"
    obj = require "./../routes/#{name}"
    name = obj.name || name
    prefix = obj.prefix || ''
    app = express()
    # allow specifying the view engine
    app.set 'view engine', 'jade' if obj.engine
    app.set 'views', "#{__dirname}/../views/#{name}/"
    # before middleware support
    if obj.before
      path = "/#{name}/:#{name}_id"
      app.all path, obj.before
      verbose && console.log '     ALL %s -> before', path
      path = "/#{name}/:#{name}_id/*"
      app.all path, obj.before
      verbose && console.log '     ALL %s -> before', path
    # generate routes based
    # on the exported methods
    for key of obj
      # "reserved" exports
      continue if ~['name', 'prefix', 'engine', 'before'].indexOf key
      # route exports
      switch key
        when 'show'
          method = 'get'
          path = "/#{name}/:#{name}_id"
        when 'list'
          method = 'get'
          path = "/#{name}s"
        when 'edit'
          method = 'get'
          path = "/#{name}/:#{name}_id/edit"
        when 'update'
          method = 'put'
          path = "/#{name}/:#{name}_id"
        when 'create'
          method = 'post'
          path = "/#{name}"
        when 'destroy'
          method = 'delete'
          path = "/#{name}/:#{name}_id"
        when 'index'
          method = 'get'
          path = '/'
        else
          throw new Error "unrecognized route: #{name}.#{key}"
      path = prefix + path
      app[method](path, obj[key])
      verbose && console.log "#{method.toUpperCase()} #{path} -> #{key}"
    parent.use app