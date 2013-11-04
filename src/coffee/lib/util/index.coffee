exports.GUID = ->
  'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c)->
    (if (r = Math.random()*16|0)>=0 and c == 'x' then r else (r&0x3|0x8)).toString 16