the_file_input_signal = File.read("dec_16_input.txt").chomp.split('').map(&:to_i)

# the_input_signal = "80871224585914546619083218645595"
# the_file_input_signal = "03081770884921959731165446850517".split('').map(&:to_i)
# the_file_input_signal = "12345678".split('').map(&:to_i)

the_input_signal = the_file_input_signal * 10000
the_message_offset = the_file_input_signal[0..6].map(&:to_s).join().to_i

def phase_array_for_step(in_step)
  return [[0] * in_step, [1] * in_step, [0] * in_step, [-1] * in_step].flatten.rotate(1)
end

# brute force
def FFT(in_signal, phase_array)
  output_string = ""
  sum_i = 0
  in_signal.split('').each_with_index do |c,i|
      the_index = i % phase_array.length
    sum_i += (c.to_i * phase_array[the_index])
  end
  output_string += (sum_i.abs % 10).to_s
  output_string
end


# delta summing for the second half, input elems not valid anymore
def FFT2(in_signal, in_step, in_prev_sum)
  sum = 0
  the_start_index = in_step - 1
# add the next in_step numbers
  end_add_indices = the_start_index + in_step
  if end_add_indices > in_signal.size # we only need to add 'shortcut'
    end_add_indices = in_signal.size
    if in_prev_sum > 0 && the_start_index > 0
      sum = in_prev_sum - in_signal[the_start_index - 1]
      return sum.abs % 10, sum
    end
  end
  phase_array = phase_array_for_step(in_step)

  sum = in_signal[the_start_index..(end_add_indices-1)].inject(0){|sum,x| sum + x }
  if in_signal.size > end_add_indices
    the_phase_index = end_add_indices % (phase_array.size)
    in_signal[end_add_indices..-1].each_with_index do |val, i|
      the_phase = phase_array[the_phase_index]
      if the_phase == 1
        sum += val
      elsif the_phase == -1
        sum -= val
      end
      the_phase_index += 1
      the_phase_index = 0 if the_phase_index >= phase_array.size
    end
  else
    return sum.abs % 10, sum
  end
  return sum.abs % 10, 0
end

# collect all first attempt
def FFT3(in_signal, in_step)
  phase_array = phase_array_for_step(in_step)
  the_phase_array = phase_array * (in_signal.size / phase_array.size + 1)

  the_one_array = []
  the_minus_array = []
  sum = 0
  the_start_index = in_step - 1
  in_signal[the_start_index..-1].each_with_index do |val, i|
    the_phase = the_phase_array[the_start_index + i ]
    if the_phase != 0
      if the_phase == 1
        the_one_array << val
     elsif the_phase == -1
        the_minus_array << val
      end
    end
  end
  sum = the_one_array.inject(0){|sum,x| sum + x } - the_minus_array.inject(0){|sum,x| sum + x }
  sum.abs % 10
end

# loop over the pattern and not over the input - attempt
def FFT4(in_signal, in_step)
  the_signal_size = in_signal.size
  phase_array = phase_array_for_step(in_step)
  phase_array_size = phase_array.size

  the_start_index = in_step - 1 # skip the leading zeros
  sum = 0
  phase_array[the_start_index..-1].each_with_index do |val, i|
    if val != 0 && i < the_signal_size
      the_index = i + the_start_index
      part_sum = 0
      while the_index < the_signal_size
        part_sum += in_signal[the_index]
        the_index += phase_array_size
      end
      sum += (val * part_sum)
    end
  end
  sum.abs % 10
end


loop_input_signal = the_input_signal
1.upto(100) do |phase_step|
  the_output_array = [0] * loop_input_signal.size
  prev_sum = 0
  loop_input_signal.size.downto(1 + loop_input_signal.size / 2) do |step|
    the_output_array[step-1] = prev_sum + loop_input_signal[step-1]
    prev_sum = the_output_array[step-1]
  end
  loop_input_signal.size.downto(loop_input_signal.size / 2) do |step|
    the_output_array[step-1] = the_output_array[step-1] % 10
  end
  our_message_offset_is_not_in_the_second_half_of_the_array_and_we_need_to_calculate_the_first_half = false
  if our_message_offset_is_not_in_the_second_half_of_the_array_and_we_need_to_calculate_the_first_half
    1.upto(loop_input_signal.size / 2) do |step|
      the_sum = FFT4(loop_input_signal, step)
      the_output_array[step-1] = the_sum
      puts "-- step: #{step}" if step % 1000 == 0
    end
  end
  loop_input_signal = the_output_array
end

puts the_message_offset
puts loop_input_signal.size
puts loop_input_signal.size / 2

puts "-"
puts loop_input_signal[the_message_offset..the_message_offset + 7].join()
