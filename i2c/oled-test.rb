require './lib/helpers'
require './lib/oled'

def main
	display = OLEDDisplay.new

	update_loop 0.1 do
		random_pixel(display)
		display.write_buffer
	end

end

def random_pixel(display)
	x = (rand * display.width).floor
	y = (rand * display.height).floor
	display.set_pixel(x, y, OLEDDisplay::COLOR_WHITE)
	puts "#{x}, #{y}"
end

main

