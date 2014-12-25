#!/usr/bin/env ruby

load './lib/alpha'

def main()
	if ARGV.length == 0
		puts usage
		return
	end

	command = ARGV[0].to_sym
	display = AlphaDisplay.open

	case command
	when :off
		display.blank
	when :set
		value = ARGV[1]
		display.set value
	when :bright
		value = ARGV[1].to_i
		raise "brightness value must be between 0-15" if value < 0 || value > 15
		display.brightness = value
	else
		puts "invalid command '#{command}'\n"
		puts usage
		return
	end

end

def usage
	"alpha <cmd> [<value>]\n" +
	" commands:\n" +
	"  off\n" +
	"  set <string>\n" +
	"  bright <0-15>\n"
end

main()