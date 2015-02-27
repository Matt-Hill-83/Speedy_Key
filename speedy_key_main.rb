require 'gosu'
require 'date'

#on pc

# require_relative '_classes\Player_class'
# require_relative '_classes\Utilities_class'
# require_relative '_classes\WordMatrix_class'
# require_relative '_classes\Keystroke_class'

#on mac
require_relative '_classes/Player_class'
require_relative '_classes/Utilities_class'
require_relative '_classes/WordMatrix_class'
require_relative '_classes/Keystroke_class'


module ZOrder
  Background, Stars, Player, UI = *0..3
end

class GameWindow < Gosu::Window
  def initialize
    initialize_window_1
    super(@window_width, @window_height , false)
    initialize_window_2
    initialize_word_matrix
    initialize_monkey
    initialize_timer
    create_banana_locations
  end
  #move player and look for keyboard input - this executes automatically
  def update
    respond_to_keyboard_inputs
    puts "copied " + @bananas_copied.to_s
    puts "pasted " + @bananas_pasted.to_s
    puts "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"
  end
  ################################## INITIALIZE ###################################
    def initialize_window_1
      @window_width = 1198
      @window_height = 825
      @game_board_x = 470
      @game_board_y = 80
      # @banana_eaten = false
      @banana_timer = MyTimer.new
      @banana_timer.keypress_delay_time_ms = 2000
      @banana_timer.restart
      @bananas_copied = false
      @bananas_pasted = false
    end
    def initialize_window_2
      self.caption = "Speedy Key"
      @game_board_image = Gosu::Image.new(self, "media/sample_code_v009.png", true)
      @background_image = Gosu::Image.new(self, "media/background v003.jpg", true)
      @banana_image = Gosu::Image.new(self, "media/banana v004.png", true)
    end
    def initialize_word_matrix
      @my_font = Gosu::Font.new(self, "Consolas", 30)
      @word_matrix = WordMatrix.new
      @word_matrix.my_font =  @my_font
      @word_matrix.row_spacing = 30
      @word_matrix.first_line_y_start = 140
      @word_matrix.load_file('_sample code for game/sample code 002.rb')
      @word_matrix.game_board_x = @game_board_x
      @word_matrix.game_board_y = @game_board_y
      @word_matrix.set_up_word_matrix
    end
    def initialize_monkey
      @my_monkey = Player.new(self)
      @my_monkey.current_char_in_row_right_arm = 20
      @my_monkey.current_char_in_row_left_arm = 4
      @my_monkey.current_word_in_row_right_arm = 0
      @my_monkey.current_word_in_row_left_arm = @my_monkey.current_word_in_row_right_arm
      @my_monkey.current_row = 3
      @my_monkey.word_matrix = @word_matrix
      @my_monkey.game_board_x = @game_board_x
      @my_monkey.game_board_y = @game_board_y
      @my_monkey.arm_left_image_path = "media/monkey_arm_left_v001.png"
      @my_monkey.arm_right_image_path = "media/monkey_arm_right_v001.png"
      @my_monkey.body_image_path = "media/monkey_body_v001.png"
      @my_monkey.load_images
      @my_monkey.set_start_position
    end
    def initialize_timer
      @my_timer = MyTimer.new
      @my_timer.keypress_delay_time_ms = 200
    end
  ##### End
  ################################## ACTION FUNCTIONS ###################################
    def respond_to_keyboard_inputs
      #If a specified delay has passed since last keystroke, look for another keystroke
      if @my_timer.time_is_complete
        define_keyboard_inputs
        query_keyboard_inputs
      end
    end
    def draw # does this execute automatically?
      @background_image.draw(0, 0, ZOrder::Background)
      @game_board_image.draw(@game_board_x, @game_board_y, ZOrder::Background)
      @word_matrix.draw_words
      @my_monkey.draw
      if @bananas_pasted
        # @banana_timer.restart
        create_banana_locations
        @bananas_pasted = false
      end
        draw_biceps
        draw_highlights
        draw_bananas
      ##### End
    end
    def define_keyboard_inputs
      #Individual keypresses
      #Are these pointers or refs, meaning do they look at the keyboard just when they are defined, or when their compound inputs are queried?
      @right_arrow_pressed = button_down? Gosu::KbRight
      @left_arrow_pressed = button_down? Gosu::KbLeft
      @down_arrow_pressed = button_down? Gosu::KbDown
      @up_arrow_pressed = button_down? Gosu::KbUp
      @home_pressed = button_down? Gosu::KbHome
      @end_pressed = button_down? Gosu::KbEnd
      @right_shift_pressed = button_down? Gosu::KbRightShift
      @left_shift_pressed = button_down? Gosu::KbLeftShift
      @shift_pressed = @right_shift_pressed || @left_shift_pressed
      @control_pressed = (button_down? Gosu::KbRightControl) || (button_down? Gosu::KbLeftControl)
      @c_pressed = button_down? Gosu::KbC
      @x_pressed = button_down? Gosu::KbX
      @v_pressed = button_down? Gosu::KbV

      #Compound keypresses
      @shift_and_control_pressed = @shift_pressed && @control_pressed
      @shift_and_control_not_pressed = !@shift_pressed && !@control_pressed

      @just_control_pressed = @control_pressed && !@shift_pressed
      @just_shift_pressed = @shift_pressed && !@control_pressed

      @just_right_arrow_pressed = @right_arrow_pressed && @shift_and_control_not_pressed
      @just_shift_right_arrow_pressed = @just_shift_pressed && @right_arrow_pressed

      @just_ctrl_right_arrow_pressed = @just_control_pressed && @right_arrow_pressed
      @ctrl_shift_right_arrow_pressed = @shift_and_control_pressed && @right_arrow_pressed

      @just_left_arrow_pressed = @left_arrow_pressed && @shift_and_control_not_pressed
      @ctrl_shift_left_arrow_pressed = @shift_and_control_pressed && @left_arrow_pressed

      @just_shift_left_arrow_pressed = @just_shift_pressed && @left_arrow_pressed
      @just_ctrl_left_arrow_pressed = @just_control_pressed && @left_arrow_pressed

      @just_home_pressed = @home_pressed && @shift_and_control_not_pressed

      @just_end_pressed = @end_pressed && @shift_and_control_not_pressed

      @just_up_arrow_pressed = @up_arrow_pressed && @shift_and_control_not_pressed

      @just_down_arrow_pressed = @down_arrow_pressed && @shift_and_control_not_pressed

      @ctrl_c_pressed = @c_pressed && @control_pressed
      @ctrl_x_pressed = @x_pressed && @control_pressed
      @ctrl_v_pressed = @v_pressed && @control_pressed
    end
    def query_keyboard_inputs
      #CTRL and right arrow pressed together
      if @just_ctrl_right_arrow_pressed
        @my_monkey.key_ctrl_right_arrow.queue_move
        @my_timer.restart
      end
      #CTRL and left arrow pressed together
      if @just_ctrl_left_arrow_pressed
        @my_monkey.key_ctrl_left_arrow.queue_move
        @my_timer.restart
      end
      #Home pressed
      if @just_home_pressed
        @my_monkey.key_home.queue_move
        @my_timer.restart
      end
      #End pressed
      if @just_end_pressed
        @my_monkey.key_end.queue_move
        @my_timer.restart
      end
      #Up arrow pressed
      if @just_up_arrow_pressed
        @my_monkey.key_up_or_down.up = true
        @my_monkey.key_up_or_down.queue_move
        @my_timer.restart
      end
      #Down arrow pressed
      if @just_down_arrow_pressed
        @my_monkey.key_up_or_down.up = false
        @my_monkey.key_up_or_down.queue_move
        @my_timer.restart
      end
      #Right arrow pressed
      if @just_right_arrow_pressed
        @my_monkey.key_right_arrow.queue_move
        @my_timer.restart
      end
      #Shift_right arrow pressed
      if @just_shift_right_arrow_pressed
        @my_monkey.key_shift_right_arrow.queue_move
        @my_timer.restart
      end


      #Left arrow pressed
      if @just_left_arrow_pressed
        @my_monkey.key_left_arrow.queue_move
        @my_timer.restart
      end
      #Ctrl-x pressed
      if @ctrl_x_pressed
        @my_monkey.word_matrix.delete_from_word_matrix(@my_monkey.current_row, 8, 5)
        @my_monkey.word_matrix.set_up_word_matrix
        @my_timer.restart
      end
      #Ctrl-v pressed
      if @ctrl_v_pressed
        @my_monkey.word_matrix.paste_chars_in_word_matrix(@my_monkey.current_row, @my_monkey.current_char_in_row_left_arm)
        @my_monkey.word_matrix.set_up_word_matrix
        #If the bananas were copied and a pasted is executed, change the corresponding booleans
        if @bananas_copied
          @bananas_copied = false
          #This will trigger new bananas to be created
          @bananas_pasted = true
        end
        @my_timer.restart
      end
      #Ctrl-c pressed
      if @ctrl_c_pressed
        #Add code: If copy location corresponsds to the banana location, set @bananas_copied trigger
        @bananas_copied = true
        @bananas_pasted = false
        @my_monkey.word_matrix.copied_word = ""
        @my_monkey.word_matrix.list_of_word_rows.each do |word_row|
          word_row.position_list.each do |position|
            if position.selected
              @my_monkey.word_matrix.copied_word += position.character
            end
          end
        end
        puts "copied_word " + @my_monkey.word_matrix.copied_word
        @my_timer.restart
      end
    end
    def draw_biceps
      #I need to put this in the Player class, but "draw_line" won't execute from there.
      my_color_yellow = Gosu::Color::YELLOW
      my_color_red = Gosu::Color::RED
      my_color_blue = Gosu::Color::BLUE

      #draw left bicep
      left_bicep_x = @my_monkey.arm_left.x - 10 + @game_board_x
      left_bicep_y = @my_monkey.arm_left.y + 11 + @game_board_y
      left_shoulder_x = @my_monkey.body.x - 20 + @game_board_x
      left_shoulder_y = @my_monkey.body.y - 8 + @game_board_y
      draw_line(left_bicep_x, left_bicep_y, my_color_yellow, left_shoulder_x, left_shoulder_y, my_color_yellow, 999)
      #draw right bicep
      right_bicep_x = @my_monkey.arm_right.x + 10 + @game_board_x
      right_bicep_y = @my_monkey.arm_right.y + 13 + @game_board_y
      right_shoulder_x = @my_monkey.body.x + 20 + @game_board_x
      right_shoulder_y = @my_monkey.body.y - 4 + @game_board_y
      draw_line(right_bicep_x, right_bicep_y, my_color_yellow, right_shoulder_x, right_shoulder_y, my_color_yellow, 999)
      cursor_height = 20
      #draw left cursor
      left_arm_x_pos = @my_monkey.arm_left.x + 5 + @game_board_x
      left_arm_y_pos = @my_monkey.arm_left.y - 20 + @game_board_y
      draw_line(left_arm_x_pos, left_arm_y_pos, my_color_red, left_arm_x_pos, left_arm_y_pos - cursor_height, my_color_red, 999)
      #draw right cursor
      right_arm_x = @my_monkey.arm_right.x - 3 + @game_board_x
      right_arm_y = @my_monkey.arm_right.y - 20 + @game_board_y
      draw_line(right_arm_x, right_arm_y, my_color_red, right_arm_x, right_arm_y - cursor_height, my_color_red, 999)
    end
    def draw_bananas
      get_word_length
      (@word_length - 0).times do |num_bananas|
        @banana_x_position_adjusted = @banana_x + (num_bananas + 1) * @my_monkey.word_matrix.char_width + @game_board_x + @my_monkey.word_matrix.text_start_x_offset
        @banana_image.draw(@banana_x_position_adjusted, @banana_y, ZOrder::Player)
      end
    end
    def draw_highlights
      #fix - do this for each row
      #Draw highlight if characters have been selected
      my_color_grey_tranparent = Gosu::Color::argb(130,255,255,255)
      @position_index = -1
      @my_monkey.word_matrix.list_of_word_rows[@my_monkey.current_row].position_list.each do |position|
        @position_index += 1
        if position.selected
          y_adder = - 43
          row_height = 26

          p1x = @position_index * @my_monkey.word_matrix.char_width + @game_board_x + @my_monkey.word_matrix.text_start_x_offset
          p1y = @my_monkey.arm_left.y + y_adder + @game_board_y

          p2x = (@position_index + 1) * @my_monkey.word_matrix.char_width + @game_board_x + @my_monkey.word_matrix.text_start_x_offset
          p2y = @my_monkey.arm_right.y + y_adder + @game_board_y

          p3x = @position_index * @my_monkey.word_matrix.char_width + @game_board_x + @my_monkey.word_matrix.text_start_x_offset
          p3y = @my_monkey.arm_left.y + row_height + y_adder + @game_board_y

          p4x = (@position_index + 1) * @my_monkey.word_matrix.char_width + @game_board_x + @my_monkey.word_matrix.text_start_x_offset
          p4y = @my_monkey.arm_left.y + row_height + y_adder + @game_board_y

          draw_quad(p1x, p1y, my_color_grey_tranparent, p2x, p2y, my_color_grey_tranparent, p3x, p3y, my_color_grey_tranparent, p4x,p4y, my_color_grey_tranparent, z = 999, mode = :default)
        end
      end
    end
    def create_banana_locations
      #Reset the trigger that causes the bananas to be pasted
      @max_row = @word_matrix.list_of_word_rows.length - 1
      @banana_row = Random.new.rand(0...@max_row)
      @max_word = @word_matrix.list_of_word_rows[@banana_row].word_list.length - 0
      if @max_word <= 0 then @max_word = 1 end # I'm not sure why I need this for word, but not row
      @banana_word = Random.new.rand(0...@max_word)

      get_word_start_location
      @banana_x = @char_number * @my_monkey.word_matrix.char_width - 14 #@my_monkey.word_matrix.text_start_x_offset - 85
      @banana_y = @banana_row * @my_monkey.word_matrix.row_spacing + @my_monkey.word_matrix.first_line_y_start + 16
    end

    def get_word_length
      @word_length = 0
      @word_matrix.list_of_word_rows[@banana_row].position_list.each do |position|
        if position.word_number == @banana_word
          @word_length += 1
        end
      end
    end
    def get_word_start_location
      @char_number = -1
      @word_matrix.list_of_word_rows[@banana_row].position_list.each do |position|
        @char_number += 1
        if position.word_number == @banana_word then break end
      end
    end
  ##### End
  def button_down(id)
    close if id == Gosu::KbEscape
  end
end

window = GameWindow.new
window.show
