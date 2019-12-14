reactions = {} # hash by element with production amount and production rule (string)
NEEDED = 0
PRODUCED = 1

File.open('dec_14_input.txt').each do |line|
  the_reaction_string, the_product = line.chomp.split(" => ")
  the_amount, the_product_name = the_product.split(" ")
  reactions[the_product_name] = [the_amount.to_i, the_reaction_string]
end

def all_needs_fulfilled?(in_prod_hash)
  in_prod_hash.each_pair do |key, value|
    if key != "ORE" && (value[NEEDED] > value[PRODUCED])
      return false
    end
  end
  return true
end

def mine_reaction(in_result_element, in_reaction, the_amount_wanted, the_production)
  the_reaction_amount = in_reaction[0]
  the_reaction_rule_string = in_reaction[1]
  num_times = 1 + ((the_amount_wanted - 1) / the_reaction_amount)

  the_reaction_rule_string.split(",").each do |rule_string|
    the_count, the_elem = rule_string.split(" ")
    the_production[the_elem] ||= [0,0]
    the_production[the_elem][NEEDED] += num_times * (the_count.to_i)
  end
  the_production[in_result_element][PRODUCED] +=num_times * the_reaction_amount
end

the_production = {} # hash by element with arrays of needed and produced amounts in an array
the_production["FUEL"] = [1,0] # we need 1 FUEL, we have produced none yet

while !all_needs_fulfilled?(the_production) do
  the_element, the_element_production = the_production.select{ |key, value| key != "ORE" && (value[NEEDED] > value[PRODUCED]) }.first # eg => [["FUEL", [1, 0]]
  the_amount_wanted = the_element_production[NEEDED] - the_element_production[PRODUCED]
  mine_reaction(the_element, reactions[the_element], the_amount_wanted, the_production)
end
puts the_production["ORE"][NEEDED]

# part 2 : lets see how much we can produce more
the_ore_amount = 1000000000000
min_fuel = the_ore_amount / the_production["ORE"][NEEDED]

the_step_size = 100000
the_fuel_test_amount = min_fuel + the_step_size

the_needed_ore = 0 # to get going
while the_needed_ore <= the_ore_amount
  puts "Trying to produce: #{the_fuel_test_amount}"

  the_production = {}
  the_production["FUEL"] = [the_fuel_test_amount,0]
  while !all_needs_fulfilled?(the_production) do
    the_element, the_element_production = the_production.select{ |key, value| key != "ORE" && (value[NEEDED] > value[PRODUCED]) }.first # eg => [["FUEL", [1, 0]]
    the_amount_wanted = the_element_production[NEEDED] - the_element_production[PRODUCED]
    mine_reaction(the_element, reactions[the_element], the_amount_wanted, the_production)
  end
  the_needed_ore = the_production["ORE"][NEEDED]
  puts "--> needed: #{the_needed_ore}"

  if the_needed_ore <= the_ore_amount
    the_fuel_test_amount += the_step_size
  else # too much: step back and reduce step size, if possible
    if the_step_size > 1
      the_fuel_test_amount -= the_step_size # step back
      the_step_size = the_step_size / 10    # reduce step size
      the_fuel_test_amount += the_step_size # step forward
      the_needed_ore = 0
    end
  end
end
