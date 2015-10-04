#!/usr/bin/env ruby

require_relative './lib/gpio'

def main
	wiringpi_pin = 3
	input = GPIOInput.new wiringpi_pin, WiringPi::PUD_UP
	input.on_key_down do
		# assume the next-display script is alredy defined in the correct place
		puts `/home/reednj/bin/nd`
	end
end


main()