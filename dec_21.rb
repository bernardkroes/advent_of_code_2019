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

  def show_robot_cleaner_output
    # puts "\e[H\e[2J" # clear the terminal for more fun
    the_row = ""
    output_array.each do |ch|
      if ch == 10
        puts the_row
        the_row = ""
      else
        the_row += ch.chr
      end
    end
    clear_output_array
  end
end
the_input_codes = File.read("dec_21_input.txt").chomp.split(",").map(&:to_i)
the_robot = IntComp.new(the_input_codes, [])

# part 1
# some hard thinking
the_robot_inputs = []
the_robot_inputs << "OR A J"
the_robot_inputs << "AND C J"
the_robot_inputs << "NOT J J"
the_robot_inputs << "AND D J"
the_robot_inputs << "WALK"

# part 2
# more hard thinking and some tinkering
the_robot_inputs = []
the_robot_inputs << "OR A J"
the_robot_inputs << "AND B J"
the_robot_inputs << "AND C J"
the_robot_inputs << "NOT J J"
the_robot_inputs << "AND D J"
the_robot_inputs << "OR E T"
the_robot_inputs << "OR H T"
the_robot_inputs << "AND T J"
the_robot_inputs << "RUN"

# run robot until it asks for instructions
the_robot.unpause
while !the_robot.is_paused? && !the_robot.is_halted?
  the_robot.process_instruction
end

# send instructions
the_robot_inputs.each do |inp|
  inp.each_char do |ch|
    the_robot.add_input(ch.ord)
  end
  the_robot.add_input(10) # newline

  # go robot go
  the_robot.unpause
  while !the_robot.is_paused? && !the_robot.is_halted?
    the_robot.process_instruction
  end
  if the_robot.is_halted?
    puts the_robot.last_output
  else
    the_robot.show_robot_cleaner_output
  end
end
