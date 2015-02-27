class Keystroke
  ####################### Accessors #############################
    attr_accessor :word_matrix,
    :ctrl_pressed,
    :move_right_arm_is_queued,
    :my_monkey,
    :keystroke_name,
    :shift_pressed,
    :up,
    :right
    ##### End
  def initialize(my_monkey)
    # @ctrl_pressed = nil
    @shift_pressed = nil
    @move_right_arm_is_queued = false
    @move_left_arm_is_queued = false
    @delay_timer = MyTimer.new
    @delay_timer.keypress_delay_time_ms = 200
    @my_monkey = my_monkey
    @right_arm_x_adjustment = 4
    @left_arm_x_adjustment = 6
    @keystroke_name = "none"
    @up = true
    @right = true
  end
  def queue_move
  end

  def clear_all_highlighted_chars
    #Clear all highlighted chars
    @my_monkey.word_matrix.list_of_word_rows.each do |word_row|
      word_row.position_list.each do |position|
        position.selected = false
      end
    end
  end

  def move_right_arm
    #placeholder for object defined method
  end
  def move_left_arm
    #placeholder for object defined method
  end
end
class Ctrl_right_arrow < Keystroke
  def queue_move
    if @my_monkey.current_char_in_row_right_arm < @my_monkey.word_matrix.list_of_word_rows[@my_monkey.current_row].position_list.length - 1
      #Add next method to the method queue.  All methods in this queue are executed in the Player class
      @my_monkey.queued_methods_to_execute << self.method(:move_right_arm)
    end
  end
  def move_right_arm
      '''Determine which of the following cases you are in:
      -last letter in line
      -letter not at end of word
      - letter at end of word

      If at end of line:
        move to letter zero on next line
      Else:
        scan list for next letter at end of word
      '''
      #Find the next character that is at the end of a word and go there, plus 1 character
        #Find char at end of current word
        #Starting with the character you are on, look through each of the chars in the string for the next char that is the end of a word.  Grab this position number.
        @number_of_this_word = @my_monkey.word_matrix.list_of_word_rows[@my_monkey.current_row].position_list[@my_monkey.current_char_in_row_right_arm].word_number
        @row_length = @my_monkey.word_matrix.list_of_word_rows[@my_monkey.current_row].position_list.length
        (@my_monkey.current_char_in_row_right_arm..(@row_length -1)).each do |position_index|
          #Look for next end of word character after the start of word character
          if @my_monkey.word_matrix.list_of_word_rows[@my_monkey.current_row].position_list[position_index].end_of_word
            @next_end_of_word_char = position_index
            break
          end
        end
        @my_monkey.current_char_in_row_right_arm = @next_end_of_word_char + 1
      @my_monkey.arm_right.x = @my_monkey.current_char_in_row_right_arm * @my_monkey.word_matrix.char_width + @my_monkey.word_matrix.text_start_x_offset + @right_arm_x_adjustment
      @my_monkey.previous_keystroke = @keystroke_name
      @delay_timer.restart
      @my_monkey.queued_methods_to_execute << self.method(:move_left_arm)
  end
  def move_left_arm
    #If time delay has been fulfilled
    if @delay_timer.time_is_complete
      @my_monkey.current_char_in_row_left_arm = @my_monkey.current_char_in_row_right_arm
      @my_monkey.arm_left.x = @my_monkey.current_char_in_row_left_arm * @my_monkey.word_matrix.char_width + @my_monkey.word_matrix.text_start_x_offset - @left_arm_x_adjustment
      @my_monkey.previous_keystroke = @keystroke_name
    else
      #If delay has not been completed, requeue method in method queue
      @my_monkey.queued_methods_to_execute << self.method(:move_left_arm)
    end
  end
end
class Ctrl_left_arrow < Keystroke
  def queue_move
    if @my_monkey.current_char_in_row_right_arm > 0
      #Add next method to the method queue.  All methods in this queue are executed in the Player class
      @my_monkey.queued_methods_to_execute << self.method(:move_right_arm)
    end
  end
  def move_right_arm
      '''Determine which of the following cases you are in:
      -first letter in line
      -letter not at start of word
      - letter at start of word

      If at start of line:
        move to last letter on previous line
      Elsif: you are at the start of a word
        move to start of previous word_number
      Else:
        move to the start of the previous word
      '''
      #Find the next character that is at the end of a word and go there
        #Find char at end of current word
        #Starting with the character you are on, look through each of the chars in the string for the next char that is the end of a word.  Grab this position number.
        @number_of_this_word = @my_monkey.word_matrix.list_of_word_rows[@my_monkey.current_row].position_list[@my_monkey.current_char_in_row_right_arm].word_number
        @row_length = @my_monkey.word_matrix.list_of_word_rows[@my_monkey.current_row].position_list.length
        find_previous_word_start(1) #fix - put this in parent class?
        @my_monkey.current_char_in_row_right_arm = @prev_start_of_word_char + 0

      @my_monkey.arm_right.x = @my_monkey.current_char_in_row_right_arm * @my_monkey.word_matrix.char_width + @my_monkey.word_matrix.text_start_x_offset + @right_arm_x_adjustment
      @my_monkey.previous_keystroke = @keystroke_name
      @delay_timer.restart
      @my_monkey.queued_methods_to_execute << self.method(:move_left_arm)
  end
  def move_left_arm
    #If time delay has been fulfilled
    if @delay_timer.time_is_complete
      @my_monkey.current_char_in_row_left_arm = @my_monkey.current_char_in_row_right_arm
      @my_monkey.arm_left.x = @my_monkey.current_char_in_row_left_arm * @my_monkey.word_matrix.char_width + @my_monkey.word_matrix.text_start_x_offset - @left_arm_x_adjustment
      @my_monkey.previous_keystroke = @keystroke_name
    else
      #If delay has not been completed, requeue method in method queue
      @my_monkey.queued_methods_to_execute << self.method(:move_left_arm)
    end
  end
  def find_previous_word_start(steps_back)
    #Count backwards in the positions list until you find the next start of word
    (@my_monkey.current_char_in_row_right_arm - steps_back).downto(0).each do |position_index|
      @prev_start_of_word_char = 0
      #Look for next start of word character after the start of word character
      if @my_monkey.word_matrix.list_of_word_rows[@my_monkey.current_row].position_list[position_index].start_of_word
        @prev_start_of_word_char = position_index
        break
      end
    end
  end
end
class Key_home < Keystroke
  def queue_move
      #Add next method to the method queue.  All methods in this queue are executed in the Player class
      @my_monkey.queued_methods_to_execute << self.method(:move_left_arm)
  end

  #Get position of first word
  def get_word_start_location(desired_word)
    @desired_word = desired_word
    @char_number = -1
    @my_monkey.word_matrix.list_of_word_rows[@my_monkey.current_row].position_list.each do |position|
      @char_number += 1
      if position.word_number == @desired_word then return @char_number end
    end
  end
  def move_left_arm
    get_word_start_location(0)
    #If keystroke was hit twice in a row, move alternatingly to left edge of line, or first character of first word
    if @my_monkey.previous_keystroke != @keystroke_name
      @my_monkey.current_char_in_row_left_arm = @char_number
    elsif @my_monkey.previous_keystroke == @keystroke_name && @my_monkey.current_char_in_row_left_arm == 0
      @my_monkey.current_char_in_row_left_arm = @char_number
    elsif @my_monkey.previous_keystroke == @keystroke_name && @my_monkey.current_char_in_row_left_arm != 0
      @my_monkey.current_char_in_row_left_arm = 0
    end
    @my_monkey.arm_left.x = @my_monkey.current_char_in_row_left_arm * @my_monkey.word_matrix.char_width + @my_monkey.word_matrix.text_start_x_offset - @left_arm_x_adjustment

    @delay_timer.restart
    @my_monkey.queued_methods_to_execute << self.method(:move_right_arm)
    @my_monkey.previous_keystroke = @keystroke_name
  end
  def move_right_arm
    #If time delay has been fulfilled
    if @delay_timer.time_is_complete
      @my_monkey.current_char_in_row_right_arm = @my_monkey.current_char_in_row_left_arm
      @my_monkey.arm_right.x = @my_monkey.current_char_in_row_right_arm * @my_monkey.word_matrix.char_width + @my_monkey.word_matrix.text_start_x_offset + @right_arm_x_adjustment
    else
      #If delay has not been completed, requeue method in method queue
      @my_monkey.queued_methods_to_execute << self.method(:move_right_arm)
    end
  end
end
class Key_end < Keystroke
  def queue_move
      #Add next method to the method queue.  All methods in this queue are executed in the Player class
      @my_monkey.queued_methods_to_execute << self.method(:move_right_arm)
      # @my_monkey.previous_keystroke = @keystroke_name
  end

  def move_right_arm
      @my_monkey.current_char_in_row_right_arm = @my_monkey.word_matrix.list_of_word_rows[@my_monkey.current_row].position_list.length - 1
      @my_monkey.arm_right.x = (@my_monkey.current_char_in_row_right_arm + 1) * @my_monkey.word_matrix.char_width + @my_monkey.word_matrix.text_start_x_offset + @right_arm_x_adjustment
      @delay_timer.restart
      @my_monkey.queued_methods_to_execute << self.method(:move_left_arm)
  end
  def move_left_arm
    #If time delay has been fulfilled
    if @delay_timer.time_is_complete
      @my_monkey.current_char_in_row_left_arm = @my_monkey.current_char_in_row_right_arm
      # @my_monkey.arm_left.x = @my_monkey.current_char_in_row_left_arm * @my_monkey.word_matrix.char_width + @my_monkey.word_matrix.text_start_x_offset - @left_arm_x_adjustment
      @my_monkey.arm_left.x = @my_monkey.arm_right.x - @left_arm_x_adjustment
      @my_monkey.previous_keystroke = @keystroke_name
    else
      #If delay has not been completed, requeue method in method queue
      @my_monkey.queued_methods_to_execute << self.method(:move_left_arm)
    end
  end
end
class Key_up_or_down < Keystroke
  def queue_move
      clear_all_highlighted_chars
      #Add next method to the method queue.  All methods in this queue are executed in the Player class
      @my_monkey.queued_methods_to_execute << self.method(:move_right_arm)
  end
  def move_right_arm
      #If you are at the right end of a word, and click the left arrow arrow, don't move left one word, just move to the left end of the word
      in_bounds_top = @my_monkey.current_row > 0
      in_bounds_bottom = @my_monkey.current_row < @my_monkey.word_matrix.list_of_word_rows.length - 2
      length_of_previous_row = @my_monkey.word_matrix.list_of_word_rows[@my_monkey.current_row - 1].position_list.length
      length_of_next_row = @my_monkey.word_matrix.list_of_word_rows[@my_monkey.current_row + 1].position_list.length
      #If the up arrow was pressed
      if @up == true and in_bounds_top
        @my_monkey.current_row -= 1
        #If current char position is greater than the final char position in the line you are moving to, move to the last char position in that line
        if @my_monkey.current_char_in_row_right_arm > length_of_previous_row - 1
          @my_monkey.current_char_in_row_right_arm = length_of_previous_row + 0
        end
        calculate_new_position_for_right_arm
        @my_monkey.queued_methods_to_execute << self.method(:move_left_arm)
        @my_monkey.previous_keystroke = @keystroke_name
        @delay_timer.restart
      end
      #If the down arrow was pressed
      if @up == false and in_bounds_bottom
        @my_monkey.current_row += 1
        #If current char position is greater than the final char position in the line you are moving to, move to the last char position in that line
        if @my_monkey.current_char_in_row_right_arm > length_of_next_row - 1
          @my_monkey.current_char_in_row_right_arm = length_of_next_row + 0
        end
        calculate_new_position_for_right_arm
        @my_monkey.queued_methods_to_execute << self.method(:move_left_arm)
        @delay_timer.restart
      end
  end
  def move_left_arm
    #If time delay has been fulfilled
    if @delay_timer.time_is_complete
      @my_monkey.current_char_in_row_left_arm = @my_monkey.current_char_in_row_right_arm
      @my_monkey.arm_left.y = @my_monkey.arm_right.y
      @my_monkey.arm_left.x = @my_monkey.arm_right.x - @left_arm_x_adjustment
      @my_monkey.previous_keystroke = @keystroke_name
    else
      #If delay has not been completed, requeue method in method queue
      @my_monkey.queued_methods_to_execute << self.method(:move_left_arm)
    end
  end
  def calculate_new_position_for_right_arm
    @my_monkey.arm_right.y = (@my_monkey.current_row - 1) * @my_monkey.word_matrix.row_spacing + @my_monkey.word_matrix.first_line_y_start + 6 # offset
    @my_monkey.arm_right.x = @my_monkey.current_char_in_row_right_arm * @my_monkey.word_matrix.char_width + @my_monkey.word_matrix.text_start_x_offset + @right_arm_x_adjustment
  end
end
class Right_arrow < Keystroke
  def queue_move
    if @my_monkey.current_char_in_row_right_arm < @my_monkey.word_matrix.list_of_word_rows[@my_monkey.current_row].position_list.length
      clear_all_highlighted_chars
      #Add next method to the method queue.  All methods in this queue are executed in the Player class
      @my_monkey.queued_methods_to_execute << self.method(:move_right_arm)
    end
  end
  def move_right_arm
      @my_monkey.current_char_in_row_right_arm += 1
      @my_monkey.arm_right.x = @my_monkey.current_char_in_row_right_arm * @my_monkey.word_matrix.char_width + @my_monkey.word_matrix.text_start_x_offset + @right_arm_x_adjustment
      @delay_timer.restart
      @my_monkey.queued_methods_to_execute << self.method(:move_left_arm)
      @my_monkey.previous_keystroke = @keystroke_name
  end
  def move_left_arm
    #If time delay has been fulfilled
    if @delay_timer.time_is_complete
      @my_monkey.current_char_in_row_left_arm = @my_monkey.current_char_in_row_right_arm
      @my_monkey.arm_left.x = @my_monkey.current_char_in_row_left_arm * @my_monkey.word_matrix.char_width + @my_monkey.word_matrix.text_start_x_offset - @left_arm_x_adjustment
    else
      #If delay has not been completed, requeue method in method queue
      @my_monkey.queued_methods_to_execute << self.method(:move_left_arm)
    end
  end
end
class Shift_right_arrow < Keystroke
  def queue_move
    @list_of_word_rows = @my_monkey.word_matrix.list_of_word_rows
    if @my_monkey.current_char_in_row_right_arm < @my_monkey.word_matrix.list_of_word_rows[@my_monkey.current_row].position_list.length
      #Add next method to the method queue.  All methods in this queue are executed in the Player class
      @my_monkey.queued_methods_to_execute << self.method(:move_right_arm)
    end
  end
  def move_right_arm
    if @delay_timer.time_is_complete
      @my_monkey.current_char_in_row_right_arm += 1
      @my_monkey.arm_right.x = @my_monkey.current_char_in_row_right_arm * @my_monkey.word_matrix.char_width + @my_monkey.word_matrix.text_start_x_offset + @right_arm_x_adjustment

      @highlight_start = @my_monkey.current_char_in_row_left_arm
      @highlight_end = @my_monkey.current_char_in_row_right_arm - 1

      (@highlight_start..@highlight_end).each do |index|
        @list_of_word_rows[@my_monkey.current_row].position_list[index].selected = true
      end

      # #Clear all highlighted words
      # @my_monkey.word_matrix.list_of_word_rows.each do |word_row|
      #   word_row.position_list.each do |position|
      #     position.selected = false
      #   end
      # end

      @delay_timer.restart #this makes less sense, fix it
      @my_monkey.previous_keystroke = @keystroke_name
    # #Test to see if selected flags are correct
    #   puts ""
    #   puts "x positions from position matrix----------start"
    #   @list_of_word_rows.each do |word_row|
    #     word_row.position_list.each do |position|
    #       if position.selected
    #         print "T"
    #       else
    #         print "+"
    #       end
    #     end
    #     puts ""
    #   end
    #   puts "x positions from position matrix----------end"
    else
      @my_monkey.queued_methods_to_execute << self.method(:move_right_arm)
    end
  end
end

class Left_arrow < Keystroke
  def queue_move
    #Make sure that you are not already at the first position
    if @my_monkey.current_char_in_row_right_arm > 0
      clear_all_highlighted_chars
      #Add next method to the method queue.  All methods in this queue are executed in the Player class
      @my_monkey.queued_methods_to_execute << self.method(:move_left_arm)
    end
  end
  def move_left_arm
      @my_monkey.current_char_in_row_left_arm -= 1
      @my_monkey.arm_left.x = @my_monkey.current_char_in_row_left_arm * @my_monkey.word_matrix.char_width + @my_monkey.word_matrix.text_start_x_offset - @left_arm_x_adjustment
      @delay_timer.restart
      @my_monkey.queued_methods_to_execute << self.method(:move_right_arm)
      @my_monkey.previous_keystroke = @keystroke_name
  end
  def move_right_arm
    #If time delay has been fulfilled
    if @delay_timer.time_is_complete
      @my_monkey.current_char_in_row_right_arm = @my_monkey.current_char_in_row_left_arm
      @my_monkey.arm_right.x = @my_monkey.current_char_in_row_right_arm * @my_monkey.word_matrix.char_width + @my_monkey.word_matrix.text_start_x_offset + @right_arm_x_adjustment
    else
      #If delay has not been completed, requeue method in method queue
      @my_monkey.queued_methods_to_execute << self.method(:move_right_arm)
    end
  end

  #I should define positions here in terms of characters and rows and translate those in the draw function
end
