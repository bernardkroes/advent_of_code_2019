class IntComp
  PARAM_MODE_POSITION = 0
  PARAM_MODE_IMMEDIATE = 1

  OPCODE_ADD = 1
  OPCODE_MULT = 2
  OPCODE_INPUT = 3
  OPCODE_OUTPUT = 4
  OPCODE_JUMP_IF_TRUE = 5
  OPCODE_JUMP_IF_FALSE = 6
  OPCODE_LESS_THAN = 7
  OPCODE_EQUALS = 8
  OPCODE_HALT = 99

  def initialize(in_code_array, input_array)
    @code_array = in_code_array.dup
    @input_array = input_array.dup
    @cursor_pos = 0
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

  # returns the next cursor pos
  def process_instruction
    the_instruction = @code_array[@cursor_pos]
    the_opcode = the_instruction % 100

    # position modes:
    param1_mode = param2_mode = param3_mode = PARAM_MODE_POSITION # default: position mode
    param1_mode = (the_instruction / 100) % 10
    param2_mode = (the_instruction / 1000) % 10
    param3_mode = (the_instruction / 10000) % 10

    if the_opcode == OPCODE_HALT
      # puts "HALT"
      @is_halted = true
      return
    end

    if the_opcode == OPCODE_ADD
      pos1 = param1_mode == PARAM_MODE_POSITION ? @code_array[@cursor_pos + 1] : @cursor_pos + 1
      pos2 = param2_mode == PARAM_MODE_POSITION ? @code_array[@cursor_pos + 2] : @cursor_pos + 2
      pos3 = param3_mode == PARAM_MODE_POSITION ? @code_array[@cursor_pos + 3] : @cursor_pos + 3

      @code_array[pos3] = @code_array[pos1] + @code_array[pos2]
      @cursor_pos += 4
    elsif the_opcode == OPCODE_MULT
      pos1 = param1_mode == PARAM_MODE_POSITION ? @code_array[@cursor_pos + 1] : @cursor_pos + 1
      pos2 = param2_mode == PARAM_MODE_POSITION ? @code_array[@cursor_pos + 2] : @cursor_pos + 2
      pos3 = param3_mode == PARAM_MODE_POSITION ? @code_array[@cursor_pos + 3] : @cursor_pos + 3

      @code_array[pos3] = @code_array[pos1] * @code_array[pos2]
      @cursor_pos += 4
    elsif the_opcode == OPCODE_INPUT
      pos1 = param1_mode == PARAM_MODE_POSITION ? @code_array[@cursor_pos + 1] : @cursor_pos + 1
      @code_array[pos1] = @input_array.shift
      @cursor_pos += 2
    elsif the_opcode == OPCODE_OUTPUT
      pos1 = param1_mode == PARAM_MODE_POSITION ? @code_array[@cursor_pos + 1] : @cursor_pos + 1
      @output_array << @code_array[pos1]
      @cursor_pos += 2
      @is_paused = true
    elsif the_opcode == OPCODE_JUMP_IF_TRUE
      pos1 = param1_mode == PARAM_MODE_POSITION ? @code_array[@cursor_pos + 1] : @cursor_pos + 1
      pos2 = param2_mode == PARAM_MODE_POSITION ? @code_array[@cursor_pos + 2] : @cursor_pos + 2

      @cursor_pos = (@code_array[pos1] != 0 ? @code_array[pos2] : @cursor_pos + 3)
    elsif the_opcode == OPCODE_JUMP_IF_FALSE
      pos1 = param1_mode == PARAM_MODE_POSITION ? @code_array[@cursor_pos + 1] : @cursor_pos + 1
      pos2 = param2_mode == PARAM_MODE_POSITION ? @code_array[@cursor_pos + 2] : @cursor_pos + 2

      @cursor_pos = (@code_array[pos1] == 0 ? @code_array[pos2] : @cursor_pos + 3)
    elsif the_opcode == OPCODE_LESS_THAN
      pos1 = param1_mode == PARAM_MODE_POSITION ? @code_array[@cursor_pos + 1] : @cursor_pos + 1
      pos2 = param2_mode == PARAM_MODE_POSITION ? @code_array[@cursor_pos + 2] : @cursor_pos + 2
      pos3 = param3_mode == PARAM_MODE_POSITION ? @code_array[@cursor_pos + 3] : @cursor_pos + 3

      @code_array[pos3] = @code_array[pos1] < @code_array[pos2] ? 1 : 0
      @cursor_pos += 4
    elsif the_opcode == OPCODE_EQUALS
      pos1 = param1_mode == PARAM_MODE_POSITION ? @code_array[@cursor_pos + 1] : @cursor_pos + 1
      pos2 = param2_mode == PARAM_MODE_POSITION ? @code_array[@cursor_pos + 2] : @cursor_pos + 2
      pos3 = param3_mode == PARAM_MODE_POSITION ? @code_array[@cursor_pos + 3] : @cursor_pos + 3

      @code_array[pos3] = @code_array[pos1] == @code_array[pos2] ? 1 : 0
      @cursor_pos += 4
    else
      @is_halted = true
    end
  end

  def add_input(the_input)
    @input_array << the_input
  end

  def last_output
    return @output_array[-1]
  end
end

LAST_AMP = 4
the_max_output = 0
the_max_phase_setting = []

[5,6,7,8,9].permutation(5).each do |phase_setting|
  the_amps = []
  0.upto(LAST_AMP) do |amp_index|
    the_input_array = [phase_setting[amp_index]]
    the_input_array << 0 if amp_index == 0
    the_amps << IntComp.new(File.read("dec_7_input.txt").chomp.split(",").map(&:to_i), the_input_array)
  end

  active_amp = 0
  while !the_amps[LAST_AMP].is_halted? do
    the_amps[active_amp].unpause
    while the_amps[active_amp].is_running? do
      the_amps[active_amp].process_instruction
    end
    amp_output = the_amps[active_amp].last_output

    active_amp += 1
    active_amp = 0 if active_amp > LAST_AMP

    the_amps[active_amp].add_input(amp_output)
  end
  # check the last output of the last amp
  if the_amps[LAST_AMP].last_output > the_max_output
    the_max_output = the_amps[4].last_output
    the_max_phase_setting = phase_setting.dup
  end
end

puts "MAX found: #{the_max_output}"
puts "Phase setting: " + the_max_phase_setting.inspect
