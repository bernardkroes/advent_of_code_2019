class Moon
  attr_reader :x, :y, :z
  attr_reader :vel_x, :vel_y, :vel_z

  def initialize(in_x, in_y, in_z)
    @x = in_x
    @y = in_y
    @z = in_z

    @vel_x = @vel_y = @vel_z = 0
  end

  def update_position
    @x += @vel_x
    @y += @vel_y
    @z += @vel_z
  end

  # only one-way for now
  def update_velocity_for_moon(in_other_moon)
    if in_other_moon.x > @x
      @vel_x += 1
    elsif in_other_moon.x < @x
      @vel_x -= 1
    end

    if in_other_moon.y > @y
      @vel_y += 1
    elsif in_other_moon.y < @y
      @vel_y -= 1
    end

    if in_other_moon.z > @z
      @vel_z += 1
    elsif in_other_moon.z < @z
      @vel_z -= 1
    end
  end

  def kin_energy
    @vel_x.abs + @vel_y.abs + @vel_z.abs
  end

  def pot_energy
    @x.abs + @y.abs + @z.abs
  end

  def total_energy
    pot_energy * kin_energy
  end

  def show_info
    puts "#{@x}, #{@y}, #{@z} - vel: #{@vel_x}, #{@vel_y}, #{@vel_z} p: #{pot_energy}, k: #{kin_energy}"
  end

  # by dimension_index: x: 0, y:1, z:2
  def moon_state(in_dimension)
    return [@x, @vel_x] if in_dimension == 0
    return [@y, @vel_y] if in_dimension == 1
    return [@z, @vel_z] if in_dimension == 2
  end
end

moons = []

# testdata
# moons << Moon.new(-1,0,2)
# moons << Moon.new(2,-10,-7)
# moons << Moon.new(4,-8,8)
# moons << Moon.new(3,5,-1)

# my input:
moons << Moon.new(13,-13,-2)
moons << Moon.new(16,2,-15)
moons << Moon.new(7,-18,-12)
moons << Moon.new(-3,-8,-8)

moons.each { |m| m.show_info }
puts "=" * 20

# The dimension are independent!
# Determine cycle per dimension (this could be combined into a single loop, but this is fast enough (so it appears))
found_cycles = []
0.upto(2) do |dimension|
  the_moon_states = {}
  the_moon_state = moons[0].moon_state(dimension) + moons[1].moon_state(dimension) + moons[2].moon_state(dimension) + moons[3].moon_state(dimension)
  the_moon_states[the_moon_state.join("_")] = 1

  cycle_found = false
  step = 0
  while !cycle_found do
    moons.each_with_index do |m,i|
      moons.each_with_index do |other_moon,j|
        m.update_velocity_for_moon(other_moon) unless i == j
      end
    end
    moons.each { |m| m.update_position }

    step += 1
    the_moon_state = moons[0].moon_state(dimension) + moons[1].moon_state(dimension) + moons[2].moon_state(dimension) + moons[3].moon_state(dimension)
    if the_moon_states.key?(the_moon_state.join("_"))
      found_cycles << step
      cycle_found = true
    else
      the_moon_states[the_moon_state.join("_")] = 1
    end
  end
end

# determine LCM off the found_cycles[], crudely
the_min_cycle = found_cycles.min

the_step_count = the_min_cycle
while (the_step_count % found_cycles[0] != 0) || (the_step_count % found_cycles[1] != 0) || (the_step_count % found_cycles[2] != 0)
  the_step_count += the_min_cycle
end
puts "=> #{the_step_count}"

