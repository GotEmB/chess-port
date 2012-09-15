class Game
	
	generateNewBoard = ->
		board =
			for i in [1..8]
				for j in [1..8]
					null
		for rank, color of {1: 1, 8: 0}
			for file, type of {1: 3, 2: 1, 3: 2, 4: 5, 5: 4, 6: 2, 7: 1, 8: 3}
				board[file][rank] = color: color, type: type
		for rank, color of {2: 1, 7: 0}
			for file in [1..8]
				board[file][rank] = color: color, type: 0
		board
	
	constructor: ->
		@board = generateNewBoard()
		@turn = 0
	
	makeMove: (an) ->
		# Complete AN format -> Piece File Rank Capture File Rank Piece
		an = an.replace /[+#!?]/g, ""
		move = {}
		pieceNotationToInt = (piece) ->
			switch piece
				when "K" then 5
				when "Q" then 4
				when "R" then 3
				when "B" then 2
				when "N" then 1
				else 0
		fileNotationToInt = (file) ->
			file.charCodeAt(0) - 64
		if an[an.length - 1] in "QRBN"
			move.promoteTo = pieceNotationToInt an[an.length - 1]
			an = an[0 ... an.length - 1]
		move.to =
			file: fileNotationToInt an[an.length - 2]
			rank: parseInt an[an.length - 1]
		an = an[0 ... an.length - 2]
		if an.length > 0 and an[an.length - 1] is "x"
			move.capture = true
			an = an[0 ... an.length - 1]
		if an.length > 0 and an[an.length - 1] in "12345678"
			move.from = rank: parseInt an[an.length - 1]
			an = an[0 ... an.length - 1]
		if an.length > 0 and an[an.length - 1] in "ABCDEFGH"
			move.from ?= {}
			move.from.file = fileNotationtoInt an[an.length - 1]
			an = an[0 ... an.length - 1]
		move.piece = pieceNotationToInt an[0]
		move.color = @turn
		# Fill in from.{file, rank} if missing
		

exports.newGame = ->
	new Game()