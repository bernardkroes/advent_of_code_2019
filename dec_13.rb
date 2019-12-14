class IntComp
  attr_reader :output_array

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
      @cursor_pos += 2
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

  def clear_output_array
    @output_array = []
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

# returns paddle_x and ball_x
def output_image(hash_image)
  puts "\e[H\e[2J" # clear the terminal for more fun

  output_chars = " #=_O"
  paddle_x = ball_x = 0
  min_x = min_y = max_x = max_y = nil
  hash_image.each_key do |the_key|
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
      if hash_image.key?(the_key)
        the_row += output_chars[hash_image[the_key]]
        if hash_image[the_key] == 3
          paddle_x = col
        elsif hash_image[the_key] == 4
          ball_x = col
        end
      else
        the_row += " "
      end
    end
    puts the_row
  end
  return paddle_x, ball_x
end

the_input_codes = File.read("dec_13_input.txt").chomp.split(",").map(&:to_i)
the_input_codes[0] = 2 # free games
the_amp = IntComp.new(the_input_codes, [])

the_last_score = 0
the_tiles = {}
while !the_amp.is_halted?
  the_amp.unpause
  while !the_amp.is_paused? && !the_amp.is_halted?
    the_amp.process_instruction
  end

  the_amp.output_array.each_slice(3) do |the_slice|
    if the_slice[0] == -1 && the_slice[1] == 0 # segment display
      the_last_score = the_slice[2]
    else
      the_tiles["#{the_slice[0]}_#{the_slice[1]}"] = the_slice[2]
    end
  end
  if the_last_score > 5088
    exit
  end
  the_amp.clear_output_array
  paddle_x, ball_x = output_image(the_tiles)

  # decide on joystick move
  the_amp.add_input(ball_x <=> paddle_x)
end
puts "Score: #{the_last_score}"

# part 1 leftovers
# count the block tiles
# the_block_count = 0
# the_tiles.each_pair do |key, value|
#   the_block_count += 1 if value == 2
# end
# puts the_block_count

__END__
