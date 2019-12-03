def process(in_array, in_cursor_pos)
  the_opcode = in_array[in_cursor_pos]

  if the_opcode == 99 # HALT
    return false
  end

  pos1 = in_array[in_cursor_pos + 1]
  pos2 = in_array[in_cursor_pos + 2]
  pos3 = in_array[in_cursor_pos + 3]

  if the_opcode == 1 # add
    the_result = in_array[pos1] + in_array[pos2]
  elsif the_opcode == 2 # multiply
    the_result = in_array[pos1] * in_array[pos2]
  end
  in_array[pos3] = the_result
  return true
end

the_wanted_output = 19690720

0.upto(99) do |noun|
  0.upto(99) do |verb|
    # init / reset memory
    all_codes_array = File.read("2_intcode_input_orig.txt").chomp.split(",").map(&:to_i)
    the_cursor_pos = 0

    all_codes_array[1] = noun
    all_codes_array[2] = verb

    should_continue = true
    while should_continue do
      should_continue = process(all_codes_array, the_cursor_pos)
      the_cursor_pos += 4 if should_continue
    end
    if all_codes_array[0] == the_wanted_output
      puts "FOUND"
      puts all_codes_array.inspect
      puts "Noun: #{noun} - Verb: #{verb}"
      exit
    end

  end
end
