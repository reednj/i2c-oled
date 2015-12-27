require 'ffi'

MOCK_DEVICE = Gem.win_platform?

if MOCK_DEVICE
	module BCM2835_I2C
		
		def self.bcm2835_i2c_write(data, len)
			puts data.unpack('C*').map { |d| d.to_s(16) }.join(' ')
			return 0
		end

		def self.bcm2835_i2c_begin
			return 0
		end

		def self.bcm2835_i2c_end
			return nil
		end

		def self.bcm2835_i2c_setSlaveAddress(device_id)
			return 0
		end
	end
else

	module BCM2835_I2C
		extend FFI::Library
		ffi_lib 'c'
		ffi_lib './bcm2835.so'
		attach_function :bcm2835_i2c_begin,[], :int
		attach_function :bcm2835_i2c_write, [:pointer, :int], :int
		attach_function :bcm2835_i2c_end, [], :void
		attach_function :bcm2835_i2c_setSlaveAddress, [:uint8], :int
	end

end

class I2CDevice
	def initialize(device_id)
		@device_id = device_id.to_i
		
		_begin
		_set_slave @device_id
	end

	def device_id
		@device_id
	end

	def write(byte_arr)
		raise 'array required' if !byte_arr.is_a? Array

		data = byte_arr.pack 'C*'
		_write data, data.length
	end

	def close
		BCM2835_I2C.bcm2835_i2c_end
	end

	def _begin
		result = BCM2835_I2C.bcm2835_i2c_begin
		raise "i2c_begin failed with code (#{result})" if result < 0
		return result
	end

	def _set_slave(device_id)
		result = BCM2835_I2C.bcm2835_i2c_setSlaveAddress device_id
		raise "i2c_set_slave failed with code (#{result})" if result < 0
		return result
	end

	def _write(data, len)
		result = BCM2835_I2C.bcm2835_i2c_write data, len
		raise "i2c_write failed with code (#{result})" if result < 0
		return result
	end

end

class OLEDDisplay

	# generic SSD consts

	# SSD_Command_Mode = 0x80  # DC bit is 0  # Seeed set C0 to 1 why ?
	SSD_Command_Mode = 0x00 # C0 and DC bit are 0 
	SSD_Data_Mode = 0x40 # C0 bit is 0 and DC bit is 1
	SSD_Inverse_Display = 0xA7

	SSD_Display_Off	= 0xAE
	SSD_Display_On = 0xAF

	SSD_Set_ContrastLevel =	0x81

	SSD_External_Vcc = 0x01
	SSD_Internal_Vcc = 0x02

	SSD_Activate_Scroll = 0x2F
	SSD_Deactivate_Scroll =	0x2E

	Scroll_Left = 0x00
	Scroll_Right = 0x01

	Scroll_2Frames = 0x07
	Scroll_3Frames = 0x04
	Scroll_4Frames = 0x05
	Scroll_5Frames = 0x00
	Scroll_25Frames = 0x06
	Scroll_64Frames = 0x01
	Scroll_128Frames = 0x02
	Scroll_256Frames = 0x03

	VERTICAL_MODE = 01
	PAGE_MODE = 01
	HORIZONTAL_MODE = 02

	# SSD1306 Displays
	# -----------------------------------------------------------------------
	# The driver is used in multiple displays (128x64, 128x32, etc.).

	SSD1306_DISPLAYALLON_RESUME	= 0xA4
	SSD1306_DISPLAYALLON = 0xA5

	SSD1306_Normal_Display = 0xA6

	SSD1306_SETDISPLAYOFFSET = 0xD3
	SSD1306_SETCOMPINS = 0xDA
	SSD1306_SETVCOMDETECT = 0xDB
	SSD1306_SETDISPLAYCLOCKDIV = 0xD5
	SSD1306_SETPRECHARGE = 0xD9
	SSD1306_SETMULTIPLEX = 0xA8
	SSD1306_SETLOWCOLUMN = 0x00
	SSD1306_SETHIGHCOLUMN = 0x10
	SSD1306_SETSTARTLINE = 0x40
	SSD1306_MEMORYMODE = 0x20
	SSD1306_COMSCANINC = 0xC0
	SSD1306_COMSCANDEC = 0xC8
	SSD1306_SEGREMAP = 0xA0
	SSD1306_CHARGEPUMP = 0x8D

	SSD1306_SET_VERTICAL_SCROLL_AREA = 0xA3
	SSD1306_RIGHT_HORIZONTAL_SCROLL = 0x26
	SSD1306_LEFT_HORIZONTAL_SCROLL = 0x27
	SSD1306_VERTICAL_AND_RIGHT_HORIZONTAL_SCROLL = 0x29
	SSD1306_VERTICAL_AND_LEFT_HORIZONTAL_SCROLL = 0x2A

	COLOR_BLACK = 0
	COLOR_WHITE = 1

	def initialize(device_id = 0x3c)
		@width = 128
		@height = 32
		@device = I2CDevice.new device_id

		initialize_display
		
		@buffer = nil
		@packet_size_bytes = 16
		clear_buffer
	end

	def initialize_display
		vcc_type = SSD_Internal_Vcc
		
		# depends on OLED type configuration
		if @height == 32
			multiplex = 0x1F
			compins = 0x02
			contrast = 0x8F
		else
			multiplex = 0x3F
			compins = 0x12
			contrast = (vcc_type == SSD_External_Vcc ? 0x9F : 0xCF)
		end
		
		if vcc_type == SSD_External_Vcc
			chargepump = 0x10
			precharge = 0x22
		else
			chargepump = 0x14
			precharge = 0xF1
		end
		
		write_command SSD_Display_Off
		write_command [SSD1306_SETDISPLAYCLOCKDIV, 0x80]
		write_command [SSD1306_SETMULTIPLEX, multiplex]
		write_command [SSD1306_SETDISPLAYOFFSET, 0x00]
		write_command SSD1306_SETSTARTLINE | 0x0
		write_command [SSD1306_CHARGEPUMP, chargepump]
		write_command [SSD1306_MEMORYMODE, 0x00]
		write_command SSD1306_SEGREMAP | 0x1
		write_command SSD1306_COMSCANDEC
		write_command [SSD1306_SETCOMPINS, compins]
		write_command [SSD_Set_ContrastLevel, contrast]
		write_command [SSD1306_SETPRECHARGE, precharge]
		write_command [SSD1306_SETVCOMDETECT, 0x40]
		write_command SSD1306_DISPLAYALLON_RESUME
		write_command SSD1306_Normal_Display

		# Reset to default value in case of 
		# no reset pin available on OLED
		write_command [0x21, 0, 127]
		write_command [0x22, 0,   7]
		
		# Empty uninitialized buffer
		write_command SSD_Display_On 
	end

	def write_command(data)
		bytes = [SSD_Command_Mode, data].flatten
		@device.write bytes
	end

	def write_data(data)
		bytes = [SSD_Data_Mode, data].flatten
		@device.write bytes
	end

	def write_buffer
		# set the write 'cursor' at (0,0) so we want refresh the whole display
		write_command(SSD1306_SETLOWCOLUMN  | 0x0); # low col = 0
		write_command(SSD1306_SETHIGHCOLUMN | 0x0); # hi col = 0
		write_command(SSD1306_SETSTARTLINE  | 0x0); # line num. 0

		(0...buffer_height).each do |y|
			(0...buffer_width).step(@packet_size_bytes).each do |x|
				packet = @buffer[y][x...(x + @packet_size_bytes)]
				self.write_data packet
			end			
		end

	end

	def buffer_height
		@height / 8
	end

	def buffer_width
		@width
	end

	def clear_buffer
		@buffer = []

		(0...buffer_height).each do |y|
			row = (0...buffer_width).map { |x| 0x00 }
			@buffer.push row
		end

		return @buffer
	end

	def set_pixel(x, y, color)
		raise "invalid color #{color}" if color != COLOR_WHITE && color != COLOR_BLACK
		raise "invalid coordinates (#{x}, #{y})" if x < 0 || x >= @width || y < 0 || y >= @height

		# we get the x and y for the buffer...
		buffer_x = x
		buffer_y = (y.to_f / 8.0).floor

		# ...plus the bit number we have to set within it
		buffer_bit = y % 8

		# @buffer[x][y] represents a single byte of the buffer, which
		# in turn represents a vertical column of 8 pixels on the display
		if color != COLOR_BLACK
			@buffer[buffer_y][buffer_x] |= (color << buffer_bit)
		else
			@buffer[buffer_y][buffer_x] ^= (1 << buffer_bit)
		end
	end

end

d = OLEDDisplay.new
d.set_pixel(10, 10, OLEDDisplay::COLOR_WHITE)
d.set_pixel(10, 11, OLEDDisplay::COLOR_WHITE)
d.set_pixel(10, 10, OLEDDisplay::COLOR_BLACK)
d.write_buffer
