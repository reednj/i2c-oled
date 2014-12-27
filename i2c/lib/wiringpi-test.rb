
module WiringPi
	HIGH = 1
	LOW = 0

	INPUT = 0
	OUTPUT = 1
	PWM_OUTPUT = 1

	PUD_OFF = 0
	PUD_DOWN = 1
	PUD_UP = 2

	LSPFIRST = 0
	MSBFIRST = 1

	class GPIO
		def mode(pin, mode)
		end

		def write(pin, value)
		end

		def pin_mode(pin, mode)
		end

		def pull_up_dn_control(pin, type)
		end

		def digital_read(pint)
			0
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