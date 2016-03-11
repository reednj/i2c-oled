require './lib/oled'

class App
	def main
		display = OLEDDisplay.new
		display.fill_color = OLEDDisplay::COLOR_WHITE
		
		w = 16
		h = 16
		x = -w

		loop do
			display.clear_buffer
			display.fill_rect x, 4, w, h
			display.write_buffer

			x += 1
			x = -w if x >= display.width
		end


	end
end

App.new.main