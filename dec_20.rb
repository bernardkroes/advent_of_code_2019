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
    @label_locations = {} # [ label_x, label_y (next to actual coord), actual_x, actual_y, level change of gate]
    @current_level = 0

    File.open(in_filename).each do |line|
      @map << line.chomp.split('')
    end
    find_all_label_locations
  end

  def find_all_label_locations
    # vertical labels starting on  line 0, 35, 94 and 129
    [0,35,94,129].each do |y|
      @map[y].each_with_index do |ch,x|
        if ch >= "A" && ch <= "Z"
          the_label = ch + @map[y+1][x]
          @label_locations[the_label] ||= []
          the_level_delta = 1
          if y == 0 || y == 129
            the_level_delta = -1
          end
          if y == 0 || y == 94
            @label_locations[the_label] << [x, y+1, x, y+2, the_level_delta]
          else
            @label_locations[the_label] << [x, y, x, y-1, the_level_delta]
          end
        end
      end
    end
    # horizontal labels starting in col 0, 35, 88 and 123
    @map.each_with_index do |line, y|
      [0, 35, 88, 123].each do |x|
        ch = @map[y][x]
        if ch >= "A" && ch <= "Z"
          the_label = ch + @map[y][x+1]
          @label_locations[the_label] ||= []
          the_level_delta = 1
          if x == 0 || x == 123
            the_level_delta = -1
          end
          if x == 0 || x == 88
            @label_locations[the_label] << [x+1,y,x+2,y,the_level_delta]
          else
            @label_locations[the_label] << [x,y,x-1,y,the_level_delta]
          end
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

  def is_warp_location?(x, y, the_level)
    @label_locations.each do |key, loc_array|
      loc_array.each_with_index do |loc, i|
        if (loc[0] == x) && (loc[1] == y)
          return false if the_level > 0 && ["AA","ZZ"].include?(key)
          return false if (the_level == 0) && (loc[4] < 0)
          return true
        end
      end
    end
    false
  end

  def is_wall_location?(x, y, the_level)
    return true if @map[y][x] == "#"
    @label_locations.each do |key, loc_array|
      loc_array.each_with_index do |loc, i|
        if (loc[0] == x) && (loc[1] == y)
          if the_level > 0 && ["AA","ZZ"].include?(key)
            return true
          end
          if the_level == 0 && (loc[4] < 0)
            return true
          end
        end
      end
    end
    false
  end

  def warp_move(x,y, the_level)
    # puts "warping! #{x} #{y} #{the_level}"
    @label_locations.each do |key, loc_array|
      loc_array.each_with_index do |loc, i|
        if (loc[0] == x) && (loc[1] == y)
          return [ loc_array[i-1][2], loc_array[i-1][3], the_level + loc_array[i][4]]
        end
      end
    end
    return [x,y, the_level]
  end

  def find_path_from_AA
    zz_label_location = @label_locations["ZZ"].first
    aa_label_location = @label_locations["AA"].first
    aa_location = [ aa_label_location[2], aa_label_location[3] ]
    the_current_level = 0
    paths = [aa_location + [the_current_level]]

    distances = { aa_location + [@current_level] => 0 } # store all the encountered distances [x,y,level] => dist
    edges = []
    while not paths.empty?
      # puts paths.inspect
      the_from_location = paths.shift
      # puts the_from_location.inspect
      from_x, from_y = the_from_location[0], the_from_location[1]
      the_current_level = the_from_location[2]
      the_prev_level = the_current_level
      DELTA_MOVES.each do |delta_x, delta_y|
        x = from_x + delta_x
        y = from_y + delta_y
        the_current_level = the_prev_level
        next if is_wall_location?(x, y, the_current_level)
        if is_warp_location?(x, y, the_current_level)
          warp_array = warp_move(x,y, the_current_level)
          x = warp_array[0]
          y = warp_array[1]
          the_current_level = warp_array[2]
        end
        next if @map[y][x] != "."
        next if distances.has_key?([x,y,the_current_level])
        distances[[x,y,the_current_level]] = distances[[from_x, from_y, the_prev_level]] + 1

        if x == zz_label_location[2] && y == zz_label_location[3] && the_current_level == 0
          puts "ZZ on level #{the_current_level}"
          puts distances[[zz_label_location[2],zz_label_location[3],the_current_level]]
          exit
        end
        paths << [x, y, the_current_level]
      end
    end
    puts distances.inspect
    puts zz_label_location.inspect
    puts distances[[zz_label_location[2],zz_label_location[3],0]]
  end
end

the_maze = Maze.new('dec_20_input.txt')
the_maze.find_path_from_AA
