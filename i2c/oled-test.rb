require './lib/helpers'
require './lib/oled'

def main

	display = OLEDDisplay.new

	display.fill_color = OLEDDisplay::COLOR_WHITE
	display.font = FreeSans12pt7b
	display.text_align = :left

	y = display.font.height / 2 + display.font.height / 2 
	display.fill_text 1, y, 'hello, world' #Time.now.strftime('%H:%M:%S')

	display.write_buffer
	display.clear_buffer

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

