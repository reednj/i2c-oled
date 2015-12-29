
require './lib/helpers'
require './lib/oled'

# this is meant to take input from the hash-client and then display it
# not actulaly do any hashing itself
class App
	def main
		display = OLEDDisplay.new
		display.fill_color = OLEDDisplay::COLOR_WHITE

		bits = 22
		hash_rate = 34567
		total_time = 1234

		hash_rate = (hash_rate / 1000).round

		display.font_size = 3
		display.text_align = :right
		display.fill_text 90, 5, '1.24m'

		display.font_size = 1
		display.fill_text 127, 2, "#{bits}bits"
		display.fill_text 127, 10, "#{hash_rate}kh/s"
		display.fill_text 127, 18, '3h5m'

		display.write_buffer

	end
end

App.new.main