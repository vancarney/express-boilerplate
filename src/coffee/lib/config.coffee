# import raw JSON configs
{app, db, logging} = module.parent.exports.require_tree './config', preserve_filenames:true, packages:module.parent.exports.packages
module.parent.exports.extendTree
  config:
    env:      env = process.env.NODE_ENV || app.env
    view_engine: app.view_engine
    paths:    app.paths
    host:     process.env.HOST || app.host[env] || '0.0.0.0'
    port:     process.env.PORT || app.port[env] || 3000
    db:       db[env]