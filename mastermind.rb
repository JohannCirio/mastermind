require 'colorize' # https://github.com/fazibear/colorize
load 'modules.rb'

WHITE = :light_white
MAGENTA = :magenta
BLUE = :light_blue
YELLOW = :light_yellow
GREEN = :green
RED = :red

LINES = 0..11
COLLUMS = 0..3

POSSIBLE_COLORS = [WHITE, MAGENTA, BLUE, YELLOW, GREEN, RED]

class Square
  attr_accessor :color
  def initialize(color)
    @color = color
  end

  def color_print
    print '⬛'.colorize(@color.to_sym)
  end
end

class Circle
  attr_accessor :color
  def initialize(color, symbol = '⬤')
    @color = color
    @symbol = symbol
  end

  def color_print
    print @symbol.colorize(@color.to_sym)
    # print "◐"
  end
end

class Board
  attr_accessor :square_lines_array, :circle_lines_array
  include Printing
  include Decoders
  def initialize
    @square_lines_array = generate_array(Square)
    @circle_lines_array = generate_array(Circle)
  end

  def generate_array(an_object)
    an_array = []
    LINES.each do |line_index|
      an_array[line_index] = []
      COLLUMS.each do |collum_index|
        an_array[line_index][collum_index] = an_object.new('light_black')
      end
    end
    an_array
  end

  def graphic_print
    puts '============================'
    puts ' | |     MASTERMIND     | |'
    LINES.each do |i|
      print ' | |'
      print_line(@square_lines_array, i)
      print_line(@circle_lines_array, i)
      puts '| |'
    end
    puts '============================'
  end

  def print_line(array, line_index)
    array[line_index].each do |element| 
      element.color_print
      print ' '
    end
  end

  def change_line(type, line_index, colors_array)
    if type == 'square'
      COLLUMS.each { |collum_index| @square_lines_array[line_index][collum_index].color = colors_array[collum_index] }
    elsif type == 'circle'
      COLLUMS.each { |collum_index| @circle_lines_array[line_index][collum_index].color = colors_array[collum_index] }
    end
    colors_array
  end
end

class Mastermind
  include Decoders
  include Printing
  include CursorControl
  @password = []

  def mode_selection
    puts 'Welcome to Mastermind!!!'
    puts 'Do you want to crack a code or make one?'
    puts 'Press 1 to Crack or 2 to Make a code, then press Enter!'
    mode = gets.chomp.to_i
    unless mode == 1 || mode == 2
      puts 'Invalid option! Press 1 to Crack or 2 to Make a code, then press Enter!'
      mode = gets.chomp.to_i
    end
    return mode
  end

  def start_game
    @board = Board.new
    clear_screen
    move_to(0, 0)
    mode_selection == 1 ? crack_a_code : make_a_code
  end

  def crack_a_code
    @password = generate_random_password
    loading_bar
    main_game_crack
  end

  def main_game_crack
    round_number = 0
    @board.graphic_print
    while round_number <= 11 do
      round_result = play_a_round(round_number, read_player_guess)
      win?(round_result)? victory : round_number += 1
    end
    defeat
  end

  def make_a_code
    puts 'Chose the password you want the computer to crack!'
    @password = read_player_guess
    main_game_make
  end

  def main_game_make
    right_guesses = []
    turn = 0

    while turn < 6
      current_guess = generate_computer_guess(right_guesses, turn)
      computer_play_result = play_a_round(turn, current_guess)
      turn += 1
      number_of_right_guesses = analyze_result(computer_play_result)
      if number_of_right_guesses == true
        computer_win
      else
        (number_of_right_guesses - right_guesses.length).times {right_guesses.push(current_guess.last)}
      end
      if right_guesses.length == 4
        break
      end
    end
    
    while turn < 12
      current_guess = []
      4.times { current_guess.push(right_guesses.sample)}
      computer_play_result = play_a_round(turn, current_guess)
      turn += 1
      if analyze_result(computer_play_result) == true
        computer_win
      end
    end
    computer_lose
  end

  def generate_computer_guess(right_guesses, turn)
    generated_guess = []
    right_guesses.each { |guess| generated_guess.push(guess) }
    until generated_guess.length == 4
      generated_guess.push(POSSIBLE_COLORS[turn])
    end
    return generated_guess
  end

  def analyze_result(result)
    if result.all? { |element| element == GREEN }
      return true
    else
      return result.count { |element| element == GREEN || element == YELLOW }
    end
  end

  def computer_win
    puts 'the computer won!'
    play_again
  end

  def computer_lose
    puts 'The computer lost!'
    play_again
  end

  def victory
    puts 'You won! Congratulations!'
    play_again
  end

  def defeat
    puts 'You lost! Better luck next time'
    play_again
  end

  def play_again
    puts 'Do you want to play again? Press y/n and press Enter!'
    mode = gets.chomp.downcase
    unless mode == 'y' || mode == 'n'
      puts 'Invalid option! Press y/n and press Enter!'
      mode = gets.chomp.downcase
    end
    mode == 'y'? start_game : exit(true)
  end

  def generate_random_password
    secret_password = []
    4.times { secret_password.push(POSSIBLE_COLORS.sample)}
    return secret_password
  end

  def choose_color_ui
    puts "6 possible colors: | white  = #{'⬛'.colorize(WHITE)} | magenta = #{'⬛'.colorize(MAGENTA)} | blue = #{'⬛'.colorize(BLUE)} |
                   | yellow = #{'⬛'.colorize(YELLOW)} | green =   #{'⬛'.colorize(GREEN)} | red =  #{'⬛'.colorize(RED)} |"
    puts "Choose a sequence of 4 colors in a 4 letter format, e.g 'rrrr' =  #{"⬛".red}#{"⬛".red}#{"⬛".red}#{"⬛".red}:"
  end

  def read_player_guess
    choose_color_ui
    player_guess = string_to_colors_array(gets.chomp.to_s)
    until player_guess.length == 4 && valid_colors?(player_guess)
      wrong_input_message
      choose_color_ui
      player_guess = string_to_colors_array(gets.chomp.to_s)
    end
    player_guess
  end
  
  def valid_colors?(array_of_colors)
    array_of_colors.none? { |color| color == 'ERROR' }
  end

  def play_a_round(round_number, player_guess)
    play_result = compare_arrays(@password, player_guess)
    @board.change_line("square", round_number, player_guess)
    @board.change_line("circle", round_number, play_result)
    @board.graphic_print
    play_result
  end

  def wrong_input_message
    puts "\nWrong input, try again!\n\n"
  end

  def win?(result_array)
    result_array.all? { |color| color == GREEN }
  end

end

game = Mastermind.new
game.start_game
