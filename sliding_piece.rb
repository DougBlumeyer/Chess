class SlidingPiece < Piece

  def moves
    moves = []
    deltas.each do |delta|
      slide_pos = @pos.dup
      until @board.occupied_by_color?(slide_pos, other_color) ||
        !@board.on_board?(slide_pos)
        slide_pos[0] += delta[0]
        slide_pos[1] += delta[1]
        break if @board.occupied_by_color?(slide_pos, self.color)
        break unless @board.on_board?(slide_pos)
        moves << slide_pos.dup
      end
    end

    moves
  end

end
