require 'yaml'
require './lib/helpers'
require './lib/oled'

class App
	def main
		display = OLEDDisplay.new
		display.fill_color = OLEDDisplay::COLOR_WHITE

		c = ClassicFont.char_bitmap('M')
		
		display.draw_bitmap 10, 10, 5, 8, c
		display.write_buffer

	end
end

App.new.main