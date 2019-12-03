all_wirepaths_array = []
File.open('dec_3_input.txt').each do |line|
  the_wirepath_array = line.split(",")
  all_wirepaths_array << the_wirepath_array
end

# put it in a stupid hash
def occupy_grid(from_x, from_y, the_direction, the_distance, wire_index, the_base_steps, in_grid_hash)
  if the_direction.upcase == "U"
    the_step_x, the_step_y =  0, 1
  elsif the_direction.upcase == "D"
    the_step_x, the_step_y =  0, -1
  elsif the_direction.upcase == "L"
    the_step_x, the_step_y = -1, 0
  elsif the_direction.upcase == "R"
    the_step_x, the_step_y =  1, 0
  end
  the_walk_x, the_walk_y = from_x, from_y

  0.upto(the_distance - 1) do |the_step_num|
    the_key = "#{the_walk_x}_#{the_walk_y}"
    in_grid_hash[the_key] ||= [-1,-1]

    in_grid_hash[the_key][wire_index] = the_base_steps + the_step_num if in_grid_hash[the_key][wire_index] < 1

    the_walk_y += the_step_y
    the_walk_x += the_step_x
  end
  return the_walk_x, the_walk_y
end

the_grid_hash = Hash.new()
all_wirepaths_array.each_with_index do |wirepath, wire_index| # start walking
  x_pos = y_pos = the_wire_steps = 0

  wirepath.each do |move|
    the_direction = move[0] # first char
    the_distance = move[1..-1].to_i # rest

    new_x_pos, new_y_pos = occupy_grid(x_pos, y_pos, the_direction, the_distance, wire_index, the_wire_steps, the_grid_hash)
    the_wire_steps += the_distance

    x_pos = new_x_pos
    y_pos = new_y_pos
  end
end

# find shortest manhattan distance, we are only interested in grid_hash cells with two positive values in the value (array with steps of wire 0 and wire 1)
the_min_distance = -1
the_grid_hash.each_pair do |the_key, the_value|
  if the_value[0] > 0 && the_value[1] > 0
    the_distance = the_value[0] + the_value[1]
    if the_min_distance < 0 && the_distance > 0
      the_min_distance = the_distance
    elsif the_distance > 0 && the_distance < the_min_distance
      the_min_distance = the_distance
    end
  end
end
puts the_min_distance
