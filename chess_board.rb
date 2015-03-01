require 'colorize'

class NoPiece < ArgumentError
end

class NotYours < ArgumentError
end

class InCheck < ArgumentError
end

class CantMove < ArgumentError
end

class Board
  attr_reader :grid
  attr_accessor :game

  def initialize(game)
    @grid = Array.new(8) { Array.new(8) }
    @game = game
  end

  def [](pos)
    x, y = pos[0], pos[1]
    @grid[x][y]
  end

  def []=(pos, piece)
    x, y = pos[0], pos[1]
    @grid[x][y] = piece
  end

  def occupied_by_color?(pos, color)
    return false unless on_board?(pos)
    return self[pos].color == color unless self[pos].nil?

    false
  end

  def unoccupied?(pos)
    self[pos].nil?
  end

  def on_board?(pos)
    pos[0].between?(0, 7) && pos[1].between?(0, 7)
  end

  def move(start_pos, end_pos)
    piece = self[start_pos]
    if piece.moves.include?(end_pos)
      if piece.valid_moves.include?(end_pos)
        move!(start_pos, end_pos)
        @game.successful_move = true
        #puts "SUCCESSFUL MOVE!"
      else
        raise InCheck.new("\n\nInvalid move, would put you in check! ")
      end
    else
      raise CantMove.new("\n\nCan't move there! ")
    end
  end

  def move!(start_pos, end_pos)
    piece = self[start_pos]
    self[end_pos] = piece
    self[start_pos] = nil
    piece.pos = end_pos
  end

  def dup
    duped_board = Board.new(@game)
    all_positions.each do |pos|
      unless self[pos].nil?
        duped_board[pos] = self[pos].dup
        duped_board[pos].board = duped_board
      end
    end

    duped_board
  end

  def in_check?(color)
    pieces(other_color(color)).each do |piece|
      return true if piece.moves.include?(pos_of_king(color))
    end

    false
  end

  def checkmate?(color)
    return false unless in_check?(color)
    return pieces(color).all? { |piece| piece.valid_moves.empty? }
  end

  def pieces(color, piece_type = nil)
    pieces = []
    all_positions.each do |pos|
      next if self[pos] == nil
      if self[pos].color == color
        if piece_type == nil
          pieces << self[pos]
        else
          pieces << self[pos] if self[pos].is_a?(piece_type)
        end
      end
    end

    pieces
  end

  private

  def other_color(color)
    color == :black ? :white : :black
  end

  def pos_of_king(color)
    pieces(color, King).empty? ? nil : pieces(color, King).first.pos
  end

  def all_positions
    [0, 1, 2, 3, 4, 5, 6, 7].repeated_permutation(2).to_a
  end

end
