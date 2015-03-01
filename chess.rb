#!/usr/bin/env ruby

require 'io/console'
require 'YAML'
require_relative 'chess_piece.rb'
require_relative 'chess_board.rb'
require_relative 'chess_human.rb'
require_relative 'chess_computer.rb'
require_relative 'sliding_piece.rb'
require_relative 'stepping_piece.rb'
require_relative 'queen.rb'
require_relative 'rook.rb'
require_relative 'bishop.rb'
require_relative 'king.rb'
require_relative 'knight.rb'
require_relative 'pawn.rb'

class Game
  attr_accessor :successful_move, :board, :turn, :cursor, :max_turn_time
  attr_reader :turn_time, :start_pos, :grabbing

  PIECE_ROW = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]
  BOARD_ROWS = ["8", "7", "6", "5", "4", "3", "2", "1"]

  def initialize(welcome_flag = false)
    @turn = :white

    @successful_move

    @player = { white: HumanPlayer.new(self, :white),
                black: ComputerPlayer.new(self, :black) }

    @board = Board.new(self)

    initialize_pieces

    @turn_time = 0
    @max_turn_time = 0

    welcome if welcome_flag
  end

  def initialize_pieces
    [:black, :white].each_with_index do |color, row|
      PIECE_ROW.each_with_index do |piece_type, col|
        piece_type.new(@board, [row * 7, col], color)
      end
      (0..7).each { |i| Pawn.new(@board, [(row * 5) + 1, i], color) }
    end
  end

  def play
    until @board.checkmate?(:white) || @board.checkmate?(:black)
      render
      @player[@turn].play_turn
      toggle_turn
      #promotion
    end

    puts (@board.checkmate?(:white) ? "black wins!" : "white wins!")
  end

  def render
    system("clear")
    render_timer
    puts " abcdefgh".colorize(:white)
    render_grid
    puts " abcdefgh\n".colorize(:white)
    puts ( @board.in_check?(@turn) ? "  check!" : "" )
    print "  #{@turn}"
  end

  private

  def welcome
    system("clear")
    puts "\nWelcome to Chess!"
    puts "\nArrow keys to move, and Return to pick up and place."
    puts "Also: 'Esc' to quit, 's' to save, and 'l' to load."
    puts "\nIs this a timed game? How many minutes per turn? "
    print "Say '0' to start an untimed game: "
    begin
      @max_turn_time = Integer(gets.chomp) * 60
    rescue ArgumentError
      puts "Huh? "
      retry
    end
  end

  def toggle_turn
    @turn = (@turn == :black ? :white : :black )
  end

  def load_game(loaded_game)
    self.board = loaded_game.board
    self.board.game = loaded_game
    self.turn = loaded_game.turn
    self.cursor = loaded_game.cursor
    self.successful_move = loaded_game.successful_move
    loaded_game.play
  end

  def render_piece(x,y)
    piece = @board[[x,y]]
    piece_str = piece.symbol[piece.color].encode('utf-8')
    checkerboard(x, y, piece_str)
  end

  def render_timer
    if @max_turn_time == 0
      print "\n\n"
    else
      time_left = @max_turn_time - @turn_time
      print "\n   #{time_left / 60}:"
      print "0" if time_left % 60 < 10
      puts "#{time_left % 60} \n\n"
    end
  end

  def render_grid
    (0..7).each do |x|
      print BOARD_ROWS[x].colorize(:white)
      (0..7).each do |y|
        if @board[[x,y]].nil?
          checkerboard(x,y)
        else
          render_piece(x,y)
        end
      end
      puts BOARD_ROWS[x].colorize(:white)
    end
  end

  def checkerboard(x, y, text = " ")
    if @player[:black].cursor == [x, y] || @player[:white].cursor == [x, y]
      print text.colorize(:black).on_light_white
    elsif @player[:black].start_pos == [x, y] && @player[:black].grabbing ||
      @player[:white].start_pos == [x, y] && @player[:white].grabbing
      print text.colorize(:light_white).on_black
    elsif (x + y) % 2 == 0
      print text.colorize(:black).on_white
    else
      print text.colorize(:black).on_light_black
    end
  end


end

if __FILE__ == $PROGRAM_NAME
  game = Game.new(true)
  game.play
end

#could break game out into individual and meta, to help with game loading
#could try to move a lot of the board's stuff that references game into
#  game instead... review Ned's version of board duping.
