class Grid
  DELTA_MOVES = [[0,-1],[1,0],[0,1],[-1,0]]

  def initialize(in_filename)
    @map = []
    @next_map = []
    File.open(in_filename).each do |line|
      @map << line.chomp.split('')
    end
    @map_size = @map.size
  end

  def grid_at(in_x, in_y)
    if in_x < 0 || in_y < 0 || in_x >= @map_size || in_y >= @map_size
      return "."
    end
    return @map[in_y][in_x]
  end

  def delta_moves_for(in_x, in_y)
    DELTA_MOVES
  end

  def adjacent_count(in_x, in_y)
    the_count = 0
    delta_moves_for(in_x, in_y).each do |delta_x, delta_y|
      x = in_x + delta_x
      y = in_y + delta_y
      the_count += 1 if grid_at(x,y) == "#"
    end
    the_count
  end

  def output_map
    @map.each_with_index do |line, y|
      the_row = ""
      line.each_with_index do |ch,x|
        the_row = the_row + ch
      end
      puts the_row
    end
  end

  def conway_step
    @next_map = []
    0.upto(@map_size - 1) do |y|
      the_line = []
      0.upto(@map_size - 1) do |x|
        num_bugs = adjacent_count(x,y)
        if grid_at(x,y) == "#"
          if num_bugs != 1
            the_line << "."
          else
            the_line << "#"
          end
        else
          if (num_bugs == 1) || (num_bugs == 2)
            the_line << "#"
          else
            the_line << "."
          end
        end
      end
      @next_map << the_line
    end
    @map = @next_map.clone
  end

  def biodiversity
    the_sum = 0
    the_index = 1
    @map.each_with_index do |line, y|
      line.each_with_index do |ch, x|
        if grid_at(x,y) == "#"
          the_sum += the_index
        end
        the_index = the_index * 2
      end
    end
    the_sum
  end
end

class RecursiveGrid
  def initialize(in_filename)
    @levels = {}
    the_map = []
    File.open(in_filename).each do |line|
      the_map << line.chomp.split('')
    end
    @levels["l_0"] = the_map
    @map_size = the_map.size

    @delta_moves_hash = {}
    @delta_moves_hash["0_0"] = [ [ 2, 1,-1], [1, 0, 0], [0, 1, 0], [ 1, 2,-1] ]
    @delta_moves_hash["1_0"] = [ [ 2, 1,-1], [2, 0, 0], [1, 1, 0], [ 0, 0, 0] ]
    @delta_moves_hash["2_0"] = [ [ 2, 1,-1], [3, 0, 0], [2, 1, 0], [ 1, 0, 0] ]
    @delta_moves_hash["3_0"] = [ [ 2, 1,-1], [4, 0, 0], [3, 1, 0], [ 2, 0, 0] ]
    @delta_moves_hash["4_0"] = [ [ 2, 1,-1], [3, 2,-1], [4, 1, 0], [ 3, 0, 0] ]

    @delta_moves_hash["0_1"] = [ [ 0, 0, 0], [1, 1, 0], [0, 2, 0], [ 1, 2,-1] ]
    @delta_moves_hash["1_1"] = [ [ 1, 0, 0], [2, 1, 0], [1, 2, 0], [ 0, 1, 0] ]
    @delta_moves_hash["2_1"] = [ [ 2, 0, 0], [3, 1, 0],            [ 1, 1, 0] ] + [ [0,0,1], [1,0,1], [2,0,1], [3,0,1], [4,0,1] ]
    @delta_moves_hash["3_1"] = [ [ 3, 0, 0], [4, 1, 0], [3, 2, 0], [ 2, 1, 0] ]
    @delta_moves_hash["4_1"] = [ [ 4, 0, 0], [3, 2,-1], [4, 2, 0], [ 3, 1, 0] ]

    @delta_moves_hash["0_2"] = [ [ 0, 1, 0], [1, 2, 0], [0, 3, 0], [ 1, 2,-1] ]
    @delta_moves_hash["1_2"] = [ [ 1, 1, 0],            [1, 3, 0], [ 0, 2, 0] ] + [ [0,0,1], [0,1,1], [0,2,1], [0,3,1], [0,4,1] ]
    @delta_moves_hash["2_2"] = [ ]
    @delta_moves_hash["3_2"] = [ [ 3, 1, 0], [4, 2, 0], [3, 3, 0]             ] + [ [4,0,1], [4,1,1], [4,2,1], [4,3,1], [4,4,1] ]
    @delta_moves_hash["4_2"] = [ [ 4, 1, 0], [3, 2,-1], [4, 3, 0], [ 3, 2, 0] ]

    @delta_moves_hash["0_3"] = [ [ 0, 2, 0], [1, 3, 0], [0, 4, 0], [ 1, 2,-1] ]
    @delta_moves_hash["1_3"] = [ [ 1, 2, 0], [2, 3, 0], [1, 4, 0], [ 0, 3, 0] ]
    @delta_moves_hash["2_3"] = [             [3, 3, 0], [2, 4, 0], [ 1, 3, 0] ] + [ [0,4,1], [1,4,1], [2,4,1], [3,4,1], [4,4,1] ]
    @delta_moves_hash["3_3"] = [ [ 3, 2, 0], [4, 3, 0], [3, 4, 0], [ 2, 3, 0] ]
    @delta_moves_hash["4_3"] = [ [ 4, 2, 0], [3, 2,-1], [4, 4, 0], [ 3, 3, 0] ]

    @delta_moves_hash["0_4"] = [ [ 0, 3, 0], [1, 4, 0], [2, 3,-1], [ 1, 2,-1] ]
    @delta_moves_hash["1_4"] = [ [ 1, 3, 0], [2, 4, 0], [2, 3,-1], [ 0, 4, 0] ]
    @delta_moves_hash["2_4"] = [ [ 2, 3, 0], [3, 4, 0], [2, 3,-1], [ 1, 4, 0] ]
    @delta_moves_hash["3_4"] = [ [ 3, 3, 0], [4, 4, 0], [2, 3,-1], [ 2, 4, 0] ]
    @delta_moves_hash["4_4"] = [ [ 4, 3, 0], [3, 2,-1], [2, 3,-1], [ 3, 4, 0] ]
  end

  def grid_at(in_x, in_y, in_level)
    if @levels.has_key?("l_#{in_level}")
      if in_x < 0 || in_y < 0 || in_x >= @map_size || in_y >= @map_size
        return "."
      end
      return @levels["l_#{in_level}"][in_y][in_x]
    end
    return "."
  end

  def adjacent_count(in_x, in_y, in_level)
    the_count = 0
    @delta_moves_hash["#{in_x}_#{in_y}"].each do |delta_pos|
      x = delta_pos[0]
      y = delta_pos[1]
      lvl = in_level + delta_pos[2]
      the_count += 1 if grid_at(x,y,lvl) == "#"
    end
    the_count
  end

  def output_map
    @levels.each_pair do |key, value|
      the_level = key.gsub("l_","").to_i
      puts "LEVEL #{the_level}:"
      value.each_with_index do |line, y|
        the_row = ""
        line.each_with_index do |ch,x|
          the_row = the_row + ch
        end
        puts the_row
      end
    end
  end

  def conway_step
    next_levels = {}

    min_level = 0
    max_level = 0
    @levels.each_pair do |key, value|
      the_level = key.gsub("l_","").to_i
      min_level = the_level if the_level < min_level
      max_level = the_level if the_level > max_level
      the_next_map = []
      0.upto(@map_size - 1) do |y|
        the_line = []
        0.upto(@map_size - 1) do |x|
          num_bugs = adjacent_count(x,y, the_level)
          if grid_at(x,y, the_level) == "#"
            the_line << (num_bugs != 1 ? "." : "#")
          else
            the_line <<( ((num_bugs == 1) || (num_bugs == 2)) ? "#" : ".")
          end
        end
        the_next_map << the_line
      end
      next_levels["l_#{the_level}"] = the_next_map
    end
    # do min_level - 1 and max_level + 1 as well
    [min_level - 1, max_level + 1].each do |the_level|
      the_next_map = []
      0.upto(@map_size - 1) do |y|
        the_line = []
        0.upto(@map_size - 1) do |x|
          num_bugs = adjacent_count(x,y, the_level)
          if grid_at(x,y, the_level) == "#"
            the_line << (num_bugs != 1 ? "." : "#")
          else
            the_line <<( ((num_bugs == 1) || (num_bugs == 2)) ? "#" : ".")
          end
        end
        the_next_map << the_line
      end
      next_levels["l_#{the_level}"] = the_next_map
    end
    @levels = next_levels.clone
  end

  def alive_count
    the_count = 0
    @levels.each_pair do |key, value|
      value.each_with_index do |line|
        the_count += line.count("#")
      end
    end
    the_count
  end
end

# the_grid = Grid.new('dec_24_input.txt')
# all_diversities = []
# the_diversity = the_grid.biodiversity
# all_diversities << the_diversity
# while true
#   the_grid.conway_step
#   the_diversity = the_grid.biodiversity
#   if all_diversities.include?(the_diversity)
#     the_grid.output_map
#     puts "DUPLICATE: #{the_diversity}"
#     exit
#   end
#   all_diversities << the_diversity
# end

the_grid = RecursiveGrid.new('dec_24_input.txt')
200.times do |step|
  the_grid.conway_step
end
the_grid.output_map
puts "Bug count: #{the_grid.alive_count}"

__END__

1922 : too high
