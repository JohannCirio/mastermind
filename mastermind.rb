require 'colorize' # https://github.com/fazibear/colorize

WHITE = :light_white
MAGENTA = :magenta
BLUE = :light_blue
YELLOW = :light_yellow
GREEN = :green
RED = :red

LINES = 0..11
COLLUMS = 0..3

POSSIBLE_COLORS = [WHITE, MAGENTA, BLUE, YELLOW, GREEN, RED]

module Printing
  def print_bar(full_squares_number, max_squares)
    print "||"
    full_squares_number.times { print "⬛" }
    (max_squares - full_squares_number).times { print "#{"⬛".black}" }
    print "||"
  end

  def loading_bar
    puts "Computer is generating password, please wait"
    i = 0
    print_bar(i, 10)
    while (i <= 10)
      print "\r"
      print_bar(i, 10)
      sleep(0.5)
      i += 1
    end
    sleep(1)
    puts "\rPassword Generated!                     "
    sleep(1)
  end

  def cursor_move_up
    print "\033[2A"
  end
end

module Decoders
  def letter_to_color_symbol(letter)
    case letter
    when 'w' then WHITE
    when 'm' then MAGENTA
    when 'b' then BLUE
    when 'y' then YELLOW
    when 'g' then GREEN
    when 'r' then RED
    else 'ERROR'
    end
  end

  def string_to_colors_array(string)
    letters_array = string.downcase.split('')
    colors_array = []
    letters_array.each { |letter| colors_array.push(letter_to_color_symbol(letter)) }
    return colors_array
  end

  def compare_arrays(passwords, plays)
    result_array = []
    remaining_keys = {}
    wrong_guesses = {}
    COLLUMS.each do |i|
      if passwords[i] == plays[i]
        result_array.push(GREEN)
      else
        remaining_keys[passwords[i]].nil? ? remaining_keys[passwords[i]] = 1 : remaining_keys[passwords[i]] += 1
        wrong_guesses[plays[i]].nil? ? wrong_guesses[plays[i]] = 1 : wrong_guesses[plays[i]] += 1
      end
    end
    return result_array if result_array.length == 4

    half_rights = 0
    remaining_keys.each_key do |key|
      if wrong_guesses[key].nil?
        next
      elsif remaining_keys[key] == wrong_guesses[key]
        half_rights += remaining_keys[key]
      else 
        half_rights += (remaining_keys[key] - wrong_guesses[key]).abs
      end
    end
    half_rights.times { result_array.push(YELLOW) }
    (4 - result_array.length).times { result_array.push(RED) }
    return result_array
  end
end

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
    puts '====================='
    puts ' | | MASTERMIND | |'
    LINES.each do |i|
      print ' | |'
      print_line(@square_lines_array, i)
      print_line(@circle_lines_array, i)
      puts '| |'
    end
    puts '====================='
  end

  def print_line(array, line_index)
    array[line_index].each { |element| element.color_print }
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
  @password = []

  def start_game
    @board = Board.new
    mode_selection == 1? crack_a_code : make_a_code
  end

  def crack_a_code
    @password = generate_random_password
    loading_bar
    main_game
  end

  def main_game
    round_number = 0
    @board.graphic_print
    while round_number <= 11 do
      round_result = play_a_round(round_number)
      win?(round_result)? victory : round_number += 1
    end
    defeat
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

  def play_a_round(round_number)
    p @password
    player_guess = read_player_guess
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
