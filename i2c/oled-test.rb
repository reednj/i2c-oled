require './lib/helpers'
require './lib/oled'

class App
	def main
		display = OLEDDisplay.new

		STDIN.each_line do |line|
			display.puts line

			display.write_line_buffer
			display.write_buffer
			display.clear_buffer
		end

	end


	def random_pixel(display)
		x = (rand * display.width).floor
		y = (rand * display.height).floor
		display.set_pixel(x, y, OLEDDisplay::COLOR_WHITE)
	end

	def benchmark(count = 1, &block)
		start = Time.now

		count.times do |i|
			yield
		end

		duration = Time.now - start
		per_sec = count / duration

		return benchmark(count*2, &block) if duration < 0.5
		return per_sec.to_f
	end

end

App.new.main

