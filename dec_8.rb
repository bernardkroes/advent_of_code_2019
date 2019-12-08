IMAGE_WIDTH = 25
IMAGE_HEIGHT = 6
LAYERS_SIZE = IMAGE_WIDTH * IMAGE_HEIGHT

all_pixel_color_string = File.read("dec_8_input.txt").chomp

min_zeros = LAYERS_SIZE + 1
all_pixel_color_string.scan(/.{150}/).each do |layer|
  the_num_zeros = layer.count("0")
  the_num_ones = layer.count("1")
  the_num_twos = layer.count("2")
  if the_num_zeros < min_zeros
    min_zeros = the_num_zeros
    puts the_num_ones * the_num_twos
  end
end

#part 2
the_final_image = nil
all_pixel_color_string.scan(/.{150}/).each do |layer|
  if the_final_image.nil?
    the_final_image = layer
  else
    # brute force it
    0.upto(149) do |i|
      if the_final_image[i] == "2"
        the_final_image[i] = layer[i]
      end
    end
  end
end

the_final_image.scan(/.{25}/).each do |row|
  puts row.gsub("0"," ")
end

