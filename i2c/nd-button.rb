#!/usr/bin/env ruby

begin
	require 'wiringpi2'
rescue Exception => e
	require_relative '../i2c/lib/wiringpi-test'
end

def main
	wiringpi_pin = 3
	input = GPIOInput.new wiringpi_pin, WiringPi::PUD_UP
	input.on_key_down do
		# assume the next-display script is alredy defined in the correct place
		puts `/home/reednj/bin/nd`
	end
end

class GPIOInput
	def initialize(pin, pull_type)
		@pin = pin
		@gpio = WiringPi::GPIO.new
		@gpio.pin_mode @pin, WiringPi::INPUT
		@gpio.pull_up_dn_control @pin, pull_type
	end

	def on_key_down(poll_delay=0.1)

		last_value = self.read
		loop do
			value = self.read 
			
			if value != last_value
				yield if last_value == 1 and value == 0
			end
			
			last_value = value
			sleep poll_delay
		end
	end

	def read
		@gpio.digital_read @pin
	end
end

main()