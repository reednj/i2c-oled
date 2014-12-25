require './gpio-helper'


def main()
	i = 0
	delay = (ARGV.length > 0) ? ARGV[0].to_i : 250
	g = GPIONumeric.new()

	begin
		while true
			n = i # rand(100)
			g.set_number(n)
			sleep delay.to_f / 1000.0
			i +=1
		end

	rescue Exception => e
		puts 'stop...'
	end

	g.cleanup
end

main()