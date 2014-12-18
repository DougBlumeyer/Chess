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

  def initialize(welcome_flag = false)
    @turn = :white

    @player = { white: HumanPlayer.new, black: ComputerPlayer.new }

    @board = Board.new(self)

    initialize_pieces

    @cursor = [4,4]
    @start_pos = []
    @end_pos = []
    @grabbing = false

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
      @board.render
      @player[@turn].play_turn
      toggle_turn
    end

    puts (@board.checkmate?(:white) ? "black wins!" : "white wins!")
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

  def play_turn
    @successful_move = false
    @timer = Time.now.to_i
    @turn_time = 0
    until @successful_move
      if @max_turn_time > 0 && Time.now.to_i > @timer + @turn_time
        update_timer
      else
        wait_for_input
      end
    end
  end

  def update_timer
    @turn_time = Time.now.to_i - @timer
    @board.render
    if @turn_time > @max_turn_time
      @turn_time = @max_turn_time
      puts "\nOUT OF TIME!"
      exit
    end
  end

  def wait_for_input
    begin
      input(read_char)
      @board.render
    rescue ArgumentError => bad_move
      puts bad_move.message
      retry
    end
  end

  def toggle_grabbing
    @grabbing = (@grabbing == true ? false : true)
  end

  def input(key)
    case key
    when "\e[A"
      @cursor[0] -= 1 if @cursor[0] > 0
    when "\e[D"
      @cursor[1] -= 1 if @cursor[1] > 0
    when "\e[B"
      @cursor[0] += 1 if @cursor[0] < 7
    when "\e[C"
      @cursor[1] += 1 if @cursor[1] < 7
    when "\r"
      attempt_action
    when 's'
      File.open("chess_#{Time.now}.yml", "w") do |f|
        f.puts self.to_yaml
      end
    when 'l'
      print "Filename: "
      File.open(gets.chomp) do |f|
        loaded_game = YAML.load(f)
        load_game(loaded_game)
      end
    when "\e"
      exit
    else
      puts key
    end
  end

  def attempt_action
    @grabbing ? @end_pos = @cursor.dup : @start_pos = @cursor.dup
    raise NoPiece.new("\n\nNo piece there! ") if @board[@start_pos].nil?
    raise NotYours.new("\n\nThat's not your piece! ") if @board[@start_pos].color != turn
    toggle_grabbing
    @board.move(@start_pos, @end_pos) unless @grabbing
  end

  def read_char
    STDIN.echo = false
    STDIN.raw!
    input = STDIN.getc.chr
    if input == "\e" then
      input << STDIN.read_nonblock(3) rescue nil
      input << STDIN.read_nonblock(2) rescue nil
    end
  ensure
    STDIN.echo = true
    STDIN.cooked!
    return input
  end

end

if __FILE__ == $PROGRAM_NAME
  game = Game.new(true)
  game.play
end

#could break game out into individual and meta, to help with game loading
#could try to move a lot of the board's stuff that references game into
#  game instead... review Ned's version of board duping.
