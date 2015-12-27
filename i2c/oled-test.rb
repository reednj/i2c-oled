require './lib/helpers'
require './lib/oled'

display = OLEDDisplay.new
update_loop 1.0 do
	x = (rand * display.width).floor
	y = (rand * display.height).floor

	display.set_pixel(x, y, OLEDDisplay::COLOR_WHITE)
	display.write_buffer
end

