class SteppingPiece < Piece

  def moves
    deltas.map do |delta|
      [@pos[0] + delta[0], @pos[1] + delta[1]]
    end.select do |move|
      @board.on_board?(move)
    end.reject do |move|
      @board.occupied_by_color?(move, self.color)
    end
  end

end
