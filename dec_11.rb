class IntComp
  PARAM_MODE_POSITION = 0
  PARAM_MODE_IMMEDIATE = 1
  PARAM_MODE_RELATIVE = 2

  OPCODE_ADD = 1
  OPCODE_MULT = 2
  OPCODE_INPUT = 3
  OPCODE_OUTPUT = 4
  OPCODE_JUMP_IF_TRUE = 5
  OPCODE_JUMP_IF_FALSE = 6
  OPCODE_LESS_THAN = 7
  OPCODE_EQUALS = 8
  OPCODE_ADJUST_RELATIVE_BASE = 9
  OPCODE_HALT = 99

  def initialize(in_code_array, input_array)
    @code_array = in_code_array.dup
    @cursor_pos = 0
    @relative_base = 0

    @input_array = input_array.dup
    @output_array = []

    @is_paused = false
    @is_halted = false
  end

  def is_paused?
    return @is_paused
  end

  def is_halted?
    return @is_halted
  end

  def is_running?
    !is_paused? && !is_halted?
  end

  def unpause
    @is_paused = false
  end

  def pos_for_param_and_mode(in_param_pos, in_param_mode)
    return in_param_pos if in_param_mode == PARAM_MODE_IMMEDIATE
    the_pos = @code_array[in_param_pos]
    the_pos += @relative_base if in_param_mode == PARAM_MODE_RELATIVE
    the_pos
  end

  def process_instruction
    the_instruction = @code_array[@cursor_pos]
    the_opcode = the_instruction % 100

    # position modes:
    param1_mode = param2_mode = param3_mode = PARAM_MODE_POSITION # default: position mode
    param1_mode = (the_instruction / 100) % 10
    param2_mode = (the_instruction / 1000) % 10
    param3_mode = (the_instruction / 10000) % 10

    if the_opcode == OPCODE_HALT
      puts "HALT"
      @is_halted = true
      return
    end

    if the_opcode == OPCODE_ADD
      pos1 = pos_for_param_and_mode(@cursor_pos + 1, param1_mode)
      pos2 = pos_for_param_and_mode(@cursor_pos + 2, param2_mode)
      pos3 = pos_for_param_and_mode(@cursor_pos + 3, param3_mode)

      @code_array[pos1] ||= 0
      @code_array[pos2] ||= 0
      @code_array[pos3] = @code_array[pos1] + @code_array[pos2]
      @cursor_pos += 4
    elsif the_opcode == OPCODE_MULT
      pos1 = pos_for_param_and_mode(@cursor_pos + 1, param1_mode)
      pos2 = pos_for_param_and_mode(@cursor_pos + 2, param2_mode)
      pos3 = pos_for_param_and_mode(@cursor_pos + 3, param3_mode)

      @code_array[pos1] ||= 0
      @code_array[pos2] ||= 0
      @code_array[pos3] = @code_array[pos1] * @code_array[pos2]
      @cursor_pos += 4
    elsif the_opcode == OPCODE_INPUT
      if @input_array.size == 0
        @is_paused = true
        return
      end
      pos1 = pos_for_param_and_mode(@cursor_pos + 1, param1_mode)
      @code_array[pos1] = @input_array.shift
      @cursor_pos += 2
    elsif the_opcode == OPCODE_OUTPUT
      pos1 = pos_for_param_and_mode(@cursor_pos + 1, param1_mode)
      @output_array << @code_array[pos1]
      # puts "--> #{@code_array[pos1]}"
      @cursor_pos += 2
      # @is_paused = true
    elsif the_opcode == OPCODE_JUMP_IF_TRUE
      pos1 = pos_for_param_and_mode(@cursor_pos + 1, param1_mode)
      pos2 = pos_for_param_and_mode(@cursor_pos + 2, param2_mode)

      @code_array[pos1] ||= 0
      @code_array[pos2] ||= 0
      @cursor_pos = (@code_array[pos1] != 0 ? @code_array[pos2] : @cursor_pos + 3)
    elsif the_opcode == OPCODE_JUMP_IF_FALSE
      pos1 = pos_for_param_and_mode(@cursor_pos + 1, param1_mode)
      pos2 = pos_for_param_and_mode(@cursor_pos + 2, param2_mode)

      @code_array[pos1] ||= 0
      @code_array[pos2] ||= 0
      @cursor_pos = (@code_array[pos1] == 0 ? @code_array[pos2] : @cursor_pos + 3)
    elsif the_opcode == OPCODE_LESS_THAN
      pos1 = pos_for_param_and_mode(@cursor_pos + 1, param1_mode)
      pos2 = pos_for_param_and_mode(@cursor_pos + 2, param2_mode)
      pos3 = pos_for_param_and_mode(@cursor_pos + 3, param3_mode)

      @code_array[pos1] ||= 0
      @code_array[pos2] ||= 0
      @code_array[pos3] = @code_array[pos1] < @code_array[pos2] ? 1 : 0
      @cursor_pos += 4
    elsif the_opcode == OPCODE_EQUALS
      pos1 = pos_for_param_and_mode(@cursor_pos + 1, param1_mode)
      pos2 = pos_for_param_and_mode(@cursor_pos + 2, param2_mode)
      pos3 = pos_for_param_and_mode(@cursor_pos + 3, param3_mode)

      @code_array[pos1] ||= 0
      @code_array[pos2] ||= 0
      @code_array[pos3] = @code_array[pos1] == @code_array[pos2] ? 1 : 0
      @cursor_pos += 4
    elsif the_opcode == OPCODE_ADJUST_RELATIVE_BASE
      pos1 = pos_for_param_and_mode(@cursor_pos + 1, param1_mode)

      @code_array[pos1] ||= 0
      @relative_base += @code_array[pos1]
      @cursor_pos += 2
    else
      @is_halted = true
    end
  end

  def add_input(the_input)
    @input_array << the_input
  end

  # output array is kept: this does not provide protection against reading the same value multiple times
  def last_output
    return @output_array[-1]
  end

  # output array is kept: this does not provide protection against reading the same value multiple times
  def last_color_output
    return @output_array[-2]
  end

  # output array is kept: this does not provide protection against reading the same value multiple times
  def last_turn_output
    return @output_array[-1]
  end
end

class Robot
  DIRECTION_UP = 0
  DIRECTION_RIGHT = 1
  DIRECTION_DOWN = 2
  DIRECTION_LEFT = 3

  def initialize()
    @painted_hash = {}
    @x_pos = 0
    @y_pos = 0
    @direction = DIRECTION_UP
  end

  def get_current_color
    the_key = "#{@x_pos}_#{@y_pos}"
    if @painted_hash.key?(the_key)
      return @painted_hash[the_key]
    end
    if @x_pos == 0 && @y_pos == 0 # part 2: first pixel is white
      return 1
    end
    return 0
  end

  def move_one_step
    if @direction == DIRECTION_UP
      @y_pos -= 1
    elsif @direction == DIRECTION_RIGHT
      @x_pos += 1
    elsif @direction == DIRECTION_DOWN
      @y_pos += 1
    elsif @direction == DIRECTION_LEFT
      @x_pos -= 1
    end
  end

  def process_instruction(in_color, in_turn)
    the_key = "#{@x_pos}_#{@y_pos}"
    @painted_hash[the_key] = in_color
    # turn 
    @direction += (in_turn == 0 ? -1 : 1)
    @direction = DIRECTION_LEFT if @direction < DIRECTION_UP
    @direction = DIRECTION_UP if @direction > DIRECTION_LEFT
    move_one_step
  end

  def painted_squares_count
    @painted_hash.length
  end

  def output_image
    min_x = min_y = max_x = max_y = nil
    @painted_hash.each_key do |the_key|
      the_key_x, the_key_y = the_key.split("_").map(&:to_i)
      min_x = the_key_x if min_x.nil? || the_key_x < min_x
      max_x = the_key_x if max_x.nil? || the_key_x > max_x
      min_y = the_key_y if min_y.nil? || the_key_y < min_y
      max_y = the_key_y if max_y.nil? || the_key_y > max_y
    end

    (min_y..max_y).each do |row|
      the_row = ""
      (min_x..max_x).each do |col|
        the_key = "#{col}_#{row}"
        if @painted_hash.key?(the_key)
          the_row += (@painted_hash[the_key] == 0 ? " " : "#")
        else
          the_row += " "
        end
      end
      puts the_row
    end
  end
end


the_amp = IntComp.new(File.read("dec_11_input.txt").chomp.split(",").map(&:to_i), [])
the_robot = Robot.new

# the_robot.process_instruction(1,0)
# the_robot.process_instruction(0,0)
# the_robot.process_instruction(1,0)
# the_robot.process_instruction(1,0)
# the_robot.process_instruction(0,1)
# the_robot.process_instruction(1,0)
# the_robot.process_instruction(1,0)
# puts "Painted some squares: #{the_robot.painted_squares_count}" # should be six

puts "=" * 20

while !the_amp.is_halted?
  the_amp.add_input(the_robot.get_current_color)
  the_amp.unpause
  while !the_amp.is_paused? && !the_amp.is_halted?
    the_amp.process_instruction
  end
  the_robot.process_instruction(the_amp.last_color_output, the_amp.last_turn_output)
end
puts "Painted some squares: #{the_robot.painted_squares_count}"

puts "=" * 20

# part 2
the_robot.output_image

__END__
