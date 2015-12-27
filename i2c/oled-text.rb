require 'yaml'
require './lib/helpers'
require './lib/oled'

class App
	def main
		display = OLEDDisplay.new

		display.fill_color = OLEDDisplay::COLOR_WHITE
		display.font = ClassicFont
		
		i = 0
		size = 1.0
		size = ARGV[0].to_f if ARGV.length > 0

		update_loop 0.2 do

			t = Time.now.strftime '%H:%M:%S'
			display.font_size = size
			display.fill_text 1, 1, t
			
			display.font_size = 1
			display.fill_text 108, 1, size.round(1).to_s

			display.write_buffer
			display.clear_buffer
			i += 1
		end

	end
end

App.new.main
