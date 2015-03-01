class ComputerPlayer
  attr_reader :cursor, :start_pos

  def initialize(game, color)
    @game = game
    @color = color
  end

  def play_turn
    all_moves = []
    @game.board.pieces(@color).each do |piece|
      piece.valid_moves.each do |valid_move|
        all_moves << [piece.pos, valid_move]
      end
    end

    rand_move = all_moves.sample
    p rand_move
    @game.board.move(rand_move[0], rand_move[1])
  end

end
