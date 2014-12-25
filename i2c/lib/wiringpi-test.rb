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

	class I2C
		def initialize(device)
		end
		
		def write(data)
		end

		def write_reg_8(reg, data)
			#print data.to_s(16) + ' '
		end
	end
end