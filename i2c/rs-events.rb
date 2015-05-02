require 'rest-client'
require_relative 'lib/alpha'

URL = 'http://reddit-stream.com/api/actions/count/today'

def main()
	display = AlphaDisplayShared.new
	
	n = 0
	last_count = nil
	rate = 0
	last_update = Time.now

	t1 = Thread.new do
		update_loop 60 do
			 n = event_count()
			 rate = (n - last_count).to_f / last_update.age if !last_count.nil?
			 last_update = Time.now
			 last_count = n
		end
	end
	
	t2 = Thread.new do
		update_loop 0.25 do
			estimated_count = n + last_update.age * rate
			estimated_count = estimated_count.round
			display.set estimated_count
		end
	end

	t1.join
	t2.join
	
end

def event_count
	data = RestClient.get URL
	return data.to_f
end

class Time
	def age
		Time.now - self
	end
end

main()