require 'gosu'

class WordMatrix
  attr_accessor :list_of_word_rows,
  :my_font,
  :text_list,
  :row_spacing,
  :left_arm,
  :right_arm,
  :first_line_y_start,
  :text_start_x_offset,
  :char_width,
  :game_board_x,
  :game_board_y,
  :copied_word
  def initialize
    @list_of_word_rows = []
    @text_list = []
    @row_num = 0
    @red_words = ["for", "if", "in", "def", "then", "end", "<", ">", "=="]
    @word_is_in_string = false
    @first_line_y_start = nil
    @my_font = nil
    @row_spacing = nil
    @arm_left = nil
    @arm_right = nil
    @text_start_x_offset = 70
    @text_start_y_offset = 72
    @char_width = 14
    @game_board_x = 0
    @game_board_y = 0
    @copied_word = ""
  end
  def load_file(file_path)
    File.open(file_path).lines.each {|line| @text_list << line}
  end
  def delete_from_word_matrix(row, start_char, num_chars_to_delete)
    @text_list[row] = @text_list[row].slice(0,start_char) + @text_list[row].slice(start_char + num_chars_to_delete, @text_list[row].length - 1)
  end

  def paste_chars_in_word_matrix(row, start_char)
    @text_list[row] = @text_list[row].slice(0,start_char) + @copied_word + @text_list[row].slice(start_char, @text_list[row].length - 1)
  end

  def set_up_word_matrix
    # text_list.each do |row|
    #   puts row
    # end
    @list_of_word_rows = []
    @row_num = 0
    @width_of_space_char = @my_font.text_width(" ", factor_x = 1)
    #For each row in text file
    @text_list.each do |line|
      @line = line
      @x_offset = 0
      swap_leading_spaces_for_dashes #So that
      word_num = 0
      #Init word_row list for word_matrix
      @word_row_list = WordRow.new
      @word_row_list.row_num = @row_num

      @line.split(" ").each do |word|
        @word = word
        word_num += 1
        swap_dashes_for_leading_spaces
        set_word_color
	      #Stick word in word_row_list
        my_word = Word.new(@word, @x_offset.to_i, @word_color)
        @x_offset += @my_font.text_width(@word, factor_x = 1) + @width_of_space_char
        @word_row_list.word_list << my_word
      end
      @list_of_word_rows << @word_row_list
      @row_num += 1
    end
    set_up_position_information
      # #test print
      # @list_of_word_rows.each {|row| row.word_list.each {|word| print word.x_position.to_i.to_s + " "}; puts ""}
      # puts "++++++++++++++++++++ words from word row - start"
      # @list_of_word_rows.each {|row| row.word_list.each {|word| print word.word_text + " "}; puts ""}
      # puts "++++++++++++++++++++ words from word row - end"
  end
  def swap_leading_spaces_for_dashes
    #Count the number of leading spaces
    num_leading_spaces = 0
    @line.each_char {|letter| letter == " " ? num_leading_spaces += 1 : break}

    #Replace leading spaces with dashes (After you split the string, turn these back into spaces.)
    #Split the string after the leading spaces
    string_after_spaces = @line[num_leading_spaces, @line.length - num_leading_spaces]
    @line = "-" * num_leading_spaces + string_after_spaces
  end
  def swap_dashes_for_leading_spaces
    #Replace dashes with spaces
    @word.gsub!("-", " ")
  end
  def set_word_color
    #If word is the start of a string in quotes, set the "word_is_in_string" flag
    if @word[0] == "\"" then @word_is_in_string = true end
    #If word is at the start of a string of words in quotes
    if @word_is_in_string
      @word_color = Gosu::Color::YELLOW
    #If word is a special red word
    elsif @red_words.include?(@word)
      @word_color = Gosu::Color::RED
    #If word is a single digit
    elsif @word.length == 1 && @word =~ /[[:digit:]]/
      @word_color = Gosu::Color::GREEN
    #All other words
    else
      @word_color = Gosu::Color::WHITE
    end
    #If word is at the end of a string in quotes, allow the word to print in yellow (above), but then turn the yellow off
    if @word[-1] == "\"" then @word_is_in_string = false end
  end
  def draw_words
    #This should be rewritten to draw characters, not words
    #Parse word matrix and display words-->
    @list_of_word_rows.each {|word_row| word_row.word_list.each do|word|
      @my_font.draw(word.word_text.chomp.gsub(/\t/, "    "), @text_start_x_offset + word.x_position + @game_board_x, @text_start_y_offset + word_row.row_num * @row_spacing + @game_board_y, 1.0, 1.0, 1.0, word.color)
    end}
  end
  def set_up_position_information
    #For each line in the text file, create a list of objects, where each object represents the position of the character and other details about the character in that position.
    #Add this array to the array of word rows that was just created.
    #This array will be referenced to determine whether the monkey is at the beginning, middle, or end of a word and other relevant information that defines how it will move next
    @row_index = -1
    #For each line in the file
    @text_list.each do |line|
      @row_index += 1
      temp_position_list = []
      @char_index = -1
      @rstripped_line = line.rstrip
      @character_x_position = 0
      #For each character in the line

      @rstripped_line.each_char do |char|
        @char_index += 1
        #Create a new Position object for each character
        @temp_position = Position.new()
        @temp_position.character = char
        # @temp_position.x = @character_x_position
        # @character_x_position += @my_font.text_width(char, factor_x = 1)
        check_if_char_is_start_or_end_of_line
        #Add newly created position to list of positions for the row
        temp_position_list << @temp_position
      end
      #Add position list to corresponding word row in list of word rows
      @list_of_word_rows[@row_index].position_list = temp_position_list
      check_if_char_is_start_or_end_of_word
    end
    #Do not delete this test
    # print_verification_of_position_info
  end
  def check_if_char_is_start_or_end_of_word
    #Test whether character is at the start or end of a word
      previous_character = ""
      word_number = -1
      @char_index = -1
      @list_of_word_rows[@row_index].position_list.each do |position|
        @char_index += 1
        #Special cases
        #Is char first letter of first word with no leading spaces?
          if @char_index == @rstripped_line.length - 1 && position.character != " "
            position.end_of_word = true
          end
        #Is char last letter of last word?
          if @char_index == 0  && position.character != " "
            position.start_of_word = true
          end
        #Normal cases
        #Start of word
        if position.character != " " && (previous_character == " " || @char_index ==0)
          position.start_of_word = true
          word_number += 1
        end
        #record which word you are in.  Only assign a word number to characters, not spaces. make this a different method
        if @list_of_word_rows[@row_index].position_list[@char_index -0].character != " "
          position.word_number = word_number
        end
        #End of word (exclude analysis of characters that are the first in the row, since they will produce a false positive)
        if position.character == " " && previous_character != " " && @char_index != 0
          @list_of_word_rows[@row_index].position_list[@char_index -1].end_of_word = true
        end
      #Store previous character for comparison
      previous_character = position.character
      end
  end
  def check_if_char_is_start_or_end_of_line
    #Check whether the character is at the start of the line
    if @char_index == 0 then @temp_position.start_of_line = true end
    #Check whether the character is at the end of the line
    if (@char_index == (@rstripped_line.length - 1)) then @temp_position.end_of_line = true end
  end
  #Put on other file
  def print_verification_of_position_info
    #Test to see if characters are correct
      puts "characters from position matrix----------start"
      @list_of_word_rows.each do |word_row|
        word_row.position_list.each do |position|
          print position.character
        end
        puts ""
      end
      puts "words from position matrix----------end"
      puts ""

    #Test to see if word starts and ends are correct
      puts "start and end of words from position matrix----------start"
      @list_of_word_rows.each do |word_row|
        word_row.position_list.each do |position|
          if position.start_of_word
            print "^"
            print position.character
            print position.word_number
          end
          #If the character is a single letter word, then the char is both the start and end of the word.
          #Don't reprint the character, which has already been printed
          if position.start_of_word && position.end_of_word
            print "*"
          #If the character is at the end of a word, print the character
          elsif position.end_of_word
            print position.character
            print position.word_number
            print "*"
          end
          if !position.start_of_word && !position.end_of_word
            print position.character
          if position.character != " "
            print position.word_number
          end
          end
        end
        puts ""
      end
      puts "start and end of words from position matrix----------end"

    #Test to see if word numbers are correct
      puts "word numbers from position matrix----------start"
      @list_of_word_rows.each do |word_row|
        word_row.position_list.each do |position|
          print position.word_number.to_s + " "
        end
        puts ""
      end
      puts "word numbers from position matrix----------end"


    #Test to see if line starts and ends are correct
      puts ""
      puts "start and end of lines from position matrix----------start"
      @list_of_word_rows.each do |word_row|
        word_row.position_list.each do |position|
          if position.start_of_line
            print "-"
          elsif position.end_of_line
            print "+"
          else
            print position.character
          end
        end
        puts ""
      end
      puts "start and end of lines from position matrix----------end"
  end
end

class WordRow
  attr_accessor :word_list, :row_num, :position_list
  def initialize
    @num_leading_spaces = 0
    @word_list = []
    @position_list = []
  end
end

class Word
  attr_accessor :word_text, :x_position, :color
  def initialize(word_text, x_position, color)
    @word_text = word_text
    @x_position = x_position
    @color = color
  end
end

class Position
  attr_accessor :word_text,
    :character,
    :start_of_line,
    :end_of_line,
    :start_of_word,
    :end_of_word,
    :word_number,
    :selected,
    :color
  def initialize()
    @character
    @color
    @start_of_line = false
    @end_of_line = false
    @start_of_word = false
    @end_of_word = false
    @word_number = nil
    @selected = false
  end
end
