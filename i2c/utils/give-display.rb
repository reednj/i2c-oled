#!/usr/bin/env ruby
#
# This creates a directory in the /var/run tmpfs so that we can store
# pid files for i2c applications.
#
SIG = 'SIGUSR1'

def main
	if ARGV.length ==0
		puts "use a string argument to give the first process that matches control of its i2c bus"
		return 1
	end

	search_for = ARGV[0]
	pids = `pgrep -f "#{search_for}"`
	pid = pids.split("\n").first.to_i

	if pid.nil? || pid == 0 || pid == Process.pid
		puts "no pid found for '#{search_for}'"
		return 1
	end

	`kill -#{SIG.upcase} #{pid}`
end

main()
