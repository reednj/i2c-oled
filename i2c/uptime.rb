require 'time'
require './lib/alpha'

def main()
	display = AlphaDisplayShared.new
	start = system_boot()
	update_loop 1.0 do
		duration = (Time.now - start).to_ts
		display.set duration
	end
	
end

def system_boot
	boot_str = Gem.win_platform? ? '         system boot  2014-12-21 07:13' : `who -b`
	time_str = boot_str.split(' ')[-2..-1].join(' ')
	return Time.parse time_str
end

main()