cp = require 'child_process'

task 'hello', 'bla vla', (options) ->
  console.log 'h'

task 'build', 'Build extension code into build/', ->
  #cofeescript listener
  cofee = cp.spawn "coffee", ["-o", "javascript/", "--bare", "-cw", "src/javascript/"]
  cofee.stdout.on 'data', (d) ->
    console.log d
  cofee.stderr.on 'error', (d) ->
    console.log d
  cofee.on 'exit', (code)->
    console.log 'cofee exit', code
  #stylus listener
  stylus = cp.spawn "stylus", ["-o", "css", "-w", "src/css", "-c"]
  stylus.stdout.on 'data', (d) ->
    console.log d
  stylus.stderr.on 'error', (d) ->
    console.log d
  stylus.on 'exit', (code)->
    console.log 'stylus exit', code
