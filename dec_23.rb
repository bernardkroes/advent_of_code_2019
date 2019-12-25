class IntComp
  attr_reader :output_array, :input_array

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
    @is_idle_inputting = false
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

  def reset_is_idle_inputting
    @is_idle_inputting = false
  end

  def is_idle_inputting?
    return @is_idle_inputting
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
      if @input_array.size > 0
        the_input = @input_array.shift
      else
        the_input = -1
        @is_idle_inputting = true
      end
      pos1 = pos_for_param_and_mode(@cursor_pos + 1, param1_mode)
      @code_array[pos1] = the_input
      @cursor_pos += 2
    elsif the_opcode == OPCODE_OUTPUT
      pos1 = pos_for_param_and_mode(@cursor_pos + 1, param1_mode)
      @output_array << @code_array[pos1]
      puts "output #{@code_array[pos1]}"
      @is_idle_inputting = false
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
    @is_idle_inputting = true
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

the_input_codes = File.read("dec_23_input.txt").chomp.split(",").map(&:to_i)
nics = []

50.times do |i|
  nics << IntComp.new(the_input_codes, [i])
end

# run all nics
the_nat_x = the_nat_y = nil
nat_sent = []
while true
  all_idle = true
  50.times do |i|
    nics[i].process_instruction
    if nics[i].output_array.size == 3
      the_dest = nics[i].output_array[0]
      the_x = nics[i].output_array[1]
      the_y = nics[i].output_array[2]
      if the_dest == 255 # NAT
        the_nat_x = the_x
        the_nat_y = the_y
        puts "NAT SET: #{the_x} #{the_y}"
      else
        nics[the_dest].add_input(the_x)
        nics[the_dest].add_input(the_y)
      end
      nics[i].clear_output_array
    end
    if nics[i].is_idle_inputting?
      # puts "IDLE: #{i}"
    end
    all_idle = false if !nics[i].is_idle_inputting?
  end
  50.times do |i|
    if nics[i].output_array.size > 0 || nics[i].input_array.size > 0
      all_idle = false
    end
  end
  if all_idle && !the_nat_x.nil? && !the_nat_y.nil?
    nics[0].add_input(the_nat_x)
    nics[0].add_input(the_nat_y)
    puts "NAT SENT: #{the_nat_x} #{the_nat_y}"
    50.times { |i| nics[i].reset_is_idle_inputting }
    if nat_sent.size > 1 && (nat_sent[-1][1] == the_nat_y)
      puts nat_sent.inspect
      puts "NAT sent Y: #{the_nat_y} twice in a row"
      exit
    end
    nat_sent << [the_nat_x, the_nat_y]
  end
end
