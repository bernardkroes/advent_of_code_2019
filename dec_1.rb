def fuel_for_module_mass(in_mass)
  return 0 if in_mass <= 0
  the_fuel = (in_mass / 3.0).floor - 2
  the_fuel = 0 if the_fuel < 0
  return the_fuel + fuel_for_module_mass(the_fuel)
end

puts fuel_for_module_mass(14)
puts fuel_for_module_mass(1969)
puts fuel_for_module_mass(100756)

the_total_mass = 0

File.open('1_module_mass_input.txt').each do |line|
  the_module_mass = line.to_i
  the_total_mass += fuel_for_module_mass(the_module_mass)
end

puts the_total_mass

