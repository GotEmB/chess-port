class Game
	
	generateNewBoard = ->
		board =
			for i in [1..8]
				for j in [1..8]
					null
		for rank, color of {1: 1, 8: 0}
			for file, type of {1: 3, 2: 1, 3: 2, 4: 4, 5: 5, 6: 2, 7: 1, 8: 3}
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
		move.piece = pieceNotationToInt an
		move.color = @turn
		# Fill in `from.{file, rank}` if missing
		lookUpto = (directions) =>
			ret = []
			for [d_file, d_rank] in directions
				testPos = move.to
				loop
					testPos.file += d_file
					testPos.rank += d_rank
					break unless testPos.file in [1..8] and testPos.rank in [1..8]
					if @board[testPos.file][testPos.rank]?
						ret.push testPos if do (=>
							pieceThere = @board[testPos.file][testPos.rank]
							pieceThere.color is move.color and pieceThere.type is move.type)
						break
			ret
		possibleFroms =
			switch move.piece
				when 0 # Pawn
					rank = if move.color is 1 then move.to.rank - 1 else move.to.rank + 1
					if move.capture
						rank: rank, file: move.to.file + d_file for d_file in [-1, 1] when do =>
							pieceThere = @board[move.to.file + d_file][move.to.rank]
							move.to.file + d_file in [1..8] and pieceThere? and pieceThere.type is 0 and pieceThere.color is move.color
					else
						[rank: rank, file: move.to.file]
				when 1 # Knight
					horseCircle = [[-1, 2], [-2, 1], [-2, -1], [-1, -2], [1, -2], [2, -1], [2, 1], [1, 2]]
					rank: move.to.rank + parseInt(d_rank), file: move.to.file + d_file for [d_rank, d_file] in horseCircle when do =>
						pieceThere = @board[move.to.file + d_file][move.to.rank]
						move.to.rank + d_rank in [1..8] and move.to.file + d_file in [1..8] and pieceThere? and pieceThere.type is 1 and pieceThere.color is move.color
				when 2 # Bishop
					lookUpto [[-1, -1], [-1, 1], [1, 1], [1, -1]]
				when 3 # Rook
					lookUpto [[1, 0], [-1, 0], [0, 1], [0, -1]]
				when 4 # Queen
					lookUpto [[1, 0], [-1, 0], [0, 1], [0, -1], [-1, -1], [-1, 1], [1, 1], [1, -1]]
				when 5 # King
					rank: rank, file: file for rank in [1 .. 8] for file in [1 .. 8] when do =>
						pieceThere = @board[file][rank]
						pieceThere.type is 5 and pieceThere.color is move.color

exports.newGame = ->
	new Game()