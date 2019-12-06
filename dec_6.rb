all_orbits = {}

File.open('dec_6_input.txt').each do |line|
  is_orbiting, the_orbiter = line.chomp.split(")")
  all_orbits[the_orbiter] = is_orbiting
end

def orbit_count_for_orbiter(in_orbiter, all_orbits)
  return all_orbits.key?(in_orbiter) ? 1 + orbit_count_for_orbiter(all_orbits[in_orbiter], all_orbits) : 0
end

def orbits_for_orbiter(in_orbiter, all_orbits)
  return all_orbits.key?(in_orbiter) ? [all_orbits[in_orbiter]] + orbits_for_orbiter(all_orbits[in_orbiter], all_orbits) : [""]
end


# part 1
the_orbit_count = 0
all_orbits.keys.each do |orbiter|
  the_orbit_count += orbit_count_for_orbiter(orbiter, all_orbits)
end

puts the_orbit_count

# part 2
you_orbiting_around = orbits_for_orbiter("YOU", all_orbits)
san_orbiting_around = orbits_for_orbiter("SAN", all_orbits)

# find first common ancestor
common_orbiting_around = you_orbiting_around & san_orbiting_around

# assuming that an intersect keeps the same ordering:
first_common_orbiter = common_orbiting_around[0]

steps_for_you = you_orbiting_around.index(first_common_orbiter)
steps_for_san = san_orbiting_around.index(first_common_orbiter)

puts steps_for_you + steps_for_san
