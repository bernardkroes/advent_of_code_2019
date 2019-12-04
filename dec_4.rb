# Your puzzle input is 153517-630395
#
the_first = 153517
the_last = 630395

# assumption in_number consists of 6 digits
def meets_criteria_part1?(in_number)
  in_number_string = "#{in_number}"
  the_digits = [in_number_string[0], in_number_string[1], in_number_string[2], in_number_string[3], in_number_string[4], in_number_string[5]].map(&:to_i)
  two_adjacent_same = false
  never_decreases = true
  0.upto(4) do |i|
    two_adjacent_same = true if the_digits[i] == the_digits[i+1]
    never_decreases = false if the_digits[i+1] < the_digits[i]
  end
  the_digits
  return two_adjacent_same && never_decreases
end

puts meets_criteria_part1?(111111)
puts meets_criteria_part1?(223450)
puts meets_criteria_part1?(123789)
puts "=" * 20

def meets_criteria?(in_number)
  in_number_string = "#{in_number}"
  the_digits = [in_number_string[0], in_number_string[1], in_number_string[2], in_number_string[3], in_number_string[4], in_number_string[5]].map(&:to_i)
  two_adjacent_same = false
  never_decreases = true
  the_same_digits_found = []
  0.upto(4) do |i|
    two_adjacent_same = true if the_digits[i] == the_digits[i+1]
    the_same_digits_found << the_digits[i]
    never_decreases = false if the_digits[i+1] < the_digits[i]
  end
  only_two_adjacent_same = false
  if two_adjacent_same
    the_same_digits_found.each do |candidate|
      the_cand_string = "#{candidate}"
      the_replaced_string = in_number_string.gsub(the_cand_string * 6, "").gsub(the_cand_string * 5, "").gsub(the_cand_string * 4, "").gsub(the_cand_string * 3, "")
      if the_replaced_string.include?(the_cand_string * 2)
        only_two_adjacent_same = true
      end
    end
  end
  return only_two_adjacent_same && never_decreases
end

puts meets_criteria?(112233)
puts meets_criteria?(123444)
puts meets_criteria?(111122)
puts meets_criteria?(222122)

meets_criteria_count = 0
the_first.upto(the_last) do |the_number|
  meets_criteria_count += 1 if meets_criteria?(the_number)
end

puts meets_criteria_count
