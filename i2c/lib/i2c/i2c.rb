require 'ffi'

# extend FFI with a build method so we can automatically build the .so files
# if they don't exist. It will check for a build.sh or a Makefile
module FFI
	module Library
		# if the library is not found at the path provided, try building it
		def build_extern(lib_path)
			# the library already exists, don't need to do anything
			return if File.exist? lib_path

			dir = File.dirname(lib_path)
			makefile = File.join dir, 'Makefile'
			build_sh = File.join dir, 'build.sh'

			if File.exist? makefile
				`cd #{dir}; make > /dev/null`
			elsif File.exist? build_sh
				`cd #{dir}; ./build.sh > /dev/null`
			else
				raise "Could not find any way to build #{lib_path}"
			end

			# check that the lib exists now, if it doesn't, throw an exception as the build
			# must have failed
			raise "#{lib_path} could not be built" if !File.exist? lib_path
			return
		end
	end
end

# checks to see if the i2c device exists, if it doesn't we will probably want to create
# a mock device
def i2c_exists?
	File.exist?('/dev/i2c-0') || File.exist?('/dev/i2c-1')
end

if !i2c_exists?

	# I2C doesn't exist on this device, so we want to create a mock object
	# it will always be successful, and will print any data written to the 
	# device to stdout as hex
	module BCM2835_I2C
		
		def self.bcm2835_i2c_write(data, len)
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

	# use the I2C methods from the BCM library. These have a big limitation, in that
	# they store the I2C fd as a global in the module, so it only allows a SINGLE I2C
	# device to be open at one time
	module BCM2835_I2C
		extend FFI::Library
		ffi_lib 'c'
		
		# build the bcm lib (if needed), then add it to ffi
		lib_path = File.join File.dirname(__FILE__), 'extern/bcm2835.so'
		build_extern lib_path
		ffi_lib lib_path

		# attach the i2c methods. There are many more in the lib, but these
		# are the only ones we actually need
		attach_function :bcm2835_i2c_begin,[], :int
		attach_function :bcm2835_i2c_write, [:pointer, :int], :int
		attach_function :bcm2835_i2c_end, [], :void
		attach_function :bcm2835_i2c_setSlaveAddress, [:uint8], :int
	end

end

# represents a I2C device, only allows opening, closing and writing to the 
# device. Inherit this class to implement more specific methods for each
# I2C device
class I2CDevice
	def initialize(device_id, options = {})
		@options = options || {}
		@options[:debug] ||= false

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
		write_debug data if @options[:debug]
	end

	def close
		BCM2835_I2C.bcm2835_i2c_end
	end

	def write_debug(data)
		puts data.unpack('C*').map { |d| d.to_s(16).pad }.join(' ')
		STDOUT.flush
	end

	private

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

class String
	def pad(len=2)
		return self if self.length >= len
		return '0' + self
	end
end