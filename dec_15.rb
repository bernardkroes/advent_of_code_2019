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

class Droid
  attr_reader :direction, :walk_moves, :possible_moves, :backtracking, :x_pos, :y_pos

  DIRECTION_NORTH = 1
  DIRECTION_SOUTH = 2
  DIRECTION_WEST = 3
  DIRECTION_EAST = 4

  DELTA_MOVES = [[0,0],[0,-1],[0,1],[-1,0],[1,0]]

  def initialize()
    @map_hash = {}
    @x_pos = 0
    @y_pos = 0
    @direction = DIRECTION_NORTH

    @possible_moves = {}
    @walk_moves = []
    @backtracking = false
  end

  def get_current_color
    the_key = "#{@x_pos}_#{@y_pos}"
    if @map_hash.key?(the_key)
      return @map_hash[the_key]
    end
    return 0
  end

  def move_one_step
    if @direction == DIRECTION_NORTH
      @y_pos -= 1
    elsif @direction == DIRECTION_EAST
      @x_pos += 1
    elsif @direction == DIRECTION_SOUTH
      @y_pos += 1
    elsif @direction == DIRECTION_WEST
      @x_pos -= 1
    end
  end

  def move_one_step_back
    if @direction == DIRECTION_NORTH
      @y_pos += 1
    elsif @direction == DIRECTION_EAST
      @x_pos -= 1
    elsif @direction == DIRECTION_SOUTH
      @y_pos -= 1
    elsif @direction == DIRECTION_WEST
      @x_pos += 1
    end
  end

  def position_known?(in_x, in_y)
    @map_hash.key?("#{in_x}_#{in_y}")
  end

  def at_origin?
    (@x_pos == 0) && (@y_pos == 0)
  end

  def all_directions_known?
    (DIRECTION_NORTH..DIRECTION_EAST).each do |pos_dir|
      if !position_known?(@x_pos + DELTA_MOVES[pos_dir][0], @y_pos + DELTA_MOVES[pos_dir][1])
        return false
      end
    end
    true
  end

  def change_direction # counterclockwise
    (DIRECTION_NORTH..DIRECTION_EAST).each do |pos_dir|
      if !position_known?(@x_pos + DELTA_MOVES[pos_dir][0], @y_pos + DELTA_MOVES[pos_dir][1])
        @backtracking = false
        @direction = pos_dir
        return
      end
    end
    # all known, track back:
    @backtracking = true
    revert_direction
  end

  def revert_direction
    if @walk_moves[-1] == DIRECTION_NORTH
      @direction = DIRECTION_SOUTH
    elsif @walk_moves[-1] == DIRECTION_EAST
      @direction = DIRECTION_WEST
    elsif @walk_moves[-1] == DIRECTION_SOUTH
      @direction = DIRECTION_NORTH
    elsif @walk_moves[-1] == DIRECTION_WEST
      @direction = DIRECTION_EAST
    end
  end

  def process_instruction(in_instruction)
    if in_instruction == 0 # found a wall in the current direction, do not move
      move_one_step
      the_key = "#{@x_pos}_#{@y_pos}"
      @map_hash[the_key] = 1 unless @map_hash[the_key] == 2
      move_one_step_back
    elsif in_instruction == 1 # no wall, move
      the_orig_key = "#{@x_pos}_#{@y_pos}"
      @map_hash[the_orig_key] = 0 unless @map_hash[the_orig_key] == 2

      @walk_moves << @direction unless @backtracking
      move_one_step
      @walk_moves.pop if @backtracking

      # build a bi-directional graph
      the_dest_key = "#{@x_pos}_#{@y_pos}"
      @possible_moves[the_orig_key] ||= []
      @possible_moves[the_dest_key] ||= []
      @possible_moves[the_orig_key] << the_dest_key
      @possible_moves[the_dest_key] << the_orig_key
    elsif in_instruction == 2 # found the oxygen station
      the_key = "#{@x_pos}_#{@y_pos}"
      @map_hash[the_key] = 0 unless @map_hash[the_key] == 2

      @walk_moves << @direction unless @backtracking
      move_one_step

      the_key = "#{@x_pos}_#{@y_pos}"
      @map_hash[the_key] = 2

      @walk_moves.pop if @backtracking
    end
    change_direction
  end

  def output_image
    puts "\e[H\e[2J" # clear the terminal for more fun
    min_x = min_y = max_x = max_y = nil
    @map_hash.each_key do |the_key|
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
        if col == 0 && row == 0
          the_row += "O"
        elsif col == @x_pos && row == @y_pos
          the_row += "D"
        elsif @map_hash.key?(the_key)
          if @map_hash[the_key] == 2
            the_row += "*"
          else
            the_row += (@map_hash[the_key] == 0 ? "." : "#")
          end
        else
          the_row += " "
        end
      end
      puts the_row
    end
  end
end


the_input_codes = File.read("dec_15_input.txt").chomp.split(",").map(&:to_i)
the_amp = IntComp.new(the_input_codes, [])
the_droid = Droid.new

# find oxygen system first
the_output = the_step_count = 0
maze_known = false
the_oxygen_machine_hash_key = ""

while !(the_droid.at_origin? && the_droid.all_directions_known?)
  the_amp.unpause
  the_amp.add_input(the_droid.direction)
  while !the_amp.is_paused? && !the_amp.is_halted?
    the_amp.process_instruction
  end
  the_output = the_amp.last_output
  the_droid.process_instruction(the_output)
  the_droid.output_image
  the_oxygen_machine_hash_key = "#{the_droid.x_pos}_#{the_droid.y_pos}" if the_output == 2
  the_step_count += 1
end
the_droid.output_image

# fill the maze with oxygen
the_filled_hash = {}
the_droid.possible_moves.each { |key, value| the_filled_hash[key] = 0 }
the_filled_hash[the_oxygen_machine_hash_key] = 1

the_minute_count = 0
while the_filled_hash.any? { |k,v| v == 0 } # keep pumping oxygen
  the_newly_filled = []
  the_filled_hash.each do |key,value|
    the_newly_filled = the_newly_filled + the_droid.possible_moves[key] if value == 1
  end
  the_newly_filled.each { |dest_key| the_filled_hash[dest_key] = 1 }
  the_minute_count += 1
end
puts "Minutes: #{the_minute_count}"
