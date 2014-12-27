require_relative 'lib/alpha'

def main
	i = 0
	hidden_delay = 60

	display = AlphaDisplayShared.new
	sensor = Therm1Wire.new

	loop do
		# when the display is show, refresh the sensor every second, when its not
		# we only refresh every minute or so
		if display.has_display? || i % hidden_delay == 0
			t = sensor.read
			puts t
		end
		
		if !t.nil?
			s = t.round(1).to_s + 'c'
			display.set s
		end
		
		i += 1
		sleep 1.0
	end
end

#class DataFile
#	def initialize(root)
#	end
#end

class Therm1Wire
	TEST_DATA = "a7 01 4b 46 7f ff 09 10 e0 : crc=e0 YES\na7 01 4b 46 7f ff 09 10 e0 t=26437\n"
	def initialize
		@path = self.find_path		
	end

	def read
		data = self.read_raw
		lines = data.split "\n"

		raise 'invalid w1 file data' if lines.length != 2

		check_line = lines.first
		data_line = lines.last

		return nil if check_line.split(" ").last != 'YES'
		temp_raw_s = data_line.split(' ').last.gsub('t=', '')
		temp_raw = temp_raw_s.to_i

		return temp_raw.to_f / 1000
	end

	def read_raw
		return TEST_DATA if Gem.win_platform?
		return File.read @path
	end

	def find_path
		sys_path = '/sys/bus/w1/devices/'
		device_name = '28-000002afcb2b'
		filename = 'w1_slave'
		File.join sys_path, device_name, filename
	end

end

main()
