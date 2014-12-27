#!/usr/bin/env ruby
#
#
#

require_relative '../lib/alpha'

def main
	display_id = 0x70
	base_path = (Gem.win_platform?) ? '../' : '/var/run/i2c'
	pid_registry = PIDRegistry.new File.join(base_path, display_id.to_s(16))
	pid_lock = PIDLock.new File.join(base_path, "i2c-#{display_id.to_s(16)}.pid")

	current_index = pid_registry.index_of(pid_lock.pid)
	current_index ||= 0 # if the current owner has stopped running, or is not registered

	# will automatically loop around if it is beyond the range of the array
	r = pid_registry.get(current_index + 1)
	raise "no processes registered at #{base_path}" if r.nil?

	if Process.exist? r[:pid]
		PIDLock.give_lock r[:pid]
		puts "display given to #{r[:name]}"
	else
		puts "pid '#{r[:pid]}' does not exist"
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

main()
