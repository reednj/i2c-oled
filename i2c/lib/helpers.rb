

class TimeSpan
	def initialize(value)
		@value = value.to_f
	end

	def total_seconds
		@value
	end

	def total_minutes
		@value / 1.minute
	end

	def total_hours
		@value / 1.hour
	end

	def total_days
		@value / 1.day
	end

	def seconds
		self.total_seconds.to_i % 60
	end

	def minutes
		self.total_minutes.to_i % 60
	end

	def hours
		self.total_hours.to_i % 24
	end

	def days
		self.total_days.to_i
	end

	def to_s
		h = '%02d' % total_hours.to_i
		m = '%02d' % minutes
		s = '%02d' % seconds
		result = "#{m}:#{s}"
		result = "#{h}:#{result}" if hours > 0
		return result
	end

	def to_i
		@value.to_i
	end

	def to_f
		@value.to_f
	end
end

class SharedVariable
	def initialize(path)
		@value = nil
		@path = path
		@last_mtime = nil

		# if the directory doesn't exist, then throw an error

		# create the file if it doesn't exist yet
		if !File.exist? @path
			File.write(@path, '')
		end
	end

	def get
		# only re-read the file data if the mtime has changed
		mtime = File.mtime(@path)
		if @last_mtime.nil? || @last_mtime < mtime
			@value = File.read(@path)
			@last_mtime = mtime
		end
		
		return @value
	end

	def set(v)
		File.write(@path, v.to_s)
	end
end

class PIDLock < SharedVariable
	def has_lock?
		Process.pid == self.get.to_i
	end

	def take_lock
		self.set "#{Process.pid}\n"
	end
end

class Fixnum
	def seconds
		self
	end

	def minutes
		self * 60
	end

	def hours
		self * 60.minutes
	end

	def days
		self * 24.hours
	end

	def weeks
		self * 7.days
	end

	alias minute minutes
	alias hour hours
	alias day days
	alias week weeks
end

def update_loop(delay = 1.0)
	while true
		yield
		sleep delay
	end
end
