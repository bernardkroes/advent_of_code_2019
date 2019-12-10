class AsteroidMap
  def initialize(in_filename)
    @asteroid_map = []
    File.open(in_filename).each do |line|
      @asteroid_map << line.chomp
    end
    @size_x = @asteroid_map[0].size
    @size_y = @asteroid_map.size
  end

  def contains_asteroid?(in_x, in_y)
    return @asteroid_map[in_y][in_x] == "#"
  end

  def number_of_asteroids
    num_occupied = 0
    0.upto(@size_x-1) do |x|
      0.upto(@size_y-1) do |y|
        num_occupied += 1 if contains_asteroid?(x,y)
      end
    end
    num_occupied
  end

  def on_map?(in_x, in_y)
    in_x >= 0 && in_x < @size_x && in_y >= 0 && in_y < @size_y
  end

  def trace_visibility_line_on_map(in_map, in_x, in_y, in_step_x, in_step_y)
    the_multiplier = 1
    found_asteroid = false
    while on_map?(in_x + the_multiplier * in_step_x, in_y + the_multiplier * in_step_y)
      if !found_asteroid && (in_map[in_y + the_multiplier * in_step_y][in_x + the_multiplier * in_step_x] == "#")
        found_asteroid = true
      else
        if found_asteroid
          in_map[in_y + the_multiplier * in_step_y][in_x + the_multiplier * in_step_x] = "."
        end
      end
      the_multiplier += 1
    end
  end

  def get_visibility_map_for(in_x, in_y)
    visible_asteroids_map = Marshal.load(Marshal.dump(@asteroid_map)) # deep clone?

    # start sweeping squares until all corners out of bounds
    the_delta = 1
    # if any of the middel of the borders on the map, continue
    while on_map?(in_x, in_y - the_delta) || on_map?(in_x, in_y + the_delta) || on_map?(in_x - the_delta, in_y) || on_map?(in_x + the_delta, in_y)
      # sweep the borders
      (-the_delta..the_delta).each do |the_walk|
        # top border
        trace_visibility_line_on_map(visible_asteroids_map, in_x, in_y, the_walk, -the_delta) if on_map?(in_x + the_walk, in_y - the_delta)
        # bottom_border
        trace_visibility_line_on_map(visible_asteroids_map, in_x, in_y, the_walk, the_delta) if on_map?(in_x + the_walk, in_y + the_delta)
      end
      the_y_delta = the_delta -1 # avoid overlap
      (-the_y_delta..the_y_delta).each do |the_walk|
        # right border
        trace_visibility_line_on_map(visible_asteroids_map, in_x, in_y, -the_delta, the_walk) if on_map?(in_x - the_delta, in_y + the_walk)
        trace_visibility_line_on_map(visible_asteroids_map, in_x, in_y, the_delta, the_walk) if on_map?(in_x + the_delta, in_y + the_walk)
      end
      the_delta += 1
    end
    return visible_asteroids_map
  end

  def number_of_visible_asteroids_for(in_x, in_y)
    visible_asteroids_map = get_visibility_map_for(in_x, in_y)

    num_occupied = 0
    0.upto(@size_x-1) do |x|
      0.upto(@size_y-1) do |y|
        num_occupied += 1 if visible_asteroids_map[y][x] == "#"
      end
    end
    return num_occupied - 1 # exclude the station
  end

  def find_best_location
    max_visible_asteroids = 0

    0.upto(@size_y-1) do |y|
      0.upto(@size_x-1) do |x|
        if contains_asteroid?(x,y)
          the_num_visible_asteroids = number_of_visible_asteroids_for(x, y)
          # puts "Visible: #{the_num_visible_asteroids} from #{x}, #{y}"
          if the_num_visible_asteroids > max_visible_asteroids
            max_visible_asteroids = the_num_visible_asteroids
            puts "Max visible: #{max_visible_asteroids} from #{x}, #{y}"
          end
        end
      end
    end
    return max_visible_asteroids
  end
end

the_map = AsteroidMap.new('dec_10_input.txt')
the_map.find_best_location # check the last line of the output

# part 2
# find asteroid 200
# we only need to sweep once (there are more than 200 asteroids visible) so no need to lasersweep more than once (yay!)
# get visiblity map
the_station_x = 11
the_station_y = 11
visibility_map = the_map.get_visibility_map_for(the_station_x, the_station_y)
visibility_map[11][11] = "." # no need to laser ourselves

# gather coordinates
all_visible_asteroids = []
visibility_map.each_with_index do |line, y|
  x = 0
  line.each_char do |c|
    if c == '#'
      all_visible_asteroids << [x,y]
    end
    x += 1
  end
end

def angle_from_to(in_station, in_asteroid)
  delta_x = in_asteroid[0] - in_station[0]
  delta_y = in_asteroid[1] - in_station[1]

  the_angle = Math.atan2(delta_y, delta_x) + Math::PI/2
  the_angle += 2 * Math::PI if the_angle < 0
  return the_angle
end

# sort all of them by angle to us, take number 200
the_sorted_asteroids = all_visible_asteroids.sort do |ast1, ast2|
  angle_from_to([the_station_x, the_station_y], ast1) <=> angle_from_to([the_station_x, the_station_y], ast2)
end
puts the_sorted_asteroids[199].inspect

__END__

Max visible: 221 from 11, 11

