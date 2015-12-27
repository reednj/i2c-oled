require './lib/helpers'
require './lib/oled'

def main
	display = OLEDDisplay.new

	puts "benchmarking oled fps"

	result = benchmark do
		10.times { random_pixel(display) }
		display.write_buffer
	end

	puts "#{result.round(1)} fps"

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

main

