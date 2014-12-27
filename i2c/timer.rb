require_relative 'lib/alpha'

def main()
	display = AlphaDisplayShared.new
	start = Time.now
	update_loop 0.5 do
		duration = (Time.now - start).to_ts
		display.set duration
	end
	
end

main()