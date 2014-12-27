#!/usr/bin/env ruby
#
# This creates a directory in the /var/run tmpfs so that we can store
# pid files for i2c applications.
#

require_relative '../lib/helpers'

def main
	if ARGV.length ==0
		puts "Usage: give-display <process name or keyword>"
		return 1
	end

	search_for = ARGV[0]
	pid = get_pids(search_for).first

	if pid.nil? || pid == 0 || pid == Process.pid
		puts "no pid found for '#{search_for}'"
		return 1
	end

	PIDLock.give_lock pid
end

def get_pids search_for
	pids = `pgrep -f "#{search_for}"`
	pids.split("\n").map do |p| 
		if p.to_i == Process.pid || p.to_i == Process.ppid
			nil
		else
			p.to_i
		end
	end
end

main()
