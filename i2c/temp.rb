require 'time'
require_relative 'lib/alpha'

def main
	display = AlphaDisplayShared.new
	sensor = Therm1Wire.new
	logger = DataLogger.new (Gem.win_platform? ? './data' : '/home/reednj/log/temp')
	timer = SingleTimer.new 1.minute, {:start_expired => true}

	update_loop 1.second do
		# when the display is show, refresh the sensor every second, when its not
		# we only refresh every minute or so
		if display.has_display? || timer.expired?
			t = sensor.read
			puts t
		end

		if timer.expired?
			logger.log "#{Time.now.iso8601}\t#{t}"
		end

		timer.reset if timer.expired?
		
		if !t.nil?
			s = t.round(1).to_s + 'c'
			display.set s
		end

	end
end

class SingleTimer
	def initialize(delay, options)
		@delay = delay
		@options = options || {}
		@start = (Time.now - 52.weeks * 100)

		self.reset if @options[:start_expired] != true
	end

	def expired?
		Time.now - @start > @delay
	end

	def reset
		@start = Time.now
	end
end

class DataLogger
	def initialize(dir)
		@dir = dir.to_s
	end

	def filename
		Time.now.strftime('%Y-%m-%d') + '.txt'
	end

	def path
		File.join @dir, self.filename
	end

	def log(s)
		File.open self.path, 'a' do |f|
			f.puts s
		end
	end
end

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
