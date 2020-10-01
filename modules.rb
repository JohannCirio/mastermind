module CursorControl
  def clear_screen
    print "\033[2J"
  end

  def cursor_up(number_of_lines)
    print "\033[#{number_of_lines}A"
  end

  def move_to(line_number, column_number)
    print "\033[#{line_number};#{column_number}H"
  end
end

module Printing
  def print_bar(full_squares_number, max_squares)
    print "||"
    full_squares_number.times { print "⬛" }
    (max_squares - full_squares_number).times { print "#{"⬛".black}" }
    print "||"
  end

  def loading_bar
    puts 'Ok! Computer is generating password, please wait'
    i = 0
    print_bar(i, 20)
    while (i <= 20)
      print "\r"
      print_bar(i, 20)
      sleep(0.2)
      i += 1
    end
    sleep(1)
    puts "\rPassword Generated!                            "
    sleep(1)
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