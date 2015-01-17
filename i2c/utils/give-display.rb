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
	pid = get_pid(search_for)

	if pid.nil? || pid == 0 || pid == Process.pid
		puts "no pid found for '#{search_for}'"
		return 1
	end

	PIDLock.give_lock pid
end

def get_pid(search_for)
	pids = `pgrep -o -f "#{search_for}"`
	pids.strip
end

main()
