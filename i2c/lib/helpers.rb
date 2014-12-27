


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
		Process.pid == self.pid
	end

	def take_lock
		self.set "#{Process.pid}\n"
	end

	def self.give_lock(pid)
		return nil if Gem.win_platform? # do nothing on windows - doesn't support SIGUSR1
		Process.kill 'SIGUSR1', pid.to_i
	end

	def pid
		get.to_i
	end
end

class PIDRegistry
	def initialize(path)
		@base_path = path
		@pid_file_path = nil
		@pid_list = nil
		self.path_exist!
	end

	# return a list of all pid files and their contents in the directory
	def load
		self.path_exist!

		result = []
		Dir.glob_path @base_path, '*.pid' do |filename, path|
			name = filename.gsub '.pid', ''
			pid = File.read(path).to_i
			result.push({ :name => name, :pid => pid })
		end

		# todo: should sort the list by name
		@pid_list = result
		return @pid_list
	end

	def index_of(name_or_pid)
		self.load if @pid_list.nil?
		@pid_list.index { |a| a[:name].start_with?(name_or_pid.to_s) || a[:pid] == name_or_pid}
	end

	def get(index)
		return nil if index.nil?
		self.load if @pid_list.nil?

		@pid_list[index % @pid_list.length]
	end

	def get_by_pid(pid)
		i = self.index_of pid.to_i
		self. get i
	end

	# we register the script in the /var/run/i2c structure, so that we
	# can create programs to cycle through everything that is using the
	# display
	def register_script(name=nil)
		self.path_exist!

		name ||= ProcessHelper.script_name
		raise "could not generate script name" if name.nil? || name == ''
		
		@pid_file_path = File.join @base_path, "#{name}.pid"
		File.write @pid_file_path, "#{Process.pid}\n"
	end

	def deregister_script
		self.script_registered!
		File.delete @pid_file_path
	end

	def reg_path
		(Gem.win_platform?) ? './' : "/var/run/i2c/#{@device_id.to_s 16}"
	end

	def script_registered!
		raise 'PIDRegistry: no script registered' if @pid_file_path.nil? || !File.exist?(@pid_file_path)
	end

	def path_exist!
		raise "PIDRegistry: requested path '#{@base_path}' does not exist" if !Dir.exist? @base_path
	end
end

class Dir
	# copy of Fir.glob, but takes a path argument, instead of just working on
	# the cwd
	def self.glob_path(dir, pattern)
		p = Dir.pwd
		Dir.chdir dir
		
		if block_given?
			Dir.glob pattern do |f|
				yield f, File.join(Dir.pwd, f)
			end
			result = nil
		else
			result = Dir.glob pattern
		end

		Dir.chdir p

		return result
	end
end

module Process
	def self.exist? pid
		return true if Gem.win_platform?

		begin
			Process.getpgid pid
			true
		rescue Errno::ESRCH
			false
		end
	end
end

class ProcessHelper
	def self.script_name
		$PROGRAM_NAME.split('/').last.gsub('.rb','')
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
