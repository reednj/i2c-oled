
begin
	require 'wiringpi2'
rescue Exception => e
	require_relative './wiringpi-test'
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

	def self.pull_up_3
		return GPIOInput.new(3, WiringPi::PUD_UP)
	end
end