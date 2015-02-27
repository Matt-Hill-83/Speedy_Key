require 'date'

class MyTimer
  #This timer lets you check to see whether a specified time has transpired in ms.
  #You can also reset the timer
  attr_accessor :keypress_delay_time_ms, :previous_keypress_time, :time_delta
  def initialize
    @previous_keypress_time = DateTime.now.strftime('%Q').to_i
    @keypress_delay_time_ms = 500
    @time_delta = 0
  end
  def restart
    @previous_keypress_time = DateTime.now.strftime('%Q').to_i
  end
  def time_is_complete
    @time_delta = DateTime.now.strftime('%Q').to_i - @previous_keypress_time
    result = @time_delta >= @keypress_delay_time_ms
  end
end