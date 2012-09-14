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
	
	makeMove: (move) ->
		# Decrypt chess notation and play!

exports.newGame = ->
	new Game()