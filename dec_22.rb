class Deck
  attr_reader :cards

  def initialize(n)
    @cards = []
    0.upto(n-1) { |i| @cards << i }
  end

  def deal_with_increment(n)
    new_deck = [-1] * @cards.size
    src_walk = 0
    walk = 0
    while src_walk < @cards.size
      new_deck[walk] = @cards[src_walk]
      walk += n
      if walk >= @cards.size
        walk -= @cards.size
      end
      src_walk += 1
    end
    @cards = new_deck
  end

  def cut_deck(n)
    @cards.rotate!(n)
  end

  def deal_into_new_stack
    @cards.reverse!
  end
end

# copied from online example:
def modular_inverse(a, n)
  t, newt = [0, 1]
  r, newr = [n, a]
  until newr == 0
    q = r / newr
    t, newt = [newt, t - q * newt]
    r, newr = [newr, r - q * newr]
  end
  r > 1 ? nil : t % n
end

# all your modulos are belong to us
class SmartDeck # store a deck as an offset (of the first card) and a delta
  attr_reader :offset, :delta

  def initialize(n)
    @number_of_cards = n
    @offset = 0
    @delta = 1
  end

  def deal_with_increment(n)
    @delta *= modular_inverse(n, @number_of_cards)
    @delta = @delta % @number_of_cards
  end

  def cut_deck(n)
    @offset += @delta * n
    @offset = @offset % @number_of_cards
  end

  def deal_into_new_stack
    @delta = -1 * @delta
    @offset += @delta
    @offset = @offset % @number_of_cards
  end

  def show_info
    puts "Offset: #{@offset}"
    puts "Delta: #{@delta}"
  end
end

instructions = []
File.open("dec_22_input.txt").each do |line|
  instructions << line
end

the_deck = Deck.new(10007)
instructions.each do |line|
  if line.start_with?("deal with increment")
    the_deck.deal_with_increment(line.gsub("deal with increment ", "").to_i)
  elsif line.start_with?("cut")
    the_deck.cut_deck(line.gsub("cut ", "").to_i)
  elsif line.start_with?("deal into new stack")
    the_deck.deal_into_new_stack
  end
end

# part 2
#
# test data:
# the_deck_size = 10007
# the_shuffle_times = 1
# target_pos = 1234 # answer of part 1

the_deck_size = 119315717514047
the_shuffle_times = 101741582076661
target_pos = 2020

the_smart_deck = SmartDeck.new(the_deck_size)

instructions.each do |line|
  if line.start_with?("deal with increment")
    the_smart_deck.deal_with_increment(line.gsub("deal with increment ", "").to_i)
  elsif line.start_with?("cut")
    the_smart_deck.cut_deck(line.gsub("cut ", "").to_i)
  elsif line.start_with?("deal into new stack")
    the_smart_deck.deal_into_new_stack
  end
end
the_smart_deck.show_info

# apply the shuffling the_shuffle_times
# the_final_delta = the_smart_deck.delta.pow(the_shuffle_times, the_deck_size) # not on ruby 2.5 yet
the_final_delta = 1237948625428 # used an online tool to calculate this ( https://www.dcode.fr/modular-exponentiation )
the_final_offset = the_smart_deck.offset * (1 - the_final_delta) * modular_inverse(1 - the_smart_deck.delta, the_deck_size) % the_deck_size

puts "Final delta: #{the_final_delta}"
puts "Final offset: #{the_final_offset}"

puts "Card at #{target_pos}"
puts (the_final_offset + target_pos * the_final_delta) % the_deck_size
