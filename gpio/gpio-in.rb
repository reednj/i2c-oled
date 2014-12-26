#!/usr/bin/env ruby

begin
	require 'wiringpi2'
rescue Exception => e
	require '../i2c/lib/wiringpi-test'
end

def main
	pin = 3
	gpio = WiringPi::GPIO.new
	gpio.pin_mode pin, WiringPi::INPUT
	gpio.pull_up_dn_control pin, WiringPi::PUD_UP

	delay = 0.1
	last_value = gpio.digital_read pin
	while true
		value = gpio.digital_read(pin) 
		
		if value != last_value
			key_down() if last_value == 1 and value == 0
			key_up() if last_value == 0 and value == 1
		end
		
		last_value = value
		sleep delay
	end
end

def key_down
	puts 'down'
end

def key_up
	puts 'up'
end

main()