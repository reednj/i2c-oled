#!/usr/bin/env ruby

begin
	require 'wiringpi2'
rescue Exception => e
	require_relative '../i2c/lib/wiringpi-test'
end

def main
	pin = 3
	gpio = WiringPi::GPIO.new
	gpio.pin_mode pin, WiringPi::INPUT
	gpio.pull_up_dn_control pin, WiringPi::PUD_UP

	on_key_down gpio, pin do
		# assume the next-display script is alredy defined in the correct place
		puts `/home/reednj/bin/nd`
	end
end

def on_key_down(gpio, pin)
	delay = 0.1

	last_value = gpio.digital_read pin
	loop do
		value = gpio.digital_read(pin) 
		
		if value != last_value
			yield if last_value == 1 and value == 0
		end
		
		last_value = value
		sleep delay
	end
end

main()