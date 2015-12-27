require 'yaml'
require './lib/helpers'
require './lib/oled'

class App
	def main
		display = OLEDDisplay.new

		display.fill_color = OLEDDisplay::COLOR_WHITE
		display.font = ClassicFont
		
		update_loop 0.2 do
			t = Time.now.strftime '%H:%M:%S'
			display.fill_text 40, 12, t
			display.write_buffer
			display.clear_buffer
		end

	end
end

App.new.main