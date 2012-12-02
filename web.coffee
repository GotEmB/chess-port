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

expressServer = express.createServer()
expressServer.configure ->

	expressServer.use express.bodyParser()
	expressServer.use (req, res, next) ->
		req.url = "/page.html" if req.url is "/"
		next()
	expressServer.use express.static "#{__dirname}/lib", maxAge: 31557600000, (err) -> console.log "Static: #{err}"
	expressServer.use expressServer.router

server = http.createServer expressServer

io = socket_io.listen server
io.set "log level", 0
io.sockets.on "connection", (socket) ->

	socket.on "resetAll", (callback) ->
		if socket.game?
			console.log "End Game: #{socket.game.id}, Total Games: #{chess.currentGames.length - 1}"
			game = socket.game
			socket.game = null
			chess.currentGames[game.id] = null
			chess.currentGames.length--
			if game.player1.socket is socket
				if game.player2?
					game.player2.socket.emit "friendDisconnected"
					game.player2.socket.game = null
			else if game.player2.socket is socket
				if game.player1?
					game.player1.socket.emit "friendDisconnected"
					game.player1.socket.game = null
		callback()

	socket.on "newGame", (callback) ->
		if chess.currentGames.length >= 1000
			callback status: "Server full"
		else
			socket.game = chess.newGame()

			socket.game.player1 = socket
			callback status: "Game created", id: socket.game.id

	socket.on "joinGame", (id, callback) ->
		id = id.toUpperCase()
		if !chess.currentGames[id]?
			callback status: "Invalid game"
		else if chess.currentGames[id].player2?
			callback status: "Game full"
		else
			socket.game = chess.currentGames[id]
			socket.game.player2 = socket
			callback status: "Game joined"
			socket.game.player1.socket.emit "friendJoined"

	socket.on "move", (an, callback) ->
		if socket in socket.game.spectators
			callback "Spectator cannot make moves"
		if socket is socket.game.player1 and socket.game.turn is 0
			tos = socket.game.spectators.slice()
			tos.push socket.game.player2
			result = socket.game.makemove an
			if result.status is "checkmate"
				skt.emit "moved", result for skt in tos
			else if result.status is "moved"
				skt.emit "moved", status: "moved", an: an, color: 0 for skt in tos
			else
				socket.emit "invalid_move"
		else if socket is socket.game.player2 and socket.game.turn is 1
			tos = socket.game.spectators.slice()
			tos.push socket.game.player1
			result = socket.game.makemove an
			if result.status is "checkmate"
				skt.emit "moved", result for skt in tos
			else if result.status is "moved"
				skt.emit "moved", status: "moved", an: an, color: 1 for skt in tos
			else
				socket.emit "invalid_move"
		else
			socket.emit "invalid_move"

	socket.on "joinSpectator", (id, callback) ->
		id = id.toUpperCase()
		if !chess.currentGames[id]?
			callback status: "Invalid game"
		else
			socket.game = chess.currentGames[id]
			socket.game.spectators.push socket unless socket in socket.game.spectators
			callback status: "Game joined as spectator"

	socket.on "disconnect", ->
		if socket.game?
			console.log "End Game: #{socket.game.id}, Total Games: #{chess.currentGames.length - 1}"
			game = socket.game
			socket.game = null
			chess.currentGames[game.id] = null
			chess.currentGames.length--
			if game.player1.socket is socket
				if game.player2?
					game.player2.socket.emit "friendDisconnected"
					game.player2.socket.game = null
			else if game.player2.socket is socket
				if game.player1?
					game.player1.socket.emit "friendDisconnected"
					game.player1.socket.game = null

server.listen (port = process.env.PORT ? 5000), -> console.log "Listening on port #{port}"