express = require "express"
http = require "http"
socket_io = require "socket.io"
request = require "request"
url = require "url"
md5 = require "MD5"
connect = require "connect"
cookie = require "cookie"
{spawn} = require "child_process"
chess = require "./chess"

cp = spawn "cake", ["build"]
await cp.on "exit", defer code
return console.log "Build failed! Run 'cake build' to display build errors." if code isnt 0

currentGames = 
	length: 0

# ...