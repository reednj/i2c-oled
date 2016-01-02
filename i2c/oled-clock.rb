require './lib/helpers'
require './lib/oled'

class App
	def main
		display = OLEDDisplay.new

		display.fill_color = OLEDDisplay::COLOR_WHITE
		display.font_size = 2
		display.text_align = :center

		center_point = display.display_center

		display.update_loop 0.2 do
			t = Time.now.strftime '%H:%M:%S'
			d = Time.now.strftime '%Y-%m-%d'

			display.font_size = 1
			display.fill_text center_point[:x], 8, d

			display.font_size = 2
			display.fill_text center_point[:x], 31, t
			
		end

	end
end

App.new.main
