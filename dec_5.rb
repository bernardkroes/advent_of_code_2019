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

THE_NOT_SO_MANUAL_INPUT = 5

# returns the next cursor pos
def process(in_array, in_cursor_pos)
  the_instruction = in_array[in_cursor_pos]
  the_opcode = the_instruction % 100

  # position modes:
  param1_mode = param2_mode = param3_mode = PARAM_MODE_POSITION # default: position mode
  param1_mode = (the_instruction / 100) % 10
  param2_mode = (the_instruction / 1000) % 10
  param3_mode = (the_instruction / 10000) % 10

  if the_opcode == OPCODE_HALT
    puts "HALT"
    return 0
  end

  if the_opcode == OPCODE_ADD
    pos1 = param1_mode == PARAM_MODE_POSITION ? in_array[in_cursor_pos + 1] : in_cursor_pos + 1
    pos2 = param2_mode == PARAM_MODE_POSITION ? in_array[in_cursor_pos + 2] : in_cursor_pos + 2
    pos3 = param3_mode == PARAM_MODE_POSITION ? in_array[in_cursor_pos + 3] : in_cursor_pos + 3

    in_array[pos3] = in_array[pos1] + in_array[pos2]
    return in_cursor_pos + 4
  elsif the_opcode == OPCODE_MULT
    pos1 = param1_mode == PARAM_MODE_POSITION ? in_array[in_cursor_pos + 1] : in_cursor_pos + 1
    pos2 = param2_mode == PARAM_MODE_POSITION ? in_array[in_cursor_pos + 2] : in_cursor_pos + 2
    pos3 = param3_mode == PARAM_MODE_POSITION ? in_array[in_cursor_pos + 3] : in_cursor_pos + 3

    in_array[pos3] = in_array[pos1] * in_array[pos2]
    return in_cursor_pos + 4
  elsif the_opcode == OPCODE_INPUT
    pos1 = param1_mode == PARAM_MODE_POSITION ? in_array[in_cursor_pos + 1] : in_cursor_pos + 1
    in_array[pos1] = THE_NOT_SO_MANUAL_INPUT
    return in_cursor_pos + 2
  elsif the_opcode == OPCODE_OUTPUT
    pos1 = param1_mode == PARAM_MODE_POSITION ? in_array[in_cursor_pos + 1] : in_cursor_pos + 1
    puts "Output: #{in_array[pos1]}"
    return in_cursor_pos + 2
  elsif the_opcode == OPCODE_JUMP_IF_TRUE
    pos1 = param1_mode == PARAM_MODE_POSITION ? in_array[in_cursor_pos + 1] : in_cursor_pos + 1
    pos2 = param2_mode == PARAM_MODE_POSITION ? in_array[in_cursor_pos + 2] : in_cursor_pos + 2
    return in_array[pos1] != 0 ? in_array[pos2] : in_cursor_pos + 3
  elsif the_opcode == OPCODE_JUMP_IF_FALSE
    pos1 = param1_mode == PARAM_MODE_POSITION ? in_array[in_cursor_pos + 1] : in_cursor_pos + 1
    pos2 = param2_mode == PARAM_MODE_POSITION ? in_array[in_cursor_pos + 2] : in_cursor_pos + 2
    return in_array[pos1] == 0 ? in_array[pos2] : in_cursor_pos + 3
  elsif the_opcode == OPCODE_LESS_THAN
    pos1 = param1_mode == PARAM_MODE_POSITION ? in_array[in_cursor_pos + 1] : in_cursor_pos + 1
    pos2 = param2_mode == PARAM_MODE_POSITION ? in_array[in_cursor_pos + 2] : in_cursor_pos + 2
    pos3 = param3_mode == PARAM_MODE_POSITION ? in_array[in_cursor_pos + 3] : in_cursor_pos + 3

    in_array[pos3] = in_array[pos1] < in_array[pos2] ? 1 : 0
    return in_cursor_pos + 4
  elsif the_opcode == OPCODE_EQUALS
    pos1 = param1_mode == PARAM_MODE_POSITION ? in_array[in_cursor_pos + 1] : in_cursor_pos + 1
    pos2 = param2_mode == PARAM_MODE_POSITION ? in_array[in_cursor_pos + 2] : in_cursor_pos + 2
    pos3 = param3_mode == PARAM_MODE_POSITION ? in_array[in_cursor_pos + 3] : in_cursor_pos + 3

    in_array[pos3] = in_array[pos1] == in_array[pos2] ? 1 : 0
    return in_cursor_pos + 4
  end
  return 0
end

# tests:
# all_codes_array = [1002,4,3,4,33]
# all_codes_array = [3,9,8,9,10,9,4,9,99,-1,8]
# all_codes_array = [3,9,7,9,10,9,4,9,99,-1,8]
# all_codes_array = [3,3,1108,-1,8,3,4,3,99]
# all_codes_array = [3,3,1107,-1,8,3,4,3,99]
# all_codes_array = [3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9]
# all_codes_array = [3,3,1105,-1,9,1101,0,0,12,4,12,99,1]
# all_codes_array = [3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99]

all_codes_array = File.read("dec_5_input.txt").chomp.split(",").map(&:to_i)
the_cursor_pos = 0

while true do
  the_next_cursor_pos = process(all_codes_array, the_cursor_pos)
  if the_next_cursor_pos == 0
    exit
  end
  the_cursor_pos = the_next_cursor_pos
end
