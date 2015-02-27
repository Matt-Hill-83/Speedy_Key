require 'gosu'
class Player
  ####################### Accessors #############################
    attr_accessor :x,
    :y,
    :x_direction,
    :y_direction,
    :x_increment,
    :y_increment,
    :image,
    :current_row,
    :current_word_in_row_right_arm, # delete
    :current_word_in_row_left_arm,  # delete
    :current_char_in_row_right_arm,
    :current_char_in_row_left_arm,
    :word_matrix,
    :body_image_path,
    :arm_left_image_path,
    :arm_right_image_path,
    :arm_right,
    :arm_left,
    :color,
    :body,
    :key_right_arrow,
    :key_shift_right_arrow,
    :key_left_arrow,
    :key_ctrl_right_arrow,
    :key_ctrl_left_arrow,
    :key_home,
    :key_end,
    :key_up_or_down,
    :key_down,
    :previous_keystroke,
    :queued_methods_to_execute,
    :game_board_x,
    :game_board_y
    ##### End
  def initialize(window)
    @current_row = nil
    @current_word_in_row_right_arm = 0
    @current_word_in_row_left_arm = 0
    @current_char_in_row_right_arm = 0
    @current_char_in_row_left_arm = 0
    @word_matrix = nil
    @arm_left_image_path = nil
    @arm_right_image_path = nil
    @body_image_path = nil
    @window = window

    @color = Gosu::Color.new(0xff000000)
    @color.red = 80
    @color.green = 73
    @color.blue = 5
    @previous_keystroke = "none"
    @hilighting_is_on = false
    @hilighting_start_position_x = nil
    @hilighting_start_position_y = nil
    #Create new keystroke objects
    @key_right_arrow = Right_arrow.new(self)
    @key_shift_right_arrow = Shift_right_arrow.new(self)

    @key_left_arrow = Left_arrow.new(self)
    @key_ctrl_right_arrow = Ctrl_right_arrow.new(self)
    @key_ctrl_left_arrow = Ctrl_left_arrow.new(self)
    @key_home = Key_home.new(self)
    @key_end = Key_end.new(self)
    @key_up_or_down = Key_up_or_down.new(self)

    #Can I set these in the subclass definition?
    @key_right_arrow.keystroke_name = "right_arrow"
    @key_shift_right_arrow.keystroke_name = "shift_right_arrow"
    @key_left_arrow.keystroke_name = "left_arrow"

    @key_ctrl_right_arrow.keystroke_name = "ctrl_right_arrow"
    @key_ctrl_left_arrow.keystroke_name = "ctrl_left_arrow"
    @key_home.keystroke_name = "key_home"
    @key_end.keystroke_name = "key_end"
    @key_up_or_down.keystroke_name = "key_up_or_down"

    ############################## Init other variables #########################
    @vertical_move_direction = 1
    @x_adder_when_left_and_right_arms_colocated = 10
    @queued_methods_to_execute = []
    @game_board_x = 0
    @game_board_y = 0
    ##### End
  end
  ############################## Set up monkey #########################
    def set_start_position
      @arm_left.x = @current_char_in_row_right_arm * @word_matrix.char_width
      @arm_left.y = @current_row * @word_matrix.row_spacing  + @word_matrix.first_line_y_start
      @arm_right.x = @arm_left.x + @x_adder_when_left_and_right_arms_colocated
      @arm_right.y = @arm_left.y
    end
    def load_images
      @arm_left = BodyPart.new(@window, arm_left_image_path, @game_board_x, @game_board_y)
      @arm_right = BodyPart.new(@window, arm_right_image_path, @game_board_x, @game_board_y)
      @body = BodyPart.new(@window, body_image_path, @game_board_x, @game_board_y)
    end
  ##### End
  def move_monkey_body
    @body.x = (@arm_right.x - @arm_left.x)/2 + @arm_left.x - 0
    @body.y = [@arm_left.y, @arm_right.y].min + 50;
  end
  def draw
    execute_queued_methods
    @arm_right.draw
    @arm_left.draw
    move_monkey_body
    @body.draw
  end
  def execute_queued_methods
    #Execute only the methods in the queue at this moment
    #More methods will be added as each method executes
    #If there are methods in the queue, pop them from the front of the queue (using shift) and execute them.
    queue_length = @queued_methods_to_execute.length
    if queue_length > 0
      for iteration in 0..queue_length -1
        @queued_methods_to_execute.shift.call
      end
    end
  end
end

class BodyPart
  attr_accessor :x, :y, :image_path, :image, :game_board_x, :game_board_y
  def initialize(window,image_path, game_board_x, game_board_y)
    @x = 0
    @y = 0
    @game_board_x = game_board_x
    @game_board_y = game_board_y
    @image = Gosu::Image.new(window, image_path, false)
  end
  def draw
    # puts " -------------------------------x,y: " + @game_board_x.to_s + " " + @game_board_y.to_s
    @image.draw_rot(@x + @game_board_x, @y + @game_board_y, ZOrder::Player,0)
  end
end


# asdfsaf    asf   asfdsadf   asfd asfd asfd
