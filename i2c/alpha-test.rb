require_relative 'lib/alpha'


def main()
	#Signal.trap 'INT' do |signo|
	#	puts 'Interupt'
	#	#return
	#end

	d = AlphaDisplayShared.new
	d.debug = true
	b = 0

	d.brightness = 0
	d.blink = AlphaDisplay::HT16K33_BLINK_OFF
	start = Time.now - 5.days - 35653

	puts Process.pid

	while true
		d.set (Time.now - start).to_ts.to_alpha
		sleep 1
	end

	#while true
	#
	#	puts "#{i.to_alpha} #{i.to_s}"
	#	d.set i
	#	b += 1
	#
	#	i -= 8124.7
	#	sleep 0.1	
	#
	#end
	
end

main()