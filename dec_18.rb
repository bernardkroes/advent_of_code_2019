class Edge
  attr_accessor :name, :steps, :doors

  def initialize(in_name, in_doors, in_steps)
    @name = in_name
    @doors = in_doors
    @steps = in_steps
  end
end

class Maze
  DELTA_MOVES = [[0,-1],[1,0],[0,1],[-1,0]]

  def initialize(in_filename)
    @map = []
    @nodes = {}
    @key_locations = {}

    File.open(in_filename).each do |line|
      @map << line.chomp.split('')
    end
    find_all_key_locations
  end

  def find_all_key_locations
    startcount = 0
    @map.each_with_index do |line,y|
      line.each_with_index do |ch,x|
        if ch >= "a" && ch <= "z"
          @key_locations[ch] = [x,y]
        elsif ch == "@"
          @key_locations["@#{startcount}"] = [x,y]
          startcount += 1
        end
      end
    end
  end

  def output_maze
    @map.each_with_index do |line, y|
      the_row = ""
      line.each_with_index do |ch,x|
        the_row = the_row + ch
      end
      puts the_row
    end
  end

  def output_nodes
    @nodes.each_pair do |key, value|
      puts "From #{key}:"
      value.each do |edge|
        puts "-> #{edge.name} - #{edge.steps} - #{edge.doors.join}"
      end
    end
  end

  def show_keys
    puts @key_locations.inspect
  end

  def build_graph
    @key_locations.each do |key, location|
      paths = [ [location[0], location[1], []] ] # x, y, collected doors
      distances = { location => 0 } # store all the encountered distances [x,y] => dist
      edges = []
      while not paths.empty?
        from_x, from_y, doors = paths.shift
        DELTA_MOVES.each do |delta_x, delta_y|
          x = from_x + delta_x
          y = from_y + delta_y
          ch = @map[y][x]
          next if ch == "#"
          next if distances.has_key?([x,y])
          distances[[x,y]] = distances[[from_x,from_y]] + 1
          if ch >= "a" && ch <= "z"
            edges << Edge.new(ch, doors, distances[[x,y]])
          end
          if ch >= "A" && ch <= "Z"
            paths << [x, y, doors + [ch]]
          else
            paths << [x, y, doors]
          end
        end
      end
      @nodes[key] = edges
    end
  end

  # write your own:
  def reachable_keys(in_keypos_array, unlocked_doors = [])
    keys = []
    in_keypos_array.each_with_index do |from_key, i|
      @nodes[from_key].each do |edge|
        next if unlocked_doors.include?(edge.name.upcase)
        next unless (edge.doors - unlocked_doors).empty?
        keys << [ i, edge.name, edge.steps ]
      end
    end
    return keys
  end

  # walk all the (currently reachable) paths
  def min_steps(in_start_pos_array, unlocked_doors = [], cache = {})
    cache_hashkey = [in_start_pos_array.sort.join, unlocked_doors.sort.join]
    if not cache.has_key?(cache_hashkey)
      keys = reachable_keys(in_start_pos_array, unlocked_doors)
      if keys.empty?
        the_min_steps = 0
      else
        steps = []
        keys.each do |walk, key, distance|
          orig = in_start_pos_array[walk]
          in_start_pos_array[walk] = key
          steps << distance + min_steps(in_start_pos_array, unlocked_doors + [key.upcase], cache)
          in_start_pos_array[walk] = orig
        end
        the_min_steps = steps.min
      end
      cache[cache_hashkey] = the_min_steps
    end
    return cache[cache_hashkey]
  end
end

# the_maze = Maze.new('dec_18_input.txt')
# the_maze.show_keys
# the_maze.output_maze
# the_maze.build_graph
# the_maze.output_nodes

# the_start_pos_array = ["@"]
# puts the_maze.min_steps(the_start_pos_array)

the_maze2 = Maze.new('dec_18_input_part2.txt')
the_maze2.output_maze
the_maze2.build_graph
the_maze2.output_nodes
the_maze2.show_keys

the_start_pos_array = ["@0", "@1", "@2", "@3"]
puts the_maze2.min_steps(the_start_pos_array)

__END__
