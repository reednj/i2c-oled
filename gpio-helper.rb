
begin
	require 'wiringpi'
	GPIO_SIMULATED = false
rescue Exception => e
	INPUT = 0
	OUTPUT = 1
	GPIO_SIMULATED = true

	module WiringPi
		class GPIO
			def mode(pin, mode)
			end

			def write(pin, value)
			end
		end
	end
end

def main()
	i = 0
	delay = (ARGV.length > 0) ? ARGV[0].to_i : 250
	g = GPIONumeric.new()

	begin
		while true
			n = i # rand(100)
			g.set_number(n)
			sleep delay.to_f / 1000.0
			i +=1
		end

	rescue Exception => e
		puts 'stop...'
	end

	g.cleanup
end

class GPIOHelper

	def initialize()
		@pins = [11, 10, 6, 5, 3, 4, 1, 0]
		@value_mask = 2**(bits) - 1;
		
		@gpio = WiringPi::GPIO.new

		@pins.each do |pin|
			@gpio.mode pin, OUTPUT
		end		
	end

	def set(value)
		value = value & @value_mask
		@pins.each_with_index do |pin, pin_index|
			shift = @pins.length - pin_index - 1
			bit_value = value & (1 << shift)
			set_bit pin_index, bit_value.to_bool
		end

		puts value.to_s(2) if GPIO_SIMULATED
	end

	def set_bit(pin_index, is_on)
		raise "invalid pin index '#{pin_index}'" if pin_index >= @pins.length
		set_pin(@pins[pin_index], is_on.to_i)
	end

	def set_pin(pin, value)
		@gpio.write pin, value.to_i
	end

	def bits()
		@pins.length
	end

	def cleanup()
		@pins.each do |pin|
			self.set_pin pin, 0
			@gpio.mode pin, INPUT
		end
	end
end

class GPIOBar < GPIOHelper
	def set_bar(value)
		value = value % bits
		set(2**value-1)
	end
end

class GPIONumeric < GPIOHelper
	attr_accessor :decimal

	def initialize()
		self.decimal = false
		@patterns = [
			0b01111110, # 0
			0b01001000, # 1
			0b00111101, # 2
			0b01101101, # 3
			0b01001011, # 4
			0b01100111, # 5
			0b01110111, # 6
			0b01001100, # 7
			0b01111111, # 8
			0b01001111, # 9
			0b11001111, # 9
		]

		super()
	end

	def set_number(value)
		bit_value = @patterns[value % 10]
		bit_value = (bit_value | 0b10000000) if decimal
		self.set bit_value
	end
end

class TrueClass
	def to_i()
		1
	end
end

class FalseClass
	def to_i()
		0
	end
end

class Numeric
	def to_bool
		!(self == 0)
	end
end