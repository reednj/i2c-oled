require 'yaml'
require './lib/helpers'
require './lib/oled'

class App
	def main
		display = OLEDDisplay.new

		display.fill_color = OLEDDisplay::COLOR_WHITE
		display.font = ClassicFont
		display.font_size = 1

		start = Time.now
		start_text = start.strftime '%H:%M:%S'
		start_text = "started: #{start_text}"

		update_loop 0.010 do
			duration = Time.now - start
			time_text = duration.round(1)

			display.font_size = 1
			text_size = display.measure_text start_text
			display.fill_text (display.width - text_size[:width]) / 2, 1, start_text

			display.font_size = 2
			text_size = display.measure_text time_text
			display.fill_text (display.width - text_size[:width]) / 2, 16, time_text
			display.write_buffer
			display.clear_buffer
		end

	end
end

App.new.main
